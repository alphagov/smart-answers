status :draft
section_slug "money-and-tax"
subsection_slug "pension"
satisfies_need "99999"

multiple_choice :gender? do
  save_input_as :gender

  option :male
  option :female

  next_node :dob?
end

date_question :dob? do
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
    response.to_i > 29 ? :result : :years_of_jsa?
  end
end

value_question :years_of_jsa? do
  save_input_as :jsa_years

  calculate :calculator do
    Calculators::StatePensionAmountCalculator.new(
      gender: gender, dob: dob, qualifying_years: ni_years.to_i + jsa_years.to_i
    )
  end

  next_node do |response|
    ni_years.to_i + response.to_i > 29 ? :result : :years_of_benifit?
  end
end

value_question :years_of_benifit? do
  save_input_as :benifit_years

  calculate :calculator do
    Calculators::StatePensionAmountCalculator.new(
      gender: gender, dob: dob, 
      qualifying_years: ni_years.to_i + jsa_years.to_i + benifit_years.to_i)
  end

  next_node do |response|
    if ni_years.to_i + response.to_i + benifit_years.to_i > 29
      :result
    else
      :years_of_work?
    end
  end
end

value_question :years_of_work? do
  save_input_as :work_years

  calculate :calculator do
    y = ni_years.to_i + jsa_years.to_i + benifit_years.to_i + work_years.to_i
    Calculators::StatePensionAmountCalculator.new(
      gender: gender, dob: dob, qualifying_years: y)
  end

  next_node :result
end

outcome :reached_state_pension_age
outcome :too_young
outcome :result