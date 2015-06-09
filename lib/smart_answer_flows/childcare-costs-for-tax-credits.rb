module SmartAnswer
  class ChildcareCostsForTaxCreditsFlow < Flow
    def define
      name 'childcare-costs-for-tax-credits'
      status :published
      satisfies_need "100422"

      #Q1
      multiple_choice :currently_claiming? do
        option :yes
        option :no

        next_node do |response|
          if response == 'yes'
            :have_costs_changed?
          elsif response == 'no'
            :how_often_use_childcare?
          end
        end
      end

      #Q2
      multiple_choice :how_often_use_childcare? do
        option :regularly_less_than_year
        option :regularly_more_than_year
        option :only_short_while

        next_node do |response|
          if response == 'regularly_less_than_year'
            :how_often_pay_1? #Q4
          elsif response == 'regularly_more_than_year'
            :pay_same_each_time? #Q11
          elsif response == 'only_short_while'
            :call_helpline_detailed #O1
          end
        end
      end

      #Q3
      multiple_choice :have_costs_changed? do
        option :yes
        option :no

        next_node do |response|
          if response == 'yes'
            :how_often_pay_2? #Q5
          elsif response == 'no'
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

        next_node do |response|
          if response == 'weekly_same_amount'
            :round_up_weekly #O3
          elsif response == 'weekly_diff_amount'
            :how_much_52_weeks_1? #Q7
          elsif response == 'monthly_same_amount'
            :how_much_each_month? #Q10
          elsif response == 'monthly_diff_amount'
            :how_much_12_months_1? #Q6
          elsif response == 'other'
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

        next_node do |response|
          if response == 'weekly_same_amount'
            :new_weekly_costs? #Q17
          elsif response == 'weekly_diff_amount'
            :how_much_52_weeks_2? #Q8
          elsif response == 'monthly_same_amount'
            :new_monthly_cost? #Q19
          elsif response == 'monthly_diff_amount'
            :how_much_12_months_2? #Q9
          elsif response == 'other'
            :how_much_52_weeks_2? #Q9
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

        next_node do |response|
          amount = Money.new(response)
          if amount == 0
            :no_longer_paying
          else
            :old_weekly_amount_1?
          end
        end
      end

      #Q9
      money_question :how_much_12_months_2? do
        calculate :weekly_cost do |response|
          SmartAnswer::Calculators::ChildcareCostCalculator.weekly_cost(response)
        end
        next_node do |response|
          amount = Money.new(response)
          if amount == 0
            :no_longer_paying
          else
            :old_weekly_amount_1?
          end
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

        next_node do |response|
          if response == 'yes'
            :how_often_pay_providers? #Q12
          elsif response == 'no'
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

        next_node do |response|
          if response == 'weekly'
            :round_up_weekly #O3
          elsif response == 'fortnightly'
            :how_much_fortnightly? #Q13
          elsif response == 'every_4_weeks'
            :how_much_4_weeks? #Q14
          elsif response == 'every_month'
            :how_much_each_month? #Q10
          elsif response == 'termly'
            :call_helpline_plain #O5
          elsif response == 'yearly'
            :how_much_yearly? #Q15
          elsif response == 'other'
            :call_helpline_plain #O5
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
        next_node do |response|
          amount = Money.new(response)
          if amount == 0
            :no_longer_paying
          else
            :old_weekly_amount_2?
          end
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

        next_node do |response|
          amount = Money.new(response)
          if amount == 0
            :no_longer_paying
          else
            :old_weekly_amount_3?
          end
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

        calculate :cost_change_4_weeks do
          true
        end

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
      outcome :call_helpline_detailed do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end

      #O5
      outcome :call_helpline_plain do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end

      #O2
      outcome :no_change do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end

      #O3
      outcome :round_up_weekly do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end

      #O4
      outcome :weekly_costs_are_x do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end

      #O6, 7, 8
      outcome :cost_changed do
        precalculate :ten_or_more do
          weekly_difference_abs >= 10
        end

        precalculate :title_change_text do
          if weekly_difference >= 10
            "increased"
          else
            "decreased"
          end
        end

        precalculate :difference_money do
          Money.new(weekly_difference.abs)
        end
        precalculate :body_phrases do
          if ten_or_more
            if cost_change_4_weeks
              PhraseList.new(:cost_change_4_weeks)
            else
              PhraseList.new(:cost_change_does_matter)
            end
          else
            PhraseList.new(:cost_change_doesnt_matter)
          end
        end

      end

      #O9
      outcome :no_longer_paying do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end
    end
  end
end
