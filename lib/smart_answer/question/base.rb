module SmartAnswer
  module Question
    class Base < Node
      PRESENTER_CLASS = QuestionPresenter

      def initialize(flow, name, &block)
        @on_response_blocks = []
        @validations = []
        super
      end

      def validate(message = nil, &block)
        @validations << [message, block]
      end

      def transition(current_state, raw_input)
        input = parse_input(raw_input)
        new_state = @on_response_blocks.inject(current_state.dup) do |state, block|
          block.evaluate(state, input)
        end
        validate!(new_state, input)
        next_node = next_node_for(new_state, input)
        new_state.transition_to(next_node, input)
      end

      def on_response(&block)
        @on_response_blocks << Block.new(&block)
      end

      def parse_input(raw_input)
        raw_input
      end

      def question?
        true
      end

    private

      def validate!(current_state, input)
        @validations.each do |message, predicate|
          unless current_state.instance_exec(input, &predicate)
            if message
              raise InvalidResponse, message
            else
              raise InvalidResponse
            end
          end
        end
      end
    end
  end
end
