require_relative "../../test_helper"

module SmartAnswer
  class PartYearProfitCalculatorTest < ActiveSupport::TestCase
    context 'tax credits finish in 2015/16 tax year for an ongoing business with accounting period aligned to the tax year' do
      setup do
        @calculator = Calculators::PartYearProfitCalculator.new

        @calculator.tax_credits_award_ends_on  = Date.parse('2015-08-01')
        @calculator.accounts_end_month_and_day = Date.parse('0000-04-05')
        @calculator.taxable_profit             = Money.new(10_000)
      end

      should "use the 2015/16 tax year" do
        expected_tax_year = TaxYear.new(begins_in: 2015)
        assert_equal expected_tax_year, @calculator.tax_year
      end

      should "use the accounting period from 6th Apr 2015 to 5th Apr 2016" do
        expected_accounting_period = YearRange.new(
          begins_on: Date.parse('2015-04-06')
        )
        assert_equal expected_accounting_period, @calculator.accounting_period
        assert_equal 366, @calculator.accounting_period.number_of_days
      end

      should "have an award period from the start of the tax year to the date the tax credits award end" do
        expected_award_period = DateRange.new(
          begins_on: Date.parse('2015-04-06'),
          ends_on:   Date.parse('2015-08-01')
        )
        assert_equal expected_award_period, @calculator.tax_credits_part_year
        assert_equal 118, @calculator.tax_credits_part_year.number_of_days
      end

      should "calculate the profit per day" do
        expected_profit_per_day = (Money.new(10_000) / 366).floor(2)
        assert_equal 27.32, expected_profit_per_day
        assert_equal expected_profit_per_day, @calculator.profit_per_day
      end

      should "calculate taxable profit for the award period" do
        expected_taxable_profit = (27.32 * 118).floor
        assert_equal 3223, expected_taxable_profit
        assert_equal expected_taxable_profit, @calculator.part_year_taxable_profit
      end
    end

    context 'tax credits finish in 2015/16 tax year for an ongoing business with accounting period aligned to the calendar year' do
      setup do
        @calculator = Calculators::PartYearProfitCalculator.new

        @calculator.tax_credits_award_ends_on  = Date.parse('2015-08-01')
        @calculator.accounts_end_month_and_day = Date.parse('0000-12-31')
        @calculator.taxable_profit             = Money.new(10_000)
      end

      should "use the 2015/16 tax year" do
        expected_tax_year = TaxYear.new(begins_in: 2015)
        assert_equal expected_tax_year, @calculator.tax_year
      end

      should "use the accounting period from 1st Jan to 31st Dec 2015" do
        expected_accounting_period = YearRange.new(
          begins_on: Date.parse('2015-01-01')
        )
        assert_equal expected_accounting_period, @calculator.accounting_period
        assert_equal 365, @calculator.accounting_period.number_of_days
      end

      should "have an award period from the start of the tax year to the date the tax credits award end" do
        expected_award_period = DateRange.new(
          begins_on: Date.parse('2015-04-06'),
          ends_on:   Date.parse('2015-08-01')
        )
        assert_equal expected_award_period, @calculator.tax_credits_part_year
        assert_equal 118, @calculator.tax_credits_part_year.number_of_days
      end

      should "calculate the profit per day" do
        expected_profit_per_day = (Money.new(10_000) / 365).floor(2)
        assert_equal 27.39, expected_profit_per_day
        assert_equal expected_profit_per_day, @calculator.profit_per_day
      end

      should "calculate taxable profit for the award period" do
        expected_taxable_profit = (27.39 * 118).floor
        assert_equal 3232, expected_taxable_profit
        assert_equal expected_taxable_profit, @calculator.part_year_taxable_profit
      end
    end
  end
end
