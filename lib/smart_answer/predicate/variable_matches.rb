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

      def or(other)
        if other.variable_name != self.variable_name
          raise "Can't perform variable match OR on different variables " +
            "#{other.variable_name}, #{self.variable_name}"
        end
        SmartAnswer::Predicate::VariableMatches.new(variable_name,
          self.acceptable_responses + other.acceptable_responses,
          self.match_description + " | " + other.match_description)
      end

      alias_method :+, :or

      def match_description
        @match_description || "{ #{@acceptable_responses.join(" | ")} }"
      end

      def label
        "#{@variable_name} == #{match_description}"
      end
    end
  end
end
