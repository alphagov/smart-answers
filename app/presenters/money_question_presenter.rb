class MoneyQuestionPresenter < QuestionPresenter
  include SmartAnswer::FormattingHelper

  def response_label(value)
    format_money(SmartAnswer::Money.new(value))
  end

  def hint_text
    text = [body, suffix_label].reject(&:blank?).compact.join(", ")
    ActionView::Base.full_sanitizer.sanitize(text)
  end
end
