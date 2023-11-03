# frozen_string_literal: true

desc 'Build Android project'
private_lane :build do |options|
  project_dir = is_react_native || is_flutter || is_expo ? 'android/' : './'

  update_build_number(track: options[:track], project_dir:)
  gradle(task: 'clean', project_dir:)

  task = get_build_task(default: options[:default_artifact] || 'aab')
  build_type = ENV['FL_ANDROID_BUILD_TYPE'] || 'Release'
  flavor = ENV['FL_ANDROID_FLAVOR']

  android_env_vars = %w[FL_ANDROID_STORE_FILE FL_ANDROID_STORE_PASSWORD FL_ANDROID_KEY_ALIAS FL_ANDROID_KEY_PASSWORD]
  ensure_env_vars(env_vars: android_env_vars)

  properties = {
    'android.injected.signing.store.file' => ENV['FL_ANDROID_STORE_FILE'],
    'android.injected.signing.store.password' => ENV['FL_ANDROID_STORE_PASSWORD'],
    'android.injected.signing.key.alias' => ENV['FL_ANDROID_KEY_ALIAS'],
    'android.injected.signing.key.password' => ENV['FL_ANDROID_KEY_PASSWORD'],
  }

  build_number = ENV['FL_BUILD_NUMBER']
  properties['fastlane.version.code'] = build_number if build_number

  gradle(task:, build_type:, flavor:, project_dir:, properties:)
end

desc 'Increment build number'
private_lane :update_build_number do |options|
  build_number_env = ENV['FL_BUILD_NUMBER']
  build_number = if build_number_env == 'store' && %w[beta production].include?(options[:track])
                   google_play_track_version_codes(track: options[:track]) + 1
                 else
                   Integer(build_number_env, exception: false)
                 end

  if is_expo
    increment_expo_version(android_version_code: build_number, platform: 'android')
    setup_expo_project
  else
    increment_version_code(version_code: build_number, project_dir: options[:project_dir])
  end
end

desc 'Get Android build task based on the artifact type: apk, aab'
private_lane :get_build_task do |options|
  artifact = ENV['FL_ANDROID_ARTIFACT']
  artifact = artifact.downcase.strip
  unless %w[apk aab].include?(artifact)
    UI.important("FL_ANDROID_ARTIFACT set to unknown value '#{artifact}', defaulting to '#{options[:default]}'")
    artifact = options[:default]
  end

  case artifact
  when 'apk'
    'assemble'
  when 'aab'
    'bundle'
  else
    raise "Unreachable statement, artifact type: #{artifact} (fixme)"
  end
end

desc 'Commit version bump and push'
private_lane :commit_and_push do
  if is_expo
    commit_expo_app_json
  else
    project_dir = is_react_native || is_flutter ? 'android/' : './'
    properties_path = File.join(project_dir, 'gradle.properties')
    git_commit(path: [properties_path], message: 'chore: Version bump')
  end

  push_to_git_remote
end
