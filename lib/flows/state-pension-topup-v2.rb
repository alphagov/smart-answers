status :draft
satisfies_need "100865"

data_query = Calculators::StatePensionTopupDataQueryV2.new()

#Q1
date_question :dob_age? do
  from { 110.years.ago }
  to { Date.today - 18.years }

  save_input_as :date_of_birth

  define_predicate(:age_limit_reached?) { |response| Date.parse(response) <= Date.parse('1914-10-12') }

  define_predicate(:age_not_yet_reached?) { |response| Date.parse(response) >= Date.parse('1953-04-07') }

  next_node_if(:outcome_age_limit_reached_birth, age_limit_reached?)
  next_node_if(:outcome_pension_age_not_reached, age_not_yet_reached?)
  next_node :gender?
end

#Q2
multiple_choice :gender? do
  option :male
  option :female

  save_input_as :gender

  calculate :upper_age do
    data_query.date_difference_in_years(Date.parse(date_of_birth), Date.parse('2017-04-01'))
  end

  calculate :lower_age do
    data_query.date_difference_in_years(Date.parse(date_of_birth), Date.parse('2015-10-12'))
  end

  define_predicate(:male_and_young_enough?) do |response|
    (response == "male") & (Date.parse(date_of_birth) >= Date.parse('1951-04-07'))
  end

  next_node_if(:outcome_pension_age_not_reached, male_and_young_enough?)
  next_node :how_much_extra_per_week?
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
    data_query.money_rate_cost(upper_age, weekly_amount)
  end

  calculate :lower_rate_cost do
    data_query.money_rate_cost(lower_age, weekly_amount)
  end

  define_predicate(:male_or_female_and_old_enough?) do |response|
    (gender == "male" && lower_age > 64) || (gender == "female" && lower_age > 62)
  end

  define_predicate(:older_than_101?) { upper_age > 101 }

  on_condition(male_or_female_and_old_enough?) do
    next_node_if(:top_up_calculations_upper_age, older_than_101?)
    next_node :top_up_calculations_both_ages
  end
  next_node :top_up_calculations_lower_age
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
