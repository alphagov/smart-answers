module SmartAnswer
  module Question
    class Radio < Base
      PRESENTER_CLASS = RadioQuestionPresenter

      attr_accessor :option_keys, :options_block

      def initialize(flow, name, &block)
        @option_keys = []
        @options_block = nil
        super
      end

      def option(key)
        @option_keys << key.to_s
      end

      def options(&block)
        raise InvalidNode, "Options needs to be a given a block" unless block_given?

        @options_block = block
      end

      def valid_option?(option)
        @option_keys.include?(option.to_s)
      end

      def setup(state)
        unless @options_block.nil?
          @option_keys = state.instance_exec(&@options_block)
        end
      end

      def parse_input(raw_input)
        raise SmartAnswer::InvalidResponse, "Illegal option #{raw_input} for #{name}", caller unless valid_option?(raw_input)

        super
      end
    end
  end
end
