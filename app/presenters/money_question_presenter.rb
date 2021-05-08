class MoneyQuestionPresenter < QuestionPresenter
  include SmartAnswer::FormattingHelper

  def response_label
    format_money(SmartAnswer::Money.new(response))
  end
end
