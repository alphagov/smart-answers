module SmartAnswer
  module Question
    class Base < Node
      attr_accessor :number
      
      def initialize(name, options = {}, &block)
        @calculations = []
        @save_input_as = nil
        @number = options.delete(:number)
        @next_node_function = lambda {|_,_|}
        super
      end

      def next_node(*args, &block)
        if block_given?
          @next_node_function = block
        elsif args.count == 1
          @next_node_function = lambda { |_current_state, _input| args.first }
        else
          raise ArgumentError
        end
      end
      
      def next_node_for(current_state, input)
        @next_node_function.call(current_state, input)
      end
    
      def save_input_as(variable_name)
        @save_input_as = variable_name
      end
  
      def calculate(variable_name, &block)
        @calculations << Calculation.new(variable_name, &block)
      end
  
      def transition(current_state, input)
        next_node = next_node_for(current_state, input)
        new_state = current_state.dup
        new_state.current_node = next_node
        new_state.responses ||= []
        new_state.responses += [input]
        new_state.send("#{@save_input_as}=", input) if @save_input_as
        new_state.freeze
        @calculations.each do |calculation|
          new_state = calculation.evaluate(new_state)
        end
        new_state
      end
    end
  end
end