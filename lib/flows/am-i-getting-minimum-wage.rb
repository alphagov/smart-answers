status :published
satisfies_need "2013"

# Q1
multiple_choice :what_would_you_like_to_check? do
  option "current_payment" => :are_you_an_apprentice?
  option "past_payment" => :past_payment_date?
  save_input_as :current_or_past_payments
end

# Q1A
multiple_choice :past_payment_date? do

  year = 1.year.ago.year
  # Rate changes take place on 1st Oct.
  year -= 1 if Date.today.month < 10

  6.times do  
    option "#{year}-10-01"
    year -= 1
  end

  save_input_as :payment_date

  next_node :were_you_an_apprentice?
end

# Q2
multiple_choice :are_you_an_apprentice? do
  save_input_as :is_apprentice
  option "no" => :how_old_are_you?
  option "apprentice_under_19" => :how_often_do_you_get_paid?
  option "apprentice_over_19" => :how_often_do_you_get_paid?
end

# Q2 Past
multiple_choice :were_you_an_apprentice? do
  save_input_as :was_apprentice
  option "no" => :how_old_were_you?
  option "apprentice_under_19" => :how_often_did_you_get_paid?
  option "apprentice_over_19" => :how_often_did_you_get_paid?

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
value_question :how_old_are_you? do
  calculate :age do
    # Fail-hard cast to Integer here will raise
    # an exception and show the appropriate error.
    age = Integer(responses.last)
    if age <= 0
      raise SmartAnswer::InvalidResponse
    end
    age
  end
  next_node :how_often_do_you_get_paid?
end

# Q3 Past
value_question :how_old_were_you? do
  calculate :age do 
    # Fail-hard cast to Integer here will raise
    # an exception and show the appropriate error.
    age = Integer(responses.last)
    if age <= 0
      raise SmartAnswer::InvalidResponse
    end
    age  
  end
  next_node :how_often_did_you_get_paid?
end

# Q4
value_question :how_often_do_you_get_paid? do
  calculate :pay_frequency do
    pay_frequency = responses.last.to_i
    if pay_frequency < 1 or pay_frequency > 31
      raise SmartAnswer::InvalidResponse, "Please enter a valid number of days."
    end
    pay_frequency
  end
  next_node :how_many_hours_do_you_work?
end

# Q4 Past
value_question :how_often_did_you_get_paid? do
  calculate :pay_frequency do
    pay_frequency = responses.last.to_i
    if pay_frequency < 1 or pay_frequency > 31
      raise SmartAnswer::InvalidResponse, "Please enter a valid number of days."
    end
    pay_frequency
  end
  next_node :how_many_hours_did_you_work?
end

# Q5
value_question :how_many_hours_do_you_work? do
  calculate :basic_hours do 
    basic_hours = Float(responses.last)
    if basic_hours < 0 or basic_hours > (pay_frequency * 16)
      raise SmartAnswer::InvalidResponse
    end
    basic_hours
  end
  next_node :how_much_are_you_paid_during_pay_period?
end

# Q5 Past
value_question :how_many_hours_did_you_work? do
  calculate :basic_hours do 
    basic_hours = Float(responses.last)
    if basic_hours < 0 or basic_hours > (pay_frequency * 16)
      raise SmartAnswer::InvalidResponse
    end
    basic_hours
  end
  next_node :how_much_were_you_paid_during_pay_period?
end

# Q6
money_question :how_much_are_you_paid_during_pay_period? do

  calculate :calculator do
    amount_paid = Float(responses.last)
    if amount_paid < 0
      raise SmartAnswer::InvalidResponse
    end
    Calculators::MinimumWageCalculator.new({
      age: age.to_i,
      pay_frequency: pay_frequency,
      basic_hours: basic_hours,
      basic_pay: amount_paid,
      is_apprentice: (is_apprentice != 'no')
    })
  end

  next_node :how_many_hours_overtime_do_you_work?
end

# Q6 Past
money_question :how_much_were_you_paid_during_pay_period? do

  calculate :calculator do
    amount_paid = Float(responses.last)
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
value_question :how_many_hours_overtime_do_you_work? do

  calculate :overtime_hours do
    overtime_hours = Float(responses.last)
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
value_question :how_many_hours_overtime_did_you_work? do
  save_input_as :overtime_hours

  calculate :overtime_hours do
    overtime_hours = Float(responses.last)
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

  calculate :overtime_rate do
    overtime_hourly_rate = Float(responses.last)
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

  calculate :overtime_rate do
    overtime_hourly_rate = Float(responses.last)
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
  save_input_as :accommodation_charge

  calculate :accommodation_charge do
    accommodation_charge = Float(responses.last)
    if accommodation_charge <= 0
      raise SmartAnswer::InvalidResponse
    end
    accommodation_charge
  end
  next_node :current_accommodation_usage?
end

# Q10 Past
money_question :past_accommodation_charge? do
  save_input_as :accommodation_charge

  calculate :accommodation_charge do
    accommodation_charge = Float(responses.last)
    if accommodation_charge <= 0
      raise SmartAnswer::InvalidResponse
    end
    accommodation_charge
  end
  next_node :past_accommodation_usage?
end

# Q11
value_question :current_accommodation_usage? do

  calculate :calculator do
    days_per_week = Integer(responses.last)
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
value_question :past_accommodation_usage? do

  calculate :calculator do
    days_per_week = Integer(responses.last)
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
    calculator.accommodation_adjustment(accommodation_charge, Integer(response))
    
    if calculator.historical_adjustment <= 0
      :past_payment_above
    else
      :past_payment_below
    end

  end
end

outcome :current_payment_above
outcome :current_payment_below do
  precalculate :total_underpayment do
    calculator.format_money calculator.total_underpayment
  end
end
outcome :past_payment_above
outcome :past_payment_below do
  precalculate :total_underpayment do
    calculator.format_money calculator.historical_adjustment
  end
end
outcome :does_not_apply_to_historical_apprentices
