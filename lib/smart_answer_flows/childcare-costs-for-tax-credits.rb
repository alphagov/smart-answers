module SmartAnswer
  class ChildcareCostsForTaxCreditsFlow < Flow
    def define
      content_id "f8c575b7-d7a2-41a4-9911-069a06f1a2cc"
      name 'childcare-costs-for-tax-credits'
      status :published
      satisfies_need "100422"

      use_erb_templates_for_questions

      #Q1
      multiple_choice :currently_claiming? do
        option :yes
        option :no

        calculate :cost_change_4_weeks do
          nil
        end

        permitted_next_nodes = [
          :have_costs_changed?,
          :how_often_use_childcare?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'yes'
            :have_costs_changed? #Q3
          when 'no'
            :how_often_use_childcare? #Q2
          end
        end
      end

      #Q2
      multiple_choice :how_often_use_childcare? do
        option :regularly_less_than_year
        option :regularly_more_than_year
        option :only_short_while

        permitted_next_nodes = [
          :how_often_pay_1?,
          :pay_same_each_time?,
          :call_helpline_detailed
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'regularly_less_than_year'
            :how_often_pay_1? #Q4
          when 'regularly_more_than_year'
            :pay_same_each_time? #Q11
          when 'only_short_while'
            :call_helpline_detailed #O1
          end
        end
      end

      #Q3
      multiple_choice :have_costs_changed? do
        option :yes
        option :no

        permitted_next_nodes = [
          :how_often_pay_2?,
          :no_change
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'yes'
            :how_often_pay_2? #Q5
          when 'no'
            :no_change #O2
          end
        end
      end

      #Q4
      multiple_choice :how_often_pay_1? do
        option :weekly_same_amount
        option :weekly_diff_amount
        option :monthly_same_amount
        option :monthly_diff_amount
        option :other

        permitted_next_nodes = [
          :round_up_weekly,
          :how_much_52_weeks_1?,
          :how_much_each_month?,
          :how_much_12_months_1?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'weekly_same_amount'
            :round_up_weekly #O3
          when 'weekly_diff_amount'
            :how_much_52_weeks_1? #Q7
          when 'monthly_same_amount'
            :how_much_each_month? #Q10
          when 'monthly_diff_amount', 'other'
            :how_much_12_months_1? #Q6
          end
        end
      end

      #Q5
      multiple_choice :how_often_pay_2? do
        option :weekly_same_amount
        option :weekly_diff_amount
        option :monthly_same_amount
        option :monthly_diff_amount
        option :other

        permitted_next_nodes = [
          :new_weekly_costs?,
          :how_much_52_weeks_2?,
          :new_monthly_cost?,
          :how_much_12_months_2?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'weekly_same_amount'
            :new_weekly_costs? #Q17
          when 'weekly_diff_amount', 'other'
            :how_much_52_weeks_2? #Q8
          when 'monthly_same_amount'
            :new_monthly_cost? #Q19
          when 'monthly_diff_amount'
            :how_much_12_months_2? #Q9
          end
        end
      end

      #Q6
      money_question :how_much_12_months_1? do
        calculate :weekly_cost do |response|
          SmartAnswer::Calculators::ChildcareCostCalculator.weekly_cost(response)
        end
        next_node :weekly_costs_are_x #O4
      end

      #Q7
      money_question :how_much_52_weeks_1? do
        calculate :weekly_cost do |response|
          SmartAnswer::Calculators::ChildcareCostCalculator.weekly_cost(response)
        end
        next_node :weekly_costs_are_x #O4
      end

      #Q8
      money_question :how_much_52_weeks_2? do
        calculate :weekly_cost do |response|
          SmartAnswer::Calculators::ChildcareCostCalculator.weekly_cost(response)
        end

        permitted_next_nodes = [
          :no_longer_paying,
          :old_weekly_amount_1?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          amount = Money.new(response)
          amount == 0 ? :no_longer_paying : :old_weekly_amount_1?
        end
      end

      #Q9
      money_question :how_much_12_months_2? do
        calculate :weekly_cost do |response|
          SmartAnswer::Calculators::ChildcareCostCalculator.weekly_cost(response)
        end

        permitted_next_nodes = [
          :no_longer_paying,
          :old_weekly_amount_1?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          amount = Money.new(response)
          amount == 0 ? :no_longer_paying : :old_weekly_amount_1?
        end
      end

      #Q10
      money_question :how_much_each_month? do
        calculate :weekly_cost do |response|
          SmartAnswer::Calculators::ChildcareCostCalculator.weekly_cost_from_monthly(response)
        end
        next_node :weekly_costs_are_x #O4
      end

      #Q11
      multiple_choice :pay_same_each_time? do
        option :yes
        option :no

        permitted_next_nodes = [
          :how_often_pay_providers?,
          :how_much_spent_last_12_months?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'yes'
            :how_often_pay_providers? #Q12
          when 'no'
            :how_much_spent_last_12_months? #Q16
          end
        end
      end

      #Q12
      multiple_choice :how_often_pay_providers? do
        option :weekly
        option :fortnightly
        option :every_4_weeks
        option :every_month
        option :termly
        option :yearly
        option :other

        permitted_next_nodes = [
          :round_up_weekly,
          :how_much_fortnightly?,
          :how_much_4_weeks?,
          :how_much_each_month?,
          :call_helpline_plain,
          :how_much_yearly?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'weekly'
            :round_up_weekly #O3
          when 'fortnightly'
            :how_much_fortnightly? #Q13
          when 'every_4_weeks'
            :how_much_4_weeks? #Q14
          when 'every_month'
            :how_much_each_month? #Q10
          when 'termly', 'other'
            :call_helpline_plain #O5
          when 'yearly'
            :how_much_yearly? #Q15
          end
        end
      end

      #Q13
      money_question :how_much_fortnightly? do
        calculate :weekly_cost do |response|
          SmartAnswer::Calculators::ChildcareCostCalculator.weekly_cost_from_fortnightly(response)
        end

        next_node :weekly_costs_are_x #O4
      end

      #Q14
      money_question :how_much_4_weeks? do
        calculate :weekly_cost do |response|
          SmartAnswer::Calculators::ChildcareCostCalculator.weekly_cost_from_four_weekly(response)
        end
        next_node :weekly_costs_are_x #04
      end

      #Q15
      money_question :how_much_yearly? do
        calculate :weekly_cost do |response|
          SmartAnswer::Calculators::ChildcareCostCalculator.weekly_cost(response)
        end
        next_node :weekly_costs_are_x #O4
      end

      #Q16
      money_question :how_much_spent_last_12_months? do
        calculate :weekly_cost do |response|
          SmartAnswer::Calculators::ChildcareCostCalculator.weekly_cost(response)
        end
        next_node :weekly_costs_are_x #O4
      end

      #Q17
      money_question :new_weekly_costs? do
        calculate :new_weekly_costs do |response|
          Float(response).ceil
        end

        permitted_next_nodes = [
          :no_longer_paying,
          :old_weekly_amount_2?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          amount = Money.new(response)
          amount == 0 ? :no_longer_paying : :old_weekly_amount_2?
        end
      end

      #Q18
      money_question :old_weekly_amount_1? do
        # get weekly amount from Q8 or Q9 (whichever the user answered)
        # calculate different using input from Q18
        calculate :old_weekly_cost do |response|
          Float(response).ceil
        end

        calculate :weekly_difference do
          SmartAnswer::Calculators::ChildcareCostCalculator.cost_change(weekly_cost, old_weekly_cost)
        end

        calculate :weekly_difference_abs do
          weekly_difference.abs
        end

        next_node :cost_changed
      end

      #Q19
      money_question :new_monthly_cost? do
        calculate :new_weekly_costs do |response|
          SmartAnswer::Calculators::ChildcareCostCalculator.weekly_cost_from_monthly(response)
        end

        permitted_next_nodes = [
          :no_longer_paying,
          :old_weekly_amount_3?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          amount = Money.new(response)
          amount == 0 ? :no_longer_paying : :old_weekly_amount_3?
        end
      end

      #Q20
      money_question :old_weekly_amount_2? do
        calculate :old_weekly_costs do |response|
          Float(response).ceil
        end

        calculate :weekly_difference do
          SmartAnswer::Calculators::ChildcareCostCalculator.cost_change(new_weekly_costs, old_weekly_costs)
        end

        calculate :weekly_difference_abs do
          weekly_difference.abs
        end

        calculate :cost_change_4_weeks do true end

        next_node :cost_changed
      end

      #Q21
      money_question :old_weekly_amount_3? do
        calculate :old_weekly_costs do |response|
          Float(response).ceil
        end

        calculate :weekly_difference do
          SmartAnswer::Calculators::ChildcareCostCalculator.cost_change(new_weekly_costs, old_weekly_costs)
        end

        calculate :weekly_difference_abs do
          weekly_difference.abs
        end

        next_node :cost_changed
      end

      ### Outcomes

      #O1
      outcome :call_helpline_detailed

      #O5
      outcome :call_helpline_plain

      #O2
      outcome :no_change

      #O3
      outcome :round_up_weekly

      #O4
      outcome :weekly_costs_are_x

      #O6, 7, 8
      outcome :cost_changed do
        precalculate :ten_or_more do
          weekly_difference_abs >= 10
        end

        precalculate :cost_change_4_weeks do
          cost_change_4_weeks || false
        end

        precalculate :title_change_text do
          weekly_difference >= 10 ? "increased" : "decreased"
        end

        precalculate :difference_money do
          Money.new(weekly_difference.abs)
        end
      end

      #O9
      outcome :no_longer_paying
    end
  end
end
