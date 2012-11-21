status :draft
satisfies_need "2548"

## Q1
multiple_choice :how_many_children_paid_for? do
  option "1_child"
  option "2_children"
  option "3_children"
  option "4_same_parent"
  option "4_different_parents"

  calculate :number_of_children do
    ## to_i will look for the first integer in the string
    responses.last.to_i
  end

  ## initial filtering: 4 children from same parent -> 2012 scheme
  ## everyone else -> 2003 scheme
  calculate :maintenance_scheme do
    responses.last == '4_same_parent' ? :new : :old
  end

  next_node :gets_benefits?
end

## Q2
multiple_choice :gets_benefits? do
  save_input_as :benefits
  option "yes"
  option "no"

  calculate :calculator do
    Calculators::ChildMaintenanceCalculator.new(number_of_children, maintenance_scheme, benefits)
  end
  
  next_node do |response|
    if response == 'yes'
      :how_many_nights_children_stay_with_payee?
    else
      maintenance_scheme == :new ? :gross_income_of_payee? : :net_income_of_payee?
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
    calculator.number_of_other_children = Integer(responses.last)
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
