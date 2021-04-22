class SalaryQuestionPresenter < QuestionPresenter
  include SmartAnswer::FormattingHelper

  def response_label(value)
    format_salary(SmartAnswer::Salary.new(value))
  end

  def amount
    return if response_for_current_question.blank?

    response = to_response(response_for_current_question)
    response ? response[:amount] : response_for_current_question[:amount]
  end
end
