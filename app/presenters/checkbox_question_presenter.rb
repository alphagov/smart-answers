class CheckboxQuestionPresenter < QuestionWithOptionsPresenter
  def response_labels
    response.map do |value|
      if value == SmartAnswer::Question::Checkbox::NONE_OPTION
        "None"
      else
        option_attributes(value)[:label]
      end
    end
  end

  def multiple_responses?
    true
  end

  def checkboxes
    options.each_with_object([]) do |option, items|
      if option[:value] == "none"
        items << :or
      end

      items << {
        label: option[:label],
        value: option[:value],
        hint: option[:hint_text],
        checked: checked?(option[:value]),
        exclusive: option[:value] == "none" || nil,
      }
    end
  end

  def checked?(value)
    return false if response.blank?

    response.include?(value)
  end
end
