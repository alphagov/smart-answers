status :draft
section_slug "money-and-tax"
satisfies_need "2013"

## Q1
# checkbox_question :select_employee_criteria? do
# 	option :maternity_paternity => 										## A2
# 	option :sick_less_than_four_days => 							## A1
# 	option :chronic_illness => 												## A3
# 	option :havent_told_you_they_were_sick =>						## A7
# 	option :different_days => 														## A4
# 	option :none => :employee_paid_for_last_8_weeks? 	## Q3
# end

## Q2
multiple_choice :employee_paid_for_last_8_weeks? do
	option :yes => :related_illness? 						## Q3
	option :no => :what_was_average_weekly_pay? ## Q5
end

## Q3
multiple_choice :related_illness? do
	option :yes => :how_many_days_missed? 						## Q4
	option :no => :what_was_average_weekly_earnings? 	## Q6
end

## Q4
value_question :how_many_days_missed? do
	calculate :prev_sick_days do
		responses.last.to_i
	end
	calculate :calculator do
		Calculators::CalculateStatutorySickPay.new(prev_sick_days)
	end
	next_node :how_many_days_worked?
end

## Q5
money_question :what_was_average_weekly_pay? do
	calculate :not_entitled_reason do 
		PhraseList.new(:earnings_too_low)
	end
	calculate :under_eight_awe do
		responses.last 
	end
	next_node do |response|
		if response.to_f < 107.00
			:not_entitled
		else
			:how_many_days_worked?
		end
	end
end

## Q6
money_question :what_was_average_weekly_earnings? do
	calculate :not_entitled_reason do 
		PhraseList.new(:earnings_too_low)
	end
	calculate :over_eight_awe do
		responses.last
	end
	next_node do |response|
		if response.to_f < 107.00
			:not_entitled
		else
			:how_many_days_worked?
		end
	end
end

## Q7
value_question :how_many_days_worked? do
	calculate :pattern_days do
		responses.last.to_i
	end
	calculate :daily_rate do
		calculator.set_daily_rate(pattern_days)
		calculator.daily_rate
	end
	next_node :normal_workdays_taken_as_sick?
end

## Q8
value_question :normal_workdays_taken_as_sick? do
	calculate :normal_workdays_out do
		calculator.set_normal_work_days(responses.last.to_i)
		calculator.normal_work_days
	end
	calculate :ssp_payment do
		calculator.ssp_payment
	end
	next_node :entitled
end

## Outcomes

## A1
outcome :not_entitled_sick4days
## A2, A3, A5
outcome :not_entitled

## A4
## A6
outcome :entitled
