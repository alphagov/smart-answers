module SmartAnswer
  class PartYearProfitTaxCreditsFlow < Flow
    def define
      name 'part-year-profit-tax-credits'

      status :published
      satisfies_need "103438"

      date_question :when_did_your_tax_credits_award_end? do
        from { Calculators::PartYearProfitTaxCreditsCalculator::TAX_CREDITS_AWARD_ENDS_EARLIEST_DATE }
        to   { Calculators::PartYearProfitTaxCreditsCalculator::TAX_CREDITS_AWARD_ENDS_LATEST_DATE }

        next_node_calculation :calculator do
          Calculators::PartYearProfitTaxCreditsCalculator.new
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
          :have_you_stopped_trading?
        end
      end

      multiple_choice :have_you_stopped_trading? do
        option "yes"
        option "no"

        next_node do |response|
          if response == 'yes'
            calculator.stopped_trading = true
            :did_you_start_trading_before_the_relevant_accounting_year?
          elsif response == 'no'
            calculator.stopped_trading = false
            :do_your_accounts_cover_a_12_month_period?
          end
        end
      end

      multiple_choice :did_you_start_trading_before_the_relevant_accounting_year? do
        option "yes"
        option "no"

        precalculate(:accounting_year_begins_on) { calculator.accounting_year.begins_on }

        next_node do |response|
          if response == "yes"
            :when_did_you_stop_trading?
          elsif response == "no"
            :when_did_you_start_trading?
          end
        end
      end

      date_question :when_did_you_stop_trading? do
        from { Calculators::PartYearProfitTaxCreditsCalculator::START_OR_STOP_TRADING_EARLIEST_DATE }
        to   { Calculators::PartYearProfitTaxCreditsCalculator::START_OR_STOP_TRADING_LATEST_DATE }

        precalculate(:tax_year_begins_on) { calculator.tax_year.begins_on }
        precalculate(:tax_year_ends_on)   { calculator.tax_year.ends_on }

        validate(:not_in_tax_year_error) do |response|
          calculator.valid_stopped_trading_date?(response)
        end

        next_node do |response|
          calculator.stopped_trading_on = response
          :what_is_your_taxable_profit?
        end
      end

      multiple_choice :do_your_accounts_cover_a_12_month_period? do
        option "yes"
        option "no"

        precalculate(:accounting_year_ends_on) { calculator.accounting_year.ends_on }

        next_node do |response|
          if response == "yes"
            :what_is_your_taxable_profit?
          else
            :when_did_you_start_trading?
          end
        end
      end

      date_question :when_did_you_start_trading? do
        from { Calculators::PartYearProfitTaxCreditsCalculator::START_OR_STOP_TRADING_EARLIEST_DATE }
        to   { Calculators::PartYearProfitTaxCreditsCalculator::START_OR_STOP_TRADING_LATEST_DATE }

        precalculate(:award_period_ends_on) { calculator.award_period.ends_on }

        validate(:invalid_start_trading_date) do |response|
          calculator.valid_start_trading_date?(response)
        end

        next_node do |response|
          calculator.started_trading_on = response
          if calculator.stopped_trading
            :when_did_you_stop_trading?
          else
            :what_is_your_taxable_profit?
          end
        end
      end

      money_question :what_is_your_taxable_profit? do
        precalculate(:basis_period_begins_on) { calculator.basis_period.begins_on }
        precalculate(:basis_period_ends_on)   { calculator.basis_period.ends_on }

        next_node do |response|
          calculator.taxable_profit = response
          :result
        end
      end

      outcome :result
    end
  end
end
