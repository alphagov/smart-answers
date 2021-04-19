class CheckboxQuestionPresenter < QuestionWithOptionsPresenter
  include CurrentQuestionHelper

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

  def hint_text
    hint
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
        checked: prefill_value_includes?(self, option[:value]),
        exclusive: option[:value] == "none" || nil,
      }
    end
  end

  def checked?(value)
    response = response_for_current_question

    if response_for_current_question.is_a?(String)
      response = to_response(response_for_current_question)
    end

    response.include?(value)

    # If the response is an array
    # response_for_current_question.include?(value)

    # if the response is a string
    # >> response_for_current_question
    # => "nightclubs_or_adult_entertainment,nurseries,retail_hospitality_or_leisure"

    # >> to_response(response_for_current_question)
    # => ["nightclubs_or_adult_entertainment", "nurseries", "retail_hospitality_or_leisure"]
  end
end
