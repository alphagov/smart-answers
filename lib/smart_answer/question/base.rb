module SmartAnswer
  module Question
    class Base < Node
      class NextNodeUndefined < StandardError; end

      attr_reader :permitted_next_nodes

      def initialize(flow, name, options = {}, &block)
        @save_input_as = nil
        @validations = []
        @default_next_node_block = lambda { |_| nil }
        @permitted_next_nodes = []
        super
      end

      def next_node(next_node = nil, permitted: [], &block)
        if @next_node_block.present?
          raise 'Multiple calls to next_node are not allowed'
        end
        if block_given?
          unless permitted.any?
            raise ArgumentError, 'You must specify at least one permitted next node'
          end
          @permitted_next_nodes = permitted
          @next_node_block = block
        elsif next_node
          @permitted_next_nodes = [next_node]
          @next_node_block = lambda { |_| next_node }
        else
          raise ArgumentError, 'You must specify a block or a single next node key'
        end
      end

      def validate(message = nil, &block)
        @validations << [message, block]
      end

      def next_node_for(current_state, input)
        validate!(current_state, input)
        next_node = current_state.instance_exec(input, &next_node_block)
        responses_and_input = current_state.responses + [input]
        unless next_node
          raise NextNodeUndefined.new("Next node undefined. Node: #{current_state.current_node}. Responses: #{responses_and_input}")
        end
        unless @permitted_next_nodes.include?(next_node)
          raise "Next node (#{next_node}) not in list of permitted next nodes (#{@permitted_next_nodes.to_sentence})"
        end
        next_node
      end

      def save_input_as(variable_name)
        @save_input_as = variable_name
      end

      def transition(current_state, raw_input)
        input = parse_input(raw_input)
        new_state = @next_node_calculations.inject(current_state.dup) do |new_state, calculation|
          calculation.evaluate(new_state, input)
        end
        next_node = next_node_for(new_state, input)
        new_state = new_state.transition_to(next_node, input) do |state|
          state.save_input_as @save_input_as if @save_input_as
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
