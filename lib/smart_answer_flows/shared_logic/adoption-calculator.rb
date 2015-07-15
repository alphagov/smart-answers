## QA0
multiple_choice :taking_paternity_leave_for_adoption? do
  option yes: :employee_date_matched_paternity_adoption? #QAP1
  option no: :date_of_adoption_match? # QA1
end

## QA1
date_question :date_of_adoption_match? do
  calculate :match_date do |response|
    response
  end
  calculate :calculator do
    Calculators::MaternityPaternityCalculator.new(match_date, "adoption")
  end

  next_node :date_of_adoption_placement?
end

## QA2
date_question :date_of_adoption_placement? do
  calculate :adoption_placement_date do |response|
    placement_date = response
    raise SmartAnswer::InvalidResponse if placement_date < match_date
    calculator.adoption_placement_date = placement_date
    placement_date
  end

  calculate :a_leave_earliest_start do
    adoption_placement_date - 14
  end

  calculate :a_leave_earliest_start_formatted do
    calculator.format_date a_leave_earliest_start
  end

  calculate :employment_start do
    calculator.a_employment_start
  end
  next_node :adoption_did_the_employee_work_for_you?
end

## QA3
multiple_choice :adoption_did_the_employee_work_for_you? do
  option yes: :adoption_employment_contract?
  option no: :adoption_not_entitled_to_leave_or_pay
end

## QA4
multiple_choice :adoption_employment_contract? do
  option :yes
  option :no

  save_input_as :employee_has_contract_adoption

  next_node :adoption_is_the_employee_on_your_payroll?
end

## QA5
multiple_choice :adoption_is_the_employee_on_your_payroll? do
  option :yes
  option :no

  save_input_as :on_payroll

  calculate :to_saturday do
    calculator.matched_week.last
  end

  calculate :to_saturday_formatted do
    calculator.format_date_day to_saturday
  end

  define_predicate(:no_contract_not_on_payroll?) do |response|
    employee_has_contract_adoption == 'no' && response == 'no'
  end

  next_node_if(:adoption_not_entitled_to_leave_or_pay, no_contract_not_on_payroll?)
  next_node :adoption_date_leave_starts?
end

## QA6
date_question :adoption_date_leave_starts? do
  calculate :adoption_date_leave_starts do |response|
    ald_start = response
    raise SmartAnswer::InvalidResponse if ald_start < a_leave_earliest_start
    calculator.leave_start_date = ald_start
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

  calculate :a_notice_leave do
    calculator.format_date calculator.a_notice_leave
  end

  define_predicate(:has_contract_not_on_payroll?) do
    employee_has_contract_adoption == 'yes' && on_payroll == 'no'
  end

  next_node_if(:adoption_leave_and_pay, has_contract_not_on_payroll?)
  next_node :last_normal_payday_adoption?
end

# QA7
date_question :last_normal_payday_adoption? do
  from { 2.years.ago(Date.today) }
  to { 2.years.since(Date.today) }

  calculate :last_payday do |response|
    calculator.last_payday = response
    raise SmartAnswer::InvalidResponse if calculator.last_payday > to_saturday
    calculator.last_payday
  end
  next_node :payday_eight_weeks_adoption?
end

# QA8
date_question :payday_eight_weeks_adoption? do
  from { 2.year.ago(Date.today) }
  to { 2.years.since(Date.today) }

  precalculate :payday_offset do
    calculator.payday_offset
  end

  precalculate :payday_offset_formatted do
    calculator.format_date_day payday_offset
  end

  calculate :last_payday_eight_weeks do |response|
    payday = response + 1.day
    raise SmartAnswer::InvalidResponse if payday > payday_offset
    calculator.pre_offset_payday = payday
    payday
  end

  calculate :relevant_period do
    calculator.formatted_relevant_period
  end

  next_node :pay_frequency_adoption?
end

# QA9
multiple_choice :pay_frequency_adoption? do
  option weekly: :earnings_for_pay_period_adoption?
  option every_2_weeks: :earnings_for_pay_period_adoption?
  option every_4_weeks: :earnings_for_pay_period_adoption?
  option monthly: :earnings_for_pay_period_adoption?
  save_input_as :pay_pattern

  calculate :calculator do |response|
    calculator.pay_method = response
    calculator
  end
end

## QA10
money_question :earnings_for_pay_period_adoption? do

 calculate :lower_earning_limit do
   sprintf("%.2f", calculator.lower_earning_limit)
 end

  calculate :average_weekly_earnings do
    sprintf("%.2f", calculator.average_weekly_earnings)
  end

  calculate :above_lower_earning_limit do
    calculator.average_weekly_earnings > calculator.lower_earning_limit
  end

  next_node_calculation :calculator do |response|
    calculator.calculate_average_weekly_pay(pay_pattern, response)
    calculator
  end

  define_predicate(:average_weekly_earnings_under_lower_earning_limit?) do
    calculator.average_weekly_earnings < calculator.lower_earning_limit
  end

  next_node_if(:adoption_leave_and_pay, average_weekly_earnings_under_lower_earning_limit?)
  next_node :how_do_you_want_the_sap_calculated?
end

## QA11
multiple_choice :how_do_you_want_the_sap_calculated? do
  option :weekly_starting
  option :usual_paydates

  save_input_as :sap_calculation_method

  next_node_if(:adoption_leave_and_pay, responded_with('weekly_starting'))
  next_node_if(:monthly_pay_paternity?, variable_matches(:pay_pattern, 'monthly')) ## Shared with paternity calculator
  next_node :next_pay_day_paternity? ## Shared with paternity calculator
end

outcome :adoption_leave_and_pay, use_outcome_templates: true do
  precalculate :pay_method do
    calculator.pay_method = (
      if monthly_pay_method
        if monthly_pay_method == 'specific_date_each_month' and pay_day_in_month > 28
          'last_day_of_the_month'
        else
          monthly_pay_method
        end
      elsif sap_calculation_method == 'weekly_starting'
        sap_calculation_method
      else
        pay_pattern
      end
    )
  end

  precalculate :pay_dates_and_pay do
    if above_lower_earning_limit
      calculator.paydates_and_pay.map do |date_and_pay|
        %Q(#{date_and_pay[:date].strftime("%e %B %Y")}|£#{sprintf("%.2f", date_and_pay[:pay])})
      end.join("\n")
    end
  end

  precalculate :total_sap do
    if above_lower_earning_limit
      sprintf("%.2f", calculator.total_statutory_pay)
    end
  end
end

outcome :adoption_not_entitled_to_leave_or_pay
