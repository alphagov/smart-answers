module SmartAnswer
  module Question
    class Base < Node
      PRESENTER_CLASS = QuestionPresenter

      def initialize(flow, name, &block)
        @validations = []
        super
      end

      def validate(message = nil, &block)
        @validations << [message, block]
      end

      def transition(current_state, raw_input)
        input = parse_input(raw_input)
        validate!(current_state, input)
        new_state = @on_response_blocks.inject(current_state.dup) do |state, block|
          block.evaluate(state, input)
        end
        next_node = next_node_for(new_state, input)
        new_state.transition_to(next_node, input)
      end

      def parse_input(raw_input)
        raw_input
      end

      def question?
        true
      end

    private

      def next_node_block
        @next_node_block || @default_next_node_block
      end

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
