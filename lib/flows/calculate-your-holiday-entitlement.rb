status :published
satisfies_need 355

multiple_choice :what_is_your_employment_status? do
  option "full-time" => :full_time_how_long_employed?
  option "part-time" => :part_time_how_long_employed?
  option "casual-or-irregular-hours" => :casual_or_irregular_hours?
  option "annualised-hours" => :annualised_hours?
  option "compressed-hours" => :compressed_hours_how_many_hours_per_week?
  option "shift-worker" => :shift_worker_basis?
  save_input_as :employment_status
end

multiple_choice :full_time_how_long_employed? do
  option "full-year" => :full_time_how_many_days_per_week?
  option "starting" => :what_is_your_starting_date?
  option "leaving" => :what_is_your_leaving_date?
end

date_question :what_is_your_starting_date? do
  from { Date.civil(Date.today.year, 1, 1) }
  to { Date.civil(Date.today.year, 12, 31) }
  save_input_as :start_date
  next_node :when_does_your_leave_year_start?
end

date_question :what_is_your_leaving_date? do
  from { Date.civil(Date.today.year, 1, 1) }
  to { Date.civil(Date.today.year, 12, 31) }
  save_input_as :leaving_date
  next_node :when_does_your_leave_year_start?
end

date_question :when_does_your_leave_year_start? do
  from { Date.civil(Date.today.year, 1, 1) }
  to { Date.civil(Date.today.year, 12, 31) }
  save_input_as :leave_year_start_date
  next_node do |response|
    case employment_status
    when 'full-time'
      :full_time_how_many_days_per_week?
    when 'part-time'
      :part_time_how_many_days_per_week?
    when 'shift-worker'
      :shift_worker_hours_per_shift?
    end
  end
end

multiple_choice :full_time_how_many_days_per_week? do
  option "5-days"
  option "6-or-7-days"

  calculate :days_per_week do
    responses.last.to_i
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
  calculate :fraction_of_year do
    calculator.formatted_fraction_of_year
  end
  calculate :content_sections do
    full_year = start_date.nil? && leaving_date.nil?
    capped = days_per_week != 5
    sections = PhraseList.new
    if full_year
      sections << (capped ? :answer_fy_capped : :answer_ft_pt)
      sections << :your_employer
      sections << (capped ? :calculation_ft_capped : :calculation_ft)
    else
      sections << (capped ? :answer_py_capped : :answer_ft_py)
      sections << :your_employer_with_rounding
      sections << :calculation_ft_partial_year
    end
    sections
  end
  next_node :done
end

multiple_choice :part_time_how_long_employed? do
  option "full-year" => :part_time_how_many_days_per_week?
  option "starting" => :what_is_your_starting_date?
  option "leaving" => :what_is_your_leaving_date?
end

value_question :part_time_how_many_days_per_week? do
  calculate :days_per_week do
    days = responses.last.to_i
    raise InvalidResponse if days > 7 or days < 1
    days
  end
  calculate :calculator do
    Calculators::HolidayEntitlement.new(
      :days_per_week => days_per_week,
      :start_date => start_date,
      :leaving_date => leaving_date,
      :leave_year_start_date => leave_year_start_date
    )
  end
  calculate :holiday_entitlement_days do
    calculator.formatted_full_time_part_time_days
  end
  calculate :fraction_of_year do
    calculator.formatted_fraction_of_year
  end
  calculate :content_sections do
    full_year = start_date.nil? && leaving_date.nil?
    capped = days_per_week != 5 && full_year

    sections = PhraseList.new
    sections << :answer_ft_pt
    if full_year
      sections << :your_employer << :calculation_pt
    else
      sections << :your_employer_with_rounding << :calculation_pt_partial_year
    end
    sections
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
    PhraseList.new :answer_hours_minutes, :your_employer, :calculation_casual_irregular
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
    PhraseList.new :answer_hours_minutes_annualised, :your_employer, :calculation_annualised
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
    PhraseList.new :answer_compressed_hours, :your_employer_with_rounding, :calculation_compressed_hours
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

    sections = PhraseList.new :answer_shift_worker
    if full_year
      sections << :your_employer << :calculation_shift_worker
    else
      sections << :your_employer_with_rounding << :calculation_shift_worker_partial_year
    end
    sections
  end
  next_node :done
end

outcome :done
