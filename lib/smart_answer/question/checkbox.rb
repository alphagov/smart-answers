module SmartAnswer
  module Question
    class Checkbox < Base
      NONE_OPTION = "none".freeze

      attr_reader :options, :none_option_label, :none_option_prefix

      def initialize(flow, name, &block)
        @options = []
        @none_option = false
        super
      end

      def option(option_slug)
        raise InvalidNode.new("Can't use reserved option name '#{NONE_OPTION}'") if option_slug.to_s == NONE_OPTION
        raise InvalidNode.new("Invalid option specified") unless option_slug.to_s =~ /\A[a-z0-9_-]+\z/

        @options << option_slug.to_s
      end

      def valid_option?(option)
        @options.include?(option) || option == NONE_OPTION
      end

      def parse_input(raw_input)
        if raw_input.blank?
          # Raise on for blank input when showing a 'none' option as input is required.
          raise SmartAnswer::InvalidResponse, "No option specified", caller if has_none_option?

          return NONE_OPTION
        end
        return NONE_OPTION if raw_input == NONE_OPTION

        raw_input = raw_input.split(",") if raw_input.is_a?(String)
        raw_input.each do |option|
          raise SmartAnswer::InvalidResponse, "Illegal option #{option} for #{name}", caller unless valid_option?(option)
        end
        raw_input.sort.join(",")
      end

      def to_response(input)
        input.split(",").reject { |v| v == NONE_OPTION }
      end

      def has_none_option?
        none_option_label.present?
      end

      def set_none_option(label:, prefix: nil)
        @none_option_label = label
        @none_option_prefix = prefix
      end
    end
  end
end
