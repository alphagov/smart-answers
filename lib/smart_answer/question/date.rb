require "date"

module SmartAnswer
  module Question
    class Date < Base
      PRESENTER_CLASS = DateQuestionPresenter

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

      def default_day(&block)
        if block_given?
          @default_day_func = block
        else
          @default_day_func && @default_day_func.call
        end
      end

      def default_month(&block)
        if block_given?
          @default_month_func = block
        else
          @default_month_func && @default_month_func.call
        end
      end

      def default_year(&block)
        if block_given?
          @default_year_func = block
        else
          @default_year_func && @default_year_func.call
        end
      end

      def parse_input(input)
        date = case input
               when Hash, ActiveSupport::HashWithIndifferentAccess
                 input = input.symbolize_keys
                 year_month_and_day = [
                   default_year || input[:year],
                   default_month || input[:month],
                   default_day || input[:day],
                 ]
                 raise InvalidResponse unless year_month_and_day.all?(&:present?)

                 ::Date.new(*year_month_and_day.map(&:to_i))
               when String
                 ::Date.parse(input)
               when ::Date
                 input
               else
                 raise InvalidResponse, "Bad date", caller
               end

        validate_input(date)
      rescue ArgumentError => e
        if e.message =~ /invalid date/
          raise InvalidResponse, "Bad date: #{input.inspect}", caller
        else
          raise
        end
      end

      def date_of_birth_defaults
        from { 122.years.ago.beginning_of_year.to_date }
        to { ::Time.zone.today.end_of_year }
      end

    private

      def validate_input(date)
        raise "from date must not be after the to date" if from && to && from > to

        if date.year < 100
          date = ::Date.new(date.year.to_i + 2000, date.month, date.day)
        end

        if (from && date < from) || (to && date > to)
          raise InvalidResponse, "Provided date is out of range: #{date}", caller
        end

        date
      end
    end
  end
end
