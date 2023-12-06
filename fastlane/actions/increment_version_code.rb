# frozen_string_literal: true

require_relative '../util/util'

module Fastlane
  module Actions
    module SharedValues
      INCREMENT_VERSION_CODE_VALUE = :INCREMENT_VERSION_CODE_VALUE
    end

    # Action to increment version code in gradle.properties
    class IncrementVersionCodeAction < Action
      def self.run(params)
        project_dir = params[:project_dir]

        properties_file = File.join(project_dir, 'gradle.properties')
        properties_contents = File.read(properties_file)

        version_code = params[:version_code]
        version_code = get_version_code(properties_contents) if blank?(version_code)
        version_code = [version_code.to_i, 1].max

        updated_contents = properties_contents.gsub!(/^\s*version\.code\s*=\s*\S+/, "version.code=#{version_code}")
        updated_contents = properties_contents + "\nversion.code=#{version_code}" if blank?(updated_contents)

        # noinspection RubyMismatchedArgumentType
        File.write(properties_file, updated_contents)

        Actions.lane_context[SharedValues::INCREMENT_VERSION_CODE_VALUE] = version_code
      end

      def self.get_version_code(contents)
        extracted_version = contents.match(/^\s*version\.code\s*=\s*(\S+)/)&.[](1) || '0'
        extracted_version.to_i + 1
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Increment version code for Android in gradle.properties'
      end

      def self.details
        "The updated value is located in the property 'version.code' inside gradle.properties file"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :version_code,
                                       env_name: 'FL_INCREMENT_VERSION_CODE_VERSION_CODE',
                                       description: 'Value for version code',
                                       optional: true,
                                       skip_type_validation: true),
          FastlaneCore::ConfigItem.new(key: :project_dir,
                                       env_name: 'FL_INCREMENT_VERSION_CODE_PROJECT_DIR',
                                       description: 'Android project dir',
                                       is_string: true,
                                       default_value: '.')
        ]
      end

      def self.output
        [
          ['INCREMENT_VERSION_CODE_VALUE', 'The new version code value']
        ]
      end

      def self.return_value
        'The incremented version code value'
      end

      def self.authors
        ['quebin31']
      end

      def self.is_supported?(platform)
        platform == :android
      end
    end
  end
end
