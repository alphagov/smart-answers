require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class PartYearProfitCalculatorTest < ActiveSupport::TestCase
      context 'validation of stopped trading date' do
        setup do
          @calculator = PartYearProfitCalculator.new
          @calculator.tax_credits_award_ends_on = Date.parse('2015-08-01')
        end

        should 'be valid if the stopped trading date is in the tax year that the tax credits award ended' do
          assert @calculator.valid_stopped_trading_date?(Date.parse('2015-04-06'))
          assert @calculator.valid_stopped_trading_date?(Date.parse('2016-04-05'))
        end

        should 'be invalid if the stopped trading date is before the tax year that the tax credits award ended' do
          refute @calculator.valid_stopped_trading_date?(Date.parse('2015-04-05'))
        end

        should 'be invalid if the stopped trading date is after the tax year that the tax credits award ended' do
          refute @calculator.valid_stopped_trading_date?(Date.parse('2016-04-06'))
        end
      end

      context 'validation of start trading date' do
        setup do
          @calculator = PartYearProfitCalculator.new
        end

        context 'when the business is still trading' do
          setup do
            @calculator.tax_credits_award_ends_on = Date.parse('2015-08-01')
          end

          should 'be valid if the date is before the date the tax credits award ends' do
            assert @calculator.valid_start_trading_date?(Date.parse('2015-07-31'))
          end

          should 'be invalid if the date is on or after the date the tax credits award ends' do
            refute @calculator.valid_start_trading_date?(Date.parse('2015-08-01'))
            refute @calculator.valid_start_trading_date?(Date.parse('2016-01-01'))
          end
        end

        context 'when the business stops trading before the tax credits award ends' do
          setup do
            @calculator.tax_credits_award_ends_on = Date.parse('2015-08-01')
            @calculator.stopped_trading_on        = Date.parse('2015-07-01')
          end

          should 'be valid if the date is before the date the business stopped trading' do
            assert @calculator.valid_start_trading_date?(Date.parse('2015-06-30'))
          end

          should 'be invalid if the date is on or after the date the business stopped trading' do
            refute @calculator.valid_start_trading_date?(Date.parse('2015-07-01'))
            refute @calculator.valid_start_trading_date?(Date.parse('2016-01-01'))
          end
        end
      end

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

      context 'basis period' do
        setup do
          @accounting_period = YearRange.new(begins_on: Date.parse('2015-01-01'))
          @calculator = PartYearProfitCalculator.new
          @calculator.stubs(accounting_period: @accounting_period)
        end

        should 'return the accounting period when the business is still trading' do
          @calculator.stopped_trading_on = nil
          assert_equal @accounting_period, @calculator.basis_period
        end

        should 'return the period between the start of the accounting period and the stopped trading date' do
          @calculator.stopped_trading_on = Date.parse('2015-02-01')
          expected_range = DateRange.new(begins_on: Date.parse('2015-01-01'), ends_on: Date.parse('2015-02-01'))
          assert_equal expected_range, @calculator.basis_period
        end

        context 'when the business commenced trading in the accounting year that ends in the tax year within which tax credits award ends' do
          setup do
            @calculator = PartYearProfitCalculator.new
            @calculator.tax_credits_award_ends_on  = Date.parse('2016-02-01')
            @calculator.accounts_end_month_and_day = Date.parse('0000-04-05')
            @calculator.started_trading_on         = Date.parse('2015-05-01')
          end

          context 'and the business is still trading' do
            should 'return the period between the commenced trading date and the accounting date that falls in the tax year within which tax credits award ends' do
              expected_basis_period = DateRange.new(
                begins_on: Date.parse('2015-05-01'),
                ends_on:   Date.parse('2016-04-05')
              )

              assert_equal expected_basis_period, @calculator.basis_period
            end
          end

          context 'and the business stops trading' do
            setup do
              @calculator.stopped_trading_on = Date.parse('2016-03-01')
            end

            should 'return the period between the commenced trading date and the stopped trading date' do
              expected_basis_period = DateRange.new(
                begins_on: Date.parse('2015-05-01'),
                ends_on:   Date.parse('2016-03-01')
              )

              assert_equal expected_basis_period, @calculator.basis_period
            end
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

      context 'award period' do
        setup do
          @tax_credits_award_ends_on = Date.parse('2016-02-20')
          @calculator = PartYearProfitCalculator.new(tax_credits_award_ends_on: @tax_credits_award_ends_on)
        end

        should 'begin at the beginning of the tax year in which the tax credits award ends' do
          assert_equal Date.parse('2015-04-06'), @calculator.award_period.begins_on
        end

        should 'end on the date the tax credits award ends' do
          assert_equal @tax_credits_award_ends_on, @calculator.award_period.ends_on
        end

        should 'end on the date the business stops trading if that date is before the date the tax credits award ends' do
          stopped_trading_on = Date.parse('2016-02-19')
          @calculator.stopped_trading_on = stopped_trading_on
          assert_equal stopped_trading_on, @calculator.award_period.ends_on
        end
      end

      context 'profit per day' do
        setup do
          @number_of_days_in_basis_period = 366
          @taxable_profit = Money.new(15000)
          basis_period = stub('basis_period', number_of_days: @number_of_days_in_basis_period)
          @calculator = PartYearProfitCalculator.new(taxable_profit: @taxable_profit)
          @calculator.stubs(:basis_period).returns(basis_period)
        end

        should 'divide profit by number of days in basis period and round down to nearest penny' do
          expected_profit_per_day = @taxable_profit / @number_of_days_in_basis_period
          assert_not_equal expected_profit_per_day, @calculator.profit_per_day, 'Not rounded down to nearest penny'
          assert_equal expected_profit_per_day.floor(2), @calculator.profit_per_day
        end
      end

      context 'pro rata taxable profit' do
        setup do
          @number_of_days_in_award_period = 321
          @profit_per_day = 40.98
          award_period = stub('award_period', number_of_days: @number_of_days_in_award_period)
          @calculator = PartYearProfitCalculator.new
          @calculator.stubs(award_period: award_period, profit_per_day: @profit_per_day)
        end

        should 'multiply profit per day by number of days in award period and round down to nearest pound' do
          expected_award_period_taxable_profit = @profit_per_day * @number_of_days_in_award_period
          assert_not_equal expected_award_period_taxable_profit, @calculator.pro_rata_taxable_profit, 'Not rounded down to nearest pound'
          assert_equal expected_award_period_taxable_profit.floor, @calculator.pro_rata_taxable_profit
        end
      end

      context 'award period taxable profit' do
        setup do
          @tax_year_begins_on = Date.parse('2015-04-06')
          @tax_credit_award_ends_on = Date.parse('2015-08-01')
          @award_period = DateRange.new(begins_on: @tax_year_begins_on, ends_on: @tax_credit_award_ends_on)
          @calculator = PartYearProfitCalculator.new
          @calculator.stubs(award_period: @award_period)
        end

        should 'return taxable profit figure when the award period matches the basis period' do
          basis_period = DateRange.new(begins_on: @tax_year_begins_on, ends_on: @tax_credit_award_ends_on)
          @calculator.stubs(basis_period: basis_period)
          @calculator.stubs(taxable_profit: 10_000)

          assert_equal 10_000, @calculator.award_period_taxable_profit
        end

        should 'return pro rata taxable profit when the award period and basis period are different' do
          basis_period = YearRange.new(begins_on: @tax_year_begins_on)
          @calculator.stubs(basis_period: basis_period)
          @calculator.stubs(pro_rata_taxable_profit: 10_000)

          assert_equal 10_000, @calculator.award_period_taxable_profit
        end
      end
    end
  end
end
