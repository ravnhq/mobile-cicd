module Fastlane
  module Actions
    module SharedValues
      IS_FLUTTER_PROJECT = :IS_FLUTTER_PROJECT
    end

    # Action to detect if project is Flutter
    class IsFlutterAction < Action
      def self.run(_params)
        return false unless File.exist?('pubspec.yaml')
        return false unless Dir.exist?('lib') && (Dir.exist?('android') || Dir.exist?('ios'))

        pubspec_content = read_pubspec_yaml
        is_flutter = pubspec_content&.dig('dependencies')&.dig('flutter')&.dig('sdk') == 'flutter'
        return Action.lane_context[SharedValues::IS_FLUTTER_PROJECT] = is_flutter
      end

      def self.read_pubspec_yaml
        require 'psych'
        Psych.load_file('pubspec.yaml')
      rescue StandardError
        {}
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Action to detect if the current project is using Flutter'
      end

      def self.details
        'The return value of this action is true if a Flutter project is detected'
      end

      def self.output
        [
          'IS_FLUTTER_PROJECT', 'Whether or not the project uses Flutter'
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
