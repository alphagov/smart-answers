module SmartAnswer
  class PartYearProfitTaxCreditsFlow < Flow
    def define
      name 'part-year-profit-tax-credits'

      status :published
      satisfies_need "103438"
      content_id "de6723a5-7256-4bfd-aad3-82b04b06b73e"

      date_question :when_did_your_tax_credits_award_end? do
        from { Calculators::PartYearProfitTaxCreditsCalculator::TAX_CREDITS_AWARD_ENDS_EARLIEST_DATE }
        to   { Calculators::PartYearProfitTaxCreditsCalculator::TAX_CREDITS_AWARD_ENDS_LATEST_DATE }

        on_response do |response|
          self.calculator = Calculators::PartYearProfitTaxCreditsCalculator.new
          calculator.tax_credits_award_ends_on = response
        end

        next_node do
          question :what_date_do_your_accounts_go_up_to?
        end
      end

      date_question :what_date_do_your_accounts_go_up_to? do
        default_year { 0 }

        on_response do |response|
          calculator.accounts_end_month_and_day = response
        end

        next_node do
          question :have_you_stopped_trading?
        end
      end

      multiple_choice :have_you_stopped_trading? do
        option "yes"
        option "no"

        on_response do |response|
          if response == 'yes'
            calculator.stopped_trading = true
          elsif response == 'no'
            calculator.stopped_trading = false
          end
        end

        next_node do
          if calculator.stopped_trading
            question :did_you_start_trading_before_the_relevant_accounting_year?
          else
            question :do_your_accounts_cover_a_12_month_period?
          end
        end
      end

      multiple_choice :did_you_start_trading_before_the_relevant_accounting_year? do
        option "yes"
        option "no"

        precalculate(:accounting_year_begins_on) { calculator.accounting_year.begins_on }

        next_node do |response|
          if response == "yes"
            question :when_did_you_stop_trading?
          elsif response == "no"
            question :when_did_you_start_trading?
          end
        end
      end

      date_question :when_did_you_stop_trading? do
        from { Calculators::PartYearProfitTaxCreditsCalculator::START_OR_STOP_TRADING_EARLIEST_DATE }
        to   { Calculators::PartYearProfitTaxCreditsCalculator::START_OR_STOP_TRADING_LATEST_DATE }

        precalculate(:tax_year_begins_on) { calculator.tax_year.begins_on }
        precalculate(:tax_year_ends_on)   { calculator.tax_year.ends_on }

        on_response do |response|
          calculator.stopped_trading_on = response
        end

        validate(:not_in_tax_year_error) do
          calculator.valid_stopped_trading_date?
        end

        next_node do
          question :what_is_your_taxable_profit?
        end
      end

      multiple_choice :do_your_accounts_cover_a_12_month_period? do
        option "yes"
        option "no"

        precalculate(:accounting_year_ends_on) { calculator.accounting_year.ends_on }

        next_node do |response|
          if response == "yes"
            question :what_is_your_taxable_profit?
          else
            question :when_did_you_start_trading?
          end
        end
      end

      date_question :when_did_you_start_trading? do
        from { Calculators::PartYearProfitTaxCreditsCalculator::START_OR_STOP_TRADING_EARLIEST_DATE }
        to   { Calculators::PartYearProfitTaxCreditsCalculator::START_OR_STOP_TRADING_LATEST_DATE }

        precalculate(:award_period_ends_on) { calculator.award_period.ends_on }

        on_response do |response|
          calculator.started_trading_on = response
        end

        validate(:invalid_start_trading_date) do
          calculator.valid_start_trading_date?
        end

        next_node do
          if calculator.stopped_trading
            question :when_did_you_stop_trading?
          else
            question :what_is_your_taxable_profit?
          end
        end
      end

      money_question :what_is_your_taxable_profit? do
        precalculate(:basis_period_begins_on) { calculator.basis_period.begins_on }
        precalculate(:basis_period_ends_on)   { calculator.basis_period.ends_on }

        on_response do |response|
          calculator.taxable_profit = response
        end

        next_node do
          outcome :result
        end
      end

      outcome :result
    end
  end
end
