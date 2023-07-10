module SmartAnswer
  module Question
    class Value < Base
      PRESENTER_CLASS = ValueQuestionPresenter

      def initialize(flow, name, options = {}, &block)
        @parse = options[:parse]
        super(flow, name, &block)
      end

      def parse_input(raw_input)
        if @parse == Integer
          begin
            Integer(raw_input)
          rescue TypeError, ArgumentError
            raise InvalidResponse
          end
        elsif @parse == :to_i
          raw_input.to_i
        elsif @parse == Float
          begin
            Float(raw_input)
          rescue TypeError, ArgumentError
            raise InvalidResponse
          end
        elsif @parse == :to_f
          raw_input.to_f
        else
          super
        end
      end
    end
  end
end
