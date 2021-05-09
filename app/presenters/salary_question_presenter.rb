class SalaryQuestionPresenter < QuestionPresenter
  include SmartAnswer::FormattingHelper

  def response_label
    format_salary(SmartAnswer::Salary.new(response))
  end

  def amount
    return response unless response.is_a? Hash

    response[:amount]
  end

  def period
    return unless response.is_a? Hash

    response[:period]
  end
end
