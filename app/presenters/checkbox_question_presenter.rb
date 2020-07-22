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
    options.map do |option|
      {
        label: option[:label],
        value: option[:value],
        hint: option[:hint_text],
        checked: prefill_value_includes?(self, option[:value]),
        exclusive: option[:value] == "none" || nil,
      }
    end
  end
end
