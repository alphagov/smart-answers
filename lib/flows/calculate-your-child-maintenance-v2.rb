status :draft
satisfies_need "2548"

## Q1
  
multiple_choice :how_many_children_paid_for? do
  option "1_child"
  option "2_children"
  
  calculate :number_of_children do
    ## to_i will look for the first integer in the string
    responses.last.to_i
  end

  ## initial filtering: 4+ children -> 2012 scheme
  ## everyone else -> 2003 scheme
  calculate :maintenance_scheme do
    responses.last == '1_child' ? :old : :new
  end

  next_node do |response|
    maintenance_scheme = response.to_i > 1 ? :new : :old
    "gets_benefits_#{maintenance_scheme.to_s}?".to_sym
  end
end

## Q2
multiple_choice :gets_benefits_old? do
  save_input_as :benefits
  option "yes"
  option "no"

  calculate :calculator do
    Calculators::ChildMaintenanceCalculatorV2.new(number_of_children, maintenance_scheme, benefits)
  end
  
  next_node do |response|
    if response == 'yes'
      :how_many_nights_children_stay_with_payee?
    else
      :net_income_of_payee?
    end
  end
end

## Q2a
multiple_choice :gets_benefits_new? do
  save_input_as :benefits
  option "yes"
  option "no"

  calculate :calculator do
    Calculators::ChildMaintenanceCalculatorV2.new(number_of_children, maintenance_scheme, benefits)
  end
  
  next_node do |response|
    if response == 'yes'
      :how_many_nights_children_stay_with_payee?
    else
      :gross_income_of_payee?
    end
  end
end



## Q3
money_question :net_income_of_payee? do

  next_node do |response|
    calculator.income = response
    rate_type = calculator.rate_type
    if [:nil, :flat].include?(rate_type)
      "#{rate_type.to_s}_rate_result".to_sym
    else
      :how_many_other_children_in_payees_household?
    end
  end
end

## Q3a
money_question :gross_income_of_payee? do


  calculate :flat_rate_amount do
    calculator.base_amount
  end
  next_node do |response|
    calculator.income = response
    rate_type = calculator.rate_type
    if [:nil, :flat].include?(rate_type)
      "#{rate_type.to_s}_rate_result".to_sym
    else
      :how_many_other_children_in_payees_household?
    end
  end
end

## Q4
value_question :how_many_other_children_in_payees_household? do
  calculate :calculator do
    # if converting to int messes things up, raise invalid response
    # this deals with nil input through the API
    raise SmartAnswer::InvalidResponse if responses.last.to_i.to_s != responses.last
    calculator.number_of_other_children = responses.last.to_i
    calculator
  end
  next_node :how_many_nights_children_stay_with_payee?
end

## Q5
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
    calculator.number_of_shared_care_nights = response.to_i
    rate_type = calculator.rate_type
    if [:nil, :flat].include?(rate_type)
      "#{rate_type.to_s}_rate_result".to_sym
    else
      :reduced_and_basic_rates_result
    end
  end
end

outcome :nil_rate_result do
  precalculate :nil_rate_reason do
    if benefits == 'yes'
      PhraseList.new(:nil_rate_reason_benefits)
    else
      PhraseList.new(:nil_rate_reason_income)
    end
  end
end
outcome :flat_rate_result do
  precalculate :flat_rate_amount do
    calculator.base_amount
  end
end
outcome :reduced_and_basic_rates_result do
  precalculate :rate_type_formatted do
    rate_type = calculator.rate_type
    if rate_type.to_s == 'basic_plus'
      'basic plus'
    else
      rate_type.to_s
    end
  end
end
