status :draft
satisfies_need "2548"

## Q1
value_question :how_many_children_paid_for? do
  calculate :calculator do
    Calculators::ChildMaintenanceCalculator.new(responses.last)
  end
  next_node do |response|
    number_of_children = response.to_i
    if number_of_children == 0
      raise SmartAnswer::InvalidResponse
    # Hide the 2012 scheme questions until next iteration
    #elsif number_of_children > 3
    #  :gross_income_of_payee?
    else 
      :net_income_of_payee?
    end
  end
end

## Q2
money_question :net_income_of_payee? do
  calculate :flat_rate_amount do
    calculator.base_amount
  end
  next_node do |response|
    calculator.net_income = response
    rate_type = calculator.rate_type
    if [:nil, :flat].include?(rate_type)
      "#{rate_type.to_s}_rate_result".to_sym
    else
      :how_many_other_children_in_payees_household?
    end
  end
end

## Q2a
money_question :gross_income_of_payee? do
  calculate :flat_rate_amount do
    calculator.base_amount
  end
  next_node do |response|
    calculator.net_income = response
    rate_type = calculator.rate_type
    if [:nil, :flat].include?(rate_type)
      "#{rate_type.to_s}_rate_result".to_sym
    else
      :how_many_other_children_in_payees_household?
    end
  end
end

## Q3
value_question :how_many_other_children_in_payees_household? do
  calculate :calculator do
    calculator.number_of_other_children = Integer(responses.last)
    calculator
  end
  next_node :how_many_nights_children_stay_with_payee?
end

## Q4
multiple_choice :how_many_nights_children_stay_with_payee? do
  option 0
  option 1
  option 2
  option 3
  option 4
  calculate :child_maintenance_payment do
    calculator.number_of_shared_care_nights = responses.last.to_i
    sprintf("%.0f", calculator.calculate_maintenance_payment)
  end
  next_node do |response|
    :reduced_and_basic_rates_result
  end
end

outcome :nil_rate_result
outcome :flat_rate_result
outcome :reduced_and_basic_rates_result
