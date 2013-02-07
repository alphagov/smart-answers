date_question :date_of_redundancy? do
  from { Date.civil(Date.today.year - 1,1,1) }
  to { Date.today }
  calculate :rate do
    if Date.parse(responses.last) < Date.new(2013,02,01)
      430
    else
      450
    end
  end
  calculate :max_amount do
    if Date.parse(responses.last) < Date.new(2013,02,01)
      "12,900"
    else
      "13,500"
    end
  end
  
  next_node :age_of_employee?
end

value_question :age_of_employee? do
  calculate :employee_age do
    age = responses.last.to_i
    raise InvalidResponse if age < 16 or age > 100
    age
  end
  calculate :years_available do
    employee_age - 15
  end
  next_node :years_employed?
end

# This needs validation - any string not representing a numeric value will be converted to 0.0 e.g. 'whatever'.to_f => 0.0
# Using Float(response) instead will fail with an ArgumentError that will be handled by the flow controller
value_question :years_employed? do
  save_input_as :years_employed
  calculate :years_employed do
    ye = Float(responses.last).floor
    raise InvalidResponse if ye.to_i > years_available
    ye
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
  calculate :calculator do
    Calculators::RedundancyCalculator.new(rate, employee_age, years_employed, responses.last)
  end
  calculate :statutory_redundancy_pay do
    calculator.format_money(calculator.pay.to_f)
  end
  calculate :number_of_weeks_entitlement do
    calculator.number_of_weeks_entitlement
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
