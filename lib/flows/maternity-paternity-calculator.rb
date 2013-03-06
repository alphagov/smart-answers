status :published
satisfies_need "B1012"

## Q1
multiple_choice :what_type_of_leave? do
  save_input_as :leave_type
  option :maternity => :baby_due_date_maternity?
  option :paternity => :leave_or_pay_for_adoption?
  option :adoption => :taking_paternity_leave_for_adoption?
end

## QM1
date_question :baby_due_date_maternity? do
  from { 1.year.ago(Date.today) }
  to { 2.years.since(Date.today) }

  calculate :calculator do
    Calculators::MaternityPaternityCalculator.new(Date.parse(responses.last))
  end
  next_node :employment_contract?
end

## QM2
multiple_choice :employment_contract? do
  option :yes
  option :no
  calculate :maternity_leave_info do
    if responses.last == 'yes'
      PhraseList.new(:maternity_leave_table)
    else
      PhraseList.new(:not_entitled_to_statutory_maternity_leave)
    end
  end
  next_node :date_leave_starts?
end

## QM3
date_question :date_leave_starts? do
  from { 2.years.ago(Date.today) }
  to { 2.years.since(Date.today) }

  precalculate :leave_earliest_start_date do
    calculator.leave_earliest_start_date
  end

  calculate :leave_start_date do
    ls_date = Date.parse(responses.last)
    raise SmartAnswer::InvalidResponse if ls_date < leave_earliest_start_date
    calculator.leave_start_date = ls_date
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
  calculate :ssp_stop do
    calculator.ssp_stop
  end
  next_node :did_the_employee_work_for_you?
end

## QM4
multiple_choice :did_the_employee_work_for_you? do
  option :yes => :is_the_employee_on_your_payroll?
  option :no => :maternity_leave_and_pay_result
  calculate :not_entitled_to_pay_reason do
    responses.last == 'no' ? :not_worked_long_enough : nil
  end
end

## QM5
multiple_choice :is_the_employee_on_your_payroll? do
  option :yes => :last_normal_payday? # NOTE: goes to shared questions
  option :no => :maternity_leave_and_pay_result

  calculate :not_entitled_to_pay_reason do
    responses.last == 'no' ? :must_be_on_payroll : nil
  end

  calculate :payday_exit do
    'maternity'
  end
  calculate :to_saturday do
    calculator.format_date_day calculator.qualifying_week.last
  end
end

## QM5.2 && QP6.2 && QA6.2
date_question :last_normal_payday? do
  from { 2.years.ago(Date.today) }
  to { 2.years.since(Date.today) }

  calculate :last_payday do
    calculator.last_payday = Date.parse(responses.last)
    raise SmartAnswer::InvalidResponse if calculator.last_payday > Date.parse(to_saturday)
    calculator.last_payday
  end

  next_node :payday_eight_weeks?
end

## QM5.3 && P6.3 && A6.3
date_question :payday_eight_weeks? do
  from { 2.year.ago(Date.today) }
  to { 2.years.since(Date.today) }

  precalculate :payday_offset do
    calculator.format_date_day calculator.payday_offset
  end

  calculate :last_payday_eight_weeks do
    payday = Date.parse(responses.last)
    payday += 1 if leave_type == 'maternity'
    raise SmartAnswer::InvalidResponse if payday > Date.parse(payday_offset)
    calculator.pre_offset_payday = payday
    payday
  end

  calculate :relevant_period do
    calculator.formatted_relevant_period
  end

  next_node do |response|
    case payday_exit
    when 'maternity'
      :pay_frequency?
    when 'paternity'
      :employees_average_weekly_earnings_paternity?
    when 'paternity_adoption'
      :padoption_employee_avg_weekly_earnings?
    when 'adoption'
      :adoption_employees_average_weekly_earnings?
    end
  end
end

## QM5.4
multiple_choice :pay_frequency? do
  save_input_as :pay_pattern
  option :weekly => :earnings_for_pay_period? ## QM5.5
  option :every_2_weeks => :earnings_for_pay_period? ## QM5.5
  option :every_4_weeks => :earnings_for_pay_period? ## QM5.5
  option :monthly => :earnings_for_pay_period? ## QM5.5
  option :irregularly => :earnings_for_pay_period? ## QM5.5
end

## QM5.5
money_question :earnings_for_pay_period? do
  calculate :calculator do
    raise SmartAnswer::InvalidNode if responses.last < 1
    calculator.calculate_average_weekly_pay(pay_pattern, responses.last)
    calculator
  end
  calculate :average_weekly_earnings do
    calculator.average_weekly_earnings
  end

  next_node :how_do_you_want_the_smp_calculated?
end

## QM7
multiple_choice :how_do_you_want_the_smp_calculated? do
  option :weekly_starting
  option :usual_paydates

  next_node do |response|
    if response == "usual_paydates"
      frequencies = %w(weekly every_2_weeks every_4_weeks irregularly)
      if frequencies.any? { |freq| responses.include? freq }
        :when_is_your_employees_next_pay_day?
      else
        :when_in_the_month_is_the_employee_paid?
      end
    else
      :maternity_leave_and_pay_result
    end
  end
end

## QM8
date_question :when_is_your_employees_next_pay_day? do
  calculate :next_pay_day do
    Date.parse(responses.last)
  end

  next_node :maternity_leave_and_pay_result
end

multiple_choice :when_in_the_month_is_the_employee_paid? do
  option :first_day_of_the_month => :maternity_leave_and_pay_result
  option :last_day_of_the_month => :maternity_leave_and_pay_result
  option :specific_date_each_month => :what_specific_date_each_month_is_the_employee_paid?
  option :last_working_day_of_the_month => :what_days_does_the_employee_work?
end

value_question :what_specific_date_each_month_is_the_employee_paid? do
  calculate :specific_pay_date do
    responses.last
  end
end

multiple_choice :what_days_does_the_employee_work? do
  option :test

  next_node :maternity_leave_and_pay_result
end

## Maternity outcomes
outcome :maternity_leave_and_pay_result do
  precalculate :smp_a do
    sprintf("%.2f", calculator.statutory_maternity_rate_a)
  end
  precalculate :smp_b do
    sprintf("%.2f", calculator.statutory_maternity_rate_b)
  end
  precalculate :lower_earning_limit do
    sprintf("%.2f", calculator.lower_earning_limit)
  end
  precalculate :total_smp do
    sprintf("%.2f", calculator.total_statutory_pay)
  end
  precalculate :notice_request_pay do
    calculator.notice_request_pay
  end

  precalculate :below_threshold do
    calculator.average_weekly_earnings and
      calculator.average_weekly_earnings < calculator.lower_earning_limit
  end

  precalculate :not_entitled_to_pay_reason do
    if below_threshold
      :must_earn_over_threshold
    else
      not_entitled_to_pay_reason
    end
  end

  precalculate :maternity_pay_info do
    if not_entitled_to_pay_reason.present?
      pay_info = PhraseList.new(calculator.average_weekly_earnings ?
                                :not_entitled_to_smp_intro_with_awe : :not_entitled_to_smp_intro)
      pay_info << not_entitled_to_pay_reason
      pay_info << :not_entitled_to_smp_outro
    else
      pay_info = PhraseList.new(:maternity_pay_table)
    end
    pay_info
  end

  calendar do |responses|
    date "Statutory Maternity Leave", responses.leave_start_date..responses.leave_end_date
    date "Latest date to give notice", responses.notice_of_leave_deadline
    date "Earliest date maternity leave can start", responses.leave_earliest_start_date
  end
end


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

  calculate :employment_start do
    calculator.employment_start
  end
  calculate :employment_end do
    due_date
  end
  calculate :p_notice_leave do
    calculator.notice_of_leave_deadline
  end
  calculate :not_entitled_reason do
    PhraseList.new :not_responsible_for_upbringing
  end
	option :yes => :employee_work_before_employment_start?
	option :no => :paternity_not_entitled_to_leave_or_pay # result 5P DP
end

## QP3
multiple_choice :employee_work_before_employment_start? do
	calculate :not_entitled_reason do
    PhraseList.new :not_worked_long_enough
  end
  option :yes => :employee_has_contract_paternity?
	option :no => :paternity_not_entitled_to_leave_or_pay # result 5P EP
end

## QP4
multiple_choice :employee_has_contract_paternity? do
	option :yes
	option :no
	calculate :paternity_leave_info do
    if responses.last == 'yes'
      PhraseList.new(:paternity_entitled_to_leave)
    else
      PhraseList.new(:paternity_not_entitled_to_leave)
    end
  end
  next_node :employee_employed_at_employment_end_paternity?
end

## QP5
multiple_choice :employee_employed_at_employment_end_paternity? do
	option :yes => :employee_on_payroll_paternity?
  option :no => :paternity_leave_and_pay #4P_AP
  calculate :paternity_pay_info do
    if responses.last == 'no'
      pay_info = PhraseList.new (:paternity_not_entitled_to_pay_intro)
      pay_info << :must_be_employed_by_you
      pay_info << :paternity_not_entitled_to_pay_outro
    end
    pay_info
  end
end


## QP6
multiple_choice :employee_on_payroll_paternity? do
	option :yes => :last_normal_payday? # NOTE: this goes to a shared question => QM5.2
  option :no => :paternity_leave_and_pay # 4P BP
  calculate :paternity_pay_info do
    if responses.last == 'no'
      pay_info = PhraseList.new (:paternity_not_entitled_to_pay_intro)
      pay_info << :must_be_on_payroll
      pay_info << :paternity_not_entitled_to_pay_outro
    end
    pay_info
  end

  calculate :payday_exit do
    'paternity'
  end
  calculate :to_saturday do
    calculator.format_date_day calculator.qualifying_week.last
  end
end

## QP7
money_question :employees_average_weekly_earnings_paternity? do
	calculate :spp_rate do
    calculator.average_weekly_earnings = responses.last
    sprintf("%.2f",calculator.statutory_paternity_rate)
  end
  calculate :lower_earning_limit do
    sprintf("%.2f",calculator.lower_earning_limit)
  end
  calculate :paternity_pay_info do
    if responses.last >= calculator.lower_earning_limit
			pay_info = PhraseList.new(:paternity_entitled_to_pay)
		else
			pay_info = PhraseList.new(:paternity_not_entitled_to_pay_intro)
			pay_info << :must_earn_over_threshold
      pay_info << :paternity_not_entitled_to_pay_outro
    end
    pay_info
	end
  next_node :paternity_leave_and_pay
end

# Paternity outcomes
outcome :paternity_leave_and_pay
outcome :paternity_not_entitled_to_leave_or_pay



## Paternity Adoption

## QAP1
date_question :employee_date_matched_paternity_adoption? do
	calculate :matched_date do
    Date.parse(responses.last)
  end
  calculate :calculator do
    Calculators::MaternityPaternityCalculator.new(matched_date, Calculators::MaternityPaternityCalculator::LEAVE_TYPE_ADOPTION)
  end
  next_node :padoption_date_of_adoption_placement?
end

## QAP2
date_question :padoption_date_of_adoption_placement? do

  calculate :ap_adoption_date do
    placement_date = Date.parse(responses.last)
    raise SmartAnswer::InvalidResponse if placement_date < matched_date
    calculator.adoption_placement_date = placement_date
    placement_date
  end
  calculate :ap_adoption_date_formatted do
    calculator.format_date_day ap_adoption_date
  end

  calculate :employment_start do
    calculator.a_employment_start
  end
  calculate :matched_date_formatted do
    calculator.format_date_day matched_date
  end
  calculate :employment_end do
    matched_date
  end
  next_node :padoption_employee_responsible_for_upbringing?
end

## QAP3
multiple_choice :padoption_employee_responsible_for_upbringing? do
	calculate :not_entitled_reason do
    PhraseList.new :not_responsible_for_upbringing
  end
  option :yes => :padoption_employee_start_on_or_before_employment_start?
	option :no => :padoption_not_entitled_to_leave_or_pay #5AP DP
end

## QAP4
multiple_choice :padoption_employee_start_on_or_before_employment_start? do
	calculate :not_entitled_reason do
    PhraseList.new :not_worked_long_enough
  end
  option :yes => :padoption_have_employee_contract?
	option :no => :padoption_not_entitled_to_leave_or_pay #5AP EP
end

## QAP5
multiple_choice :padoption_have_employee_contract? do
	option :yes
	option :no

  calculate :padoption_leave_info do
    if responses.last == 'yes'
      PhraseList.new(:padoption_entitled_to_leave)
    else
      PhraseList.new(:padoption_not_entitled_to_leave)
    end
  end

  next_node :padoption_employed_at_employment_end?
end

## QAP6
multiple_choice :padoption_employed_at_employment_end? do
  option :yes => :padoption_employee_on_payroll?
  option :no => :padoption_leave_and_pay # 4AP AP
	calculate :padoption_pay_info do
    if responses.last == 'no'
      pay_info = PhraseList.new (:padoption_not_entitled_to_pay_intro)
      pay_info << :pa_must_be_employed_by_you
      pay_info << :padoption_not_entitled_to_pay_outro
      #not entitled to pay so add form download links to end of leave info if they were entitled to leave
      if padoption_leave_info.phrase_keys.include?(:padoption_entitled_to_leave)
        padoption_leave_info << :padoption_leave_and_pay_forms
      end
    end
    pay_info
  end
end

## QAP7
multiple_choice :padoption_employee_on_payroll? do
  option :yes => :last_normal_payday? # NOTE: goes to shared questions
  option :no => :padoption_leave_and_pay # 4AP BP
	calculate :padoption_pay_info do
    if responses.last == 'no'
      pay_info = PhraseList.new(:padoption_not_entitled_to_pay_intro)
      pay_info << :must_be_on_payroll
      pay_info << :padoption_not_entitled_to_pay_outro
      #not entitled to pay so add form download links to end of leave info if they were entitled to leave
      if padoption_leave_info.phrase_keys.include?(:padoption_entitled_to_leave)
        padoption_leave_info << :padoption_leave_and_pay_forms
      end
    end
    pay_info
  end

  calculate :payday_exit do
    'paternity_adoption'
  end
  calculate :to_saturday do
    calculator.format_date_day calculator.matched_week.last
  end
end


## QAP8
money_question :padoption_employee_avg_weekly_earnings? do
  calculate :sapp_rate do
    calculator.average_weekly_earnings = responses.last
    sprintf("%.2f", calculator.statutory_paternity_rate)
  end
  calculate :lower_earning_limit do
    sprintf("%.2f", calculator.lower_earning_limit)
  end
  calculate :padoption_pay_info do
    if responses.last >= calculator.lower_earning_limit
      pay_info = PhraseList.new(:padoption_entitled_to_pay)
      pay_info << :padoption_leave_and_pay_forms
    else
      pay_info = PhraseList.new(:padoption_not_entitled_to_pay_intro)
      pay_info << :must_earn_over_threshold
      pay_info << :padoption_not_entitled_to_pay_outro
      #not entitled to pay so add form download links to end of leave info if they were entitled to leave
      if padoption_leave_info.phrase_keys.include?(:padoption_entitled_to_leave)
        padoption_leave_info << :padoption_leave_and_pay_forms
      end
    end
    pay_info
  end

  next_node :padoption_leave_and_pay
end

## Paternity Adoption Results
outcome :padoption_leave_and_pay
outcome :padoption_not_entitled_to_leave_or_pay



## Adoption
## QA0
multiple_choice :taking_paternity_leave_for_adoption? do
  option :yes => :employee_date_matched_paternity_adoption? #QAP1
  option :no => :date_of_adoption_match? # QA1
end

## QA1
date_question :date_of_adoption_match? do
  calculate :match_date do
    Date.parse(responses.last)
  end
  calculate :calculator do
    Calculators::MaternityPaternityCalculator.new(match_date, Calculators::MaternityPaternityCalculator::LEAVE_TYPE_ADOPTION)
  end
  next_node :date_of_adoption_placement?
end

## QA2
date_question :date_of_adoption_placement? do
  calculate :adoption_placement_date do
    placement_date = Date.parse(responses.last)
    raise SmartAnswer::InvalidResponse if placement_date < match_date
    calculator.adoption_placement_date = placement_date
    placement_date
  end
  calculate :a_leave_earliest_start do
    calculator.format_date (adoption_placement_date - 14)
  end
  next_node :adoption_employment_contract?
end

## QA3
multiple_choice :adoption_employment_contract? do
  option :yes
  option :no

  save_input_as :employee_has_contract_adoption

  #not entitled to leave if no contract; keep asking questions to check eligibility
  calculate :adoption_leave_info do
    if responses.last == 'no'
      PhraseList.new(:adoption_not_entitled_to_leave)
    end
  end
  next_node :adoption_date_leave_starts?
end

## QA4
date_question :adoption_date_leave_starts? do
  calculate :adoption_date_leave_starts do
    ald_start = Date.parse(responses.last)
    raise SmartAnswer::InvalidResponse if ald_start < Date.parse(a_leave_earliest_start)
    calculator.adoption_leave_start_date = ald_start
  end

  calculate :leave_start_date do
    calculator.leave_start_date
  end
  calculate :leave_end_date do
    calculator.leave_end_date
  end

  calculate :pay_start_date do
    calculator.pay_start_date
  end
  calculate :pay_end_date do
    calculator.pay_end_date
  end
  calculate :employment_start do
    calculator.a_employment_start
  end

  calculate :a_notice_leave do
    calculator.format_date calculator.a_notice_leave
  end

  next_node :adoption_did_the_employee_work_for_you?
end

## QA5
multiple_choice :adoption_did_the_employee_work_for_you? do
  option :yes => :adoption_is_the_employee_on_your_payroll?
  option :no => :adoption_not_entitled_to_leave_or_pay
  #at this point we know for sure if employee is entitled to leave
  calculate :adoption_leave_info do
    if (responses.last == 'yes') and (employee_has_contract_adoption == 'yes')
      PhraseList.new(:adoption_leave_table)
    else
      PhraseList.new(:adoption_not_entitled_to_leave)
    end
  end
end

## QA6
multiple_choice :adoption_is_the_employee_on_your_payroll? do
  option :yes => :last_normal_payday? # NOTE: this goes to a shared question => QM5.2
  option :no => :adoption_leave_and_pay
  calculate :adoption_pay_info do
    if responses.last == 'no'
      pay_info = PhraseList.new(:adoption_not_entitled_to_pay_intro)
      pay_info << :must_be_on_payroll
      pay_info << :adoption_not_entitled_to_pay_outro
    end
    pay_info
  end


  calculate :payday_exit do
    'adoption'
  end
  calculate :to_saturday do
    calculator.format_date_day calculator.matched_week.last
  end
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
 calculate :adoption_pay_info do
    if responses.last >= calculator.lower_earning_limit
      PhraseList.new(:adoption_pay_table)
    else
      pay_info = PhraseList.new(:adoption_not_entitled_to_pay_intro)
      pay_info << :must_earn_over_threshold
      pay_info << :adoption_not_entitled_to_pay_outro
      pay_info
    end
  end
  next_node :adoption_leave_and_pay
end

outcome :adoption_leave_and_pay
outcome :adoption_not_entitled_to_leave_or_pay
