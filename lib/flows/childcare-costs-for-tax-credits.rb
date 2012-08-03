satisfies_need "9999"
status :draft
section_slug "money-and-tax"
subsection_slug "tax"

# Questions
#

# Q1
multiple_choice :first_time_claim? do
  option :yes => :frequency_of_childcare?
  option :no => :have_the_costs_changed?
end

# Q2
multiple_choice :frequency_of_childcare? do
  option :regularly_less_than_a_year => :how_often_do_you_pay?
  option :regularly_more_than_a_year => :do_you_pay_the_same_every_time?
  option :intermittently => :call_the_helpline # A19
end

# Q3
multiple_choice :have_the_costs_changed? do
  option :yes => :how_often_and_what_do_you_pay_your_providers? # Q7
  option :no => :no_change_to_credits # A20
end

# Q4
multiple_choice :how_often_do_you_pay? do
  option :same_amount_weekly => :round_up_total # A1
  option :varying_amount_weekly => :costs_for_year_in_weeks? # C1
  option :same_monthly => :how_much_do_you_pay_each_month? # C3
  option :varying_amount_monthly => :costs_for_year_in_months? # C4
  option :other => :costs_for_year_in_months? # C2 
end

# Q5
multiple_choice :do_you_pay_the_same_every_time? do
  option :yes => :how_often_do_you_pay_your_providers? # Q6
  option :no => :varying_annual_cost? # C9
end

# Q6
multiple_choice :how_often_do_you_pay_your_providers? do
  option :weekly => :round_up_total # A6
  option :fornightly => :how_much_do_you_pay_each_fortnight? # C5
  option :every_four_weeks => :how_much_do_you_pay_every_four_weeks? # C6
  option :monthly => :how_much_do_you_pay_each_month? # C7
  option :termly => :contact_the_tax_credit_office # A10
  option :yearly => :how_much_do_you_pay_anually? # C8
  option :other => :contact_the_tax_credit_office # A12
end

# Q7
multiple_choice :how_often_and_what_do_you_pay_your_providers? do
  option :same_amount_weekly => :new_weekly_costs? # C10
  option :varying_amount_weekly => :new_annual_costs? # C11
  option :same_monthly => :new_average_weekly_costs? # C13
  option :varying_amount_monthly => :new_annual_costs? # C14
  option :other => :new_annual_costs? # C12
end

# Calculation Questions
#

# C1
value_question :costs_for_year_in_weeks? do
  calculate :cost do
    Calculators::ChildcareCostCalculator.weekly_cost(responses.last.to_i)
  end
  next_node :weekly_costs # A2
end

# C2, C4
value_question :costs_for_year_in_months? do
  calculate :cost do
    Calculators::ChildcareCostCalculator.weekly_cost(responses.last.to_i)
  end
  next_node :weekly_costs # A3, A5  
end

# C3, C7
value_question :how_much_do_you_pay_each_month? do
  calculate :cost do
    Calculators::ChildcareCostCalculator.weekly_cost_from_monthly(responses.last.to_i)
  end
  next_node :weekly_costs # A4
end

# C5
value_question :how_much_do_you_pay_each_fortnight? do
  calculate :cost do
    Calculators::ChildcareCostCalculator.weekly_cost_from_fortnightly(responses.last.to_i)
  end
  next_node :weekly_costs_for_claim_form # A7
end

# C6
value_question :how_much_do_you_pay_every_four_weeks? do
  calculate :cost do
    Calculators::ChildcareCostCalculator.weekly_cost_from_four_weekly(responses.last.to_i)
  end
  next_node :weekly_costs_for_claim_form # A8
end

# C8
value_question :how_much_do_you_pay_anually? do
  calculate :cost do
    Calculators::ChildcareCostCalculator.weekly_cost(responses.last.to_i)
  end
  next_node :weekly_costs_for_claim_form # A11  
end

# C9
value_question :varying_annual_cost? do
  calculate :cost do
    Calculators::ChildcareCostCalculator.weekly_cost(responses.last.to_i)
  end
  next_node :weekly_costs_for_claim_form # A13   
end

# C10A
value_question :new_weekly_costs? do
  save_input_as :new_weekly_cost
  next_node :old_weekly_costs?
end

# C10B
value_question :old_weekly_costs? do
  calculate :cost do
    Calculators::ChildcareCostCalculator.cost_change(new_weekly_cost.to_i, responses.last.to_i)
  end
  next_node do |response|
    diff = Calculators::ChildcareCostCalculator.cost_change(new_weekly_cost.to_i, response.to_i)
    if diff > 10
      :costs_have_increased
    else
      :costs_have_not_increased
    end
  end
end

# C11A, C12A, C14A
value_question :new_annual_costs? do
  save_input_as :new_annual_cost
  next_node :old_annual_costs?
end

# C11B, C12B, C14B
value_question :old_annual_costs? do
  calculate :cost do
    Calculators::ChildcareCostCalculator.cost_change_annual(new_annual_cost.to_i, responses.last.to_i)
  end
  next_node do |response|
    diff = Calculators::ChildcareCostCalculator.cost_change_annual(new_annual_cost.to_i, response.to_i)
    if diff > 10
      :costs_have_increased
    else
      :costs_have_not_increased
    end
  end
end

# C13A
value_question :new_average_weekly_costs? do
  save_input_as :new_average_weekly_cost
  next_node :old_average_weekly_costs?
end

# C13B
value_question :old_average_weekly_costs? do
  calculate :cost do
    Calculators::ChildcareCostCalculator.cost_change_month(new_average_weekly_cost.to_i, responses.last.to_i)
  end
  next_node do |response|
    diff = Calculators::ChildcareCostCalculator.cost_change_month(new_average_weekly_cost.to_i, response.to_i)
    if diff > 10
      :costs_have_increased
    else
      :costs_have_not_increased
    end
  end  
end

outcome :round_up_total # A1, A6
outcome :weekly_costs # A2, A3, A4, A5
outcome :weekly_costs_for_claim_form # A7, A8, A9, A11, A13
outcome :contact_the_tax_credit_office # A10, A12
outcome :costs_have_increased # A14, A15, A16, A17, A18
outcome :costs_have_not_increased # A14, A15, A16, A17, A18
outcome :call_the_helpline # A19
outcome :no_change_to_credits # A20
