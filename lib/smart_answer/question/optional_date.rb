module SmartAnswer
  module Question
    class OptionalDate < SmartAnswer::Question::Date

      def parse_input(input)
        if negative?(input)
          (input['selection'] || input).to_sym
        else
          super(input)
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

      def negative?(input)
        input.to_s == "no" || (
          input.is_a?(Hash) and 
          input.has_key?('selection') and 
          input['selection'].to_s == "no"
        )
      end
    end
  end
end
