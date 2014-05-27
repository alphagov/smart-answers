module SmartAnswer
  module Predicate
    class RespondedWith < Base
      def initialize(acceptable_responses, label = nil)
        @acceptable_responses = [*acceptable_responses]
        @label = label
      end

      def call(state, response)
        @acceptable_responses.include?(response.to_s)
      end

      def label
        @label || @acceptable_responses.join(" | ")
      end
    end
  end
end
