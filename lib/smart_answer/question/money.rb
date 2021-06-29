module SmartAnswer
  module Question
    class Money < Base
      PRESENTER_CLASS = MoneyQuestionPresenter

      def parse_input(raw_input)
        SmartAnswer::Money.new(raw_input)
      end
    end
  end
end
