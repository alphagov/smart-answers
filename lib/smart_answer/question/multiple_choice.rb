module SmartAnswer
  module Question
    class MultipleChoice < Base
      def initialize(name, options = {}, &block)
        @transitions = {}
        super
      end

      def next_node_for(current_state, input)
        raise "Illegal option #{input} for #{name}" unless valid_option?(input)
        @transitions[input]
      end
      
      def option(transitions, options = {})
        transitions.each_pair { |option, next_node| @transitions[option] = next_node }
      end
    
      def options
        @transitions.keys
      end
    
      def valid_option?(option)
        @transitions.has_key?(option)
      end
    end
  end
end