class SalaryQuestionPresenter < QuestionPresenter
  include SmartAnswer::FormattingHelper

  def response_label(value)
    format_salary(SmartAnswer::Salary.new(value))
  end

  def parsed_response
    return {} if current_response.blank?
    return current_response if current_response.is_a?(Hash)

    salary = @node.parse_input(current_response)
    {
      amount: salary.amount,
      period: salary.period,
    }
  rescue SmartAnswer::InvalidResponse
    {}
  end
end
