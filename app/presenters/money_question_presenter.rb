class MoneyQuestionPresenter < QuestionPresenter
  include ActionView::Helpers::NumberHelper

  def response_label(value)
    money = SmartAnswer::Money.new(value)
    number_to_currency(money, precision: ((money.to_f == money.to_f.round) ? 0 : 2))
  end
end
