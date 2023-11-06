# frozen_string_literal: true

desc 'Setup Apple App Store Connect authorization'
private_lane :authenticate do
  ensure_env_vars(env_vars: %w[FL_APPLE_KEY_ID FL_APPLE_KEY_FILE FL_APPLE_ISSUER_ID])
  app_store_connect_api_key(
    key_file_path: ENV['FL_APPLE_KEY_FILE']&.trim,
    key_id: ENV['FL_APPLE_KEY_ID']&.trim,
    issuer_id: ENV['FL_APPLE_ISSUER_ID']&.trim,
    duration: 1200,
    in_house: parse_boolean(ENV['FL_APPLE_ENTERPRISE'] || 'false')
  )
end

desc 'Build iOS project'
private_lane :build do |options|
  ensure_env_vars(env_vars: %w[FL_IOS_SCHEME])
  setup_expo_project if is_expo # needs to be done before searching for an XCode project

  xcode_project = find_xcode_project
  type = options[:type]
  live = options[:env] == 'release'

  provision_certificates(type:)
  update_build_number(type:, live:, xcodeproj: xcode_project)
  gym(scheme: ENV['FL_IOS_SCHEME']&.trim, project: xcode_project)
end

desc 'Find main iOS XCode Project'
private_lane :find_xcode_project do
  projects_glob = is_react_native || is_flutter || is_expo ? './ios/*.xcodeproj' : './**/*.xcodeproj'
  projects = Dir.glob(projects_glob)

  return projects.first if projects.length == 1

  UI.user_error!("Zero or more than one XCode projects found for '#{projects_glob}' (count: #{projects.length})")
end

desc 'Fetch certificates and provisioning profiles'
private_lane :provision_certificates do |options|
  identifier = CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)
  match(app_identifier: identifier, type: options[:type], readonly: is_ci)
end

desc 'Increment build number'
private_lane :update_build_number do |options|
  build_number_env = ENV['FL_BUILD_NUMBER']&.downcase&.trim

  build_number = nil
  if options[:type] == 'appstore' && build_number_env == 'store'
    build_number = app_store_build_number(live: options[:live]) + 1
  else
    build_number = Integer(build_number_env, exception: false) unless build_number_env.nil?
  end

  if is_expo
    increment_expo_version(ios_build_number: build_number, platform: 'ios')
    setup_expo_project # regenerate native projects with updated versions
  else
    increment_build_number(build_number:, xcodeproj: options[:xcodeproj])
  end
end

desc 'Commit version bump and push'
private_lane :commit_and_push do
  if is_expo
    commit_expo_app_json
  else
    commit_version_bump(message: 'chore: Version bump', xcodeproj: find_xcode_project)
  end

  push_to_git_remote
end
