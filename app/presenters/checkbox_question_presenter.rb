class CheckboxQuestionPresenter < QuestionPresenter
  def response_labels(values)
    values.split(',').map do |value|
      translate_option(value)
    end
  end

  def multiple_responses?
    true
  end
end
