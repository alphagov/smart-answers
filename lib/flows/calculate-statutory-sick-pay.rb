status :draft
section_slug "money-and-tax"
satisfies_need "2013"

## Q1
multiple_choice :select_employee_criteria? do
	option :maternity_paternity => :already_receiving_benefit								## A2
	option :sick_less_than_four_days => :must_be_sick_for_at_least_4_days 	## A1
	option :chronic_illness => :has_chronic_illness													## A3
	option :havent_told_you_they_were_sick =>	:not_informed_soon_enough			## A7
	option :different_days => :irregular_work_schedule											## A4
	option :none => :employee_paid_for_last_8_weeks? 												## Q2
end

## Q2
multiple_choice :employee_paid_for_last_8_weeks? do
	option :yes => :related_illness? 											## Q3
	option :no => :what_was_average_weekly_pay? 					## Q5
end

## Q3 
multiple_choice :related_illness? do
	option :yes => :how_many_days_missed? 						## Q4
	option :no => :what_was_average_weekly_earnings? 	## Q6
end

## Q4
value_question :how_many_days_missed? do
	calculate :prev_sick_days do
		if ! (responses.last.to_s =~ /\A\d+\z/)
      raise SmartAnswer::InvalidResponse
    else
      if responses.last.to_i < 1
      	raise SmartAnswer::InvalidResponse
      else
      	responses.last.to_i
      end
    end
	end
	next_node :how_many_days_worked? 								## Q7
end

## Q5 
money_question :what_was_average_weekly_pay? do
	calculate :under_eight_awe do
		if responses.last < 1
			raise SmartAnswer::InvalidResponse
		else
			responses.last
		end
	end
	next_node do |response|
		if response.to_f < 107.00
			:not_earned_enough												## A5
		else
			:how_many_days_worked?										## Q7
		end
	end
end

## Q6
money_question :what_was_average_weekly_earnings? do
	calculate :over_eight_awe do
		if responses.last < 1
			raise SmartAnswer::InvalidResponse
		else
			responses.last
		end
	end
	next_node do |response|
		if response.to_f < 107.00
			:not_earned_enough											## A5
		else
			:how_many_days_worked?									## Q7
		end
	end
end

## Q7
value_question :how_many_days_worked? do
	calculate :pattern_days do
		# ensure we get an integer
		if ! (responses.last.to_s =~ /\A\d+\z/)
      raise SmartAnswer::InvalidResponse
    else
    	# and one between 1..7
      if (1..7).include?(responses.last.to_i)
      	responses.last.to_i
      else
      	raise SmartAnswer::InvalidResponse
      end
    end
	end
	calculate :calculator do
		if prev_sick_days
			Calculators::CalculateStatutorySickPay.new(prev_sick_days)
		else 
			Calculators::CalculateStatutorySickPay.new(0)
		end
	end
	calculate :daily_rate do
		calculator.set_daily_rate(pattern_days)
		calculator.daily_rate
	end
	next_node :normal_workdays_taken_as_sick?		## Q8
end

## Q8
value_question :normal_workdays_taken_as_sick? do
	calculate :normal_workdays_out do
		if ! (responses.last.to_s =~ /\A\d+\z/)
      raise SmartAnswer::InvalidResponse
    else
			if responses.last.to_i < 1
      	raise SmartAnswer::InvalidResponse
      else
				calculator.set_normal_work_days(responses.last.to_i)
				calculator.normal_work_days
      end
		end
	end
	calculate :ssp_payment do
		if calculator.ssp_payment < 1
			0.0
		else
			calculator.ssp_payment
		end
	end
	next_node :entitled													## A6
end

## Outcomes

## A1
outcome :must_be_sick_for_at_least_4_days
## A2
outcome :already_receiving_benefit
## A3
outcome :has_chronic_illness
## A4
outcome :irregular_work_schedule
## A5
outcome :not_earned_enough
## A6
outcome :entitled
## A7
outcome :not_informed_soon_enough

