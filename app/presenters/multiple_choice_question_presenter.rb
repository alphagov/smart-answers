class MultipleChoiceQuestionPresenter < QuestionWithOptionsPresenter
  def response_label(value)
    options.find { |option| option[:value] == value }[:label]
  end

  def radio_buttons
    options.map do |option|
      {
        text: option[:label],
        value: option[:value],
        hint_text: option[:hint_text],
        checked: selected?(option[:value]),
      }
    end
  end

  def selected?(value)
    return false if response_for_current_question.blank?

    value == response_for_current_question
  end
end
