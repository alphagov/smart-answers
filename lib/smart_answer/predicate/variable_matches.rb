module SmartAnswer
  module Predicate
    class VariableMatches < Base
      attr_reader :variable_name, :acceptable_responses

      def initialize(variable_name, acceptable_responses, match_description = nil)
        @variable_name = variable_name
        @acceptable_responses = [*acceptable_responses]
        @match_description = match_description
      end

      def call(state, response)
        @acceptable_responses.include?(state.send(@variable_name))
      end

      def match_description
        @match_description || "{ #{@acceptable_responses.join(" | ")} }"
      end

      def or(other)
        if other.is_a?(VariableMatches) && other.variable_name == self.variable_name
          super(other, "#{@variable_name} == #{self.match_description} | #{other.match_description}")
        else
          super
        end
      end

      alias_method :|, :or

      def label
        "#{@variable_name} == #{match_description}"
      end
    end
  end
end
