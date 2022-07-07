require "date"

module SmartAnswer
  module Question
    class Year < Base
      PRESENTER_CLASS = YearQuestionPresenter

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
        date.year
      rescue ArgumentError => e
        if e.message =~ /invalid date/
          raise InvalidResponse, "Bad date: #{input.inspect}", caller
        else
          raise
        end
      end
    end
  end
end
