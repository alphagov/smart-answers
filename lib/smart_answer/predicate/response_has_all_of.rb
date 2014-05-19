module SmartAnswer
  module Predicate
    class ResponseHasAllOf < Base
      def initialize(required_responses)
        @required_responses = [*required_responses]
      end

      def call(state, response)
        (response.split(",") & @required_responses).size == @required_responses.size
      end

      def label
        @required_responses.join(" & ")
      end
    end
  end
end
