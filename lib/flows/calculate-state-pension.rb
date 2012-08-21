status :draft
section_slug "money-and-tax"
subsection_slug "pension"
satisfies_need "564"

multiple_choice :gender? do
  save_input_as :gender

  option :male
  option :female

  next_node :which_calculation?
end

multiple_choice :which_calculation? do
  save_input_as :calculate_age_or_amount
  
  option :age
  option :amount
  
  next_node do |response|
    response == "age" ? :dob_age? : :dob_amount?
  end
end

date_question :dob_age? do
  from { 100.years.ago }
  to { Date.today }

  calculate :state_pension_date do
    Calculators::StatePensionAmountCalculator.new(
      gender: gender, dob: responses.last, qualifying_years: nil
    ).state_pension_date.to_date.to_formatted_s(:long)
  end
  
  next_node :age_result
end

date_question :dob_amount? do
  from { 100.years.ago }
  to { Date.today }

  save_input_as :dob

  calculate :calculator do
    Calculators::StatePensionAmountCalculator.new(gender: gender, dob: dob)
  end

  calculate :state_pension_age do
    calculator.state_pension_age
  end

  next_node do |response|
    calc = Calculators::StatePensionAmountCalculator.new(
      gender: gender, dob: response)
    if calc.before_state_pension_date?
      if calc.under_20_years_old?
        :too_young
      else
        :years_paid_ni?
      end
    else
      :reached_state_pension_age
    end
  end
end

value_question :years_paid_ni? do
  save_input_as :ni_years

  calculate :calculator do
    ni_years = Integer(responses.last)
    raise InvalidResponse if ni_years < 0 or ni_years > 70 
    Calculators::StatePensionAmountCalculator.new(
      gender: gender, dob: dob, qualifying_years: ni_years)
  end

  calculate :state_pension_date do
    calculator.state_pension_date.to_date.to_formatted_s(:long)
  end

  calculate :pension_amount do
    sprintf("%.2f", calculator.what_you_get)
  end

  calculate :pension_loss do
    sprintf("%.2f", calculator.pension_loss)
  end

  next_node do |response|
    Integer(response) > 29 ? :amount_result : :years_of_jsa?
  end
end

value_question :years_of_jsa? do
  save_input_as :jsa_years

  calculate :calculator do
    jsa_years = Integer(responses.last)
    raise InvalidResponse if jsa_years < 0 or jsa_years > 70
    Calculators::StatePensionAmountCalculator.new(
      gender: gender, dob: dob, qualifying_years: (ni_years.to_i + jsa_years)
    )
  end
  
  calculate :state_pension_date do
    calculator.state_pension_date.to_date.to_formatted_s(:long)
  end

  calculate :pension_amount do
    sprintf("%.2f", calculator.what_you_get)
  end

  calculate :pension_loss do
    sprintf("%.2f", calculator.pension_loss)
  end

  next_node do |response|
    (ni_years.to_i + Integer(response)) > 29 ? :amount_result : :years_of_benefit?
  end
end

value_question :years_of_benefit? do
  save_input_as :benefit_years
  
  calculate :calculator do
    benefit_years = Integer(responses.last)
    raise InvalidResponse if benefit_years < 0 or benefit_years > 70
    Calculators::StatePensionAmountCalculator.new(
      gender: gender, dob: dob,
      qualifying_years: (ni_years.to_i + jsa_years.to_i + benefit_years)
    )
  end
  
  calculate :state_pension_date do
    calculator.state_pension_date.to_date.to_formatted_s(:long)
  end

  calculate :pension_amount do
    sprintf("%.2f", calculator.what_you_get)
  end

  calculate :pension_loss do
    sprintf("%.2f", calculator.pension_loss)
  end

  next_node do |response|
    if (ni_years.to_i + jsa_years.to_i + Integer(response)) > 29
      :amount_result
    else
      :years_of_work?
    end
  end
end

value_question :years_of_work? do
  save_input_as :work_years

  calculate :calculator do
    work_years = Integer(responses.last)
    raise InvalidResponse if work_years < 0 or work_years > 70
    y = ni_years.to_i + jsa_years.to_i + benefit_years.to_i + work_years
    Calculators::StatePensionAmountCalculator.new(
      gender: gender, dob: dob, qualifying_years: y)
  end
  
  calculate :state_pension_date do
    calculator.state_pension_date.to_date.to_formatted_s(:long)
  end

  calculate :pension_amount do
    sprintf("%.2f", calculator.what_you_get)
  end

  calculate :pension_loss do
    sprintf("%.2f", calculator.pension_loss)
  end

  next_node :amount_result
end

outcome :reached_state_pension_age
outcome :too_young
outcome :amount_result
outcome :age_result
