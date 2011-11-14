class SalaryQuestionPresenter < QuestionPresenter
  def response_label(value)
    value_for_interpolation(SmartAnswer::Salary.new(value))
  end
end