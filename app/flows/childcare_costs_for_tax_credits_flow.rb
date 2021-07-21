class ChildcareCostsForTaxCreditsFlow < SmartAnswer::Flow
  def define
    content_id "f8c575b7-d7a2-41a4-9911-069a06f1a2cc"
    name "childcare-costs-for-tax-credits"
    status :published

    # Q1
    radio :currently_claiming? do
      option :yes
      option :no

      on_response do
        self.calculator = SmartAnswer::Calculators::ChildcareCostCalculator.new
      end

      next_node do |response|
        case response
        when "yes"
          question :have_costs_changed? # Q3
        when "no"
          question :how_often_use_childcare? # Q2
        end
      end
    end

    # Q2
    radio :how_often_use_childcare? do
      option :regularly_less_than_year
      option :regularly_more_than_year
      option :only_short_while

      next_node do |response|
        case response
        when "regularly_less_than_year"
          question :how_often_pay_1? # Q4
        when "regularly_more_than_year"
          question :pay_same_each_time? # Q11
        when "only_short_while"
          outcome :call_helpline_detailed # O1
        end
      end
    end

    # Q3
    radio :have_costs_changed? do
      option :yes
      option :no

      next_node do |response|
        case response
        when "yes"
          question :how_often_pay_2? # Q5
        when "no"
          outcome :no_change # O2
        end
      end
    end

    # Q4
    radio :how_often_pay_1? do
      option :weekly_same_amount
      option :weekly_diff_amount
      option :monthly_same_amount
      option :monthly_diff_amount
      option :other

      next_node do |response|
        case response
        when "weekly_same_amount"
          question :round_up_weekly # O3
        when "weekly_diff_amount"
          question :how_much_52_weeks_1? # Q7
        when "monthly_same_amount"
          question :how_much_each_month? # Q10
        when "monthly_diff_amount", "other"
          question :how_much_12_months_1? # Q6
        end
      end
    end

    # Q5
    radio :how_often_pay_2? do
      option :weekly_same_amount
      option :weekly_diff_amount
      option :monthly_same_amount
      option :monthly_diff_amount
      option :other

      next_node do |response|
        case response
        when "weekly_same_amount"
          question :new_weekly_costs? # Q17
        when "weekly_diff_amount", "other"
          question :how_much_52_weeks_2? # Q8
        when "monthly_same_amount"
          question :new_monthly_cost? # Q19
        when "monthly_diff_amount"
          question :how_much_12_months_2? # Q9
        end
      end
    end

    # Q6
    money_question :how_much_12_months_1? do
      on_response do |response|
        calculator.weekly_cost = calculator.weekly_cost_from_annual(response)
      end

      next_node do
        outcome :weekly_costs_are_x # O4
      end
    end

    # Q7
    money_question :how_much_52_weeks_1? do
      on_response do |response|
        calculator.weekly_cost = calculator.weekly_cost_from_annual(response)
      end
      next_node do
        outcome :weekly_costs_are_x # O4
      end
    end

    # Q8
    money_question :how_much_52_weeks_2? do
      on_response do |response|
        calculator.weekly_cost = calculator.weekly_cost_from_annual(response)
      end

      next_node do |response|
        amount = SmartAnswer::Money.new(response)
        amount == 0 ? outcome(:no_longer_paying) : question(:old_weekly_amount_1?) # rubocop:disable Style/NumericPredicate
      end
    end

    # Q9
    money_question :how_much_12_months_2? do
      on_response do |response|
        calculator.new_weekly_costs = calculator.weekly_cost_from_annual(response)
      end

      next_node do |response|
        amount = SmartAnswer::Money.new(response)
        amount == 0 ? outcome(:no_longer_paying) : question(:old_monthly_amount?) # rubocop:disable Style/NumericPredicate
      end
    end

    # Q10
    money_question :how_much_each_month? do
      on_response do |response|
        calculator.weekly_cost = calculator.weekly_cost_from_monthly(response)
      end
      next_node do
        outcome :weekly_costs_are_x # O4
      end
    end

    # Q11
    radio :pay_same_each_time? do
      option :yes
      option :no

      next_node do |response|
        case response
        when "yes"
          question :how_often_pay_providers? # Q12
        when "no"
          question :how_much_spent_last_12_months? # Q16
        end
      end
    end

    # Q12
    radio :how_often_pay_providers? do
      option :weekly
      option :fortnightly
      option :every_4_weeks
      option :every_month
      option :termly
      option :yearly
      option :other

      next_node do |response|
        case response
        when "weekly"
          outcome :round_up_weekly # O3
        when "fortnightly"
          question :how_much_fortnightly? # Q13
        when "every_4_weeks"
          question :how_much_4_weeks? # Q14
        when "every_month"
          question :how_much_each_month? # Q10
        when "termly", "other"
          outcome :call_helpline_plain # O5
        when "yearly"
          question :how_much_yearly? # Q15
        end
      end
    end

    # Q13
    money_question :how_much_fortnightly? do
      on_response do |response|
        calculator.weekly_cost = calculator.weekly_cost_from_fortnightly(response)
      end

      next_node do
        outcome :weekly_costs_are_x # O4
      end
    end

    # Q14
    money_question :how_much_4_weeks? do
      on_response do |response|
        calculator.weekly_cost = calculator.weekly_cost_from_four_weekly(response)
      end
      next_node do
        outcome :weekly_costs_are_x # 04
      end
    end

    # Q15
    money_question :how_much_yearly? do
      on_response do |response|
        calculator.weekly_cost = calculator.weekly_cost_from_annual(response)
      end
      next_node do
        outcome :weekly_costs_are_x # O4
      end
    end

    # Q16
    money_question :how_much_spent_last_12_months? do
      on_response do |response|
        calculator.weekly_cost = calculator.weekly_cost_from_annual(response)
      end
      next_node do
        outcome :weekly_costs_are_x # O4
      end
    end

    # Q17
    money_question :new_weekly_costs? do
      on_response do |response|
        calculator.new_weekly_costs = Float(response).ceil
      end

      next_node do |response|
        amount = SmartAnswer::Money.new(response)
        amount == 0 ? outcome(:no_longer_paying) : question(:old_weekly_amount_2?) # rubocop:disable Style/NumericPredicate
      end
    end

    # Q18
    money_question :old_weekly_amount_1? do
      # get weekly amount from Q8 or Q9 (whichever the user answered)
      # calculate different using input from Q18
      on_response do |response|
        calculator.old_weekly_costs = Float(response).ceil
        calculator.weekly_difference = calculator.cost_change(
          calculator.weekly_cost,
          calculator.old_weekly_costs,
        )
      end

      next_node do
        outcome :cost_changed
      end
    end

    # Q19
    money_question :new_monthly_cost? do
      on_response do |response|
        calculator.new_weekly_costs = calculator.weekly_cost_from_monthly(response)
      end

      next_node do |response|
        amount = SmartAnswer::Money.new(response)
        amount == 0 ? outcome(:no_longer_paying) : question(:old_monthly_amount?) # rubocop:disable Style/NumericPredicate
      end
    end

    # Q20
    money_question :old_weekly_amount_2? do
      on_response do |response|
        calculator.old_weekly_costs = Float(response).ceil
        calculator.weekly_difference = calculator.cost_change(
          calculator.new_weekly_costs,
          calculator.old_weekly_costs,
        )
        calculator.cost_change_4_weeks = true
      end

      next_node do
        outcome :cost_changed
      end
    end

    # Q21
    money_question :old_monthly_amount? do
      on_response do |response|
        calculator.old_weekly_costs = calculator.weekly_cost_from_monthly(response)
        calculator.weekly_difference = calculator.cost_change(
          calculator.new_weekly_costs,
          calculator.old_weekly_costs,
        )
      end

      next_node do
        outcome :cost_changed
      end
    end

    ### Outcomes

    # O1
    outcome :call_helpline_detailed

    # O5
    outcome :call_helpline_plain

    # O2
    outcome :no_change

    # O3
    outcome :round_up_weekly

    # O4
    outcome :weekly_costs_are_x

    # O6, 7, 8
    outcome :cost_changed

    # O9
    outcome :no_longer_paying
  end
end
