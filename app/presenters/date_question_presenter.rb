class DateQuestionPresenter < QuestionPresenter
  def response_label(value)
    I18n.localize(Date.parse(value), format: :long)
  end
end