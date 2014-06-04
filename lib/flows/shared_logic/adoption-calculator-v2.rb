## QA0
multiple_choice :taking_paternity_leave_for_adoption? do
  option yes: :employee_date_matched_paternity_adoption? #QAP1
  option no: :date_of_adoption_match? # QA1
end

## QA1
date_question :date_of_adoption_match? do
  calculate :match_date do
    Date.parse(responses.last)
  end
  calculate :calculator do
    Calculators::MaternityPaternityCalculatorV2.new(match_date, "adoption")
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
  option yes: :adoption_is_the_employee_on_your_payroll?
  option no: :adoption_not_entitled_to_leave_or_pay
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
  option yes: :last_normal_payday? # NOTE: this goes to a shared question => QM5.2
  option no: :adoption_leave_and_pay
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
