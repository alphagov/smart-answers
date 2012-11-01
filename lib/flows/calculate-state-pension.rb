status :published
satisfies_need "564"

# Q1
multiple_choice :which_calculation? do
  save_input_as :calculate_age_or_amount
  
  option :age     
  option :amount

  next_node :gender?
end

# Q2
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


# Q3:Age
date_question :dob_age? do
  from { 100.years.ago }
  to { Date.today }

  save_input_as :dob

  calculate :calculator do
    Calculators::StatePensionAmountCalculator.new(
      gender: gender, dob: dob, qualifying_years: nil
    )
  end

  calculate :state_pension_date do
    calculator.state_pension_date
  end

  calculate :pension_credit_date do
    calculator.state_pension_date(:female).strftime("%e %B %Y")
  end
  
  #TODO: refactor this so text lives in .yml file
  calculate :pension_credit_statement do
    if calculator.state_pension_date(:female) > Date.today
      "You may be entitled to receive Pension Credit from " + pension_credit_date + "."
    else
      "You may have been entitled to receive Pension Credit from " + pension_credit_date + "."
    end
  end

  #TODO: refactor this so text lives in .yml file
  calculate :bus_pass_statement do
    if calculator.state_pension_date(:female) > Date.today
      "You may qualify for an [elderly person’s bus pass](/apply-for-elderly-person-bus-pass) from " + pension_credit_date + "."
    else
      "You may have qualified for an [elderly person’s bus pass](/apply-for-elderly-person-bus-pass) from" + pension_credit_date + "."
    end
  end

  calculate :formatted_state_pension_date do
    state_pension_date.strftime("%e %B %Y")
  end
  
  calculate :tense_specific_title do
    if state_pension_date > Date.today
      PhraseList.new(:will_reach_pension_age) 
    else
      PhraseList.new(:have_reached_pension_age)
    end
  end
  
  calculate :formatted_pension_pack_date do
    4.months.ago(state_pension_date).strftime("%B %Y")
  end

  calculate :state_pension_age do
    calculator.state_pension_age
  end

  
  calculate :state_pension_age_statement do
    if state_pension_date > Date.today
      PhraseList.new(:state_pension_age_is)
    else
      PhraseList.new(:state_pension_age_was)
    end
  end
  
  next_node do |response|
    calc = Calculators::StatePensionAmountCalculator.new(
      gender: gender, dob: response)
    if (calc.before_state_pension_date? and calc.within_four_months_four_days_from_state_pension?)
      :near_state_pension_age
    else
      :age_result
    end
  end
end

# Q3:Amount
date_question :dob_amount? do
  from { 100.years.ago }
  to { Date.today }

  calculate :dob do
    responses.last
  end

  calculate :calculator do
    Calculators::StatePensionAmountCalculator.new(gender: gender, dob: dob)
  end

  calculate :state_pension_age do
    calculator.state_pension_age
  end
  
  calculate :state_pension_date do
    calculator.state_pension_date.to_date
  end

  calculate :formatted_state_pension_date do
    state_pension_date.strftime("%e %B %Y")
  end

  calculate :remaining_years do
    calculator.years_to_pension
  end


  calculate :available_ni_years do
    calculator.available_years
  end


  next_node do |response|
    calc = Calculators::StatePensionAmountCalculator.new(
      gender: gender, dob: response)
    if calc.before_state_pension_date?
      (calc.under_20_years_old? ? :too_young : (calc.within_four_months_four_days_from_state_pension? ? :near_state_pension_age : :years_paid_ni?) )
    else
      :reached_state_pension_age
    end
  end
end

# Q4
value_question :years_paid_ni? do
  # part of a hint for questions 4, 7 and 9 that should only be displayed for women born before 1962
  precalculate :carer_hint_for_women do
    if gender == 'female' and (Date.parse(dob) < Date.parse('1962-01-01'))
      PhraseList.new(:carers_allowance_women_hint)
    else
      ''
    end
  end

  calculate :carer_hint_for_women_q9 do
    if gender == 'female' and (Date.parse(dob) < Date.parse('1962-01-01'))
      PhraseList.new(:carers_allowance_women_hint_q9)
    else
      ''
    end
  end


  calculate :qualifying_years do
    ni_years = Integer(responses.last)
    raise InvalidResponse if ni_years < 0 or ni_years > available_ni_years 
    ni_years
  end

  calculate :available_ni_years do
    calculator.available_years_sum(qualifying_years) 
  end

  next_node do |response|
    ni = Integer(response)
    if calculator.enough_qualifying_years?(ni)
      :amount_result
    else
      if calculator.no_more_available_years?(ni)
        if calculator.three_year_credit_age?
          :amount_result
        else
          :years_of_work? # Q10
        end
      else
        :years_of_jsa? # Q5
      end
    end
  end
end

# Q5
value_question :years_of_jsa? do
  calculate :qualifying_years do
    jsa_years = Integer(responses.last)
    qy = (qualifying_years + jsa_years)
    raise InvalidResponse if jsa_years < 0 or !(calculator.has_available_years?(qy)) #jsa_years > available_ni_years #70
    qy
  end

  calculate :available_ni_years do
    calculator.available_years_sum(qualifying_years) 
  end

  calculate :calc do 
    calc = Calculators::StatePensionAmountCalculator.new(
    gender: gender, dob: dob, qualifying_years: qualifying_years )
  end

  next_node do |response|
    ni = Integer(response) + qualifying_years
    if calculator.enough_qualifying_years?(ni)
      :amount_result
    else 
      if calculator.no_more_available_years?(ni)
        if calculator.three_year_credit_age?
          :amount_result
        else
          :years_of_work? # Q10
        end
      else
        :received_child_benefit? # Q6
      end
    end
  end
end

## Q5a - removed for initial release
# multiple_choice :employed_between_60_and_64? do
#   save_input_as :employed_between_60_and_64_yes_no

#   option :yes 
#   option :no 

#   calculate :automatic_years do
#     employed_between_60_and_64_yes_no == "no" ? calc.allocate_automatic_years : 0
#   end

#   calculate :qualifying_years do
#     (qualifying_years + calc.allocate_automatic_years)
#   end

#   calculate :available_ni_years do
#     calculator.available_years_sum(qualifying_years) 
#   end

#   next_node do |response|
#     if response == "yes"
#       :received_child_benefit?
#     else
#       (((calc.allocate_automatic_years + calc.qualifying_years) >= 30) ? :amount_result : :received_child_benefit?)
#     end
#   end
# end

## Q6
multiple_choice :received_child_benefit? do
  
  option :yes 
  option :no 

  next_node do |response|
    if response == "yes"
      :years_of_benefit?
    else 
      ((Date.parse(dob) >= Date.parse("1959-04-06") and Date.parse(dob) <= Date.parse("1992-04-05")) ? :amount_result : :years_of_work?) 
    end
  end
end

## Q7
value_question :years_of_benefit? do

  precalculate :years_you_can_enter do
    calculator.years_can_be_entered(available_ni_years,22)
  end

  calculate :qualifying_years do
    benefit_years = Integer(responses.last)
    qy = (benefit_years + qualifying_years)
    raise InvalidResponse if (benefit_years < 0 or benefit_years > 22) or !(calculator.has_available_years?(qy))
    qy
  end

  calculate :available_ni_years do
    calculator.available_years_sum(qualifying_years) 
  end

  next_node do |response|
    benefit_years = Integer(response)
    ni = (qualifying_years + benefit_years)
    if calculator.enough_qualifying_years?(ni)
      :amount_result    
    else
      if calculator.no_more_available_years?(ni)
        if calculator.three_year_credit_age?
          :amount_result
        else
          :years_of_work? # Q10
        end
      else
        :years_of_caring? # Q8
      end
    end
  end
end

## Q8
value_question :years_of_caring? do
  save_input_as :caring_years
  
  precalculate :allowed_caring_years do
    today = Date.today
    ((today.month > 4 ? today.year : today.year - 1) - 2010)
  end

  precalculate :years_you_can_enter do
    calculator.years_can_be_entered(available_ni_years,allowed_caring_years)
  end

  calculate :qualifying_years do
    caring_years = Integer(responses.last)
    qy = (caring_years + qualifying_years)
    today = Date.today
    raise InvalidResponse if (caring_years < 0 or caring_years > ((today.month > 4 ? today.year : today.year - 1) - 2010)) or !(calculator.has_available_years?(qy))
    qy
  end

  calculate :available_ni_years do
    calculator.available_years_sum(qualifying_years) 
  end

  next_node do |response|
    caring_years = Integer(response)
    ni = (qualifying_years + caring_years)
    if calculator.enough_qualifying_years?(ni)
      :amount_result    
    else
      if calculator.no_more_available_years?(ni)
        if calculator.three_year_credit_age?
          :amount_result
        else
          :years_of_work? # Q10
        end
      else
        :years_of_carers_allowance? # Q9
      end
    end
  end
end

## Q9
value_question :years_of_carers_allowance? do
  calculate :qualifying_years do
    caring_years = Integer(responses.last)
    qy = (caring_years + qualifying_years)
    raise InvalidResponse if caring_years < 0 or !(calculator.has_available_years?(qy)) #caring_years > 70
    qy
  end

  next_node do |response|
    caring_years = Integer(response)
    ni = (qualifying_years + caring_years) 
    if calculator.enough_qualifying_years?(ni)
      :amount_result    
    else
      calculator.three_year_credit_age? ? :amount_result : :years_of_work?
    end
  end
end


## Q10
value_question :years_of_work? do
  
  precalculate :years_you_can_enter do
    calculator.years_can_be_entered(available_ni_years,3)
  end

  save_input_as :years_of_work_entered

  calculate :qualifying_years do
    work_years = Integer(responses.last)
    qy = (work_years + qualifying_years)
    raise InvalidResponse if (work_years < 0 or work_years > 3) 
    qy
  end

  next_node :amount_result

end

outcome :near_state_pension_age
outcome :reached_state_pension_age
outcome :too_young 
outcome :age_result

outcome :amount_result do
  precalculate :calc do
    Calculators::StatePensionAmountCalculator.new(
      gender: gender, dob: dob, qualifying_years: (qualifying_years)
    )
  end

  precalculate :qualifying_years_total do
    if calc.three_year_credit_age? 
      qualifying_years + 3
    else 
      qualifying_years + calc.calc_qualifying_years_credit(years_of_work_entered.to_i)
    end
  end

  precalculate :missing_years do
    (qualifying_years_total < 30 ? (30 - qualifying_years_total) : 0)
  end
  
  precalculate :calculator do
    Calculators::StatePensionAmountCalculator.new(
      gender: gender, dob: dob, qualifying_years: (qualifying_years_total)
    )
  end

  precalculate :formatted_state_pension_date do
    calculator.state_pension_date.strftime("%e %B %Y")
  end

  calculate :state_pension_date do
    calculator.state_pension_date
  end

  precalculate :pension_amount do
    sprintf("%.2f", calculator.what_you_get)
  end

  precalculate :pension_loss do
    sprintf("%.2f", calculator.pension_loss)
  end

  precalculate :what_if_not_full do
    sprintf("%.2f", calculator.what_you_would_get_if_not_full)
  end
  
  precalculate :pension_summary do
    if calculator.pension_loss > 0
      PhraseList.new(:this_is_n_below_the_full_state_pension)
    else
      PhraseList.new(:this_is_the_full_state_pension)
    end
  end
  
  precalculate :credited_benefit_years do
    (calculator.three_year_credit_age? ? 3 : 0)
  end


  precalculate :result_text do
    if qualifying_years_total < 30
      if remaining_years >= missing_years
        text = PhraseList.new :too_few_qy_enough_remaining_years
        if ( Date.parse(dob) < Date.parse("6th October 1953") and (gender == "male") )
          text << :automatic_years_phrase
        end
        text
      else
        text = PhraseList.new :too_few_qy_not_enough_remaining_years
        if ( Date.parse(dob) < Date.parse("6th October 1953") and (gender == "male") )
          text << :automatic_years_phrase
        end
        text
      end
    else
      PhraseList.new :you_get_full_state_pension
    end
  end
end
