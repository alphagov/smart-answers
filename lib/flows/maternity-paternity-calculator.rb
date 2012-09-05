status :draft
section_slug "money-and-tax"
subsection_slug "tax"
satisfies_need "2013"

## Q1
multiple_choice :what_type_of_leave? do
  option :maternity => :baby_due_date_maternity?
  option :paternity => :leave_or_pay_for_adoption?
  option :adoption => :maternity_or_paternity_leave_for_adoption?
end

## QM1
date_question :baby_due_date_maternity? do
  calculate :calculator do
    Calculators::MaternityPaternityCalculator.new(Date.parse(responses.last))
  end
  next_node :employment_contract?
end

## QM2
multiple_choice :employment_contract? do
  option :yes
  option :no
  calculate :maternity_leave_result do
    if responses.last == 'yes'
      PhraseList.new(:maternity_leave_table)
    else
      ''
    end
  end
  next_node :date_leave_starts?
end

## QM3
date_question :date_leave_starts? do
  calculate :leave_start_date do
    calculator.leave_start_date = Date.parse(responses.last)
    calculator.leave_start_date
  end
  calculate :leave_end_date do
    calculator.leave_end_date
  end
  calculate :leave_earliest_start_date do
    calculator.leave_earliest_start_date
  end
  calculate :notice_of_leave_deadline do
    calculator.notice_of_leave_deadline
  end
  calculate :pay_start_date do
    calculator.pay_start_date
  end
  calculate :pay_end_date do
    calculator.pay_end_date
  end
  calculate :employment_start do
    calculator.employment_start
  end
  next_node :did_the_employee_work_for_you?
end

## QM4
multiple_choice :did_the_employee_work_for_you? do
  option :yes => :is_the_employee_on_your_payroll?
  option :no => :not_entitled_to_statutory_maternity_pay
  calculate :not_entitled_to_pay_reason do
    PhraseList.new :not_worked_long_enough
  end
end

## QM5
multiple_choice :is_the_employee_on_your_payroll? do
  option :yes => :employees_average_weekly_earnings?
  option :no => :not_entitled_to_statutory_maternity_pay
  calculate :relevant_period do
    calculator.relevant_period
  end
  calculate :not_entitled_to_pay_reason do
    PhraseList.new :must_be_on_payroll
  end
end

## QM6
money_question :employees_average_weekly_earnings? do
  calculate :calculator do
    calculator.average_weekly_earnings = responses.last
    calculator
  end
  calculate :smp_a do
    sprintf("%.2f", calculator.statutory_maternity_rate_a)
  end
  calculate :smp_b do
    sprintf("%.2f", calculator.statutory_maternity_rate_b)
  end
  calculate :lower_earning_limit do
    sprintf("%.2f", calculator.lower_earning_limit)
  end
  calculate :not_entitled_to_pay_reason do
    PhraseList.new :must_earn_over_threshold
  end
  next_node do |response|
    if response > calculator.lower_earning_limit
      :maternity_leave_and_pay_result
    else
      :not_entitled_to_statutory_maternity_pay
    end
  end
end

## Maternity outcomes
outcome :maternity_leave_and_pay_result
outcome :not_entitled_to_statutory_maternity_leave ## R3M
outcome :not_entitled_to_statutory_maternity_pay ## R4M


## Paternity 

## QP0
multiple_choice :leave_or_pay_for_adoption? do
	option :yes => :employee_date_matched_paternity_adoption?
	option :no => :baby_due_date_paternity?
end

## QP1
date_question :baby_due_date_paternity? do
  calculate :due_date do
    Date.parse(responses.last)
  end
  calculate :calculator do
    Calculators::MaternityPaternityCalculator.new(due_date)
  end
	next_node :employee_responsible_for_upbringing?  
end

## QP2
multiple_choice :employee_responsible_for_upbringing? do
  calculate :relevant_period do
    calculator.relevant_period
  end
  calculate :employment_start do
    calculator.employment_start
  end
  calculate :employment_end do
    due_date
  end
  calculate :p_notice_leave do
    calculator.notice_of_leave_deadline
  end
	option :biological_father => :employee_work_before_employment_start?
	option :mothers_husband_or_partner => :employee_work_before_employment_start?
	option :neither => :paternity_not_entitled_to_leave_or_pay # result 5P DP
end

## QP3
multiple_choice :employee_work_before_employment_start? do
	option :yes => :employee_has_contract_paternity?
	option :no => :paternity_not_entitled_to_leave_or_pay # result 5P EP
end

## QP4
multiple_choice :employee_has_contract_paternity? do
	# NOTE: QP5 is skipped - go straight to QP6 
	option :yes #=> :employee_employed_at_employment_end_paternity?
	option :no #=> :paternity_not_entitled_to_leave # result 3P
	next_node do |response|
    if response == 'yes'
      :employee_employed_at_employment_end_paternity?
    else
      :paternity_not_entitled_to_leave
    end
  end
end

## QP6
multiple_choice :employee_employed_at_employment_end_paternity? do
	option :yes => :employee_on_payroll_paternity?
	option :no => :paternity_not_entitled_to_pay # 4P AP
end


## QP7
multiple_choice :employee_on_payroll_paternity? do
	option :yes => :employee_average_weekly_earnings_paternity?
	option :no => :paternity_not_entitled_to_pay # 4P AP
end

## QP8
money_question :employee_average_weekly_earnings_paternity? do
	calculate :spp_rate do
    calculator.average_weekly_earnings = responses.last
    calculator.statutory_paternity_rate
  end
  calculate :lower_earning_limit do
    calculator.lower_earning_limit
  end
  next_node do |response|
    
    if response > calculator.lower_earning_limit
			# 2P
			:paternity_entitled_to_pay
		else
			# 4P
			:paternity_not_entitled_to_pay
		end
	end
end

# Paternity outcomes
# result_1P - entitled to leave
outcome :paternity_entitled_to_leave
# result_2P - entitled to pay
outcome :paternity_entitled_to_pay 
# result_3P - not entitled to leave
outcome :paternity_not_entitled_to_leave
# result_4P - not entitled to pay
outcome :paternity_not_entitled_to_pay
# result_5P – not entitled to leave or pay
outcome :paternity_not_entitled_to_leave_or_pay





## Paternity Adoption

## QAP1
date_question :employee_date_matched_paternity_adoption? do
	calculate :matched_date do
    Date.parse(responses.last)
  end
  calculate :calculator do
    Calculators::MaternityPaternityCalculator.new(matched_date)
  end
  next_node :padoption_date_of_adoption_placement?
end

## QAP1.2
date_question :padoption_date_of_adoption_placement? do
  calculate :ap_qualifying_week do 
    calculator.qualifying_week
  end
  calculate :relevant_period do
    calculator.relevant_period
  end
  calculate :employment_start do 
    calculator.employment_start
  end
  calculate :employment_end do 
    matched_date
  end
  next_node :padoption_employee_responsible_for_upbringing?
end

## QAP2
multiple_choice :padoption_employee_responsible_for_upbringing? do
	option :yes => :padoption_employee_start_on_or_before_employment_start?
	option :no => :padoption_not_entitled_to_leave_or_pay #5AP
end

## QAP3
multiple_choice :padoption_employee_start_on_or_before_employment_start? do
	option :yes => :padoption_have_employee_contract?
	option :no => :padoption_not_entitled_to_leave_or_pay #5AP
end

## QAP4
multiple_choice :padoption_have_employee_contract? do
	# NOTE: goes straight to QAP6 
	option :yes => :padoption_employed_at_employment_end?
	option :no => :padoption_not_entitled_to_leave # 3AP
end

## QAP6
multiple_choice :padoption_employed_at_employment_end? do
	option :yes => :padoption_employee_on_payroll?
	option :no => :padoption_not_entitled_to_pay # 4AP
end

## QAP7
multiple_choice :padoption_employee_on_payroll? do
	option :yes => :padoption_employee_avg_weekly_earnings?
	option :no => :padoption_not_entitled_to_pay # 4AP
end

## QAP8
money_question :padoption_employee_avg_weekly_earnings? do
  calculate :sapp_rate do
    calculator.average_weekly_earnings = responses.last
    calculator.statutory_paternity_rate
  end
  calculate :lower_earning_limit do
    calculator.lower_earning_limit
  end
  next_node do |response|
    if response > calculator.lower_earning_limit
      # 2P
      :padoption_entitled_to_pay
    else
      # 4P
      :padoption_not_entitled_to_pay
    end
  end
end

## Paternity Adoption Results
# result_1AP - entitled to leave
outcome :padoption_entitled_to_leave
# result_2AP - entitled to pay
outcome :padoption_entitled_to_pay
# result_3AP - not entitled to leave
outcome :padoption_not_entitled_to_leave
# result_4AP - not entitled to pay
outcome :padoption_not_entitled_to_pay
# result_5AP – not entitled to leave or pay
outcome :padoption_not_entitled_to_leave_or_pay



## Adoption
## QA0
multiple_choice :maternity_or_paternity_leave_for_adoption? do
  option :maternity => :date_of_adoption_match? # QA1
#  option :paternity =>
end

## QA1
date_question :date_of_adoption_match? do
  calculate :calculator do
    Calculators::MaternityPaternityCalculator.new(Date.parse(responses.last))
  end
  next_node :date_of_adoption_placement?
end

## QA2
date_question :date_of_adoption_placement? do
  calculate :adoption_placement_date do
    placement_date = Date.parse(responses.last)
    calculator.adoption_placement_date = placement_date
    placement_date
  end
  next_node :adoption_employment_contract?
end

## QA3
multiple_choice :adoption_employment_contract? do
  option :yes => :adoption_date_leave_starts?
  option :no => :adoption_not_entitled_to_leave
end

## QA4
date_question :adoption_date_leave_starts? do
  calculate :adoption_date_leave_starts do
    calculator.adoption_leave_start_date = Date.parse(responses.last)
  end
  calculate :leave_start_date do
    calculator.leave_start_date
  end
  calculate :leave_end_date do
    calculator.leave_end_date
  end
  calculate :leave_earliest_start_date do
    calculator.leave_earliest_start_date
  end
  calculate :pay_start_date do
    calculator.pay_start_date
  end
  calculate :pay_end_date do
    calculator.pay_end_date
  end
  calculate :employment_start do
    calculator.employment_start
  end
  next_node :adoption_did_the_employee_work_for_you?
end

## QA5
multiple_choice :adoption_did_the_employee_work_for_you? do
  option :yes => :adoption_is_the_employee_on_your_payroll?
  option :no => :adoption_not_entitled_to_leave_or_pay
  calculate :relevant_period do
    calculator.relevant_period
  end
  calculate :adoption_pay_inelligibility_reason do
    PhraseList.new :not_worked_long_enough
  end
end

## QA6
multiple_choice :adoption_is_the_employee_on_your_payroll? do
  calculate :adoption_pay_inelligibility_reason do
    PhraseList.new :must_be_on_payroll
  end
  option :yes => :adoption_employees_average_weekly_earnings?
  option :no => :adoption_not_entitled_to_pay
end

## QA7
money_question :adoption_employees_average_weekly_earnings? do
 calculate :sap_rate do
  calculator.average_weekly_earnings = responses.last
  sprintf("%.2f", calculator.statutory_adoption_rate)
 end
 calculate :lower_earning_limit do
   sprintf("%.2f", calculator.lower_earning_limit)
 end
 calculate :adoption_pay_inelligibility_reason do
   PhraseList.new :must_earn_over_threshold
 end
 next_node do |response|
    if response > calculator.lower_earning_limit
      :adoption_leave_and_pay
    else
      :adoption_not_entitled_to_pay
    end
  end
end

outcome :adoption_leave_and_pay
outcome :adoption_not_entitled_to_leave
outcome :adoption_not_entitled_to_pay
outcome :adoption_not_entitled_to_leave_or_pay
