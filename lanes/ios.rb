# frozen_string_literal: true

desc 'Setup Apple App Store Connect authorization'
private_lane :authenticate do
  ensure_env_vars(env_vars: %w[FL_APPLE_KEY_ID FL_APPLE_KEY_FILE FL_APPLE_ISSUER_ID])
  app_store_connect_api_key(
    key_filepath: ENV['FL_APPLE_KEY_FILE']&.strip,
    key_id: ENV['FL_APPLE_KEY_ID']&.strip,
    issuer_id: ENV['FL_APPLE_ISSUER_ID']&.strip,
    duration: 1200,
    in_house: parse_boolean(ENV['FL_APPLE_ENTERPRISE'], false)
  )
end

desc 'Build iOS project'
private_lane :build do |options|
  ensure_env_vars(env_vars: %w[FL_IOS_SCHEME FL_XCODE_PROJ])

  xcworkspace = ENV['FL_XCODE_WORKSPACE']
  xcodeproj = ENV['FL_XCODE_PROJ']

  type = options[:type]
  type = if blank?(type)
           enterprise = parse_boolean(ENV['FL_APPLE_ENTERPRISE'], false)
           enterprise ? 'enterprise' : 'appstore'
         else
           type
         end

  env = options[:env]
  env = blank?(env) ? 'release' : env

  live = env == 'release'

  configuration = ENV['FL_IOS_CONFIGURATION']&.strip || 'Release'
  configuration = 'Release' if blank?(configuration)

  update_build_number(type:, live:, xcodeproj:)
  setup_expo_project(platform: 'ios') if is_expo
  install_cocoapods unless is_expo
  configure_certificates(type:)
  configure_signing(xcodeproj:, configuration:)

  scheme = ENV['FL_IOS_SCHEME'].strip
  team_id = CredentialsManager::AppfileConfig.try_fetch_value(:team_id)

  gym(
    workspace: blank?(xcworkspace) ? nil : xcworkspace,
    project: blank?(xcworkspace) ? xcodeproj : nil,
    scheme:,
    configuration:,
    export_team_id: team_id,
    export_method: Actions.lane_context[SharedValues::SIGH_PROFILE_TYPE],
    export_options: {
      signingStyle: 'manual'
    }
  )

  # Copy IPAs and other output artifacts (always enabled for CI)
  # NOTE: This only makes sense for `enterprise` and `ad-hoc` builds, which at this point only the former is supported.
  copy_artifacts = parse_boolean(ENV['FL_COPY_ARTIFACTS'], true)
  copy_output_artifacts if copy_artifacts || is_ci
end

desc 'Increment build number'
private_lane :update_build_number do |options|
  build_number_env = ENV['FL_BUILD_NUMBER']&.downcase&.strip
  build_number = if options[:type] == 'appstore' && build_number_env == 'store'
                   app_store_build_number(live: options[:live]) + 1
                 elsif build_number_env
                   Integer(build_number_env, exception: false)
                 end

  if is_expo
    increment_expo_version(ios_build_number: build_number, platform: 'ios')
  else
    increment_build_number(build_number:, xcodeproj: options[:xcodeproj])
  end
end

desc 'Install Cocoapods if needed'
private_lane :install_cocoapods do |options|
  xcodeproj = options[:xcodeproj]

  podfile = ENV['FL_IOS_PODFILE']&.strip
  podfile = File.dirname(xcodeproj) if blank?(podfile)

  cocoapods(clean_install: is_ci, podfile:)
end

desc 'Fetch certificates and provisioning profiles'
private_lane :configure_certificates do |options|
  identifier = CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)
  match(app_identifier: identifier, type: options[:type], readonly: is_ci)
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

desc 'Upload to TestFlight or App Store '
private_lane :upload do |options|
  enterprise = parse_boolean(ENV['FL_APPLE_ENTERPRISE'], false)
  publish = parse_boolean(ENV['FL_PUBLISH_BUILD'], true)

  next if enterprise || !publish

  env = options[:env]
  env = blank?(env) ? 'release' : env

  case env
  when 'release'
    upload_to_app_store
  when 'beta'
    upload_to_testflight(skip_waiting_for_build_processing: is_ci)
  else
    UI.user_error!("Unknown environment for upload: #{env}")
  end
end

desc 'Commit version bump and push'
private_lane :commit_and_push do
  next unless parse_boolean(ENV['FL_COMMIT_INCREMENT'], false)

  ensure_env_vars(env_vars: %w[FL_XCODE_PROJ])
  commit_version(xcodeproj: ENV['FL_XCODE_PROJ'])
  push_to_git_remote
end
