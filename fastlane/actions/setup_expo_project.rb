# frozen_string_literal: true

module Fastlane
  module Actions
    # Action to setup an expo project (if any)
    class SetupExpoProjectAction < Action
      def self.run(params)
        platform = params[:platform] || 'all'
        sh("npx expo prebuild --platform #{platform} --clean")
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Set up an expo project (based on React Native) to work with fastlane'
      end

      def self.details
        'Execute `npx expo prebuild --clean` to configure Android and iOS native projects'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :platform,
                                       env_name: 'FL_SETUP_EXPO_PROJECT_PLATFORM',
                                       description: 'Platform to sync (values: android, ios, all)',
                                       type: String,
                                       default_value: 'all',
                                       verify_block: proc do |value|
                                         is_valid = %w[android ios all].include?(value)
                                         UI.user_error!("Invalid platform value '#{value}'") unless is_valid
                                       end)
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
