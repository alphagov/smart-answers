module SmartAnswer
  module Question
    class MultipleChoice < Base
      def initialize(name, options = {}, &block)
        @transitions = {}
        super
      end

      def next_node_for(current_state, input)
        raise SmartAnswer::InvalidResponse, "Illegal option #{input} for #{name}", caller unless valid_option?(input)
        @transitions[input.to_s]
      end
      
      def option(transitions, options = {})
        transitions.each_pair { |option, next_node| @transitions[option.to_s] = next_node }
      end
    
      def options
        @transitions.keys
      end
    
      def valid_option?(option)
        @transitions.has_key?(option.to_s)
      end
    end
  end
end