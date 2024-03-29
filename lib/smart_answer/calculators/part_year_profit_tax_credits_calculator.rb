module SmartAnswer
  module Calculators
    class PartYearProfitTaxCreditsCalculator
      include ActiveModel::Model

      attr_accessor :tax_credits_award_ends_on,
                    :accounts_end_month_and_day,
                    :taxable_profit,
                    :stopped_trading,
                    :started_trading_on,
                    :stopped_trading_on

      def valid_stopped_trading_date?
        tax_year.include?(stopped_trading_on)
      end

      def valid_start_trading_date?
        started_trading_on < award_period.ends_on
      end

      def tax_year
        YearRange.tax_year.including(tax_credits_award_ends_on)
      end

      def basis_period
        begins_on = [accounting_year.begins_on, started_trading_on].compact.max
        ends_on   = stopped_trading_on || accounting_year.ends_on
        DateRange.new(begins_on:, ends_on:)
      end

      def accounting_year
        YearRange.new(begins_on: accounting_year_start_date)
      end

      def award_period
        begins_on = [tax_year.begins_on, started_trading_on].compact.max
        ends_on   = [tax_credits_award_ends_on, stopped_trading_on].compact.min
        DateRange.new(begins_on:, ends_on:)
      end

      def profit_per_day
        (taxable_profit / basis_period.number_of_days).floor(2)
      end

      def award_period_taxable_profit
        if basis_period == award_period
          taxable_profit
        else
          pro_rata_taxable_profit
        end
      end

      def pro_rata_taxable_profit
        (profit_per_day * award_period.number_of_days).floor
      end

    private

      def accounting_year_end_date_in_the_tax_year_that_tax_credits_award_ends
        accounting_date = accounts_end_month_and_day.change(year: tax_year.begins_on.year)
        accounting_date += 1.year unless tax_year.include?(accounting_date)
        accounting_date
      end

      alias_method :accounting_year_end_date, :accounting_year_end_date_in_the_tax_year_that_tax_credits_award_ends

      def accounting_year_start_date
        accounting_year_end_date - 1.year + 1
      end
    end
  end
end
