status :draft
section_slug "work"

calculator = Calculators::HolidayEntitlement.new()

multiple_choice :what_is_your_employment_status? do
  option "full-time" => :full_time_how_long_employed?
  option "part-time" => :part_time_how_long_employed?
  option "casual-or-irregular-hours" => :casual_or_irregular_hours?
  option "annualised-hours" => :annualised_hours?
  option "compressed-hours" => :compressed_hours?
  option "shift-worker" => :shift_worker_basis?
end

multiple_choice :full_time_how_long_employed? do
  option "full-year" => :full_time_how_many_days_per_week?
  option "starting" => :full_time_starting_date?
  option "leaving" => :full_time_leaving_date?
end

# TODO: can we factor this date range stuff out? It's all the same
date_question :full_time_starting_date? do
  from { Date.civil(Date.today.year, 1, 1) }
  to { Date.civil(Date.today.year, 12, 31) }
  save_input_as :start_date
  next_node :full_time_how_many_days_per_week?
end

date_question :full_time_leaving_date? do
  from { Date.civil(Date.today.year, 1, 1) }
  to { Date.civil(Date.today.year, 12, 31) }
  save_input_as :leaving_date
  next_node :full_time_how_many_days_per_week?
end

multiple_choice :full_time_how_many_days_per_week? do
  option "5-days"
  option "6-days"
  option "7-days"

  calculate :days_per_week do
    responses.last.to_i
  end
  calculate :calculator do
    Calculators::HolidayEntitlement.new(
      :days_per_week => days_per_week,
      :start_date => start_date,
      :leaving_date => leaving_date
    )
  end
  calculate :holiday_entitlement_days do
    self.calculator.formatted_full_time_part_time_days
  end
  calculate :fraction_of_year do
    self.calculator.formatted_fraction_of_year
  end
  calculate :content_sections do
    full_year = start_date.nil? && leaving_date.nil?
    capped = days_per_week != 5 && full_year

    sections = PhraseList.new
    sections << (capped ? :answer_ft_pt_capped : :answer_ft_pt)
    sections << (full_year ? :your_employer : :your_employer_with_rounding)
    if full_year
      sections << (capped ? :calculation_ft_capped : :calculation_ft)
    else
      sections << :calculation_ft_partial_year
    end
    sections
  end
  next_node :done
end

multiple_choice :part_time_how_long_employed? do
  option "full-year" => :part_time_how_many_days_per_week?
  option "starting" => :part_time_starting_date?
  option "leaving" => :part_time_leaving_date?
end

date_question :part_time_starting_date? do
  from { Date.civil(Date.today.year, 1, 1) }
  to { Date.civil(Date.today.year, 12, 31) }
  save_input_as :start_date
  next_node :part_time_how_many_days_per_week?
end

date_question :part_time_leaving_date? do
  from { Date.civil(Date.today.year, 1, 1) }
  to { Date.civil(Date.today.year, 12, 31) }
  save_input_as :leaving_date
  next_node :part_time_how_many_days_per_week?
end

value_question :part_time_how_many_days_per_week? do
  calculate :days_per_week do
    responses.last.to_i
  end
  calculate :calculator do
    Calculators::HolidayEntitlement.new(
      :days_per_week => days_per_week,
      :start_date => start_date,
      :leaving_date => leaving_date
    )
  end
  calculate :holiday_entitlement_days do
    self.calculator.formatted_full_time_part_time_days
  end
  calculate :fraction_of_year do
    self.calculator.formatted_fraction_of_year
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
    responses.last.to_f
  end
  calculate :calculator do
    Calculators::HolidayEntitlement.new(:total_hours => total_hours)
  end
  calculate :holiday_entitlement_hours do
    self.calculator.casual_irregular_entitlement.first
  end
  calculate :holiday_entitlement_minutes do
    self.calculator.casual_irregular_entitlement.last
  end
  calculate :content_sections do
    PhraseList.new :answer_casual_irregular, :your_employer, :calculation_casual_irregular
  end
  next_node :done
end

value_question :annualised_hours? do
  next_node :done_annualised_hours
  save_input_as :total_hours
  calculate :annualised_weekly_average do
    total_hours.to_f / 46.4
  end
  calculate :display_annualised_weekly_average do
    sprintf("%.2f", annualised_weekly_average)
  end
  calculate :holiday_entitlement do
    calculator.hours_as_seconds 5.6 * annualised_weekly_average.to_f
  end
  calculate :entitlement_hours do
    (calculator.seconds_to_hash(holiday_entitlement)[:dd] * 24) + calculator.seconds_to_hash(holiday_entitlement)[:hh]
  end
  calculate :entitlement_minutes do
    calculator.seconds_to_hash(holiday_entitlement)[:mm]
  end
end

value_question :compressed_hours? do
  next_node :compressed_hours_days?
  save_input_as :hours_per_week
end

value_question :compressed_hours_days? do
  next_node :done_compressed_hours
  save_input_as :days_per_week
  calculate :seconds_allowance do
    calculator.hours_as_seconds hours_per_week.to_f * 5.6
  end
  calculate :hours do
    (calculator.seconds_to_hash(seconds_allowance)[:dd] * 24) + calculator.seconds_to_hash(seconds_allowance)[:hh]
  end
  calculate :minutes do
    calculator.seconds_to_hash(seconds_allowance)[:mm]
  end
  calculate :seconds_daily do
    calculator.hours_as_seconds hours_per_week.to_f / days_per_week.to_f
  end
  calculate :hours_daily do
    calculator.seconds_to_hash(seconds_daily)[:hh]
  end
  calculate :minutes_daily do
    calculator.seconds_to_hash(seconds_daily)[:mm]
  end
end

multiple_choice :shift_worker_basis? do
  option "full-year" => :shift_worker_year_shift_length?
  option "starting" => :shift_worker_starting_date?
  option "leaving" => :shift_worker_leaving_date?
end

date_question :shift_worker_starting_date? do
  from { Date.civil(Date.today.year, 1, 1) }
  to { Date.civil(Date.today.year, 12, 31) }
  save_input_as :start_date
  next_node :shift_worker_year_shift_length?
  calculate :fraction_of_year do
    calculator.old_fraction_of_year Date.civil(Date.today.year, 12, 31), start_date
  end
  calculate :display_fraction_of_year do
    sprintf("%.2f", fraction_of_year)
  end
end

date_question :shift_worker_leaving_date? do
  from { Date.civil(Date.today.year, 1, 1) }
  to { Date.civil(Date.today.year, 12, 31) }
  save_input_as :leaving_date
  next_node :shift_worker_year_shift_length?
  calculate :fraction_of_year do
    calculator.old_fraction_of_year leaving_date, Date.civil(Date.today.year, 1, 1)
  end
  calculate :display_fraction_of_year do
    sprintf("%.2f", fraction_of_year)
  end
end

value_question :shift_worker_year_shift_length? do
  next_node :shift_worker_year_shift_count?
  save_input_as :shift_length
end

value_question :shift_worker_year_shift_count? do
  next_node :shift_worker_days_pattern?
  save_input_as :shift_count
end

value_question :shift_worker_days_pattern? do
  next_node do
    fraction_of_year.nil? ? :done_shift_worker_year : :done_shift_worker_part_year
  end

  calculate :shifts_per_week do
    (shift_count.to_f / responses.last.to_f) * 7
  end
  calculate :holiday_entitlement do
    calculator.format_number shifts_per_week * 5.6 * (fraction_of_year || 1.0)
  end
end

outcome :done_annualised_hours
outcome :done_compressed_hours
outcome :done_shift_worker_year
outcome :done_shift_worker_part_year

outcome :done
