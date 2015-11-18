# Q1
multiple_choice :what_would_you_like_to_check? do
  option "current_payment"
  option "past_payment"
  option "current_payment_april_2016" if self.flow_name == 'am-i-getting-minimum-wage'

  calculate :calculator do |response|
    Calculators::MinimumWageCalculator.new(what_to_check: response)
  end

  calculate :accommodation_charge do
    nil
  end

  permitted_next_nodes = [
    :are_you_an_apprentice?,
    :how_old_are_you?,
    :past_payment_date?
  ]

  next_node(permitted: permitted_next_nodes) do |response|
    case response
    when 'current_payment'
      :are_you_an_apprentice?
    when 'current_payment_april_2016'
      :how_old_are_you?
    when 'past_payment'
      :past_payment_date?
    end
  end
end

# Q1A
multiple_choice :past_payment_date? do
  option "2014-10-01"
  option "2013-10-01"
  option "2012-10-01"
  option "2011-10-01"
  option "2010-10-01"
  option "2009-10-01"
  option "2008-10-01"

  permitted_next_nodes = [:were_you_an_apprentice?]

  next_node(permitted: permitted_next_nodes) do |response|
    calculator.date = Date.parse(response)
    :were_you_an_apprentice?
  end
end

# Q2
multiple_choice :are_you_an_apprentice? do
  option "not_an_apprentice"
  option "apprentice_under_19"
  option "apprentice_over_19_first_year"
  option "apprentice_over_19_second_year_onwards"

  permitted_next_nodes = [
    :how_old_are_you?,
    :how_often_do_you_get_paid?
  ]

  next_node(permitted: permitted_next_nodes) do |response|
    case response
    when 'not_an_apprentice', 'apprentice_over_19_second_year_onwards'
      calculator.is_apprentice = false
      :how_old_are_you?
    when 'apprentice_under_19', 'apprentice_over_19_first_year'
      calculator.is_apprentice = true
      :how_often_do_you_get_paid?
    end
  end
end

# Q2 Past
multiple_choice :were_you_an_apprentice? do
  option "no"
  option "apprentice_under_19"
  option "apprentice_over_19"

  permitted_next_nodes = [
    :how_old_were_you?,
    :how_often_did_you_get_paid?,
    :does_not_apply_to_historical_apprentices
  ]

  next_node(permitted: permitted_next_nodes) do |response|
    case response
    when "no"
      calculator.is_apprentice = false
      :how_old_were_you?
    else
      calculator.is_apprentice = true
      if calculator.apprentice_eligible_for_minimum_wage?
        :how_often_did_you_get_paid?
      else
        :does_not_apply_to_historical_apprentices
      end
    end
  end
end

# Q3
value_question :how_old_are_you?, parse: Integer do
  precalculate :age_title do
    if calculator.what_to_check == 'current_payment_april_2016'
      PhraseList.new(:how_old_are_you_april_2016)
    else
      PhraseList.new(:how_old_are_you)
    end
  end

  validate do |response|
    calculator.valid_age?(response)
  end

  validate :valid_age_for_living_wage? do |response|
    if calculator.what_to_check == 'current_payment_april_2016'
      calculator.valid_age_for_living_wage?(response)
    else
      true
    end
  end

  permitted_next_nodes = [
    :under_school_leaving_age,
    :how_often_do_you_get_paid?
  ]

  next_node(permitted: permitted_next_nodes) do |response|
    calculator.age = response
    if calculator.under_school_leaving_age?
      :under_school_leaving_age
    else
      :how_often_do_you_get_paid?
    end
  end
end

# Q3 Past
value_question :how_old_were_you?, parse: Integer do
  validate do |response|
    calculator.valid_age?(response)
  end

  permitted_next_nodes = [
    :under_school_leaving_age_past,
    :how_often_did_you_get_paid?
  ]

  next_node(permitted: permitted_next_nodes) do |response|
    calculator.age = response
    if calculator.under_school_leaving_age?
      :under_school_leaving_age_past
    else
      :how_often_did_you_get_paid?
    end
  end
end

# Q4
value_question :how_often_do_you_get_paid?, parse: :to_i do
  validate do |response|
    calculator.valid_pay_frequency?(response)
  end

  permitted_next_nodes = [:how_many_hours_do_you_work?]

  next_node(permitted: permitted_next_nodes) do |response|
    calculator.pay_frequency = response
    :how_many_hours_do_you_work?
  end
end

# Q4 Past
value_question :how_often_did_you_get_paid?, parse: :to_i do
  validate do |response|
    calculator.valid_pay_frequency?(response)
  end

  permitted_next_nodes = [:how_many_hours_did_you_work?]

  next_node(permitted: permitted_next_nodes) do |response|
    calculator.pay_frequency = response
    :how_many_hours_did_you_work?
  end
end

# Q5
value_question :how_many_hours_do_you_work?, parse: Float do
  validate(:error_hours) do |response|
    calculator.valid_hours_worked?(response)
  end

  permitted_next_nodes = [:how_much_are_you_paid_during_pay_period?]

  next_node(permitted: permitted_next_nodes) do |response|
    calculator.basic_hours = response
    :how_much_are_you_paid_during_pay_period?
  end
end

# Q5 Past
value_question :how_many_hours_did_you_work?, parse: Float do
  validate(:error_hours) do |response|
    calculator.valid_hours_worked?(response)
  end

  permitted_next_nodes = [:how_much_were_you_paid_during_pay_period?]

  next_node(permitted: permitted_next_nodes) do |response|
    calculator.basic_hours = response
    :how_much_were_you_paid_during_pay_period?
  end
end

# Q6
money_question :how_much_are_you_paid_during_pay_period? do
  permitted_next_nodes = [:how_many_hours_overtime_do_you_work?]

  next_node(permitted: permitted_next_nodes) do |response|
    calculator.basic_pay = Float(response)
    :how_many_hours_overtime_do_you_work?
  end
end

# Q6 Past
money_question :how_much_were_you_paid_during_pay_period? do
  permitted_next_nodes = [:how_many_hours_overtime_did_you_work?]

  next_node(permitted: permitted_next_nodes) do |response|
    calculator.basic_pay = Float(response)
    :how_many_hours_overtime_did_you_work?
  end
end

# Q7
value_question :how_many_hours_overtime_do_you_work?, parse: Float do
  validate do |response|
    calculator.valid_overtime_hours_worked?(response)
  end

  permitted_next_nodes = [
    :what_is_overtime_pay_per_hour?,
    :is_provided_with_accommodation?
  ]

  next_node(permitted: permitted_next_nodes) do |response|
    calculator.overtime_hours = response
    if calculator.any_overtime_hours_worked?
      :what_is_overtime_pay_per_hour?
    else
      :is_provided_with_accommodation?
    end
  end
end

# Q7 Past
value_question :how_many_hours_overtime_did_you_work?, parse: Float do
  validate do |response|
    calculator.valid_overtime_hours_worked?(response)
  end

  permitted_next_nodes = [
    :what_was_overtime_pay_per_hour?,
    :was_provided_with_accommodation?
  ]

  next_node(permitted: permitted_next_nodes) do |response|
    calculator.overtime_hours = response
    if calculator.any_overtime_hours_worked?
      :what_was_overtime_pay_per_hour?
    else
      :was_provided_with_accommodation?
    end
  end
end

# Q8
money_question :what_is_overtime_pay_per_hour? do
  permitted_next_nodes = [:is_provided_with_accommodation?]

  next_node(permitted: permitted_next_nodes) do |response|
    calculator.overtime_hourly_rate = Float(response)
    :is_provided_with_accommodation?
  end
end

# Q8 Past
money_question :what_was_overtime_pay_per_hour? do
  permitted_next_nodes = [:was_provided_with_accommodation?]

  next_node(permitted: permitted_next_nodes) do |response|
    calculator.overtime_hourly_rate = Float(response)
    :was_provided_with_accommodation?
  end
end

# Q9
multiple_choice :is_provided_with_accommodation? do
  option "no"
  option "yes_free"
  option "yes_charged"

  permitted_next_nodes = [
    :current_accommodation_usage?,
    :current_accommodation_charge?,
    :current_payment_above,
    :current_payment_below
  ]

  next_node(permitted: permitted_next_nodes) do |response|
    case response
    when "yes_free"
      :current_accommodation_usage?
    when "yes_charged"
      :current_accommodation_charge?
    else
      if calculator.minimum_wage_or_above?
        :current_payment_above
      else
        :current_payment_below
      end
    end
  end
end

# Q9 Past
multiple_choice :was_provided_with_accommodation? do
  option "no"
  option "yes_free"
  option "yes_charged"

  permitted_next_nodes = [
    :past_accommodation_usage?,
    :past_accommodation_charge?,
    :past_payment_above,
    :past_payment_below
  ]

  next_node(permitted: permitted_next_nodes) do |response|
    case response
    when "yes_free"
      :past_accommodation_usage?
    when "yes_charged"
      :past_accommodation_charge?
    else
      if calculator.minimum_wage_or_above?
        :past_payment_above
      else
        :past_payment_below
      end
    end
  end
end

# Q10
money_question :current_accommodation_charge? do
  validate do |response|
    calculator.valid_accommodation_charge?(response)
  end

  next_node :current_accommodation_usage?

  save_input_as :accommodation_charge
end

# Q10 Past
money_question :past_accommodation_charge? do
  validate do |response|
    calculator.valid_accommodation_charge?(response)
  end

  next_node :past_accommodation_usage?

  save_input_as :accommodation_charge
end

# Q11
value_question :current_accommodation_usage?, parse: Integer do
  validate do |response|
    calculator.valid_accommodation_usage?(response)
  end

  permitted_next_nodes = [
    :current_payment_above,
    :current_payment_below
  ]

  next_node(permitted: permitted_next_nodes) do |response|
    calculator.accommodation_adjustment(accommodation_charge, response)
    if calculator.minimum_wage_or_above?
      :current_payment_above
    else
      :current_payment_below
    end
  end
end

# Q11 Past
value_question :past_accommodation_usage?, parse: Integer do
  validate do |response|
    calculator.valid_accommodation_usage?(response)
  end

  permitted_next_nodes = [
    :past_payment_above,
    :past_payment_below
  ]

  next_node(permitted: permitted_next_nodes) do |response|
    calculator.accommodation_adjustment(accommodation_charge, response)
    if calculator.historically_receiving_minimum_wage?
      :past_payment_above
    else
      :past_payment_below
    end
  end
end

outcome :current_payment_above
outcome :current_payment_below

outcome :past_payment_above
outcome :past_payment_below

outcome :under_school_leaving_age
outcome :does_not_apply_to_historical_apprentices
outcome :under_school_leaving_age_past
