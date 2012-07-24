status :draft
section_slug "money-and-tax"
subsection_slug "tax"
satisfies_need "2013"

maximum_number_of_days_in_month = 31
calculator = Calculators::MinimumWageCalculator.new

# Q1
multiple_choice :what_would_you_like_to_check? do
  option "current_payment" => :are_you_an_apprentice?
  option "past_payment" => :past_payment_year?
  save_input_as :current_or_past_payments
end

# Q1A
value_question :past_payment_year? do
  save_input_as :payment_year
  next_node :are_you_an_apprentice?
end

# Q2
multiple_choice :are_you_an_apprentice? do
  save_input_as :is_apprentice
  option "no" => :how_old_are_you?
  option "apprentice_under_19" => :pay_frequency?
  option "apprentice_over_19" => :pay_frequency?
end

# Q3
value_question :how_old_are_you? do  
  save_input_as :age
  next_node :pay_frequency?
end

# Q4
value_question :pay_frequency? do 
  calculate :pay_frequency do
    if responses.last.to_i > maximum_number_of_days_in_month
      raise SmartAnswer::InvalidResponse, "Please enter a number from 1 to 31"
    end
    responses.last.to_i
  end
  next_node :hours_worked_during_the_pay_period?
end

# Q5
value_question :hours_worked_during_the_pay_period? do
  save_input_as :basic_hours
  next_node :quantity_paid_during_pay_period?
end

# Q6
value_question :quantity_paid_during_pay_period? do
  save_input_as :total_basic_pay
  
  calculate :basic_hourly_rate do
    (responses.last.to_f / basic_hours.to_f).round(2)  
  end
  
  next_node :hours_overtime_during_pay_period?
end

# Q7
value_question :hours_overtime_during_pay_period? do
  save_input_as :overtime_hours
  
  calculate :total_hours do
    (basic_hours.to_f + responses.last.to_f).round(2)  
  end
  
  calculate :historical_entitlement do
    if is_apprentice == 'no'
      rate = calculator.per_hour_minimum_wage(age.to_i, payment_year)
    else
      rate = calculator.apprentice_rate(payment_year)
    end
    (rate * total_hours).round(2)
  end
  
  next_node do |response|
    if response.to_i == 0
      :provided_with_accommodation?
    else
      :overtime_pay_per_hour?
    end
  end
end

# Q8
value_question :overtime_pay_per_hour? do
  save_input_as :overtime_rate
  
  calculate :total_overtime_pay do
    overtime_hourly_rate = responses.last.to_f
    # Calculate overtime rate as the lower of the two basic/overtime rates.
    overtime_hourly_rate = basic_hourly_rate if (overtime_hourly_rate < basic_hourly_rate)
    (overtime_hourly_rate * overtime_hours.to_f).round(2)
  end
  
  calculate :total_basic_pay do
    (total_overtime_pay + total_basic_pay.to_f).round(2)
  end
  
  calculate :total_hourly_rate do
    (total_basic_pay / total_hours).round(2)
  end
  
  next_node :provided_with_accommodation?
end

# Q9
multiple_choice :provided_with_accommodation? do
  option "no" => :results
  option "yes_free" => :accommodation_usage?
  option "yes_charged" => :accommodation_charge?
end

# Q10
value_question :accommodation_charge? do
  save_input_as :accommodation_charge
  next_node :accommodation_usage?
end

# Q11
value_question :accommodation_usage? do
  
  calculate :total_basic_pay do
    usage = responses.last.to_i # TODO: Check this input is full days only?
    accommodation_adjustment = calculator.accommodation_adjustment(accommodation_charge.to_f, usage)
    total_basic_pay.to_f + accommodation_adjustment  
  end
  
  calculate :total_hourly_rate do
    (total_basic_pay / total_hours).round(2)
  end
  
  next_node :results
end

outcome :results

#multiple_choice :how_do_you_get_paid? do
#  option :per_hour
#  option :per_piece

#  save_input_as :payment_method

#  next_node :how_old_are_you?
#end

#multiple_choice :how_old_are_you? do
#  option :"21_or_over"
#  option :"18_to_20"
#  option :"under_18"
#  option :under_19
#  option :"19_or_over"

#  save_input_as :age

#  calculate :per_hour_minimum_wage do
#    "%0.2f" % calculator.per_hour_minimum_wage(responses.last)
#  end

#  next_node do
#    if payment_method.to_sym == :per_hour
#      :how_many_hours_per_week_worked?
#    else
#      :how_many_pieces_do_you_produce_per_week?
#    end
#  end
#end

#value_question :how_many_hours_per_week_worked? do
#  save_input_as :hours_per_week

#  calculate :per_week_minimum_wage do
#    "%0.2f" % calculator.per_week_minimum_wage(age, responses.last)
#  end

#  next_node :per_hour_minimum_wage
#end

#value_question :how_many_pieces_do_you_produce_per_week? do
#  save_input_as :pieces_per_week

#  next_node :how_much_do_you_get_paid_per_piece?
#end

#value_question :how_much_do_you_get_paid_per_piece? do
#  save_input_as :pay_per_piece

#  next_node :how_many_hours_do_you_work_per_week?
#end

#value_question :how_many_hours_do_you_work_per_week? do
#  save_input_as :hours_per_week

#  calculate :hourly_wage do
#    "%0.2f" % calculator.per_piece_hourly_wage(pay_per_piece, pieces_per_week, responses.last)
#  end

#  calculate :above_below do
#    if calculator.is_below_minimum_wage?(age, pay_per_piece, pieces_per_week, responses.last)
#      "below"
#    else
#      "above"
#    end
#  end

#  next_node :per_piece_minimum_wage
#end

#outcome :per_hour_minimum_wage
#outcome :per_piece_minimum_wage
