require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class PartYearProfitCalculatorTest < ActiveSupport::TestCase
      setup do
        Timecop.freeze(Date.parse('2015-07-29'))
      end

      teardown do
        Timecop.return
      end

      context 'basis period' do
        setup do
          @accounts_start_on = Date.parse('2015-04-06')
          @calculator = PartYearProfitCalculator.new(accounts_start_on: @accounts_start_on)
        end

        should 'begins on the accounts start date' do
          assert_equal @accounts_start_on, @calculator.basis_period.begins_on
        end

        should 'be one year long' do
          assert_equal @accounts_start_on + 1.year - 1.day, @calculator.basis_period.ends_on
        end

        should 'calculate number of days' do
          expected_number_of_days = (@calculator.basis_period.ends_on - @accounts_start_on).to_i + 1
          assert_equal expected_number_of_days, @calculator.basis_period.number_of_days
        end
      end

      context 'award period' do
        setup do
          @tax_credits_awarded_on = Date.parse('2016-02-20')
          @calculator = PartYearProfitCalculator.new(tax_credits_awarded_on: @tax_credits_awarded_on)
        end

        should 'begin at the beginning of the current tax year' do
          assert_equal Date.parse('2015-04-06'), @calculator.award_period.begins_on
        end

        should 'end on the award date' do
          assert_equal @tax_credits_awarded_on, @calculator.award_period.ends_on
        end

        should 'calculate number of days' do
          expected_number_of_days = (@tax_credits_awarded_on - Date.parse('2015-04-06')).to_i + 1
          assert_equal expected_number_of_days, @calculator.award_period.number_of_days
        end
      end

      context 'profit per day' do
        setup do
          @number_of_days_in_basis_period, @profit_for_current_period = 366, Money.new(15000)
          basis_period = stub('basis_period', number_of_days: @number_of_days_in_basis_period)
          @calculator = PartYearProfitCalculator.new(profit_for_current_period: @profit_for_current_period)
          @calculator.stubs(:basis_period).returns(basis_period)
        end

        should 'divide profit by number of days in basis period and round down to nearest penny' do
          expected_profit_per_day = @profit_for_current_period / @number_of_days_in_basis_period
          assert_not_equal expected_profit_per_day, @calculator.profit_per_day, 'Not rounded down to nearest penny'
          assert_equal expected_profit_per_day.floor(2), @calculator.profit_per_day
        end
      end

      context 'part year profit' do
        setup do
          @number_of_days_in_award_period, @profit_per_day = 321, 40.98
          award_period = stub('award_period', number_of_days: @number_of_days_in_award_period)
          @calculator = PartYearProfitCalculator.new
          @calculator.stubs(award_period: award_period, profit_per_day: @profit_per_day)
        end

        should 'multiply profit per day by number of days in award period and round down to nearest pound' do
          expected_part_year_profit = @profit_per_day * @number_of_days_in_award_period
          assert_not_equal expected_part_year_profit, @calculator.part_year_profit, 'Not rounded down to nearest pound'
          assert_equal expected_part_year_profit.floor, @calculator.part_year_profit
        end
      end
    end
  end
end
