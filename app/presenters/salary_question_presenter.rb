class SalaryQuestionPresenter < QuestionPresenter
  include ActionView::Helpers::NumberHelper

  def response_label(value)
    salary = SmartAnswer::Salary.new(value)
    number_to_currency(salary.amount, precision: 0) + " per " + salary.period
  end
end
