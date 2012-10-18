satisfies_need 1660
status :published

date_question :when_is_your_baby_due? do
  save_input_as :due_date
  calculate :calculator do
    Calculators::MaternityBenefitsCalculator.new(Date.parse(responses.last))
  end

  calculate :expected_week_of_childbirth do
    calculator.expected_week
  end
  calculate :qualifying_week do
    calculator.qualifying_week
  end
  calculate :start_of_qualifying_week do
    qualifying_week.first
  end
  calculate :start_of_test_period do
    calculator.test_period.first
  end
  calculate :end_of_test_period do
    calculator.test_period.last
  end
  calculate :twenty_six_weeks_before_qualifying_week do
    calculator.employment_start
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
        :how_much_are_you_paid?
      end
    else
      # If they weren't employed 26 weeks before qualifying week, there's no
      # way they can qualify for SMP, so consider MA instead.
      :will_you_work_at_least_26_weeks_during_test_period?
    end
  end
end

multiple_choice :will_you_still_be_employed_in_qualifying_week? do
  option :yes => :how_much_are_you_paid?
  option :no => :will_you_work_at_least_26_weeks_during_test_period?
end

# Note this is only reached for 'employed' people who
# have worked 26 weeks for the same employer
# 135.45 is standard weekly rate. This may change
# 107 is the lower earnings limit. This may change
salary_question :how_much_are_you_paid? do
  weekly_salary_90 = nil
  next_node do |salary|
    weekly_salary_90 = Money.new(salary.per_week * 0.9)
    if salary.per_week >= 107
      if weekly_salary_90 < 135.45
        :you_qualify_for_statutory_maternity_pay_below_threshold
      else
        :you_qualify_for_statutory_maternity_pay_above_threshold
      end
    elsif salary.per_week >= 30
      :you_qualify_for_maternity_allowance_below_threshold
    else
      :nothing_maybe_benefits
    end
  end
  calculate :eligible_amount do
    weekly_salary_90
  end
end

multiple_choice :will_you_work_at_least_26_weeks_during_test_period? do
  option :yes
  option :no
  next_node do |input|
    if input == 'yes'
      :how_much_do_you_earn?
    else
      :nothing_maybe_benefits
    end
  end
end

# 135.45 is standard weekly rate. This may change
salary_question :how_much_do_you_earn? do
  weekly_salary_90 = nil
  next_node do |earnings|
    if earnings.per_week >= 30
      weekly_salary_90 = Money.new(earnings.per_week * 0.9)
      if weekly_salary_90 < 135.45
        :you_qualify_for_maternity_allowance_below_threshold
      else
        :you_qualify_for_maternity_allowance_above_threshold
      end
    else
      :nothing_maybe_benefits
    end
  end
  calculate :eligible_amount do
    weekly_salary_90
  end
end

outcome :nothing_maybe_benefits
outcome :you_qualify_for_statutory_maternity_pay_above_threshold
outcome :you_qualify_for_statutory_maternity_pay_below_threshold
outcome :you_qualify_for_maternity_allowance_above_threshold
outcome :you_qualify_for_maternity_allowance_below_threshold
