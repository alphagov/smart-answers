module SmartAnswer
  module Question
    class Checkbox < Base
      NONE_OPTION = "none".freeze

      attr_reader :options

      def initialize(flow, name, &block)
        @options = []
        super
      end

      def option(option_slug)
        raise InvalidNode, "Can't use reserved option name '#{NONE_OPTION}'" if option_slug.to_s == NONE_OPTION
        raise InvalidNode, "Invalid option specified" unless option_slug.to_s =~ /\A[a-z0-9_-]+\z/

        @options << option_slug.to_s
      end

      def valid_option?(option)
        @options.include?(option) || option == NONE_OPTION
      end

      def parse_input(raw_input)
        if raw_input.blank?
          # Raise on for blank input when showing a 'none' option as input is required.
          raise SmartAnswer::InvalidResponse, "No option specified", caller if none_option?

          return NONE_OPTION
        end
        return NONE_OPTION if raw_input == NONE_OPTION

        raw_input = raw_input.split(",") if raw_input.is_a?(String)
        raw_input.each do |option|
          raise SmartAnswer::InvalidResponse, "Illegal option #{option} for #{name}", caller unless valid_option?(option)
        end
        raw_input.sort.join(",")
      end

      def none_option?
        @options.include?(NONE_OPTION)
      end

      def none_option
        @options << NONE_OPTION
      end
    end
  end
end
