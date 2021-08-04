module SmartAnswer
  module Question
    class Checkbox < Base
      PRESENTER_CLASS = CheckboxQuestionPresenter
      NONE_OPTION = "none".freeze

      attr_accessor :option_keys, :options_block

      def initialize(flow, name, &block)
        @option_keys = []
        @options_block = nil
        super
      end

      def none_option
        @option_keys << NONE_OPTION
      end

      def option(key)
        key = key.to_s

        raise InvalidNode, "Can't use reserved option name '#{NONE_OPTION}'" if key == NONE_OPTION
        raise InvalidNode, "Invalid option specified" unless key =~ /\A[a-z0-9_-]+\z/

        @option_keys << key
      end

      def options(&block)
        raise InvalidNode, "Options needs to be a given a block" unless block_given?

        @options_block = block
      end

      def none_option?
        @option_keys.include?(NONE_OPTION)
      end

      def valid_option?(option)
        @option_keys.include?(option)
      end

      def setup(state)
        unless @options_block.nil?
          @option_keys = state.instance_exec(&@options_block)
        end
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
    end
  end
end
