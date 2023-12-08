# frozen_string_literal: true

desc 'Build Android project'
private_lane :build do |options|
  project_dir = is_react_native || is_flutter || is_expo ? 'android/' : './'

  update_build_number(track: options[:track], project_dir:)
  setup_expo_project(platform: 'android') if is_expo
  gradle(task: 'clean', project_dir:)

  task = get_build_task(default: fallback(options[:default_artifact], 'aab'))

  build_type = ENV['FL_ANDROID_BUILD_TYPE']
  build_type = 'Release' if blank?(build_type)

  flavor = ENV['FL_ANDROID_FLAVOR']
  properties = get_build_properties

  gradle(task:, build_type:, flavor:, project_dir:, properties:)
end

desc 'Increment build number'
private_lane :update_build_number do |options|
  build_number_env = ENV['FL_BUILD_NUMBER']&.downcase&.strip
  build_number = if %w[beta production].include?(options[:track]) && build_number_env == 'store'
                   google_play_track_version_codes(track: options[:track]) + 1
                 elsif build_number_env
                   Integer(build_number_env, exception: false)
                 end

  if is_expo
    increment_expo_version(android_version_code: build_number, platform: 'android')
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

desc 'Get Android build properties'
private_lane :get_build_properties do
  skip_signing = parse_boolean(ENV['FL_ANDROID_SKIP_SIGNING'], false)

  android_env_vars = %w[FL_ANDROID_STORE_FILE FL_ANDROID_STORE_PASSWORD FL_ANDROID_KEY_ALIAS FL_ANDROID_KEY_PASSWORD]
  ensure_env_vars(env_vars: android_env_vars) unless skip_signing

  properties = {}

  # Set signing variables optionally, let the build process fail if any of them is not set
  store_file = ENV['FL_ANDROID_STORE_FILE']
  properties['android.injected.signing.store.file'] = store_file if !skip_signing && !blank?(store_file)

  store_password = ENV['FL_ANDROID_STORE_PASSWORD']
  properties['android.injected.signing.store.password'] = store_password if !skip_signing && !blank?(store_password)

  key_alias = ENV['FL_ANDROID_KEY_ALIAS']
  properties['android.injected.signing.key.alias'] = key_alias if !skip_signing && !blank?(key_alias)

  key_password = ENV['FL_ANDROID_KEY_PASSWORD']
  properties['android.injected.signing.key.password'] = key_password if !skip_signing && !blank?(key_password)

  # Overwrite version.code property if build number environment variable is a valid number
  build_number = ENV['FL_BUILD_NUMBER']
  is_build_number_valid = !blank?(build_number) && !Integer(build_number.strip, exception: false).nil?
  properties['version.code'] = build_number if is_build_number_valid

  properties
end

desc 'Commit version bump and push'
private_lane :commit_and_push do
  next unless parse_boolean(ENV['FL_COMMIT_INCREMENT'], false)

  commit_version
  push_to_git_remote
end
