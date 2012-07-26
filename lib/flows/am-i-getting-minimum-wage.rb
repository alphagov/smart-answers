status :draft
section_slug "money-and-tax"
subsection_slug "tax"
satisfies_need "2013"

maximum_number_of_days_in_month = 31

# Q1
multiple_choice :what_would_you_like_to_check? do
  option "current_payment" => :are_you_an_apprentice?
  option "past_payment" => :past_payment_year?
  save_input_as :current_or_past_payments
end

# Q1A
multiple_choice :past_payment_year? do

  option "2011"
  option "2010"
  option "2009"
  option "2008"
  option "2007"
  option "2006"
  option "2005" 
  
  save_input_as :payment_year
  
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
end

# Q3
value_question :how_old_are_you? do  
  save_input_as :age
  next_node :how_often_do_you_get_paid?
end

# Q3 Past
value_question :how_old_were_you? do  
  save_input_as :age
  next_node :how_often_did_you_get_paid?
end

# Q4
value_question :how_often_do_you_get_paid? do 
  save_input_as :pay_frequency
  next_node :how_many_hours_do_you_work?
end

# Q4 Past
value_question :how_often_did_you_get_paid? do 
  save_input_as :pay_frequency
  next_node :how_many_hours_did_you_work?
end

# Q5
value_question :how_many_hours_do_you_work? do
  save_input_as :basic_hours
  next_node :how_much_are_you_paid_during_pay_period?
end

# Q5 Past
value_question :how_many_hours_did_you_work? do
  save_input_as :basic_hours
  next_node :how_much_were_you_paid_during_pay_period?
end

# Q6
value_question :how_much_are_you_paid_during_pay_period? do
  
  calculate :calculator do
    Calculators::MinimumWageCalculator.new({
      age: age.to_i, 
      basic_hours: basic_hours.to_f,
      basic_pay: responses.last.to_f,
      is_apprentice: (is_apprentice != 'no')
    }) 
  end
  
  next_node :how_many_hours_overtime_do_you_work?
end

# Q6 Past
value_question :how_much_were_you_paid_during_pay_period? do
  
  calculate :calculator do
    Calculators::MinimumWageCalculator.new({
      age: age.to_i,
      year: payment_year, 
      basic_hours: basic_hours.to_f,
      basic_pay: responses.last.to_f,
      is_apprentice: (is_apprentice != 'no')
    }) 
  end
  
  next_node :how_many_hours_overtime_did_you_work?
end

# Q7
value_question :how_many_hours_overtime_do_you_work? do
  
  calculate :overtime_hours do
    calculator.overtime_hours = responses.last.to_f
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
    calculator.overtime_hours = responses.last.to_f
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
value_question :what_is_overtime_pay_per_hour? do
  save_input_as :overtime_rate
  
  calculate :overtime_rate do
    calculator.overtime_hourly_rate = responses.last.to_f
  end
  
  next_node :is_provided_with_accommodation?
end

# Q8 Past
value_question :what_was_overtime_pay_per_hour? do
  save_input_as :overtime_rate
  
  calculate :overtime_rate do
    calculator.overtime_hourly_rate = responses.last.to_f
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
    calculator.above_minimum_wage?
  end
  
  next_node do |response|
    
    case response
      when "yes_free"
        :current_accommodation_usage?
      when "yes_charged"
        :current_accommodation_charge?
      else
        
        if calculator.above_minimum_wage?
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
    calculator.above_minimum_wage?
  end
  
  next_node do |response|
    
    case response
      when "yes_free"
        :past_accommodation_usage?
      when "yes_charged"
        :past_accommodation_charge?
      else
        
        if calculator.adjusted_total_underpayment >= 0
          :past_payment_above
        else
          :past_payment_below
        end
        
    end
  end
end

# Q10
value_question :current_accommodation_charge? do
  save_input_as :accommodation_charge
  next_node :current_accommodation_usage?
end

# Q10 Past
value_question :past_accommodation_charge? do
  save_input_as :accommodation_charge
  next_node :past_accommodation_usage?
end

# Q11
value_question :current_accommodation_usage? do
  
  calculate :calculator do
    calculator.accommodation_adjustment(accommodation_charge.to_f, responses.last.to_i)
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
    calculator.above_minimum_wage?
  end
  
  next_node do |response|
    
    if calculator.above_minimum_wage?
      :current_payment_above
    else
      :current_payment_below
    end
    
  end
end

# Q11 Past
value_question :past_accommodation_usage? do
  
  calculate :calculator do
    calculator.accommodation_adjustment(accommodation_charge.to_f, responses.last.to_i)
    calculator
  end
    
  calculate :total_hours do
    calculator.total_hours
  end
  
  calculate :minimum_hourly_rate do
    calculator.minimum_hourly_rate
  end
  
  calculate :above_minimum_wage do
    calculator.above_minimum_wage?
  end
  
  next_node do |response|
    
    if calculator.adjusted_total_underpayment >= 0
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
