class SalaryQuestionPresenter < QuestionPresenter
  include SmartAnswer::FormattingHelper

  def response_label
    format_salary(SmartAnswer::Salary.new(response))
  end

  def amount
    return response_for_current_question unless response_for_current_question.is_a? Hash

    response_for_current_question[:amount]
  end

  def period
    return unless response_for_current_question.is_a? Hash

    response_for_current_question[:period]
  end
end
