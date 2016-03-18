module SmartAnswer
  module Question
    class Base < Node
      class NextNodeUndefined < StandardError; end

      def initialize(flow, name, options = {}, &block)
        @save_input_as = nil
        @validations = []
        @default_next_node_block = lambda { |_| nil }
        @permitted_next_nodes = []
        super
      end

      def next_node(next_node = nil, &block)
        if @next_node_block.present?
          raise 'Multiple calls to next_node are not allowed'
        end
        if block_given?
          @permitted_next_nodes = :auto
          @next_node_block = block
        elsif next_node
          @permitted_next_nodes = [next_node]
          @next_node_block = lambda { |_| next_node }
        else
          raise ArgumentError, 'You must specify a block or a single next node key'
        end
      end

      def permitted_next_nodes
        if @permitted_next_nodes == :auto
          parser = NextNodeBlock::Parser.new
          @permitted_next_nodes = parser.possible_next_nodes(@next_node_block)
        end
        @permitted_next_nodes.uniq
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
        if @permitted_next_nodes == :auto
          unless NextNodeBlock.permitted?(next_node)
            raise "Next node (#{next_node}) not returned via question or outcome method"
          end
        else
          unless @permitted_next_nodes.include?(next_node.to_sym)
            raise "Next node (#{next_node}) not in list of permitted next nodes (#{@permitted_next_nodes.to_sentence})"
          end
        end
        next_node.to_sym
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
