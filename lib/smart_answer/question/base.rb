module SmartAnswer
  module Question
    class Base < Node
      attr_reader :next_node_function_chain
      class NextNodeUndefined < StandardError; end

      def initialize(flow, name, options = {}, &block)
        @save_input_as = nil
        @validations ||= []
        @next_node_function_chain ||= []
        @default_next_node_function ||= lambda {|_|}
        @permitted_next_nodes = []
        @predicates = {}
        @uses_erb_template = options[:use_erb_template]
        super
      end

      def next_node(next_node = nil, permitted: [], &block)
        if block_given?
          unless permitted.any?
            raise "You must specify the permitted next nodes"
          end
          @permitted_next_nodes += permitted
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
        next_node = next_node_from_function_chain(current_state, input) || next_node_from_default_function(current_state, input)
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

      def respond_to_missing?(method, include_private = false)
        @predicates.has_key?(method)
      end

      def method_missing(method, *args, &block)
        @predicates.fetch(method)
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

      def use_erb_template?
        @uses_erb_template
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

      def normalize_predicates(predicates)
        predicates.map do |predicate|
          if predicate.is_a?(SmartAnswer::Predicate::Base)
            predicate
          else
            SmartAnswer::Predicate::Callable.new(nil, predicate)
          end
        end
      end

      def next_node_from_function_chain(current_state, input)
        found = @next_node_function_chain.find do |(_, predicates)|
          predicates.all? do |predicate|
            predicate.call(current_state, input)
          end
        end
        found && found.first
      end

      def next_node_from_default_function(current_state, input)
        current_state.instance_exec(input, &@default_next_node_function)
      end
    end
  end
end
