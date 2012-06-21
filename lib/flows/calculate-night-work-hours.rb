status :draft

multiple_choice :how_old? do
  option 'under-18' => :not_old_enough
  option '18-or-over' => :have_you_worked_more_than_13_hours_in_a_night?
end

multiple_choice :have_you_worked_more_than_13_hours_in_a_night? do
  option :yes => :exceeded_working_time_limit
  option :no => :have_you_worked_more_than_6_nights_in_a_row?
end

multiple_choice :have_you_worked_more_than_6_nights_in_a_row? do
  option :yes => :exceeded_working_time_limit
  option :no => :how_many_weeks_have_you_worked_nights?
end

value_question :how_many_weeks_have_you_worked_nights? do
  save_input_as :weeks_worked

  next_node :how_many_weeks_leave_have_you_taken?
end

value_question :how_many_weeks_leave_have_you_taken? do
  calculate :weeks_leave do
    if responses.last.to_i >= weeks_worked.to_i
      raise SmartAnswer::InvalidResponse
    end
    responses.last
  end
  next_node :what_is_your_work_cycle?
end

value_question :what_is_your_work_cycle? do
  save_input_as :work_cycle

  next_node :how_many_nights_do_you_work_in_your_cycle?
end

value_question :how_many_nights_do_you_work_in_your_cycle? do
  calculate :nights_in_cycle do
    if responses.last.to_i >= work_cycle.to_i
      raise SmartAnswer::InvalidResponse
    end
    responses.last
  end

  next_node :how_many_hours_do_you_work_per_shift?
end

value_question :how_many_hours_do_you_work_per_shift? do

  next_node :how_many_overtime_hours_have_you_worked?
end

value_question :how_many_overtime_hours_have_you_worked? do

  next_node :done
end

outcome :done
outcome :not_old_enough
outcome :exceeded_working_time_limit
