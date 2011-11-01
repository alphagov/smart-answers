require 'date'

module SmartAnswer
  module Question
    class Date < Base
      def initialize(name, &block)
        super
      end

      def from(from = nil, &block)
        @from_func = block_given? ? block : lambda { from }
      end

      def to(to = nil, &block)
        @to_func = block_given? ? block : lambda { to }
      end
      
      def range
        @from_func.call..@to_func.call
      end
      
      def transition(current_state, input)
        super(current_state, parse_date_input(input))
      end
      
      private
        def parse_date_input(input)
          date = case input
          when Hash, ActiveSupport::HashWithIndifferentAccess
            input = input.symbolize_keys
            ::Date.parse("#{input[:year]}-#{input[:month]}-#{input[:day]}")
          when String
            ::Date.parse(input)
          when Date
            input
          else
            raise "Bad date input #{input}"
          end
          date.strftime('%Y-%m-%d')
        end
    end
  end
end