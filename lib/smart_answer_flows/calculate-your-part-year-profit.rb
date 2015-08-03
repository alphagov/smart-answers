module SmartAnswer
  class CalculateYourPartYearProfitFlow < Flow
    def define
      name 'calculate-your-part-year-profit'

      status :draft
      satisfies_need "103438"

      date_question :when_did_your_tax_credits_award_end? do
        next_node_calculation :calculator do
          Calculators::PartYearProfitCalculator.new
        end

        next_node do |response|
          calculator.tax_credits_award_ends_on = response
          :what_date_do_your_accounts_go_up_to?
        end
      end

      date_question :what_date_do_your_accounts_go_up_to? do
        default_year { 0 }

        next_node do |response|
          calculator.accounts_end_month_and_day = response
          :do_your_accounts_cover_a_12_month_period?
        end
      end

      multiple_choice :do_your_accounts_cover_a_12_month_period? do
        option "yes"
        option "no"

        next_node do |response|
          if response == "yes"
            :what_is_your_taxable_profit?
          else
            :unsupported
          end
        end
      end

      money_question :what_is_your_taxable_profit? do
        precalculate(:accounts_end_on) { calculator.accounts_end_on }

        next_node do |response|
          calculator.taxable_profit = response
          :result
        end
      end

      outcome :result
      outcome :unsupported
    end
  end
end
