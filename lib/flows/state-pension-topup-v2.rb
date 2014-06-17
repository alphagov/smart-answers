status :draft
satisfies_need "100865"

data_query = Calculators::StatePensionTopupDataQueryV2.new()

#Q1
date_question :dob_age? do
  from { 110.years.ago }
  to { Date.today - 18.years }

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

  calculate :upper_age do
    upper_date = Date.parse('2017-04-01')
    dob = Date.parse(date_of_birth)
    data_query.date_difference_in_years(dob,upper_date)
  end
  calculate :lower_age do
    lower_date = Date.parse('2015-10-12')
    dob = Date.parse(date_of_birth)
    data_query.date_difference_in_years(dob,lower_date)
  end

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
    sprintf("%.0f", weekly_amount)
  end

  calculate :body_phrase do
    PhraseList.new(:body_phrase)
  end

  calculate :upper_rate_cost do
    data_query.money_rate_cost(upper_age,weekly_amount)
  end
  calculate :lower_rate_cost do
    data_query.money_rate_cost(lower_age,weekly_amount)
  end

  next_node do
    if (gender=="male" and lower_age > 64) or (gender == "female" and lower_age > 62)
      if upper_age > 101
      :top_up_calculations_upper_age
      else
      :top_up_calculations_both_ages
      end
    else
      :top_up_calculations_lower_age
    end
  end
end

#A1-a
outcome :top_up_calculations_upper_age
#A1-b
outcome :top_up_calculations_lower_age
#A1-b
outcome :top_up_calculations_both_ages
#A2
outcome :outcome_pension_age_not_reached
#A3
outcome :outcome_age_limit_reached_birth