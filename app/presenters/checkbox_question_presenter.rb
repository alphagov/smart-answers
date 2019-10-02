class CheckboxQuestionPresenter < QuestionWithOptionsPresenter
  include CurrentQuestionHelper

  def response_labels(values)
    values.split(",").map do |value|
      if value == SmartAnswer::Question::Checkbox::NONE_OPTION
        value.to_s
      else
        render_option(value)
      end
    end
  end

  def multiple_responses?
    true
  end

  def hint_text
    none_option_prefix.present? ? none_option_prefix : hint
  end

  def checkboxes
    checkboxes = []

    options.each do |option|
      checkboxes << {
        label: option.label,
        value: option.value,
        checked: prefill_value_includes?(self, option.value),
      }
    end

    if none_option_label.present?
      checkboxes << {
        label: none_option_label,
        value: "none",
        checked: prefill_value_is?("none"),
      }
    end

    checkboxes
  end

private

  def none_option_label
    @node.none_option_label
  end

  def none_option_prefix
    @node.none_option_prefix
  end
end
