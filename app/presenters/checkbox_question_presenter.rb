class CheckboxQuestionPresenter < QuestionPresenter
  def response_labels(values)
    values.split(',').map do |value|
      if value == SmartAnswer::Question::Checkbox::NONE_OPTION
        value.to_s
      else
        translate_option(value)
      end
    end
  end

  def multiple_responses?
    true
  end
end
