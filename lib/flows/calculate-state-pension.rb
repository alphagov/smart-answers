status :draft
satisfies_need "564"

multiple_choice :which_calculation? do
  save_input_as :calculate_age_or_amount
  
  option :age
  option :amount

  next_node :gender?
end

multiple_choice :gender? do
  save_input_as :gender

  option :male
  option :female

  # optional text to include in a hint for a later question
  calculate :if_married_woman do
    if responses.last.eql? 'female'
      PhraseList.new(:married_woman_text)
    else
      ''
    end
  end

  next_node do
    calculate_age_or_amount == "age" ? :dob_age? : :dob_amount?
  end
end



date_question :dob_age? do
  from { 100.years.ago }
  to { Date.today }

  calculate :state_pension_date do
    Calculators::StatePensionAmountCalculator.new(
      gender: gender, dob: responses.last, qualifying_years: nil
    ).state_pension_date
  end
  
  calculate :formatted_state_pension_date do
    state_pension_date.to_date.to_formatted_s(:long)
  end
  
  calculate :tense_specific_title do
    if state_pension_date > Date.today
      PhraseList.new(:will_reach_pension_age) 
    else
      PhraseList.new(:have_reached_pension_age)
    end
  end
  
  calculate :already_elligible_text do
    state_pension_date <= Date.today ? PhraseList.new(:claim_pension_now_text) : ''
  end
  
  calculate :formatted_pension_pack_date do
    4.months.ago(state_pension_date).strftime("%B %Y")
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
  
  calculate :state_pension_date do
    calculator.state_pension_date.to_date
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

  calculate :formatted_state_pension_date do
    calculator.state_pension_date.to_date.to_formatted_s(:long)
  end

  calculate :pension_amount do
    sprintf("%.2f", calculator.what_you_get)
  end

  calculate :pension_loss do
    sprintf("%.2f", calculator.pension_loss)
  end
  
  calculate :pension_summary do
    if calculator.pension_loss > 0
      PhraseList.new(:this_is_n_below_the_full_state_pension)
    else
      PhraseList.new(:this_is_the_full_state_pension)
    end
  end
  
  calculate :contribution_callout_text do
    PhraseList.new :full_contribution_years_callout
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
  
  calculate :formatted_state_pension_date do
    calculator.state_pension_date.to_date.to_formatted_s(:long)
  end

  calculate :pension_amount do
    sprintf("%.2f", calculator.what_you_get)
  end

  calculate :pension_loss do
    sprintf("%.2f", calculator.pension_loss)
  end
  
  calculate :contribution_callout_text do
    PhraseList.new :full_contribution_years_callout
  end
  
  calculate :pension_summary do
    if calculator.pension_loss > 0
      PhraseList.new(:this_is_n_below_the_full_state_pension)
    else
      PhraseList.new(:this_is_the_full_state_pension)
    end
  end
  
  calculate :credited_benefit_years do
    (calculator.three_year_credit_age? ? 3 : 0)
  end

  next_node do |response|
    if (ni_years.to_i + Integer(response)) > 29
      :amount_result
    else 
      :years_of_benefit?
    end
  end
end

value_question :years_of_benefit? do
  save_input_as :benefit_years

  calculate :calculator do
    benefit_years = Integer(responses.last)
    credit_years = calculator.three_year_credit_age? ? 3 : 0
    
    raise InvalidResponse if benefit_years < 0 or benefit_years > 70
    Calculators::StatePensionAmountCalculator.new(
      gender: gender, dob: dob,
      qualifying_years: (ni_years.to_i + jsa_years.to_i + benefit_years + credit_years)
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
  
  calculate :remaining_contribution_years do
    remaining = (30 - calculator.qualifying_years)
    (remaining == 1 ? "#{remaining} year" : "#{remaining} years")   
  end
  
  calculate :contribution_callout_text do
    if calculator.qualifying_years > 29
      PhraseList.new :full_contribution_years_callout
    else
      PhraseList.new :remaining_contributions_years_callout
    end
  end
  
  calculate :pension_summary do
    if calculator.pension_loss > 0
      PhraseList.new(:this_is_n_below_the_full_state_pension)
    else
      PhraseList.new(:this_is_the_full_state_pension)
    end
  end

  next_node do |response|
    benefit_years = Integer(response)
    benefit_years += 3 if calculator.three_year_credit_age?
    if calculator.three_year_credit_age? or
      (ni_years.to_i + jsa_years.to_i + benefit_years) > 29
      :amount_result
    else
      :years_of_work?
    end
  end
end

value_question :years_of_work? do
  save_input_as :work_years
  
  calculate :credited_years do
    years = Integer(responses.last)
    credits = calculator.qualifying_years_credit
    case credits
      when 2 then years = credits unless years > 2
      when 1 then years = credits unless years > 0
    end
    years
  end

  calculate :calculator do
    work_years = Integer(responses.last)
    raise InvalidResponse if work_years < 0 or work_years > 3
    y = ni_years.to_i + jsa_years.to_i + benefit_years.to_i + credited_years
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
  
  calculate :remaining_contribution_years do
    remaining = (30 - calculator.qualifying_years)
    (remaining == 1 ? "#{remaining} year" : "#{remaining} years")   
  end
  
  calculate :contribution_callout_text do
    if (30 - calculator.qualifying_years) <= 0
      PhraseList.new :full_contribution_years_callout
    else
      PhraseList.new :remaining_contributions_years_callout
    end
  end
  
  calculate :pension_summary do
    if calculator.pension_loss > 0
      PhraseList.new(:this_is_n_below_the_full_state_pension)
    else
      PhraseList.new(:this_is_the_full_state_pension)
    end
  end

  next_node :amount_result
end

outcome :reached_state_pension_age
outcome :too_young
outcome :amount_result
outcome :age_result
