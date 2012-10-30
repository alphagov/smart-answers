module SmartAnswer
  module Question
    class OptionalDate < SmartAnswer::Question::Date

      def parse_input(input)
        begin
          super(input)
        rescue InvalidResponse => e
          raise InvalidResponse.new(e) unless input.to_s == "no" || input['selection'].to_s == "no"
          (input['selection'] || input).to_sym
        end
      end

      def to_response(input)
        case parse_input(input)
        when Date
          date = ::Date.parse(input)
          {
            day: date.day,
            month: date.month,
            year: date.year
          }
        else
          input
        end
      rescue
        nil
      end
    end
  end
end
