module Fastlane
  module Actions

    # Action to setup an expo project (if any)
    class SetupExpoProjectAction < Action
      def self.run(_params)
        sh('npx', 'expo', 'prebuild', '--clean')
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
        []
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
