class ValueQuestionPresenter < QuestionPresenter
  include ActionView::Helpers::NumberHelper

  def response_label(value)
    number_with_delimiter(value)
  end

  def hint_text
    text = [body, hint].reject(&:blank?).compact.join(", ")
    ActionView::Base.full_sanitizer.sanitize(text)
  end
end
