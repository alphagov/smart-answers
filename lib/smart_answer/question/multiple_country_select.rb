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
        country_list
      end

      def country_list
        @country_list ||= WorldLocation.all
      end

      def parse_input(raw_input)
        return {} if raw_input.blank?
        return raw_input if raw_input.is_a?(Hash)
        return raw_input.as_json if raw_input.is_a?(ActionController::Parameters)

        parsed_input = {}
        raw_input.split("&").each do |selection|
          entry = selection.split("=")
          parsed_input[entry.first.to_i] = entry.last
        end
        parsed_input
      end
    end
  end
end
