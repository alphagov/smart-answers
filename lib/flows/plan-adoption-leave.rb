status :published
satisfies_need "1948"

date_question :child_match_date? do 
  save_input_as :match_date

  next_node :child_arrival_date?
end

date_question :child_arrival_date? do 
	calculate :arrival_date do
    raise InvalidResponse if Date.parse(responses.last) <= Date.parse(match_date)
    responses.last
  end

	next_node :leave_start?
end

date_question :leave_start? do
	calculate :start_date do
    dist = (Date.parse(arrival_date) - Date.parse(responses.last)).to_i 
    raise InvalidResponse unless (1..14).include? dist
    responses.last
  end

  calculate :calculator do
    Calculators::PlanAdoptionLeave.new(
      match_date: match_date, 
      arrival_date: arrival_date, 
      start_date: start_date)
  end

	next_node :adoption_leave_details
end

outcome :adoption_leave_details do
	precalculate :match_date_formatted do
    calculator.formatted_match_date
  end
  precalculate :arrival_date_formatted do
		calculator.formatted_arrival_date
	end
  precalculate :start_date_formatted do
  	calculator.formatted_start_date
  end
  precalculate :distance_start do
    calculator.distance_start
  end
  precalculate :qualifying_week do
    calculator.qualifying_week.last
    # calculator.formatted_date (Date.parse(match_date) - 7)
  end
  precalculate :earliest_start do
    calculator.earliest_start
  end
  precalculate :period_of_ordinary_leave do
    calculator.format_date_range calculator.period_of_ordinary_leave
  end
  precalculate :period_of_additional_leave do
    calculator.format_date_range calculator.period_of_additional_leave
  end
end