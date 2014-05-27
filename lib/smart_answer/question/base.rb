module SmartAnswer
  module Question
    class Base < Node
      attr_reader :next_node_function_chain

      def initialize(name, options = {}, &block)
        @save_input_as = nil
        @validations ||= []
        @next_node_function_chain ||= []
        @default_next_node_function ||= lambda {|_|}
        @permitted_next_nodes = []
        @predicate_stack = []
        super
      end

      def next_node(next_node = nil, &block)
        if block_given?
          @default_next_node_function = block
        elsif next_node
          next_node_if(next_node)
        else
          raise ArgumentError
        end
      end

      def next_node_if(next_node, *predicates, &block)
        predicates << block if block_given?
        @next_node_function_chain << [next_node, normalize_predicates(@predicate_stack + predicates)]
        @permitted_next_nodes << next_node
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
        raise "Next node undefined (#{current_state.current_node}(#{input}))" unless next_node
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
          new_state = calculation.evaluate(new_state)
        end
        new_state
      end

      # Within an #on_condition block, all #next_node and #next_node_if
      # clauses must additionally satisfy the given predicate. Nesting of
      # #on_condition blocks is permitted.
      #
      # Example:
      #
      # on_condition(->(r) {r == 'tourism'}) do
      #   next_node_if(:outcome_visit_waiver) { %w(oman qatar united-arab-emirates).include?(passport_country) }
      #   next_node_if(:outcome_taiwan_exception) { %w(taiwan).include?(passport_country) }
      #   next_node_if(:outcome_school_n) do
      #     country_group_non_visa_national.include?(passport_country) or country_group_ukot.include?(passport_country))
      #   end
      #   next_node(:outcome_general_y)
      # end
      def on_condition(predicate, &block)
        @predicate_stack << predicate
        instance_eval(&block)
        @predicate_stack.pop
      end

      def responded_with(acceptable_responses)
        SmartAnswer::Predicate::RespondedWith.new(acceptable_responses)
      end

      def variable_matches(variable_name, acceptable_responses)
        SmartAnswer::Predicate::VariableMatches.new(variable_name, acceptable_responses)
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

      def normalize_predicates(predicates)
        predicates.map do |predicate|
          if predicate.is_a?(SmartAnswer::Predicate::Base)
            predicate
          else
            SmartAnswer::Predicate::Callable.new(predicate)
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
