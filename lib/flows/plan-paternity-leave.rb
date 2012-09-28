status :draft
satisfies_need "1947"

date_question :baby_due_date? do 
	save_input_as :due_date

  calculate :due_date do
    dt = Date.parse(responses.last)
    raise InvalidResponse if dt < Date.today or dt > 9.months.since(Date.today)
    responses.last
  end

	next_node :leave_start?
end

multiple_choice :leave_start? do
	save_input_as :start_date

	option :days_0
  option :days_1
  option :days_2
  option :days_3
  option :days_4
  option :days_5
  option :days_6
  option :weeks_1
  option :weeks_2
  option :weeks_3
  option :weeks_4
  option :weeks_5
  option :weeks_6
  option :weeks_7

  calculate :calculator do
    Calculators::PlanPaternityLeave.new(due_date: due_date, start_date: start_date)
  end

	next_node :paternity_leave_details
end

outcome :paternity_leave_details do
	precalculate :due_date_formatted do
		calculator.formatted_due_date
	end
  precalculate :start_date_formatted do
  	calculator.formatted_start_date
  end
  precalculate :distance_start do
    calculator.distance_start(start_date)
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