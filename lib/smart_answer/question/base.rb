module SmartAnswer
  module Question
    class Base < Node
      class NextNodeUndefined < StandardError; end

      module GotoNodeMethods
        def goto_node(key)
          throw :goto_node, key
        end
      end

      def initialize(flow, name, options = {}, &block)
        @save_input_as = nil
        @validations ||= []
        @default_next_node_function ||= lambda {|_|}
        @permitted_next_nodes = []
        super
      end

      class NextNodeBlockProcessor < Parser::AST::Processor
        attr_reader :next_nodes

        def initialize
          @next_nodes = []
        end

        def on_send(node)
          _receiver_node, method_name, *arg_nodes = *node
          if method_name == :goto_node && arg_nodes.length == 1
            if arg_nodes[0].type == :sym
              @next_nodes += arg_nodes[0].to_a
            end
          end
          super(node)
        end
      end

      def next_node(next_node = nil, permitted: [], &block)
        if block_given?
          if permitted.any?
            @permitted_next_nodes += permitted
          else
            ast = Parser::CurrentRuby.parse(block.source)
            processor = NextNodeBlockProcessor.new
            processor.process(ast)
            unless processor.next_nodes.any?
              raise "You must call goto_node at least once inside next_node block"
            end
            @permitted_next_nodes += processor.next_nodes
          end
          @default_next_node_function = block
        elsif next_node
          @permitted_next_nodes = [next_node]
          @default_next_node_function = proc { next_node }
        else
          raise ArgumentError
        end
      end

      def validate(message = nil, &block)
        @validations << [message, block]
      end

      def permitted_next_nodes(*args)
        @permitted_next_nodes += args
      end

      def next_node_for(current_state, input)
        validate!(current_state, input)
        next_node = catch :goto_node do
          next_node_from_default_function(current_state, input)
        end
        responses_and_input = current_state.responses + [input]
        raise NextNodeUndefined.new("Next node undefined. Node: #{current_state.current_node}. Responses: #{responses_and_input}") unless next_node
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
      def permitted_next_node?(next_node)
        @permitted_next_nodes.include?(next_node)
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

      def next_node_from_default_function(current_state, input)
        current_state.dup.extend(GotoNodeMethods).instance_exec(input, &@default_next_node_function)
      end
    end
  end
end
