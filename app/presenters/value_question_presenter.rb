class ValueQuestionPresenter < QuestionPresenter
  include ActionView::Helpers::NumberHelper

  def response_label
    number_with_delimiter(response)
  end
end
