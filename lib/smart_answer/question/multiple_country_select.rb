module SmartAnswer
  module Question
    class MultipleCountrySelect < Base
      PRESENTER_CLASS = MultipleCountrySelectQuestionPresenter

      attr_accessor :select_count

      def initialize(flow, name, _options = {}, &block)
        @select_count = 1
        super(flow, name, &block)
      end

      def options
        @options ||= WorldLocation.all
      end

      def parse_input(raw_input)
        return raw_input.values.join("|").gsub("/", "§") if raw_input.is_a?(ActiveSupport::HashWithIndifferentAccess)
        return raw_input if raw_input.is_a?(String)
      end
    end
  end
end
