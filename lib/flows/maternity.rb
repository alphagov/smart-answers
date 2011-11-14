date_question :when_is_your_baby_due? do
  save_input_as :due_date
  calculate :expected_week_of_childbirth do
    due_on = Date.parse(due_date)
    start = due_on - due_on.wday
    start .. start + 6.days
  end
  calculate :qualifying_week do
    start = expected_week_of_childbirth.first - 15.weeks
    start .. start + 6.days
  end
  calculate :start_of_qualifying_week do
    qualifying_week.first
  end
  calculate :start_of_test_period do
    qualifying_week.first - 51.weeks
  end
  calculate :end_of_test_period do
    expected_week_of_childbirth.first - 1.day
  end
  calculate :twenty_six_weeks_before_qualifying_week do
    qualifying_week.first - 26.weeks
  end
  next_node :are_you_employed?
end

multiple_choice :are_you_employed? do
  option :yes => :did_you_start_26_weeks_before_qualifying_week?
  option :no => :will_you_work_at_least_26_weeks_during_test_period?
end

multiple_choice :did_you_start_26_weeks_before_qualifying_week? do
  option :yes
  option :no
  next_node do |response|
    if response == 'yes'
      # We assume that if they are employed, that means they are 
      # employed *today* and if today is after the start of the qualifying
      # week we can skip that question
      if Date.today < qualifying_week.first
        :will_you_still_be_employed_in_qualifying_week?
      else
        :how_much_are_you_paid_per_week?
      end
    else
      # If they weren't employed 26 weeks before qualifying week, there's no
      # way they can qualify for SMP, so consider MA instead.
      :will_you_work_at_least_26_weeks_during_test_period?
    end
  end
end

multiple_choice :will_you_still_be_employed_in_qualifying_week? do
  option :yes => :how_much_are_you_paid_per_week?
  option :no => :will_you_work_at_least_26_weeks_during_test_period?
end

# Note this is only reached for 'employed' people who 
# have worked 26 weeks for the same employer
money_question :how_much_are_you_paid_per_week? do
  next_node do |weekly_salary|
    if weekly_salary >= 102
      :you_qualify_for_statutory_maternity_pay
    elsif weekly_salary >= 30
      :you_qualify_for_maternity_allowance
    else
      :nothing_maybe_benefits
    end
  end
end

multiple_choice :will_you_work_at_least_26_weeks_during_test_period? do
  option :yes
  option :no
  next_node do |input|
    if input == 'yes'
      if weekly_salary
        raise "Problem" unless weekly_salary >= 30
        :you_qualify_for_maternity_allowance
      else
        :how_much_do_you_earn_per_week?
      end
    else
      :nothing_maybe_benefits
    end
  end
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
