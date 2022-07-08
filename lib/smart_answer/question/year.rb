require "date"

module SmartAnswer
  module Question
    class Year < Base
      PRESENTER_CLASS = YearQuestionPresenter

      def from(&block)
        if block_given?
          @from_func = block
        else
          @from_func && @from_func.call
        end
      end

      def to(&block)
        if block_given?
          @to_func = block
        else
          @to_func && @to_func.call
        end
      end

      def parse_input(raw_input)
        date = case raw_input
               when Hash, ActiveSupport::HashWithIndifferentAccess
                 input = raw_input.symbolize_keys

                 begin
                   input = Integer(raw_input[:year])
                   ::Date.new(input, 1, 1)
                 rescue TypeError, ArgumentError
                   raise InvalidResponse
                 end
               when String
                 ::Date.parse("#{raw_input}-1-1")
               else
                 raise InvalidResponse, "Bad date", caller
               end
        validate_input(date)
        date.year
      rescue ArgumentError => e
        if e.message =~ /invalid date/
          raise InvalidResponse, "Bad date: #{input.inspect}", caller
        else
          raise
        end
      end

    private

      def validate_input(date)
        if (from && date.year < from) || (to && date.year > to)
          raise InvalidResponse, "Provided year is out of range: #{date}", caller
        end
      end
    end
  end
end
