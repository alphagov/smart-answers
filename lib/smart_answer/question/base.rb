module SmartAnswer
  module Question
    class Base < Node

      def initialize(name, options = {}, &block)
        @calculations = []
        @save_input_as = nil
        @next_node_function ||= lambda {|_|}
        super
      end

      def next_node(*args, &block)
        if block_given?
          @next_node_function = block
        elsif args.count == 1
          @next_node_function = lambda { |_input| args.first }
        else
          raise ArgumentError
        end
      end

      def next_node_for(current_state, input)
        current_state.instance_exec(input, &@next_node_function) \
          or raise "Next node undefined (#{current_state.current_node}(#{input}))"
      end

      def save_input_as(variable_name)
        @save_input_as = variable_name
      end

      def calculate(variable_name, &block)
        @calculations << Calculation.new(variable_name, &block)
      end

      def transition(current_state, raw_input)
        input = parse_input(raw_input)
        next_node = next_node_for(current_state, input)
        new_state = current_state.transition_to(next_node, input) do |state|
          state.save_input_as @save_input_as if @save_input_as
        end
        @calculations.each do |calculation|
          new_state = calculation.evaluate(new_state)
        end
        new_state
      end

      def parse_input(raw_input)
        raw_input
      end

      def to_response(input)
        input
      end
    end
  end
end