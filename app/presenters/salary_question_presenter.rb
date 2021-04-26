class SalaryQuestionPresenter < QuestionPresenter
  include SmartAnswer::FormattingHelper

  def response_label(value)
    format_salary(SmartAnswer::Salary.new(value))
  end

  def amount
    return if response_for_current_question.blank?

    response_for_current_question[:amount]
  end

  def period
    return if response_for_current_question.blank?

    response_for_current_question[:period]
  end
end
