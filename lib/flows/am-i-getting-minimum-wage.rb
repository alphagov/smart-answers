status :draft

section_slug "money-and-tax"

multiple_choice :how_do_you_get_paid? do
  option :per_hour => :how_old_are_you?
  option :per_piece => :how_old_are_you?

  save_input_as :payment_method
end

value_question :how_old_are_you? do
  save_input_as :age

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

  calculate :minimum_wage do

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

  calculate :minimum_wage do

  end

  next_node :per_piece_minimum_wage
end

outcome :per_hour_minimum_wage
outcome :per_piece_minimum_wage