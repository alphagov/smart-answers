satisfies_need "672"
status :draft

#Q1
multiple_choice :currently_claiming? do
  option :yes => :have_costs_changed?
  option :no => :how_often_use_childcare?
end

#Q2
multiple_choice :how_often_use_childcare? do
  option :regularly_less_than_year => :how_often_pay_1?
  option :regularly_more_than_year => :pay_same_each_time?
  option :only_short_while => :call_helpline

end

#Q3
multiple_choice :have_costs_changed? do
  option :yes => :how_often_pay_2?
  option :no => :no_change
end

#Q4
multiple_choice :how_often_pay_1? do
  option :weekly_same_amount => :round_up_weekly
  option :weekly_diff_amount => :how_much_52_weeks_1?
  option :monthly_same_amount => :how_much_each_month?
  option :monthly_diff_amount => :how_much_12_months_1?
  option :other => :how_much_12_months_1?
end

#Q5
multiple_choice :how_often_pay_2? do
  option :weekly_same_amount => :new_weekly_costs?
  option :weekly_diff_amount => :how_much_12_months_2?
  option :monthly_same_amount => :new_monthly_cost?
  option :monthly_diff_amount => :how_much_52_weeks_2?
  option :other => :how_much_52_weeks_2?
end

#Q6
money_question :how_much_12_months_1? do
  next_node :weekly_costs_are_x
end

#Q7
money_question :how_much_52_weeks_1? do
  next_node :weekly_costs_are_x
end

#Q8
money_question :how_much_12_months_2? do
  next_node :old_weekly_amount_1?
end

#Q9
money_question :how_much_52_weeks_2? do
  next_node :old_weekly_amount_1?
end

#Q10
money_question :how_much_each_month? do
  next_node :weekly_costs_are_x
end

#Q11
multiple_choice :pay_same_each_time? do
  option :yes => :how_often_pay_providers?
  option :no => :weekly_costs_are_x
end

#Q12
multiple_choice :how_often_pay_providers? do
  option :weekly => :round_up_weekly
  option :fortnightly => :how_much_fortnightly?
  option :every_4_weeks => :how_much_4_weeks?
  option :every_month => :how_much_each_month?
  option :termly => :call_helpline
  option :yearly => :how_much_yearly?
  option :other => :call_helpline
end

#Q13
money_question :how_much_fortnightly? do
  next_node :weekly_costs_are_x
end

#Q14
money_question :how_much_4_weeks? do
  next_node :weekly_costs_are_x
end

#Q15
money_question :how_much_yearly? do
  next_node :weekly_costs_are_x
end

#Q16
money_question :how_much_spent_last_12_months? do
  next_node :weekly_costs_are_x
end

#Q17
money_question :new_weekly_costs? do
  #Q20
end

#Q18
money_question :old_weekly_amount_1? do
  # O6 or O7
end

#Q19
money_question :new_monthly_cost? do
  :old_weekly_amount_1?
end

#Q20
money_question :old_weekly_amount_2? do
  #O6 or O8
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

#O6
outcome :cost_changed_below_10 do

end

#O7 / O8
outcome :cost_changed_above_10 do

end

