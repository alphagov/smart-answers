module SmartAnswer
  module Question
    class MultipleChoice < Base
      def initialize(name, options = {}, &block)
        transitions = @transitions = {}
        next_node { |input| transitions[input.to_s] }
        super
      end

      def option(transitions, options = {})
        if transitions.is_a?(Hash)
          transitions.each_pair { |option, next_node| @transitions[option.to_s] = next_node }
        else
          [*transitions].each { |option| @transitions[option.to_s] = nil }
        end
      end

      def options
        @transitions.keys
      end

      def valid_option?(option)
        @transitions.has_key?(option.to_s)
      end

      def parse_input(raw_input)
        raise SmartAnswer::InvalidResponse, "Illegal option #{raw_input} for #{name}", caller unless valid_option?(raw_input)
        super
      end
    end
  end
end