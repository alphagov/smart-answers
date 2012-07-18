calculator = Calculators::RedundancyCalculator.new

multiple_choice :age_of_employee? do
  option "over-41"
  option "22-40"
  option "under-22"

  save_input_as :employee_age
  next_node :years_employed?
end

# This needs validation - any string not representing a numeric value will be converted to 0.0 e.g. 'whatever'.to_f => 0.0 
# Using Float(response) instead will fail with an ArgumentError that will be handled by the flow controller
value_question :years_employed? do
  save_input_as :years_employed
  calculate :years_employed do
    Float(responses.last).floor
  end
  next_node do |response|
    if Float(response).floor < 2
      :done_no_statutory
    else
      :weekly_pay_before_tax?
    end
  end
end

money_question :weekly_pay_before_tax? do
  calculate :statutory_redundancy_pay do
    calculator.format_money(calculator.pay(employee_age, years_employed, responses.last).to_f)
  end
  next_node do |response|
    if years_employed < 2
      :done_no_statutory
    else
      :done
    end
  end
end

outcome :done_no_statutory
outcome :done
