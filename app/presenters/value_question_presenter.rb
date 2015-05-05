class ValueQuestionPresenter < QuestionPresenter
  def response_label(value)
    number_with_delimiter(value)
  end
end
