module SmartAnswer
  module Predicate
    class VariableMatches < Base
      attr_reader :variable_name, :acceptable_responses

      def initialize(variable_name, acceptable_responses, match_description = nil, label = nil)
        @variable_name = variable_name
        @acceptable_responses = [*acceptable_responses]
        @match_description = match_description
        @label = label
      end

      def call(state, response)
        @acceptable_responses.include?(state.send(@variable_name))
      end

      def or(other)
        if other.is_a?(VariableMatches) && other.variable_name == self.variable_name
          super(other, "#{@variable_name} == #{self.match_description} | #{other.match_description}")
        else
          super
        end
      end

      alias_method :|, :or

      def match_description
        @match_description || if acceptable_responses.size == 1
          acceptable_responses.first
        else
          "{ #{@acceptable_responses.join(" | ")} }"
        end
      end

      def label
        @label || "#{@variable_name} == #{match_description}"
      end
    end
  end
end
