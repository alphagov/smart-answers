status :draft
section_slug "work"

calculator = HolidayEntitlementCalculator.new()

multiple_choice :what_is_your_employment_status? do
  option "full-time" => :full_time_worked?
  option "part-time" => :part_time_worked?
  option "casual-or-irregular-hours" => :casual_or_irregular_hours?
  option "annualised-hours" => :annualised_hours?
  option "compressed-hours" => :compressed_hours?
  option "shift-worker" => :shift_worker_basis?
end

multiple_choice :full_time_worked? do
  option "full-year" => :full_time_year?
  option "starting" => :full_time_starting_date?
  option "leaving" => :full_time_leaving_date?
end

multiple_choice :full_time_year? do
  option "5-days-a-week" => :done_full_time_5_days
  option "more-than-5-days-a-week" => :done_full_time_more_than_5
end

# TODO: can we factor this date range stuff out? It's all the same
date_question :full_time_starting_date? do
  from { Date.civil(Date.today.year, 1, 1) }
  to { Date.civil(Date.today.year, 12, 31) }
  save_input_as :start_date
  next_node :full_time_part_year_days?
  calculate :fraction_of_year do
    calculator.fraction_of_year Date.civil(Date.today.year, 12, 31), start_date
  end
end

date_question :full_time_leaving_date? do
  from { Date.civil(Date.today.year, 1, 1) }
  to { Date.civil(Date.today.year, 12, 31) }
  save_input_as :leaving_date
  next_node :full_time_part_year_days?
  calculate :fraction_of_year do
    calculator.fraction_of_year leaving_date, Date.civil(Date.today.year, 1, 1)
  end
end

multiple_choice :full_time_part_year_days? do
  option "5-days" => :done_full_time_part_year
  option "6-days" => :done_full_time_part_year
  option "7-days" => :done_full_time_part_year
  calculate :holiday_entitlement_days do
    calculator.format_number 5.6 * fraction_of_year * responses.last.sub('-days', '').to_f
  end
end

multiple_choice :part_time_worked? do
  option "full-year" => :part_time_year_days_worked?
  option "starting" => :part_time_starting_date?
  option "leaving" => :part_time_leaving_date?
end

date_question :part_time_starting_date? do
  from { Date.civil(Date.today.year, 1, 1) }
  to { Date.civil(Date.today.year, 12, 31) }
  save_input_as :start_date
  next_node :part_time_part_year_days_worked?
  calculate :fraction_of_year do
    calculator.fraction_of_year Date.civil(Date.today.year, 12, 31), start_date
  end
end

date_question :part_time_leaving_date? do
  from { Date.civil(Date.today.year, 1, 1) }
  to { Date.civil(Date.today.year, 12, 31) }
  save_input_as :leaving_date
  next_node :part_time_part_year_days_worked?
  calculate :fraction_of_year do
    calculator.fraction_of_year leaving_date, Date.civil(Date.today.year, 1, 1)
  end
end

value_question :part_time_year_days_worked? do
  next_node :done_part_time_year
  calculate :part_time_holiday_entitlement do
    calculator.format_number responses.last.to_f * 5.6
  end
end

value_question :part_time_part_year_days_worked? do
  next_node :done_part_time_part_year
  calculate :part_time_holiday_entitlement do
    calculator.format_number responses.last.to_f * 5.6 * fraction_of_year
  end
end

value_question :casual_or_irregular_hours? do
  next_node :done_casual_hours
  save_input_as :total_hours
  calculate :casual_holiday_entitlement do
    calculator.hours_as_seconds total_hours.to_f * (5.6 / (52.0 - 5.6))
  end
  calculate :entitlement_hours do
    (calculator.seconds_to_hash(casual_holiday_entitlement)[:dd] * 24) + calculator.seconds_to_hash(casual_holiday_entitlement)[:hh]
  end
  calculate :entitlement_minutes do
    calculator.seconds_to_hash(casual_holiday_entitlement)[:mm]
  end
end

value_question :annualised_hours? do
  next_node :done_annualised_hours
  save_input_as :total_hours
  calculate :annualised_weekly_average do
    total_hours.to_f / 46.4
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
    calculator.fraction_of_year Date.civil(Date.today.year, 12, 31), start_date
  end
end

date_question :shift_worker_leaving_date? do
  from { Date.civil(Date.today.year, 1, 1) }
  to { Date.civil(Date.today.year, 12, 31) }
  save_input_as :leaving_date
  next_node :shift_worker_year_shift_length?
  calculate :fraction_of_year do
    calculator.fraction_of_year leaving_date, Date.civil(Date.today.year, 1, 1)
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

outcome :done_full_time_5_days
outcome :done_full_time_more_than_5
outcome :done_full_time_part_year
outcome :done_part_time_year
outcome :done_part_time_part_year
outcome :done_casual_hours
outcome :done_annualised_hours
outcome :done_compressed_hours
outcome :done_shift_worker_year
outcome :done_shift_worker_part_year
