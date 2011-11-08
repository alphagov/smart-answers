class MoneyQuestionPresenter < QuestionPresenter
  def response_label(value)
    value_for_interpolation(value)
  end
end