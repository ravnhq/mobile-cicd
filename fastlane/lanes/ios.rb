# frozen_string_literal: true

desc 'Setup Apple App Store Connect authorization'
private_lane :authenticate do
  ensure_env_vars(env_vars: %w[FL_APPLE_KEY_ID FL_APPLE_KEY_FILE FL_APPLE_ISSUER_ID])
  app_store_connect_api_key(
    key_filepath: ENV['FL_APPLE_KEY_FILE']&.strip,
    key_id: ENV['FL_APPLE_KEY_ID']&.strip,
    issuer_id: ENV['FL_APPLE_ISSUER_ID']&.strip,
    duration: 1200,
    in_house: parse_boolean(ENV['FL_APPLE_ENTERPRISE'] || 'false')
  )
end

desc 'Build iOS project'
private_lane :build do |options|
  ensure_env_vars(env_vars: %w[FL_IOS_SCHEME FL_XCODE_PROJ])

  xcworkspace = ENV['FL_XCODE_WORKSPACE']
  xcodeproj = ENV['FL_XCODE_PROJ']

  type = options[:type]
  live = options[:env] == 'release'
  configuration = ENV['FL_IOS_CONFIGURATION']&.strip || 'Release'

  update_build_number(type:, live:, xcodeproj:)
  setup_expo_project if is_expo
  configure_certificates(type:)
  configure_signing(xcodeproj:, configuration:)

  scheme = ENV['FL_IOS_SCHEME'].strip
  team_id = CredentialsManager::AppfileConfig.try_fetch_value(:team_id)

  gym(
    workspace: xcworkspace,
    project: xcworkspace ? nil : xcodeproj,
    scheme:,
    configuration:,
    export_team_id: team_id,
    export_method: Actions.lane_context[SharedValues::SIGH_PROFILE_TYPE],
    export_options: {
      signingStyle: 'manual'
    }
  )
end

desc 'Configure iOS code signing'
private_lane :configure_signing do |options|
  build_configurations = [options[:configuration]]
  path = options[:xcodeproj]

  bundle_identifier = CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)
  team_id = CredentialsManager::AppfileConfig.try_fetch_value(:team_id)
  profiles = Actions.lane_context[SharedValues::MATCH_PROVISIONING_PROFILE_MAPPING]
  profile_name = profiles[bundle_identifier]

  update_code_signing_settings(
    use_automatic_signing: false,
    bundle_identifier:,
    path:,
    profile_name:,
    team_id:,
    build_configurations:,
    code_sign_identity: 'iPhone Distribution' # fixme?: May need to change for other types of builds
  )
end

desc 'Fetch certificates and provisioning profiles'
private_lane :configure_certificates do |options|
  identifier = CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)
  match(app_identifier: identifier, type: options[:type], readonly: is_ci)
end

desc 'Increment build number'
private_lane :update_build_number do |options|
  build_number_env = ENV['FL_BUILD_NUMBER']&.downcase&.strip

  build_number = nil
  if options[:type] == 'appstore' && build_number_env == 'store'
    build_number = app_store_build_number(live: options[:live]) + 1
  else
    build_number = Integer(build_number_env, exception: false) unless build_number_env.nil?
  end

  if is_expo
    increment_expo_version(ios_build_number: build_number, platform: 'ios')
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
