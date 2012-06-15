status :draft

section_slug "money-and-tax"

calculator = Calculators::MinimumWageCalculator.new

multiple_choice :how_do_you_get_paid? do
  option :per_hour
  option :per_piece

  save_input_as :payment_method

  next_node :how_old_are_you?
end

multiple_choice :how_old_are_you? do
  option :"21_or_over"
  option :"18_to_20"
  option :"under_18"
  option :under_19
  option :"19_or_over"

  save_input_as :age

  calculate :per_hour_minimum_wage do
    "%0.2f" % calculator.per_hour_minimum_wage(responses.last)
  end

  next_node do
    if payment_method.to_sym == :per_hour
      :how_many_hours_per_week_worked?
    else
      :how_many_pieces_do_you_produce_per_week?
    end
  end
end

value_question :how_many_hours_per_week_worked? do
  save_input_as :hours_per_week

  calculate :per_week_minimum_wage do
    "%0.2f" % calculator.per_week_minimum_wage(age, responses.last)
  end

  next_node :per_hour_minimum_wage
end

value_question :how_many_pieces_do_you_produce_per_week? do
  save_input_as :pieces_per_week

  next_node :how_much_do_you_get_paid_per_piece?
end

value_question :how_much_do_you_get_paid_per_piece? do
  save_input_as :pay_per_piece

  next_node :how_many_hours_do_you_work_per_week?
end

value_question :how_many_hours_do_you_work_per_week? do
  save_input_as :hours_per_week

  calculate :hourly_wage do
    "%0.2f" % calculator.per_piece_hourly_wage(pay_per_piece, pieces_per_week, responses.last)
  end

  calculate :above_below do
    if calculator.is_below_minimum_wage?(age, pay_per_piece, pieces_per_week, responses.last)
      "below"
    else
      "above"
    end
  end

  next_node :per_piece_minimum_wage
end

outcome :per_hour_minimum_wage
outcome :per_piece_minimum_wage