class SalaryQuestionPresenter < QuestionPresenter
  include SmartAnswer::FormattingHelper

  def response_label(value)
    format_salary(SmartAnswer::Salary.new(value))
  end
end
