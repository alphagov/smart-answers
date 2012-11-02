status :published
satisfies_need 355

# Q1
multiple_choice :basis_of_calculation? do
  option "days-worked-per-week" => :calculation_period?
  option "hours-worked-per-week" => :calculation_period?
  option "casual-or-irregular-hours" => :casual_or_irregular_hours?
  option "annualised-hours" => :annualised_hours?
  option "compressed-hours" => :compressed_hours_how_many_hours_per_week?
  option "shift-worker" => :shift_worker_basis?
  save_input_as :calculation_basis
end

# Q2
multiple_choice :calculation_period? do
  option "full-year" => :how_many_days_per_week?
  option "starting" => :what_is_your_starting_date?
  option "leaving" => :what_is_your_leaving_date?
  next_node do |response|
    case response
    when "starting"
      :what_is_your_starting_date?
    when "leaving"
      :what_is_your_leaving_date?
    else
      calculation_basis == "days-worked-per-week" ? :how_many_days_per_week? : :how_many_hours_per_week?
    end
  end
end

# Q3
value_question :how_many_days_per_week? do
  calculate :days_per_week do
    days_per_week = responses.last.to_i
    raise InvalidResponse if days_per_week < 1 or days_per_week > 7
    days_per_week
  end
  calculate :days_per_week_calculated do
    (days_per_week < 5 ? days_per_week : 5)
  end
  calculate :calculator do
    Calculators::HolidayEntitlement.new(
      :days_per_week => (leave_year_start_date.nil? ? days_per_week : days_per_week_calculated),
      :start_date => start_date,
      :leaving_date => leaving_date,
      :leave_year_start_date => leave_year_start_date
    )
  end
  calculate :holiday_entitlement_days do
    calculator.formatted_full_time_part_time_days
  end
  calculate :content_sections do
    sections = PhraseList.new :answer_days
    if days_per_week > 5 and calculator.full_time_part_time_days >= 28
      sections << :maximum_days_calculated
    end
    sections << :your_employer_with_rounding
    sections
  end
  next_node :done
end

# Q4
date_question :what_is_your_starting_date? do
  from { Date.civil(1.year.ago.year, 1, 1) }
  to { Date.civil(1.year.since(Date.today).year, 12, 31) }
  save_input_as :start_date
  next_node :when_does_your_leave_year_start?
end

# Q5
date_question :what_is_your_leaving_date? do
  from { Date.civil(1.year.ago.year, 1, 1) }
  to { Date.civil(1.year.since(Date.today).year, 12, 31) }
  save_input_as :leaving_date
  next_node :when_does_your_leave_year_start?
end

# Q21
date_question :when_does_your_leave_year_start? do
  from { Date.civil(1.year.ago.year, 1, 1) }
  to { Date.civil(1.year.since(Date.today).year, 12, 31) }
  save_input_as :leave_year_start_date
  next_node do |response|
    case calculation_basis
    when "days-worked-per-week"
      :how_many_days_per_week?
    when "hours-worked-per-week"
      :how_many_hours_per_week?
    when "shift-worker"
      :shift_worker_hours_per_shift?
    end
  end
end

# Q10
value_question :how_many_hours_per_week? do
  calculate :calculator do
    Calculators::HolidayEntitlement.new(
      :hours_per_week => responses.last.to_f,
      :start_date => start_date,
      :leaving_date => leaving_date,
      :leave_year_start_date => leave_year_start_date
    )
  end
  calculate :holiday_entitlement_hours_and_minutes do
    calculator.full_time_part_time_hours_and_minutes
  end
  calculate :holiday_entitlement_hours do
    holiday_entitlement_hours_and_minutes.first
  end
  calculate :holiday_entitlement_minutes do
    holiday_entitlement_hours_and_minutes.last
  end
  calculate :content_sections do
    PhraseList.new :answer_hours, :your_employer_with_rounding
  end
  next_node :done
end

value_question :casual_or_irregular_hours? do
  calculate :total_hours do
    hours = responses.last.to_f
    raise InvalidResponse if hours <= 0
    hours
  end
  calculate :calculator do
    Calculators::HolidayEntitlement.new(:total_hours => total_hours)
  end
  calculate :holiday_entitlement_hours do
    calculator.casual_irregular_entitlement.first
  end
  calculate :holiday_entitlement_minutes do
    calculator.casual_irregular_entitlement.last
  end
  calculate :content_sections do
    PhraseList.new :answer_hours_minutes, :your_employer_with_rounding
  end
  next_node :done
end

value_question :annualised_hours? do
  calculate :total_hours do
    hours = responses.last.to_f
    raise InvalidResponse if hours <= 0
    hours
  end
  calculate :calculator do
    Calculators::HolidayEntitlement.new(:total_hours => total_hours)
  end
  calculate :average_hours_per_week do
    calculator.formatted_annualised_hours_per_week
  end
  calculate :holiday_entitlement_hours do
    calculator.annualised_entitlement.first
  end
  calculate :holiday_entitlement_minutes do
    calculator.annualised_entitlement.last
  end
  calculate :content_sections do
    PhraseList.new :answer_hours_minutes_annualised, :your_employer_with_rounding
  end
  next_node :done
end

value_question :compressed_hours_how_many_hours_per_week? do
  calculate :hours_per_week do
    hours = responses.last.to_f
    raise InvalidResponse if hours <= 0 or hours > 168
    hours
  end
  next_node :compressed_hours_how_many_days_per_week?
end

value_question :compressed_hours_how_many_days_per_week? do
  calculate :days_per_week do
    days = responses.last.to_i
    raise InvalidResponse if days <= 0 or days > 7
    days
  end
  calculate :calculator do
    Calculators::HolidayEntitlement.new(
      :hours_per_week => hours_per_week,
      :days_per_week => days_per_week
    )
  end
  calculate :holiday_entitlement_hours do
    calculator.compressed_hours_entitlement.first
  end
  calculate :holiday_entitlement_minutes do
    calculator.compressed_hours_entitlement.last
  end
  calculate :hours_daily do
    calculator.compressed_hours_daily_average.first
  end
  calculate :minutes_daily do
    calculator.compressed_hours_daily_average.last
  end
  calculate :content_sections do
    PhraseList.new :answer_compressed_hours, :your_employer_with_rounding
  end
  next_node :done
end

multiple_choice :shift_worker_basis? do
  option "full-year" => :shift_worker_hours_per_shift?
  option "starting" => :what_is_your_starting_date?
  option "leaving" => :what_is_your_leaving_date?
end

value_question :shift_worker_hours_per_shift? do
  calculate :hours_per_shift do
    hours_per_shift = responses.last.to_f
    raise InvalidResponse if hours_per_shift <= 0
    hours_per_shift
  end
  next_node :shift_worker_shifts_per_shift_pattern?
end

value_question :shift_worker_shifts_per_shift_pattern? do
  calculate :shifts_per_shift_pattern do
    shifts = responses.last.to_i
    raise InvalidResponse if shifts <=0
    shifts
  end
  next_node :shift_worker_days_per_shift_pattern?
end

value_question :shift_worker_days_per_shift_pattern? do
  calculate :days_per_shift_pattern do
    days = responses.last.to_i
    raise InvalidResponse if days < shifts_per_shift_pattern
    days
  end
  calculate :calculator do
    Calculators::HolidayEntitlement.new(
      :start_date => start_date,
      :leaving_date => leaving_date,
      :leave_year_start_date => leave_year_start_date,
      :hours_per_shift => hours_per_shift,
      :shifts_per_shift_pattern => shifts_per_shift_pattern,
      :days_per_shift_pattern => days_per_shift_pattern
    )
  end
  calculate :shifts_per_week do
    calculator.formatted_shifts_per_week
  end
  calculate :holiday_entitlement_shifts do
    calculator.formatted_shift_entitlement
  end
  calculate :fraction_of_year do
    calculator.formatted_fraction_of_year
  end
  calculate :hours_per_shift do
    calculator.strip_zeros hours_per_shift
  end
  calculate :content_sections do
    full_year = start_date.nil? && leaving_date.nil?

    PhraseList.new :answer_shift_worker, :your_employer_with_rounding
  end
  next_node :done
end

outcome :done
