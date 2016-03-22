class MultipleChoiceQuestionPresenter < QuestionPresenter
  def response_label(value)
    options.find { |option| option.value == value }.label
  end
end
