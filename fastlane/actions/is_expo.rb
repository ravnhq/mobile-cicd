module Fastlane
  module Actions
    module SharedValues
      IS_EXPO_PROJECT = :IS_EXPO_PROJECT
    end

    # Action to detect if the current project uses Expo
    class IsExpoAction < Action
      def self.run(_params)
        return false unless File.exist?('package.json')

        package_contents = read_package_json
        is_expo = package_contents&.dig('dependencies')&.dig('expo') ? true : false
        Action.lane_context[SharedValues::IS_EXPO_PROJECT] = is_expo

        is_expo
      end

      def self.read_package_json
        JSON.parse(File.read('package.json'))
      rescue StandardError
        {}
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Action to detect if the current project is using Expo'
      end

      def self.details
        'The return value of this action is true if an Expo project is detected'
      end

      def self.output
        [
          'IS_EXPO_PROJECT', 'Whether or not the project uses Expo'
        ]
      end

      def self.available_options
        []
      end

      def self.return_type
        :bool
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
