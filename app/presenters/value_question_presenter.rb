class ValueQuestionPresenter < QuestionPresenter
  include ActionView::Helpers::NumberHelper

  def response_label(value)
    number_with_delimiter(value)
  end

  def hint_text
    suffix_label.present? ? suffix_label : label
  end
end
