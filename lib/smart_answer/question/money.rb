module SmartAnswer
  module Question
    class Money < Base
      def parse_input(raw_input)
        if ! valid?(raw_input)
          raise InvalidResponse, "Sorry, I couldn't understand that number. Please try again.", caller
        end
        SmartAnswer::Money.new(raw_input)
      end
      
      def valid?(raw_input)
        raw_input =~ /\A *[0-9]+(\.[0-9]{1,2})? *\z/
      end
    end
  end
end