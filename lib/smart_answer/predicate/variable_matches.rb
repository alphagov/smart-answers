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
        acceptable_responses.include?(state.send(variable_name))
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
        @match_description || generate_match_description
      end

      def label
        @label || "#{variable_name} == #{match_description}"
      end

    private
      def generate_match_description
        if multiple_acceptable_responses?
          wrap_in_braces(acceptable_responses)
        else
          acceptable_responses.first || ""
        end
      end

      def multiple_acceptable_responses?
        acceptable_responses.size > 1
      end

      def wrap_in_braces(set)
        "{ #{set.join(' | ')} }"
      end
    end
  end
end
