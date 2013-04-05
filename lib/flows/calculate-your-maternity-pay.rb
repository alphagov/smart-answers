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
  calculate :smp_LEL do
    calculator.smp_LEL
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
        :how_much_do_you_earn?
      end
    else
      # If they weren't employed 26 weeks before qualifying week, there's no
      # way they can qualify for SMP, so consider MA instead.
      :will_you_work_at_least_26_weeks_during_test_period?
    end
  end
end

multiple_choice :will_you_still_be_employed_in_qualifying_week? do
  option :yes => :how_much_do_you_earn?
  option :no => :will_you_work_at_least_26_weeks_during_test_period?
end

# Note this is only reached for 'employed' people who
# have worked 26 weeks for the same employer
# 135.45 is standard weekly rate. This may change
# 107 is the lower earnings limit. This may change
# Question 4
salary_question :how_much_do_you_earn? do
  weekly_salary_90 = nil
  next_node do |salary|
    weekly_salary_90 = Money.new(salary.per_week * 0.9)
    if salary.per_week >= smp_LEL
      # Outcome 2
      :smp_from_employer
    elsif salary.per_week >= 30 && salary.per_week < smp_LEL
      # Outcome 3
      :you_qualify_for_maternity_allowance
    else
      # Outcome 1
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
      :how_much_did_you_earn_between?
    else
      # Outcome 1
      :nothing_maybe_benefits
    end
  end
end

# Question 7
salary_question :how_much_did_you_earn_between? do
  weekly_salary_90 = nil
  next_node do |earnings|
    weekly_salary_90 = Money.new(earnings.per_week * 0.9)
    if earnings.per_week >= 30
      # Outcome 3
      :you_qualify_for_maternity_allowance
    else
      # Outcome 1
      :nothing_maybe_benefits
    end
  end
  calculate :weekly_salary_90 do
    weekly_salary_90
  end

  calculate :eligible_amount do
    weekly_salary_90
  end

  calculate :ma_rate do
    # either ma_rate or weekly_salary_90, whichever is lower
    calculator.ma_rate > weekly_salary_90 ? weekly_salary_90 : calculator.ma_rate
  end

  calculate :ma_payable do
    ma_rate * 39
  end
end

# Outcome 1
outcome :nothing_maybe_benefits

# Outcome 2
outcome :smp_from_employer

# Outcome 3
outcome :you_qualify_for_maternity_allowance

# old outcomes
outcome :you_qualify_for_statutory_maternity_pay_above_threshold
outcome :you_qualify_for_statutory_maternity_pay_below_threshold
outcome :you_qualify_for_maternity_allowance_above_threshold
outcome :you_qualify_for_maternity_allowance_below_threshold
