status :draft
satisfies_need "2013"

## Q1
multiple_choice :getting_maternity_pay? do
	option :yes => :already_receiving_benefit
	option :no => :getting_paternity_or_adoption_pay?
end

## Q2
multiple_choice :getting_paternity_or_adoption_pay? do
	option :yes
	option :no

	calculate :warning_message do
		if responses.last == "yes"
			PhraseList.new(:paternity_adoption_warning)
		else
			''
		end
	end

	next_node :sick_less_than_four_days?
end

## Q3
multiple_choice :sick_less_than_four_days? do
	option :yes => :must_be_sick_for_at_least_4_days
	option :no => :have_told_you_they_were_sick?
end

## Q4
multiple_choice :have_told_you_they_were_sick? do
	option :yes => :different_days?
	option :no => :not_informed_soon_enough
end

## Q5
multiple_choice :different_days? do
	option :yes => :irregular_work_schedule
	option :no => :sickness_start_date?
end
	

## Q6
date_question :sickness_start_date? do
	save_input_as :sick_start_date
	next_node :sickness_end_date?
end

## Q7
date_question :sickness_end_date? do
	save_input_as :sick_end_date
	#raise SmartAnswer::InvalidResponse if responses.last.before?sick_start_date
	next_node :employee_paid_for_last_8_weeks?
end

## Q8
multiple_choice :employee_paid_for_last_8_weeks? do
	option :yes => :what_was_average_weekly_earnings? ## Q10
	option :no => :what_was_average_weekly_pay?		  ## Q9
end

## Q9 
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
			:related_illness?										## Q11
		end
	end
end


## Q10
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
			:related_illness?									## Q11
		end
	end
end

## Q11 
multiple_choice :related_illness? do
	option :yes => :how_many_days_missed? 						## Q4
	option :no => :how_many_days_worked? 						## Q13
end

## Q12
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
	next_node :how_many_days_worked? 								## Q13
end


## Q13
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

## Q14
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
		sprintf("%.2f", (calculator.ssp_payment < 1 ? 0.0 : calculator.ssp_payment))
	end
	next_node :entitled													## A6
end

## Outcomes

## A1
outcome :already_receiving_benefit
## A2
outcome :must_be_sick_for_at_least_4_days
## A3
outcome :not_informed_soon_enough
## A4
outcome :irregular_work_schedule
## A5
outcome :not_earned_enough
## A6
outcome :entitled

