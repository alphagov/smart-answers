satisfies_need "672"
status :draft

#Q1
multiple_choice :currently_claiming? do
  option :yes => :have_costs_changed? #Q3
  option :no => :how_often_use_childcare? #Q2
end

#Q2
multiple_choice :how_often_use_childcare? do
  option :regularly_less_than_year => :how_often_pay_1? #Q4
  option :regularly_more_than_year => :pay_same_each_time? #Q11
  option :only_short_while => :call_helpline #O1

end

#Q3
multiple_choice :have_costs_changed? do
  option :yes => :how_often_pay_2? #Q5
  option :no => :no_change #O2
end

#Q4
multiple_choice :how_often_pay_1? do
  option :weekly_same_amount => :round_up_weekly #O3
  option :weekly_diff_amount => :how_much_52_weeks_1? #Q7
  option :monthly_same_amount => :how_much_each_month? #Q10
  option :monthly_diff_amount => :how_much_12_months_1? #Q6
  option :other => :how_much_12_months_1? #Q6
end

#Q5
multiple_choice :how_often_pay_2? do
  option :weekly_same_amount => :new_weekly_costs? #Q17
  option :weekly_diff_amount => :how_much_52_weeks_2? #Q8
  option :monthly_same_amount => :new_monthly_cost? #Q19
  option :monthly_diff_amount => :how_much_12_months_2? #Q9
  option :other => :how_much_52_weeks_2? #Q9
end

#Q6
money_question :how_much_12_months_1? do
  calculate :weekly_cost do
    SmartAnswer::Calculators::ChildcareCostCalculator.weekly_cost(responses.last)
  end
  next_node :weekly_costs_are_x #O4
end

#Q7
money_question :how_much_52_weeks_1? do
  calculate :weekly_cost do
    SmartAnswer::Calculators::ChildcareCostCalculator.weekly_cost(responses.last)
  end
  next_node :weekly_costs_are_x #O4
end

#Q8
money_question :how_much_52_weeks_2? do
  calculate :weekly_cost do
    SmartAnswer::Calculators::ChildcareCostCalculator.weekly_cost(responses.last)
  end

  next_node do |response|
    amount = Money.new(response)
    amount == 0 ? :no_longer_paying : :old_weekly_amount_1?
  end
end


#Q9
money_question :how_much_12_months_2? do
  calculate :weekly_cost do
    SmartAnswer::Calculators::ChildcareCostCalculator.weekly_cost(responses.last)
  end
  next_node do |response|
    amount = Money.new(response)
    amount == 0 ? :no_longer_paying : :old_weekly_amount_1?
  end
end

#Q10
money_question :how_much_each_month? do
  calculate :weekly_cost do
    SmartAnswer::Calculators::ChildcareCostCalculator.weekly_cost_from_monthly(responses.last)
  end
  next_node :weekly_costs_are_x #O4
end

#Q11
multiple_choice :pay_same_each_time? do
  option :yes => :how_often_pay_providers? #Q12
  option :no => :weekly_costs_are_x #Q16
end

#Q12
multiple_choice :how_often_pay_providers? do
  option :weekly => :round_up_weekly #O3
  option :fortnightly => :how_much_fortnightly? #Q13
  option :every_4_weeks => :how_much_4_weeks? #Q14
  option :every_month => :how_much_each_month? #Q10
  option :termly => :call_helpline #O5
  option :yearly => :how_much_yearly? #Q15
  option :other => :call_helpline #O5
end

#Q13
money_question :how_much_fortnightly? do
  calculate :weekly_cost do
    SmartAnswer::Calculators::ChildcareCostCalculator.weekly_cost_from_fortnightly(responses.last)
  end

  next_node :weekly_costs_are_x #O4
end

#Q14
money_question :how_much_4_weeks? do
  calculate :weekly_cost do
    SmartAnswer::Calculators::ChildcareCostCalculator.weekly_cost_from_four_weekly(responses.last)
  end
  next_node :weekly_costs_are_x #04
end

#Q15
money_question :how_much_yearly? do
  calculate :weekly_cost do
    SmartAnswer::Calculators::ChildcareCostCalculator.weekly_cost(responses.last)
  end
  next_node :weekly_costs_are_x #O4
end

#Q16
money_question :how_much_spent_last_12_months? do
  calculate :weekly_cost do
    SmartAnswer::Calculators::ChildcareCostCalculator.weekly_cost(responses.last)
  end
  next_node :weekly_costs_are_x #O4
end

#Q17
money_question :new_weekly_costs? do
  calculate :new_weekly_costs do
    SmartAnswer::Calculators::ChildcareCostCalculator.weekly_cost(responses.last)
  end
  next_node do |response|
    amount = Money.new(response)
    amount == 0 ? :no_longer_paying : :old_weekly_amount_2?
  end
end

#Q18
money_question :old_weekly_amount_1? do
  # get weekly amount from Q8 or Q9 (whichever the user answered)
  # calculate different using input from Q18
  calculate :old_weekly_cost do
    Float(responses.last)
  end

  calculate :weekly_difference do
    SmartAnswer::Calculators::ChildcareCostCalculator.cost_change(weekly_cost, old_weekly_cost).abs
  end

  next_node :cost_changed
end

#Q19
money_question :new_monthly_cost? do
  # if input 0, O9
  # else Q21
end

#Q20
money_question :old_weekly_amount_2? do
  # subtract Q17 answer from Q20 to get difference
  # diff < 10 -> O6
  # diff >= 10 -> O8
end

#Q21
money_question :old_weekly_amount_3? do
  # get weekly from Q19, calculate diff
  # diff < 10 -> O6
  # diff >=10 -> O7
end

### Outcomes
#O1, O5
outcome :call_helpline do

end

#O2
outcome :no_change do

end

#O3
outcome :round_up_weekly do

end

#O4
outcome :weekly_costs_are_x do

end

#O6, 7, 8
outcome :cost_changed do

end

#O9
outcome :no_longer_paying do
end

