class MoneyQuestionPresenter < QuestionPresenter
  include SmartAnswer::FormattingHelper

  def response_label(value)
    format_money(SmartAnswer::Money.new(value))
  end
end
