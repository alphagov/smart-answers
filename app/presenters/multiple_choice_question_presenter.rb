class MultipleChoiceQuestionPresenter < QuestionWithOptionsPresenter
  def response_label
    options.find { |option| option[:value] == response }[:label]
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
    return false if response.blank?

    value == response
  end
end
