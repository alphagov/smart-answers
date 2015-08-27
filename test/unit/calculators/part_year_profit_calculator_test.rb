require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class PartYearProfitCalculatorTest < ActiveSupport::TestCase
      context 'tax year' do
        setup do
          @tax_credits_award_ends_on = Date.parse('2016-02-20')
          @calculator = PartYearProfitCalculator.new(tax_credits_award_ends_on: @tax_credits_award_ends_on)
        end

        should 'calculate tax year in which tax credits award ends' do
          tax_year = stub('tax-year')
          TaxYear.stubs(:on).with(@tax_credits_award_ends_on).returns(tax_year)
          assert_equal tax_year, @calculator.tax_year
        end
      end

      context 'accounts end on' do
        setup do
          @calculator = PartYearProfitCalculator.new(accounts_end_month_and_day: Date.parse('0000-06-30'))
        end

        context 'when tax credits award ends in 2015-16 tax year' do
          setup do
            @calculator.tax_credits_award_ends_on = Date.parse('2016-04-05')
          end

          should 'be date within 2015-16 tax year with specified month and day' do
            assert_equal Date.parse('2015-06-30'), @calculator.accounting_period.ends_on
          end
        end

        context 'when tax credits award ends in 2016-17 tax year' do
          setup do
            @calculator.tax_credits_award_ends_on = Date.parse('2016-04-06')
          end

          should 'be date within 2016-17 tax year with specified month and day' do
            assert_equal Date.parse('2016-06-30'), @calculator.accounting_period.ends_on
          end
        end
      end

      context 'accounting period' do
        setup do
          @accounts_end_on = Date.parse('2015-12-31')
          @calculator = PartYearProfitCalculator.new
          @calculator.stubs(:accounting_year_end_date).returns(@accounts_end_on)
        end

        should 'begin a year before the accounts end' do
          assert_equal Date.parse('2015-01-01'), @calculator.accounting_period.begins_on
        end

        should 'end on the date the accounts end' do
          assert_equal @accounts_end_on, @calculator.accounting_period.ends_on
        end
      end

      context 'tax credits part year' do
        setup do
          @tax_credits_award_ends_on = Date.parse('2016-02-20')
          @calculator = PartYearProfitCalculator.new(tax_credits_award_ends_on: @tax_credits_award_ends_on)
        end

        should 'begin at the beginning of the tax year in which the tax credits award ends' do
          assert_equal Date.parse('2015-04-06'), @calculator.tax_credits_part_year.begins_on
        end

        should 'end on the date the tax credits award ends' do
          assert_equal @tax_credits_award_ends_on, @calculator.tax_credits_part_year.ends_on
        end
      end

      context 'profit per day' do
        setup do
          @number_of_days_in_accounting_period = 366
          @taxable_profit = Money.new(15000)
          accounting_period = stub('accounting_period', number_of_days: @number_of_days_in_accounting_period)
          @calculator = PartYearProfitCalculator.new(taxable_profit: @taxable_profit)
          @calculator.stubs(:accounting_period).returns(accounting_period)
        end

        should 'divide profit by number of days in accounting period and round down to nearest penny' do
          expected_profit_per_day = @taxable_profit / @number_of_days_in_accounting_period
          assert_not_equal expected_profit_per_day, @calculator.profit_per_day, 'Not rounded down to nearest penny'
          assert_equal expected_profit_per_day.floor(2), @calculator.profit_per_day
        end
      end

      context 'part year taxable profit' do
        setup do
          @number_of_days_in_tax_credits_part_year = 321
          @profit_per_day = 40.98
          tax_credits_part_year = stub('tax_credits_part_year', number_of_days: @number_of_days_in_tax_credits_part_year)
          @calculator = PartYearProfitCalculator.new
          @calculator.stubs(tax_credits_part_year: tax_credits_part_year, profit_per_day: @profit_per_day)
        end

        should 'multiply profit per day by number of days in tax credits part year and round down to nearest pound' do
          expected_part_year_taxable_profit = @profit_per_day * @number_of_days_in_tax_credits_part_year
          assert_not_equal expected_part_year_taxable_profit, @calculator.part_year_taxable_profit, 'Not rounded down to nearest pound'
          assert_equal expected_part_year_taxable_profit.floor, @calculator.part_year_taxable_profit
        end
      end
    end
  end
end
