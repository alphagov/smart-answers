class MultipleChoiceQuestionPresenter < QuestionWithOptionsPresenter
  def response_label(value)
    options.find { |option| option.value == value }.label
  end
end
