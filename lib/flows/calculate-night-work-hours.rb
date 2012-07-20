status :draft
section_slug "work"

multiple_choice :how_old? do
  option '18-or-over' => :exception_to_limits?
  option 'under-18' => :not_old_enough
end

multiple_choice :exception_to_limits? do
  option "yes" => :investigate_specific_rules
  option "no" => :how_many_night_hours_worked?
end

value_question :how_many_night_hours_worked? do
  next_node do |response|
    hours = response.to_i
    if hours < 1
      raise SmartAnswer::InvalidResponse, "Please enter a number"
    elsif hours > 3
      :taken_rest_period?
    else
      :not_a_night_worker
    end
  end
end

multiple_choice :taken_rest_period? do
  option "yes" => :break_between_shifts?
  option "no" => :limit_exceeded
end

multiple_choice :break_between_shifts? do
  option "yes" => :reference_period?
  option "no" => :limit_exceeded
end

value_question :reference_period? do
  calculate :weeks_worked do
    weeks = responses.last.to_i
    if weeks < 1 or weeks > 52
      raise SmartAnswer::InvalidResponse, "Please enter a number between 0 and 53"
    end
    weeks
  end

  save_input_as :weeks_worked

  next_node :weeks_of_leave?
end

value_question :weeks_of_leave? do
  calculate :weeks_leave do
    if responses.last.to_i >= weeks_worked
      raise SmartAnswer::InvalidResponse
    end
    responses.last.to_i
  end

  save_input_as :weeks_leave

  next_node :what_is_your_work_cycle?
end

value_question :what_is_your_work_cycle? do
  calculate :work_cycle do
    responses.last.to_i
  end

  save_input_as :work_cycle

  next_node :nights_per_cycle?
end

value_question :nights_per_cycle? do
  calculate :nights_in_cycle do
    responses.last.to_i
  end

  save_input_as :nights_in_cycle

  next_node :hours_per_night?
end

value_question :hours_per_night? do
  calculate :hours_per_shift do
    responses.last.to_i
  end

  save_input_as :hours_per_shift

  next_node do |response|
    hours = response.to_i
    if hours < 4
      :not_a_night_worker
    elsif hours >= 4 and hours <= 13
      :overtime_hours?
    else
      :limit_exceeded
    end
  end
end

value_question :overtime_hours? do
  calculate :overtime_hours do
    responses.last.to_i
  end

  calculate :calculator do
    Calculators::NightWorkHours.new(
      :weeks_worked => weeks_worked, :weeks_leave => weeks_leave,
      :work_cycle => work_cycle, :nights_in_cycle => nights_in_cycle,
      :hours_per_shift => hours_per_shift, :overtime_hours => overtime_hours
    )
  end

  calculate :average_hours do
    calculator.average_hours
  end

  calculate :potential_days do
    calculator.potential_days
  end

  next_node do |response|
    calculator = Calculators::NightWorkHours.new(
      :weeks_worked => weeks_worked, :weeks_leave => weeks_leave,
      :work_cycle => work_cycle, :nights_in_cycle => nights_in_cycle,
      :hours_per_shift => hours_per_shift, :overtime_hours => response.to_i
    )

    if calculator.average_hours < 9
      :within_legal_limit
    else
      :outside_legal_limit
    end
  end
end

outcome :not_old_enough
outcome :investigate_specific_rules
outcome :not_a_night_worker
outcome :limit_exceeded
outcome :within_legal_limit
outcome :outside_legal_limit