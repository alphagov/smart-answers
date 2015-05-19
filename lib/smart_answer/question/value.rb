module SmartAnswer
  module Question
    class Value < Base
      def initialize(name, options = {}, &block)
        @parse = options[:parse]
        super
      end

      def parse_input(raw_input)
        if Integer == @parse
          Integer(without_commas(raw_input))
        elsif :to_i == @parse
          without_commas(raw_input).to_i
        elsif Float == @parse
          Float(without_commas(raw_input))
        elsif :to_f == @parse
          without_commas(raw_input).to_f
        else
          super
        end
      end

      private

      def without_commas(raw_input)
        raw_input.delete(',')
      end
    end
  end
end
