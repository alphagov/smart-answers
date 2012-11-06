require 'date'

module SmartAnswer
  module Question
    class Date < Base
      def initialize(name, &block)
        super
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

      def range
        @range ||= @from_func.present? and @to_func.present? ? @from_func.call..@to_func.call : false
      end

      def parse_input(input)
        date = case input
        when Hash, ActiveSupport::HashWithIndifferentAccess
          input = input.symbolize_keys
          [:year, :month, :day].each do |k| 
            raise InvalidResponse, "Please enter a complete date", caller unless input[k].present?
          end
          ::Date.parse("#{input[:year]}-#{input[:month]}-#{input[:day]}")
        when String
          ::Date.parse(input)
        when ::Date
          input
        else
          raise InvalidResponse, "Bad date", caller
        end
        date.strftime('%Y-%m-%d')
      rescue
        raise InvalidResponse, "Bad date: #{input.inspect}", caller
      end

      def to_response(input)
        date = ::Date.parse(parse_input(input))
        {
          day: date.day,
          month: date.month,
          year: date.year
        }
      rescue
        nil
      end
    end
  end
end
