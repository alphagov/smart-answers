
days_of_the_week = Calculators::MaternityPaternityCalculator::DAYS_OF_THE_WEEK

## QM1
date_question :baby_due_date_maternity? do
  from { 1.year.ago(Date.today) }
  to { 2.years.since(Date.today) }

  calculate :calculator do |response|
    Calculators::MaternityPaternityCalculator.new(response)
  end
  next_node :employment_contract?
end

## QM2
multiple_choice :employment_contract? do
  option :yes
  option :no

  save_input_as :has_employment_contract

  next_node :date_leave_starts?
end

## QM3
date_question :date_leave_starts? do
  from { 2.years.ago(Date.today) }
  to { 2.years.since(Date.today) }

  precalculate :leave_earliest_start_date do
    calculator.leave_earliest_start_date
  end

  calculate :leave_start_date do |response|
    ls_date = response
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
  option yes: :is_the_employee_on_your_payroll?
  option no: :maternity_leave_and_pay_result
  calculate :not_entitled_to_pay_reason do |response|
    response == 'no' ? :not_worked_long_enough : nil
  end
end

## QM5
multiple_choice :is_the_employee_on_your_payroll? do
  option yes: :last_normal_payday? # NOTE: goes to shared questions
  option no: :maternity_leave_and_pay_result

  calculate :not_entitled_to_pay_reason do |response|
    response == 'no' ? :must_be_on_payroll : nil
  end

  calculate :to_saturday do
    calculator.qualifying_week.last
  end

  calculate :to_saturday_formatted do
    calculator.format_date_day to_saturday
  end
end

## QM6
date_question :last_normal_payday? do
  from { 2.years.ago(Date.today) }
  to { 2.years.since(Date.today) }

  calculate :last_payday do |response|
    calculator.last_payday = response
    raise SmartAnswer::InvalidResponse if calculator.last_payday > to_saturday
    calculator.last_payday
  end
  next_node :payday_eight_weeks?
end

## QM7
date_question :payday_eight_weeks? do
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

  next_node :pay_frequency?
end

## QM8
multiple_choice :pay_frequency? do
  save_input_as :pay_pattern
  option :weekly
  option :every_2_weeks
  option :every_4_weeks
  option :monthly

  next_node(:earnings_for_pay_period?)
end

## QM9 Maternity only onwards
money_question :earnings_for_pay_period? do
  calculate :calculator do |response|
    calculator.calculate_average_weekly_pay(pay_pattern, response)
    calculator
  end
  calculate :average_weekly_earnings do
    calculator.average_weekly_earnings
  end
  next_node :how_do_you_want_the_smp_calculated?
end

## QM10
multiple_choice :how_do_you_want_the_smp_calculated? do
  option :weekly_starting
  option :usual_paydates

  save_input_as :smp_calculation_method

  on_condition(responded_with("usual_paydates")) do
    next_node_if(:when_in_the_month_is_the_employee_paid?, variable_matches(:pay_pattern, "monthly"))
    next_node(:when_is_your_employees_next_pay_day?)
  end
  next_node(:maternity_leave_and_pay_result)
end

## QM11
date_question :when_is_your_employees_next_pay_day? do
  calculate :next_pay_day do |response|
    calculator.pay_date = response
    calculator.pay_date
  end

  next_node :maternity_leave_and_pay_result
end

## QM12
multiple_choice :when_in_the_month_is_the_employee_paid? do
  option first_day_of_the_month: :maternity_leave_and_pay_result
  option last_day_of_the_month: :maternity_leave_and_pay_result
  option specific_date_each_month: :what_specific_date_each_month_is_the_employee_paid?
  option last_working_day_of_the_month: :what_days_does_the_employee_work?
  option a_certain_week_day_each_month: :what_particular_day_of_the_month_is_the_employee_paid?

  save_input_as :monthly_pay_method
end

## QM13
value_question :what_specific_date_each_month_is_the_employee_paid?, parse: :to_i do
  calculate :pay_day_in_month do |response|
    day = response
    raise InvalidResponse unless day > 0 and day < 32
    calculator.pay_day_in_month = day
  end

  next_node :maternity_leave_and_pay_result
end

## QM14
checkbox_question :what_days_does_the_employee_work? do
  (0...days_of_the_week.size).each { |i| option i.to_s.to_sym }

  calculate :last_day_in_week_worked do |response|
    calculator.work_days = response.split(",").map(&:to_i)
    calculator.pay_day_in_week = response.split(",").sort.last.to_i
  end
  next_node :maternity_leave_and_pay_result
end

## QM15
multiple_choice :what_particular_day_of_the_month_is_the_employee_paid? do
  days_of_the_week.each { |d| option d.to_sym }

  calculate :pay_day_in_week do |response|
    calculator.pay_day_in_week = days_of_the_week.index(response)
    response
  end
  next_node :which_week_in_month_is_the_employee_paid?
end

## QM16
multiple_choice :which_week_in_month_is_the_employee_paid? do
  option :"first"
  option :"second"
  option :"third"
  option :"fourth"
  option :"last"

  calculate :pay_week_in_month do |response|
    calculator.pay_week_in_month = response
  end
  next_node :maternity_leave_and_pay_result
end

## Maternity outcomes
outcome :maternity_leave_and_pay_result do

  precalculate :pay_method do
    calculator.pay_method = (
      if monthly_pay_method
        if monthly_pay_method == 'specific_date_each_month' and pay_day_in_month > 28
          'last_day_of_the_month'
        else
          monthly_pay_method
        end
      elsif smp_calculation_method == 'weekly_starting'
        smp_calculation_method
      elsif pay_pattern
        pay_pattern
      end
    )
  end
  precalculate :smp_a do
    sprintf("%.2f", calculator.statutory_maternity_rate_a)
  end
  precalculate :smp_b do
    sprintf("%.2f", calculator.statutory_maternity_rate_b)
  end
  precalculate :lower_earning_limit do
    sprintf("%.2f", calculator.lower_earning_limit)
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

  precalculate :total_smp do
    unless not_entitled_to_pay_reason.present?
      sprintf("%.2f", calculator.total_statutory_pay)
    end
  end

  precalculate :maternity_leave_info do |response|
    if has_employment_contract == 'yes'
      PhraseList.new(:maternity_leave_table)
    else
      PhraseList.new(:not_entitled_to_statutory_maternity_leave)
    end
  end

  precalculate :maternity_pay_info do
    if not_entitled_to_pay_reason.present?
      pay_info = PhraseList.new(calculator.average_weekly_earnings ?
                                :not_entitled_to_smp_intro_with_awe : :not_entitled_to_smp_intro)
      pay_info << not_entitled_to_pay_reason
      pay_info << :not_entitled_to_smp_outro
    else
      pay_info = PhraseList.new(:maternity_pay_table, :paydates_table)
    end
    pay_info
  end

  precalculate :pay_dates_and_pay do
    unless not_entitled_to_pay_reason.present?
      calculator.paydates_and_pay.map do |date_and_pay|
        %Q(#{date_and_pay[:date].strftime("%e %B %Y")}|£#{sprintf("%.2f", date_and_pay[:pay])})
      end.join("\n")
    end
  end
end
