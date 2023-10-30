module Fastlane
  module Actions

    # Action to detect if project is Flutter
    class IsFlutterAction < Action
      def self.run(params)
        return false unless File.exist?('pubspec.yaml')
        return false unless Dir.exist?('lib') && (Dir.exist?('android') || Dir.exist?('ios'))

        require 'psych'
        pubspec_content = Psych.load_file('pubspec.yaml') rescue return false
        pubspec_content&.dig('dependencies')&.dig('flutter')&.dig('sdk') == 'flutter'
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
