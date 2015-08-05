require 'date'

module SmartAnswer
  module Question
    class Date < Base
      def initialize(name, &block)
        super
      end

      def validate_in_range
        @validate_in_range = true
      end

      def from(from = nil, &block)
        if block_given?
          @from_func = block
        elsif from
          @from_func = lambda { from }
        else
          @from_func && @from_func.call
        end
      end

      def to(to = nil, &block)
        if block_given?
          @to_func = block
        elsif to
          @to_func = lambda { to }
        else
          @to_func && @to_func.call
        end
      end

      def default(default = nil, &block)
        if block_given?
          @default_func = block
        elsif default
          @default_func = lambda { default }
        else
          @default_func && @default_func.call
        end
      end

      def default_day(default_day = nil, &block)
        if block_given?
          @default_day_func = block
        elsif default_day
          @default_day_func = lambda { default_day }
        else
          @default_day_func && @default_day_func.call
        end
      end

      def defaulted_day?
        instance_variable_defined?(:@default_day_func)
      end

      def default_month(default_month = nil, &block)
        if block_given?
          @default_month_func = block
        elsif default_month
          @default_month_func = lambda { default_month }
        else
          @default_month_func && @default_month_func.call
        end
      end

      def defaulted_month?
        instance_variable_defined?(:@default_month_func)
      end

      def default_year(default_year = nil, &block)
        if block_given?
          @default_year_func = block
        elsif default_year
          @default_year_func = lambda { default_year }
        else
          @default_year_func && @default_year_func.call
        end
      end

      def defaulted_year?
        instance_variable_defined?(:@default_year_func)
      end

      def range
        @range ||= @from_func.present? and @to_func.present? ? @from_func.call..@to_func.call : false
      end

      def parse_input(input)
        date = case input
               when Hash, ActiveSupport::HashWithIndifferentAccess
                 input = input.symbolize_keys
           expected_keys = []
           expected_keys << :day unless defaulted_day?
           expected_keys << :month unless defaulted_month?
           expected_keys << :year unless defaulted_year?
           expected_keys.each do |k|
             raise InvalidResponse, "Please enter a complete date", caller unless input[k].present?
           end
           day = (default_day || input[:day]).to_i
           month = (default_month || input[:month]).to_i
           year = (default_year || input[:year]).to_i
           ::Date.new(year, month, day)
               when String
                 ::Date.parse(input)
               when ::Date
                 input
               else
                 raise InvalidResponse, "Bad date", caller
          end
        validate_input(date) if @validate_in_range
        date
      rescue
        raise InvalidResponse, "Bad date: #{input.inspect}", caller
      end

      def to_response(input)
        date = parse_input(input)
        {
          day: date.day,
          month: date.month,
          year: date.year
        }
      rescue
        nil
      end

      def date_of_birth_defaults
        from { 122.years.ago.beginning_of_year.to_date }
        to { ::Date.today.end_of_year }
        validate_in_range
      end

    private

      def validate_input(date)
        return unless range

        min, max = [range.begin, range.end].sort
        if date < min || date > max
          raise InvalidResponse, "Provided date is out of range: #{date}", caller
        end
      end
    end
  end
end
