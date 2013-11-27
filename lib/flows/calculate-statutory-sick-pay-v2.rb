status :draft
satisfies_need "2013"

# Question 1
checkbox_question :is_your_employee_getting? do
  option :statutory_maternity_pay
  option :maternity_allowance
  option :ordinary_statutory_paternity_pay
  option :statutory_adoption_pay

  calculate :employee_not_entitled_pdf do
    # this avoids lots of content duplication in the YML
    PhraseList.new(:ssp_link)
  end
  calculate :paternity_maternity_warning do
    (responses.last.split(",") & %w{ordinary_statutory_paternity_pay statutory_adoption_pay}).any?
  end
  next_node do |response|
    if (response.split(",") & %w{ordinary_statutory_paternity_pay statutory_adoption_pay none}).any?
      # Question 2
      :employee_tell_within_limit?
    else
      # Answer 1
      :already_getting_maternity
    end
  end
end

# Question 2
multiple_choice :employee_tell_within_limit? do
	option :yes => :employee_work_different_days? # Question 5
	option :no => :didnt_tell_soon_enough # Answer 3
end

# Question 3
multiple_choice :employee_work_different_days? do
	option :yes => :not_regular_schedule # Answer 4
	option :no => :first_sick_day? # Question 4
end

# Question 4
date_question :first_sick_day? do
  calculate :sick_start_date do
    Date.parse(responses.last).strftime("%e %B %Y")
  end

  next_node :last_sick_day?

end

# Question 5
date_question :last_sick_day? do
  calculate :sick_end_date do
    Date.parse(responses.last).strftime("%e %B %Y")
  end

  next_node do |response|
    start_date = Date.parse(sick_start_date)
    last_day_sick = Date.parse(response)
    days_sick = (last_day_sick - start_date).to_i + 1

    if days_sick < 1
      # invalid
      raise SmartAnswer::InvalidResponse
    end

    days_sick > 3 ? :last_payday_before_sickness? : :must_be_sick_for_4_days
  end

end

# Question 6
date_question :last_payday_before_sickness? do

  calculate :relevant_period_to do
    Date.parse(responses.last).strftime("%e %B %Y")
  end

  calculate :pay_day_offset do
    (Date.parse(relevant_period_to) - 8.weeks).strftime("%e %B %Y")
  end


  next_node do |response|
    payday = Date.parse(response)
    start = Date.parse(sick_start_date)

    unless payday < start
      raise SmartAnswer::InvalidResponse
    end

    :last_payday_before_offset?
  end
end

# Question 7
date_question :last_payday_before_offset? do
  # input plus 1 day = relevant_period_from
  calculate :relevant_period_from do
    (Date.parse(responses.last) + 1.day).strftime("%e %B %Y")
  end
   # You must enter a date on or before [pay_day_offset]
  next_node do |response|
    day = Date.parse(response)
    if day > Date.parse(pay_day_offset)
      raise SmartAnswer::InvalidResponse
    end
    :how_often_pay_employee?
  end
end

# Question 7.4
multiple_choice :how_often_pay_employee? do
  option :weekly
  option :fortnightly
  option :every_4_weeks
  option :monthly
  option :irregularly

  save_input_as :pay_pattern

  calculate :monthly_pattern_payments do
    start_date = Date.parse(relevant_period_from)
    end_date = Date.parse(relevant_period_to)
    Calculators::StatutorySickPayCalculatorV2.months_between(start_date, end_date)
  end

  next_node :on_start_date_8_weeks_paid?
end

# Question 8
multiple_choice :on_start_date_8_weeks_paid? do
  option :yes => :total_employee_earnings? # Question 10
  option :no => :employee_average_earnings? # Question 11
end

# Question 9
money_question :total_employee_earnings? do
  save_input_as :relevant_period_pay
  calculate :relevant_period_awe do
    Calculators::StatutorySickPayCalculatorV2.average_weekly_earnings(
      pay: relevant_period_pay, pay_pattern: pay_pattern, monthly_pattern_payments: monthly_pattern_payments,
      relevant_period_to: relevant_period_to, relevant_period_from: relevant_period_from)
  end

  next_node do |response|
    relevant_period_pay = Money.new(response)
    relevant_pay_awe = Calculators::StatutorySickPayCalculatorV2.average_weekly_earnings(
      pay: relevant_period_pay, pay_pattern: pay_pattern, monthly_pattern_payments: monthly_pattern_payments,
      relevant_period_to: relevant_period_to, relevant_period_from: relevant_period_from)

    if relevant_pay_awe < Calculators::StatutorySickPayCalculatorV2.lower_earning_limit_on(Date.parse(sick_start_date))
      # Answer 5
      :not_earned_enough
    else
      # Question 12
      :off_sick_4_days?
    end
  end

end

# Question 10
money_question :employee_average_earnings? do
  next_node do |response|
    if response < Calculators::StatutorySickPayCalculatorV2.lower_earning_limit_on(Date.parse(sick_start_date))
       # Answer 5
      :not_earned_enough
    else
      # Question 12
      :off_sick_4_days?
    end
  end
end

# Q11
multiple_choice :off_sick_4_days? do
  option :yes => :how_many_days_sick?
  option :no => :usual_work_days?

  calculate :previous_sickness do
    responses.last == "yes"
  end
end

# Q12
value_question :how_many_days_sick? do
  save_input_as :prior_sick_days
  next_node :usual_work_days?
end

# Q13
checkbox_question :usual_work_days? do
  %w{1 2 3 4 5 6 0}.each { |n| option n.to_s }

  calculate :calculator do
    calculator = Calculators::StatutorySickPayCalculatorV2.new(prior_sick_days.to_i, Date.parse(sick_start_date), Date.parse(sick_end_date), responses.last.split(","))
  end

  calculate :ssp_payment do
    Money.new(calculator.ssp_payment)
  end

  calculate :formatted_sick_pay_weekly_amounts do
    calculator = Calculators::StatutorySickPayCalculatorV2.new(prior_sick_days.to_i, Date.parse(sick_start_date), Date.parse(sick_end_date), responses.last.split(","))

    if calculator.ssp_payment > 0
      calculator.formatted_sick_pay_weekly_amounts
    else
      ""
    end
  end

  next_node do |response|
    calculator = Calculators::StatutorySickPayCalculatorV2.new(prior_sick_days.to_i, Date.parse(sick_start_date), Date.parse(sick_end_date), response.split(","))

    days_worked = response.split(',').size

    if prior_sick_days and prior_sick_days.to_i >= (days_worked * 28 + 3)
      # Answer 8
      :maximum_entitlement_reached
    elsif calculator.ssp_payment > 0
      # Answer 6
      :entitled_to_sick_pay
    elsif calculator.days_that_can_be_paid_for_this_period == 0
      # Answer 8
      :maximum_entitlement_reached
    else
      # Answer 7
      :not_entitled_3_days_not_paid
    end

  end
end

# Answer 1
outcome :already_getting_maternity

# Answer 2
outcome :must_be_sick_for_4_days

# Answer 3
outcome :didnt_tell_soon_enough

# Answer 4
outcome :not_regular_schedule

# Answer 5
outcome :not_earned_enough

# Answer 6
outcome :entitled_to_sick_pay do
  precalculate :days_paid do calculator.days_paid end
  precalculate :normal_workdays_out do calculator.normal_workdays end
  precalculate :pattern_days do calculator.pattern_days end
  precalculate :pattern_days_total do calculator.pattern_days * 28 end

  precalculate :paternity_adoption_warning do
    if paternity_maternity_warning
      PhraseList.new(:paternity_warning)
    else
      PhraseList.new
    end
  end
end

# Answer 7
outcome :not_entitled_3_days_not_paid do
  precalculate :normal_workdays_out do calculator.normal_workdays end
end

# Answer 8
outcome :maximum_entitlement_reached

