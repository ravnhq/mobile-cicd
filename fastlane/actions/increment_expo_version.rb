# frozen_string_literal: true
require 'json'

module Fastlane
  module Actions
    module SharedValues
      # noinspection RubyConstantNamingConvention
      INCREMENT_EXPO_VERSION_ANDROID_VALUE = :INCREMENT_EXPO_VERSION_ANDROID_VALUE
      # noinspection RubyConstantNamingConvention
      INCREMENT_EXPO_VERSION_IOS_VALUE = :INCREMENT_EXPO_VERSION_IOS_VALUE
    end

    # Action to increment version of Expo projects (in app.json)
    class IncrementExpoVersionAction < Action

      def self.run(params)
        platform = params[:platform]
        self.increment_android_version_code(params[:android_version_code]) if %w[android both].include?(platform)
        self.increment_ios_build_number(params[:ios_build_number]) if %w[ios both].include?(platform)
      end

      def self.increment_android_version_code(version_code)
        app_config = read_app_json_config
        android_config = app_config.fetch('expo', {}).fetch('android', {})
        version_code = android_config.fetch('versionCode', 0) + 1 if version_code.nil?
        android_config['versionCode'] = version_code
        Actions.lane_context[SharedValues::INCREMENT_EXPO_VERSION_ANDROID_VALUE] = version_code

        # noinspection RubyMismatchedArgumentType
        File.write('app.json', JSON.pretty_generate(app_config))
      end

      def self.increment_ios_build_number(build_number)
        app_config = read_app_json_config
        ios_config = app_config.fetch('expo', {}).fetch('ios', {})
        build_number = (Integer(ios_config['buildNumber'], exception: false) || 0) + 1 if build_number.nil?
        ios_config['buildNumber'] = build_number.to_s
        Actions.lane_context[SharedValues::INCREMENT_EXPO_VERSION_IOS_VALUE] = build_number.to_s

        # noinspection RubyMismatchedArgumentType
        File.write('app.json', JSON.pretty_generate(app_config))
      end

      def self.read_app_json_config
        JSON.parse(File.read('app.json'))
      rescue
        {}
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Increment version code and/or build number in app.json for Expo projects'
      end

      def self.details
        'Increment version code (for Android) or build number (for iOS) for projects using Expo'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :android_version_code,
                                       env_name: 'FL_INCREMENT_EXPO_VERSION_ANDROID_VERSION_CODE',
                                       description: 'Version code value for Android',
                                       optional: true,
                                       skip_type_validation: true),
          FastlaneCore::ConfigItem.new(key: :ios_build_number,
                                       env_name: 'FL_INCREMENT_EXPO_VERSION_IOS_BUILD_NUMBER',
                                       description: 'Build number value for iOS',
                                       optional: true,
                                       skip_type_validation: true),
          FastlaneCore::ConfigItem.new(key: :platform,
                                       env_name: 'FL_INCREMENT_EXPO_VERSION_PLATFORM',
                                       description: 'Platform to apply this change to (values: android, ios, both)',
                                       type: String,
                                       default_value: 'both',
                                       verify_block: proc do |value|
                                         UI.user_error!("Invalid platform value '#{value}'") unless %w[android ios both].include?(value)
                                       end)
        ]
      end

      def self.output
        [
          ['INCREMENT_EXPO_VERSION_ANDROID_VALUE', 'Android version code value'],
          ['INCREMENT_EXPO_VERSION_IOS_VALUE', 'iOS build number value']
        ]
      end

      def self.authors
        ['quebin31']
      end

      def self.is_supported?(platform)
        %i[ios android].include?(platform)
      end
    end
  end
end
