status :draft
satisfies_need "101011"

# Question 1
date_question :when_is_your_baby_due? do
  save_input_as :due_date
  calculate :calculator do
    Calculators::MaternityBenefitsCalculatorV2.new(Date.parse(responses.last))
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
  calculate :smp_lel do
    calculator.smp_lel
  end

  calculate :smp_rate do
    calculator.smp_rate
  end

  calculate :ma_rate do
    calculator.ma_rate
  end

  calculate :eleven_weeks do
    calculator.eleven_weeks
  end

  next_node :are_you_employed?
end

# Question 2
multiple_choice :are_you_employed? do
option :yes
option :no

  next_node do |response|
    if response == 'no'
      if due_date >= ("2014-07-27")
        :have_you_helped_partner_self_employed?
      else
        :will_you_work_at_least_26_weeks_during_test_period?
      end
    else
      :did_you_start_26_weeks_before_qualifying_week?
    end
  end
end

# Question 3
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

# Question 4
salary_question :how_much_do_you_earn? do
  weekly_salary_90 = nil
  next_node do |salary|
    weekly_salary_90 = Money.new(salary.per_week * 0.9)
    if salary.per_week >= smp_lel
      # Outcome 2
      :smp_from_employer
    elsif salary.per_week >= 30 && salary.per_week < smp_lel
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

  calculate :smp_6_weeks do
    weekly_salary_90
  end

  calculate :smp_33_weeks do
    smp_rate > smp_6_weeks.to_f ? smp_6_weeks : Money.new(smp_rate)
  end

  calculate :smp_total do
    Money.new(smp_6_weeks.to_f * 6 + smp_33_weeks.to_f * 33)
  end

  calculate :ma_rate do
    # either ma_rate or weekly_salary_90, whichever is lower
    calculator.ma_rate > weekly_salary_90.to_f ? weekly_salary_90 : Money.new(calculator.ma_rate)
  end

  calculate :ma_payable do
    Money.new(ma_rate.to_f * 39)
  end
end

# Question 5
multiple_choice :will_you_still_be_employed_in_qualifying_week? do
  option yes: :how_much_do_you_earn?
  option no: :will_you_work_at_least_26_weeks_during_test_period?
end

# Note this is only reached for 'employed' people who
# have worked 26 weeks for the same employer
# 135.45 is standard weekly rate. This may change
# 107 is the lower earnings limit. This may change

# Question 6
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
    if earnings.per_week >= 30.0
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
    calculator.ma_rate > weekly_salary_90.to_f ? weekly_salary_90 : Money.new(calculator.ma_rate)
  end

  calculate :ma_payable do
    Money.new(ma_rate * 39)
  end
end

# Question 8
 multiple_choice :have_you_helped_partner_self_employed? do
   option yes: :have_you_been_paid_for_helping_partner?
   option no: :will_you_work_at_least_26_weeks_during_test_period?
 end

 # Question 9
 multiple_choice :have_you_been_paid_for_helping_partner? do
   option yes: :nothing_maybe_benefits
   option no: :partner_helped_for_more_than_26weeks?
 end

 # Question 10
 multiple_choice :partner_helped_for_more_than_26weeks? do
   option yes: :lower_maternity_allowance
   option no: :nothing_maybe_benefits
 end

# Outcome 1
outcome :nothing_maybe_benefits do
  precalculate :extra_help_phrase do
    PhraseList.new(:extra_help)
  end
end

# Outcome 2
outcome :smp_from_employer do
  precalculate :extra_help_phrase do
    PhraseList.new(:extra_help)
  end
end

# Outcome 3
outcome :you_qualify_for_maternity_allowance do
  precalculate :extra_help_phrase do
    PhraseList.new(:extra_help)
  end
end

# Outcome 4
 outcome :lower_maternity_allowance do
   precalculate :extra_help_phrase do
     PhraseList.new(:extra_help)
   end

   precalculate :due_date_minus_11_weeks do
     Date.parse(due_date) - 11.weeks
   end
 end
