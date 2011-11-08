class MoneyQuestionPresenter < QuestionPresenter
  def response_label(value)
    value_for_interpolation(SmartAnswer::Money.new(value))
  end
end