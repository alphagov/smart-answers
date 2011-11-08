multiple_choice :what_is_your_employment_status? do
  save_input_as :employment_status
  option :employed => :when_is_your_baby_due?
  option :self_employed => :when_is_your_baby_due?
  option :unemployed => :nothing_maybe_benefits
end

date_question :when_is_your_baby_due? do
  save_input_as :due_date
  calculate :qualifying_week do
    due_on = Date.parse(due_date)
    start_of_expected_week_of_childbirth = due_on - due_on.wday
    start = start_of_expected_week_of_childbirth - 15.weeks
    start..start + 6.days
  end
  calculate :start_of_test_period do
    qualifying_week.first - 51.weeks
  end
  calculate :end_of_test_period do
    Date.parse(due_date)
  end
  next_node do
    if employment_status == "employed"
      :did_you_start_your_job_on_or_before_start_of_test_period?
    else
      :will_you_work_at_least_26_weeks_during_test_period?
    end
  end
end

multiple_choice :did_you_start_your_job_on_or_before_start_of_test_period? do
  option :yes => :will_you_be_employed_long_enough_to_qualify_for_maternity_allowance?
  option :no => :when_did_you_start_your_job?
  calculate :earliest_job_can_finish_to_qualify_for_maternity_allowance do
    qualifying_week.first
  end
end

date_question :when_did_you_start_your_job? do
  save_input_as :job_start_date
  
  calculate :earliest_job_can_finish_to_qualify_for_maternity_allowance do
    [qualifying_week.first, Date.parse(job_start_date) + 26.weeks].max
  end
  
  next_node do |job_start_date|
    if Date.parse(job_start_date) < (Date.parse(due_date) - 26.weeks)
      :maybe_maternity_allowance
    else
      :will_you_be_employed_long_enough_to_qualify_for_maternity_allowance?
    end
  end
end

multiple_choice :will_you_be_employed_long_enough_to_qualify_for_maternity_allowance? do
  option :yes => :how_much_are_you_paid_per_week?
  option :no => :will_you_work_at_least_26_weeks_during_test_period?
end

# Note this is only reached for 'employed' people
money_question :how_much_are_you_paid_per_week? do
  next_node do |weekly_salary|
    if weekly_salary >= 102
      :you_qualify_for_statutory_maternity_pay
    elsif weekly_salary >= 30
      :will_you_work_at_least_26_weeks_during_test_period?
    else
      :nothing_maybe_benefits
    end
  end
end

multiple_choice :will_you_work_at_least_26_weeks_during_test_period? do
  option :yes => :how_much_do_you_earn_per_week?
  option :no => :nothing_maybe_benefits
end

money_question :how_much_do_you_earn_per_week? do
  next_node do |weekly_earnings|
    if weekly_earnings >= 30
      :you_qualify_for_maternity_allowance
    else
      :nothing_maybe_benefits
    end
  end
end

outcome :nothing_maybe_benefits
outcome :you_qualify_for_statutory_maternity_pay
outcome :you_qualify_for_maternity_allowance
outcome :maybe_maternity_allowance
