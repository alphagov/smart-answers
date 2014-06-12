status :draft
satisfies_need "100865"

data_query = Calculators::StatePensionTopupDataQueryV2.new()

#Q1
date_question :dob_age? do
  from { 110.years.ago }
  to { Date.today - 15.years }

  save_input_as :date_of_birth

  next_node do |response|
    dob = Date.parse(response)
    if (dob <= Date.parse('1914-10-12'))
      :outcome_age_limit_reached_birth
    elsif (dob >= Date.parse('1953-04-07'))
      :outcome_pension_age_not_reached
    else
      :gender?
    end
  end
end

#Q2
multiple_choice :gender? do
  option :male
  option :female

  save_input_as :gender

  next_node do |response|

    dob = Date.parse(date_of_birth)
    if (response == "male") and (dob >= Date.parse('1951-04-07'))
      :outcome_pension_age_not_reached
    else
      :how_much_extra_per_week?
    end
  end
end

#Q3
money_question :how_much_extra_per_week? do
  save_input_as :weekly_amount

  calculate :integer_value do
    money = responses.last.to_f
    if (money % 1 != 0) or (money > 25 or money < 1)
      raise SmartAnswer::InvalidResponse
    end
  end

  calculate :weekly_amount do
    sprintf("%.00f", weekly_amount)
  end

  calculate :upper_age do
    upper_date = Date.parse('2017-04-17')
    dob = Date.parse(date_of_birth)
    years = upper_date.year - dob.year
    if (upper_date.month < dob.month) || ((upper_date.month == dob.month) && (upper_date.day < date_of_birth.day))
      years = years - 1
    end
    years
  end

  calculate :lower_age do
    lower_age = Date.parse('2015-10-12')
    dob = Date.parse(date_of_birth)
    years = lower_age.year - dob.year
    if (lower_age.month < dob.month) || ((lower_age.month == dob.month) && (lower_age.day < date_of_birth.day))
      years = years - 1
    end
    years
  end

  next_node :outcome_qualified_for_top_up_calculations
end

#A1
outcome :outcome_qualified_for_top_up_calculations do
  precalculate :upper_rate_cost do
    total = data_query.age_and_rates(upper_age) * weekly_amount.to_f
    total_money = SmartAnswer::Money.new(total)
  end
  precalculate :lower_rate_cost do
    total = data_query.age_and_rates(lower_age) * weekly_amount.to_f
    total_money = SmartAnswer::Money.new(total)
  end

  precalculate :age_phrases do
    phrases = PhraseList.new
    unless (gender == "male" and lower_age <= 64.years) or (gender == "female" and lower_age <= 62.years)
      phrases << :lower_age_phrase
    end
    unless upper_age >= 101.years
      phrases << :upper_age_phrase
    end
    phrases
  end
end

#A2
outcome :outcome_pension_age_not_reached
#A3
outcome :outcome_age_limit_reached_birth
#A4
outcome :outcome_age_limit_reached_payment
