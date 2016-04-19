module SmartAnswer
  module Question
    class Base < Node
      class NextNodeUndefined < StandardError; end

      def initialize(flow, name, &block)
        @validations = []
        @default_next_node_block = lambda { |_| nil }
        super
      end

      def next_node(&block)
        unless block_given?
          raise ArgumentError, 'You must specify a block'
        end
        if @next_node_block.present?
          raise 'Multiple calls to next_node are not allowed'
        end
        @next_node_block = block
      end

      def permitted_next_nodes
        @permitted_next_nodes ||= begin
          parser = NextNodeBlock::Parser.new
          parser.possible_next_nodes(@next_node_block).uniq
        end
      end

      def validate(message = nil, &block)
        @validations << [message, block]
      end

      def next_node_for(current_state, input)
        validate!(current_state, input)
        state = current_state.dup.extend(NextNodeBlock::InstanceMethods).freeze
        next_node = state.instance_exec(input, &next_node_block)
        unless next_node.present?
          responses_and_input = current_state.responses + [input]
          message = "Next node undefined. Node: #{current_state.current_node}."
          message << " Responses: #{responses_and_input}."
          raise NextNodeUndefined.new(message)
        end
        unless NextNodeBlock.permitted?(next_node)
          raise "Next node (#{next_node}) not returned via question or outcome method"
        end
        next_node.to_sym
      end

      def save_input_as(variable_name)
        @saved_input = variable_name
      end

      def transition(current_state, raw_input)
        input = parse_input(raw_input)
        state_after_on_response_blocks = @on_response_blocks.inject(current_state.dup) do |state, block|
          block.evaluate(state, input)
        end
        new_state = @next_node_calculations.inject(state_after_on_response_blocks.dup) do |state, calculation|
          calculation.evaluate(state, input)
        end
        next_node = next_node_for(new_state, input)
        new_state = new_state.transition_to(next_node, input) do |state|
          state.save_input_as @saved_input if @saved_input
        end
        @calculations.each do |calculation|
          new_state = calculation.evaluate(new_state, input)
        end
        new_state
      end

      def parse_input(raw_input)
        raw_input
      end

      def to_response(input)
        input
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
          if !current_state.instance_exec(input, &predicate)
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
