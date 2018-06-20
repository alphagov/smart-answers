class CheckboxQuestionPresenter < QuestionWithOptionsPresenter
  def response_labels(values)
    values.split(',').map do |value|
      if value == SmartAnswer::Question::Checkbox::NONE_OPTION
        value.to_s
      else
        render_option(value)
      end
    end
  end

  def none_option_label
    @node.none_option_label
  end

  def none_option_prefix
    @node.none_option_prefix
  end

  def multiple_responses?
    true
  end
end
