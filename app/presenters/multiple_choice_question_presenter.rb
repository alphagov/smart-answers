class MultipleChoiceQuestionPresenter < QuestionWithOptionsPresenter
  include CurrentQuestionHelper

  def response_label(value)
    options.find { |option| option[:value] == value }[:label]
  end

  def radio_buttons(selected_value = nil)
    options.map do |option|
      {
        text: option[:label],
        value: option[:value],
        hint_text: option[:hint_text],
        checked: prefill_value_is?(option[:value], selected_value),
      }
    end
  end
end
