class ValueQuestionPresenter < QuestionPresenter
  include ActionView::Helpers::NumberHelper

  def response_label(value)
    number_with_delimiter(value)
  end
end
