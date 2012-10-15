status :published
satisfies_need "1947"

date_question :baby_due_date? do 
	save_input_as :due_date

  calculate :calculator do
    Calculators::PlanPaternityLeave.new(due_date: due_date)
  end

	next_node :leave_duration?
end

multiple_choice :leave_duration? do
  calculate :leave_duration do
    responses.last == 'two_weeks' ? 2 : 1
  end
  calculate :potential_leave do
    calculator.leave_duration(leave_duration)
    calculator.format_date_range calculator.potential_leave
  end

  option :one_week
  option :two_weeks

  next_node :leave_start?
end

date_question :leave_start? do
  calculate :start_date do
    start_date_raw = responses.last
    start_date = Date.parse(start_date_raw)
    due_date_p = Date.parse(due_date)
    week_num = (leave_duration == 2 ? 6 : 7)
    raise SmartAnswer::InvalidResponse if start_date > week_num.weeks.since(due_date_p) or start_date < due_date_p 
    calculator.enter_start_date(start_date_raw)
    start_date_raw
  end

	next_node :paternity_leave_details
end

outcome :paternity_leave_details do
	precalculate :due_date_formatted do
		calculator.formatted_due_date
	end
  precalculate :qualifying_week do
    calculator.qualifying_week.last
  end
  precalculate :period_of_ordinary_leave do
    calculator.format_date_range calculator.period_of_ordinary_leave
  end
  precalculate :period_of_additional_leave do
    calculator.format_date_range calculator.period_of_additional_leave
  end
  precalculate :period_of_potential_ordinary_leave do
    calculator.format_date_range calculator.period_of_potential_ordinary_leave
  end
end