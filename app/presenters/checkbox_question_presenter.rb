class CheckboxQuestionPresenter < QuestionWithOptionsPresenter
  def response_labels(values)
    values.split(",").map do |value|
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

  def select_filter?
    @node.select_filter
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

private

  def checked?(value)
    response = current_response
    response = current_response.split(",") if current_response.is_a?(String)
    return false unless response.respond_to?(:include?)

    response.include?(value)
  end
end
