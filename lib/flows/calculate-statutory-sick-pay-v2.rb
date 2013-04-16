status :draft
satisfies_need "2013"

# Question 1
checkbox_question :is_your_employee_getting? do
  option :statutory_maternity_pay
  option :maternity_allowance
  option :ordinary_statutory_paternity_pay
  option :statutory_adoption_pay

  calculate :paternity_maternity_warning do
    (responses.last.split(",") & %w{ordinary_statutory_paternity_pay statutory_adoption_pay}).any?
  end
next_node do |response|
    if (response.split(",") & %w{ordinary_statutory_paternity_pay statutory_adoption_pay}).any?
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
    end_date = Date.parse(response)
    days = (end_date - start_date).to_i

    if days < 1
      # invalid
      raise SmartAnswer::InvalidResponse
    end

    days > 3 ? :last_payday_before_sickness? : :must_be_sick_for_4_days
  end

end

# Question 6
date_question :last_payday_before_sickness? do

  calculate :relevant_period_to do
    Date.parse(responses.last).strftime("%e %B %Y")
  end

  calculate :pay_day_offset do
    (Date.parse(responses.last) - 8.weeks).strftime("%e %B %Y")
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

# Question 8
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

# Question 9
multiple_choice :on_start_date_8_weeks_paid? do
  option :yes => :total_employee_earnings? # Question 10
  option :no => :employee_average_earnings? # Question 11
end

# Question 10
money_question :total_employee_earnings? do
  save_input_as :relevant_period_pay
  calculate :relevant_period_awe do
    case pay_pattern
    when "weekly", "fortnightly", "every_4_weeks"
      relevant_period_pay / 8.0
    when "monthly"
      (relevant_period_pay / monthly_pattern_payments) * ( 12.0 / 52 )
    when "irregularly"
      relevant_period_pay / (relevant_period_to - relevant_period_from).to_i * 7
    end

  end

  next_node do |response|
    relevant_period_pay = Money.new(response)
    relevant_pay_awe = case pay_pattern
    when "weekly", "fortnightly", "every_4_weeks"
      relevant_period_pay / 8.0
    when "monthly"
      relevant_period_pay / monthly_pattern_payments * 12 / 52
    when "irregularly"
      relevant_period_pay / (relevant_period_to - relevant_period_from).to_i * 7
    end

    if relevant_pay_awe < Calculators::StatutorySickPayCalculatorV2.lel
      # Answer 5
      :not_earned_enough
    else
      # Question 12
      :off_sick_4_days?
    end
  end

end

# Question 11
money_question :employee_average_earnings? do

end

# Question 12
multiple_choice :off_sick_4_days? do

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
