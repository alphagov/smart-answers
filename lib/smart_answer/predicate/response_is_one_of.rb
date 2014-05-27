module SmartAnswer
  module Predicate
    class ResponseIsOneOf < Base
      def initialize(accepted_responses)
        @accepted_responses = [*accepted_responses]
      end

      def call(state, response)
        (response.split(",") & @accepted_responses).any?
      end

      def label
        @accepted_responses.join(" | ")
      end
    end
  end
end
