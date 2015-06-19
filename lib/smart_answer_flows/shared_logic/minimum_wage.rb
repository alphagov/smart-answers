# Q1
multiple_choice :what_would_you_like_to_check? do
  option "current_payment" => :are_you_an_apprentice?
  option "past_payment" => :past_payment_date?
  save_input_as :current_or_past_payments
end

# Q1A
multiple_choice :past_payment_date? do

  option "2013-10-01"
  option "2012-10-01"
  option "2011-10-01"
  option "2010-10-01"
  option "2009-10-01"
  option "2008-10-01"

  save_input_as :payment_date

  next_node :were_you_an_apprentice?
end

# Q2
multiple_choice :are_you_an_apprentice? do
  save_input_as :is_apprentice
  option "not_an_apprentice" => :how_old_are_you?
  option "apprentice_under_19" => :how_often_do_you_get_paid?
  option "apprentice_over_19_first_year" => :how_often_do_you_get_paid?
  option "apprentice_over_19_second_year_onwards" => :how_old_are_you?
end

# Q2 Past
multiple_choice :were_you_an_apprentice? do
  save_input_as :was_apprentice
  option "no"
  option "apprentice_under_19"
  option "apprentice_over_19"

  next_node do |response|
    case response
    when "no"
      :how_old_were_you?
    else
      if Date.parse(payment_date) < Date.parse('2010-10-01')
        :does_not_apply_to_historical_apprentices
      else
        :how_often_did_you_get_paid?
      end
    end
  end
end

# Q3
value_question :how_old_are_you?, parse: Integer do
  calculate :age do |response|
    age = response
    if age <= 0 || age > 200
      raise SmartAnswer::InvalidResponse
    end
    age
  end
  next_node do |response|
    if response.to_i < 16
      :under_school_leaving_age
    else
      :how_often_do_you_get_paid?
    end
  end
end

# Q3 Past
value_question :how_old_were_you?, parse: Integer do
  calculate :age do |response|
    age = response
    if age <= 0
      raise SmartAnswer::InvalidResponse
    end
    age
  end

  next_node do |response|
    if response.to_i < 16
      :under_school_leaving_age_past
    else
      :how_often_did_you_get_paid?
    end
  end
end

# Q4
value_question :how_often_do_you_get_paid?, parse: :to_i do
  calculate :pay_frequency do |response|
    pay_frequency = response
    if pay_frequency < 1 or pay_frequency > 31
      raise SmartAnswer::InvalidResponse
    end
    pay_frequency
  end
  next_node :how_many_hours_do_you_work?
end

# Q4 Past
value_question :how_often_did_you_get_paid?, parse: :to_i do
  calculate :pay_frequency do |response|
    pay_frequency = response
    if pay_frequency < 1 or pay_frequency > 31
      raise SmartAnswer::InvalidResponse
    end
    pay_frequency
  end
  next_node :how_many_hours_did_you_work?
end

# Q5
value_question :how_many_hours_do_you_work?, parse: Float do
  calculate :basic_hours do |response|
    basic_hours = response
    if basic_hours < 0 or basic_hours > (pay_frequency * 16)
      raise SmartAnswer::InvalidResponse, :error_hours
    end
    basic_hours
  end
  next_node :how_much_are_you_paid_during_pay_period?
end

# Q5 Past
value_question :how_many_hours_did_you_work?, parse: Float do
  calculate :basic_hours do |response|
    basic_hours = response
    if basic_hours < 0 or basic_hours > (pay_frequency * 16)
      raise SmartAnswer::InvalidResponse, :error_hours
    end
    basic_hours
  end
  next_node :how_much_were_you_paid_during_pay_period?
end

# Q6
money_question :how_much_are_you_paid_during_pay_period? do

  calculate :calculator do |response|
    amount_paid = Float(response)
    if amount_paid < 0
      raise SmartAnswer::InvalidResponse
    end
    Calculators::MinimumWageCalculator.new({
      age: age.to_i,
      pay_frequency: pay_frequency,
      basic_hours: basic_hours,
      basic_pay: amount_paid,
      is_apprentice: (is_apprentice == 'apprentice_under_19' ||
                      is_apprentice == 'apprentice_over_19_first_year')
    })
  end

  next_node :how_many_hours_overtime_do_you_work?
end

# Q6 Past
money_question :how_much_were_you_paid_during_pay_period? do

  calculate :calculator do |response|
    amount_paid = Float(response)
    if amount_paid < 0
      raise SmartAnswer::InvalidResponse
    end
    Calculators::MinimumWageCalculator.new({
      age: age.to_i,
      date: Date.parse(payment_date),
      pay_frequency: pay_frequency,
      basic_hours: basic_hours,
      basic_pay: amount_paid,
      is_apprentice: (was_apprentice != 'no')
    })
  end

  next_node :how_many_hours_overtime_did_you_work?
end

# Q7
value_question :how_many_hours_overtime_do_you_work?, parse: Float do

  calculate :overtime_hours do |response|
    overtime_hours = response
    if overtime_hours < 0
      raise SmartAnswer::InvalidResponse
    end
    calculator.overtime_hours = overtime_hours
  end

  next_node do |response|
    if response.to_i == 0
      :is_provided_with_accommodation?
    else
      :what_is_overtime_pay_per_hour?
    end
  end
end

# Q7 Past
value_question :how_many_hours_overtime_did_you_work?, parse: Float do
  save_input_as :overtime_hours

  calculate :overtime_hours do |response|
    overtime_hours = response
    if overtime_hours < 0
      raise SmartAnswer::InvalidResponse
    end
    calculator.overtime_hours = overtime_hours
  end

  next_node do |response|
    if response.to_i == 0
      :was_provided_with_accommodation?
    else
      :what_was_overtime_pay_per_hour?
    end
  end
end

# Q8
money_question :what_is_overtime_pay_per_hour? do
  save_input_as :overtime_rate

  calculate :overtime_rate do |response|
    overtime_hourly_rate = Float(response)
    if overtime_hourly_rate < 0
      raise SmartAnswer::InvalidResponse
    end
    calculator.overtime_hourly_rate = overtime_hourly_rate
  end

  next_node :is_provided_with_accommodation?
end

# Q8 Past
money_question :what_was_overtime_pay_per_hour? do
  save_input_as :overtime_rate

  calculate :overtime_rate do |response|
    overtime_hourly_rate = Float(response)
    if overtime_hourly_rate < 0
      raise SmartAnswer::InvalidResponse
    end
    calculator.overtime_hourly_rate = overtime_hourly_rate
  end

  next_node :was_provided_with_accommodation?
end

# Q9
multiple_choice :is_provided_with_accommodation? do

  option "no"
  option "yes_free"
  option "yes_charged"

  calculate :accommodation_provided do |response|
    response != 'no'
  end

  calculate :total_hours do
    calculator.total_hours
  end

  calculate :minimum_hourly_rate do
    calculator.format_money calculator.minimum_hourly_rate
  end

  calculate :total_hourly_rate do
    calculator.format_money calculator.total_hourly_rate
  end

  calculate :above_minimum_wage do
    calculator.minimum_wage_or_above?
  end

  next_node do |response|

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

  calculate :accommodation_provided do |response|
    response != 'no'
  end

  calculate :total_hours do
    calculator.total_hours
  end

  calculate :minimum_hourly_rate do
    calculator.format_money calculator.minimum_hourly_rate
  end

  calculate :total_hourly_rate do
    calculator.format_money calculator.total_hourly_rate
  end

  calculate :above_minimum_wage do
    calculator.minimum_wage_or_above?
  end

  next_node do |response|

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
  calculate :accommodation_charge do |response|
    accommodation_charge = Float(response)
    if accommodation_charge <= 0
      raise SmartAnswer::InvalidResponse
    end
    accommodation_charge
  end
  next_node :current_accommodation_usage?
end

# Q10 Past
money_question :past_accommodation_charge? do
  calculate :accommodation_charge do |response|
    accommodation_charge = Float(response)
    if accommodation_charge <= 0
      raise SmartAnswer::InvalidResponse
    end
    accommodation_charge
  end
  next_node :past_accommodation_usage?
end

# Q11
value_question :current_accommodation_usage?, parse: Integer do

  save_input_as :accommodation_usage

  calculate :calculator do |response|
    days_per_week = response
    if days_per_week < 0 or days_per_week > 7
      raise SmartAnswer::InvalidResponse
    end
    calculator.accommodation_adjustment(accommodation_charge, days_per_week)
    calculator
  end

  calculate :total_hours do
    calculator.total_hours
  end

  calculate :minimum_hourly_rate do
    calculator.minimum_hourly_rate
  end

  calculate :total_hourly_rate do
    calculator.format_money calculator.total_hourly_rate
  end

  calculate :above_minimum_wage do
    calculator.minimum_wage_or_above?
  end

  next_node do |response|
    calculator.accommodation_adjustment(accommodation_charge, Integer(response))

    if calculator.minimum_wage_or_above?
      :current_payment_above
    else
      :current_payment_below
    end

  end
end

# Q11 Past
value_question :past_accommodation_usage?, parse: Integer do

  save_input_as :accommodation_usage

  calculate :calculator do |response|
    days_per_week = response
    if days_per_week < 0 or days_per_week > 7
      raise SmartAnswer::InvalidResponse
    end
    calculator.accommodation_adjustment(accommodation_charge, days_per_week)
    calculator
  end

  calculate :total_hours do
    calculator.total_hours
  end

  calculate :minimum_hourly_rate do
    calculator.format_money calculator.minimum_hourly_rate
  end

  calculate :above_minimum_wage do
    calculator.minimum_wage_or_above?
  end

  calculate :total_hourly_rate do
    calculator.format_money calculator.total_hourly_rate
  end

  calculate :historical_adjustment do
    calculator.historical_adjustment
  end

  next_node do |response|
    calculator.accommodation_adjustment(accommodation_charge, response)

    if calculator.historical_adjustment <= 0
      :past_payment_above
    else
      :past_payment_below
    end

  end
end

outcome :current_payment_above, use_outcome_templates: true do
  precalculate :total_working_pay do
    calculator.total_working_pay
  end
  precalculate :accommodation_charged do
    accommodation_charge and accommodation_charge > 0
  end
  precalculate :accommodation_rate do
    accommodation_charged ? accommodation_charge : calculator.free_accommodation_rate
  end
end

outcome :current_payment_below do
  precalculate :total_working_pay do
    calculator.total_working_pay
  end
  precalculate :accommodation_charged do
    accommodation_charge and accommodation_charge > 0
  end
  precalculate :accommodation_rate do
    accommodation_charged ? accommodation_charge : calculator.free_accommodation_rate
  end
  precalculate :total_underpayment do
    calculator.format_money calculator.total_underpayment
  end
end

outcome :past_payment_above do
  precalculate :total_working_pay do
    calculator.total_working_pay
  end
  precalculate :accommodation_charged do
    accommodation_charge and accommodation_charge > 0
  end
  precalculate :accommodation_rate do
    accommodation_charged ? accommodation_charge : calculator.free_accommodation_rate
  end
end

outcome :past_payment_below do
  precalculate :total_working_pay do
    calculator.total_working_pay
  end
  precalculate :accommodation_charged do
    accommodation_charge and accommodation_charge > 0
  end
  precalculate :accommodation_rate do
    accommodation_charged ? accommodation_charge : calculator.free_accommodation_rate
  end
  precalculate :total_underpayment do
    calculator.format_money calculator.historical_adjustment
  end
end

outcome :under_school_leaving_age
outcome :does_not_apply_to_historical_apprentices
outcome :under_school_leaving_age_past
