class CheckboxQuestionPresenter < QuestionPresenter
  def response_label(values)
    values.split(',').map do |value|
      translate_option(value)
    end.join(', ')
  end
end
