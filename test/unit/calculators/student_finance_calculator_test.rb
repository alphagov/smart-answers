require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class StudentFinanceCalculatorTest < ActiveSupport::TestCase
      context "#maintenance_grant_amount" do
        context "for students who started 2015-2016 or earlier" do
          setup do
            @course_start = '2015-2016'
          end
          should "return 0 for a houshold with income exceeding £42_620" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 42_621,
              residence: :unused_variable
            )
            assert_equal Money.new(0), calculator.maintenance_grant_amount
          end

          should "return the maximum amount, 3_387, for a household with £25k income or less" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 25_000,
              residence: :unused_variable
            )
            assert_equal Money.new(3387), calculator.maintenance_grant_amount
          end

          should "return 1494 for a household with £35k income (£1 less than max for each whole £5.28 above £25000 up to £42,611)" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 35_000,
              residence: :unused_variable
            )
            assert_equal Money.new(1494), calculator.maintenance_grant_amount
          end
        end

        context "for students who started 2016-2017 or later" do
          setup do
            @course_start = '2016-2017'
          end
          should "return 0 for any student" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 15_000,
              residence: :unused_variable
            )
            assert_equal Money.new(0), calculator.maintenance_grant_amount
          end
        end
      end

      context "#maintenance_loan_amount" do
        context "for students who started 2015-2016 with lower income" do
          setup do
            @course_start = '2015-2016'
            @household_income = 25_000
          end

          should "reduce the max amount (£4565) by £0.5 for each £1 of maintenance grant for students living at home" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'at-home'
            )
            assert_equal Money.new(2872), calculator.maintenance_loan_amount
          end

          should "reduce the max amount (£5740) by £0.5 for each £1 of maintenance grant for students living away" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'away-outside-london'
            )
            assert_equal Money.new(4047), calculator.maintenance_loan_amount
          end

          should "reduce the max amount (£8009) by £0.5 for each £1 of maintenance grant for students living away in London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'away-in-london'
            )
            assert_equal Money.new(6316), calculator.maintenance_loan_amount
          end
        end

        context "for students who started 2015-2016 with £42.621 income" do
          setup do
            @course_start = '2015-2016'
            @household_income = 42_621 # below low income thresshold for loans, does not qualify for a grant
          end

          should "give maximum loan £4565 for students living at home" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'at-home'
            )
            assert_equal Money.new(4565), calculator.maintenance_loan_amount
          end

          should "give maximum loan £5740 for students living away" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'away-outside-london'
            )
            assert_equal Money.new(5740), calculator.maintenance_loan_amount
          end

          should "give maximum loan £8009 for students living away in London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'away-in-london'
            )
            assert_equal Money.new(8009), calculator.maintenance_loan_amount
          end
        end

        context "for students who started 2015-2016 with higher income" do
          setup do
            @course_start = '2015-2016'
            @household_income = 50_000
          end

          should "reduce the max amount (£4565) by £1 for each full £9.90 of income above £42875 for students living at home" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'at-home'
            )
            assert_equal Money.new(3823), calculator.maintenance_loan_amount
          end

          should "reduce the max amount (£5740) by £1 for each full £9.90 of income above £42875 for students living away" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'away-outside-london'
            )
            assert_equal Money.new(4998), calculator.maintenance_loan_amount
          end

          should "reduce the max amount (£8009) by £1 for each full £9.90 of income above £42875 for students living away in London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'away-in-london'
            )
            assert_equal Money.new(7267), calculator.maintenance_loan_amount
          end
        end

        context "for students who started 2015-2016 with high income" do
          setup do
            @course_start = '2015-2016'
            @household_income = 500_000
          end

          should "apply the 65% of max load amount minimum and give 0.65 * £4565 for students living at home" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'at-home'
            )
            assert_equal Money.new(2967), calculator.maintenance_loan_amount
          end

          should "apply the 65% of max load amount minimum and give 0.65 * £5740 for students living away" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'away-outside-london'
            )
            assert_equal Money.new(3731), calculator.maintenance_loan_amount
          end

          should "apply the 65% of max load amount minimum and give 0.65 * £8009 for students living away in London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'away-in-london'
            )
            assert_equal Money.new(5205), calculator.maintenance_loan_amount
          end
        end
      end
    end
  end
end
