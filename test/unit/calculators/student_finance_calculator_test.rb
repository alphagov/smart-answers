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
            assert_equal Money.new(0).to_s, calculator.maintenance_grant_amount.to_s
          end

          should "return the maximum amount, 3_387, for a household with £25k income or less" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 25_000,
              residence: :unused_variable
            )
            assert_equal Money.new(3387).to_s, calculator.maintenance_grant_amount.to_s
          end

          should "return 1494 for a household with £35k income (£1 less than max for each whole £5.28 above £25000 up to £42,611)" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 35_000,
              residence: :unused_variable
            )
            assert_equal Money.new(1494).to_s, calculator.maintenance_grant_amount.to_s
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
            assert_equal Money.new(0).to_s, calculator.maintenance_grant_amount.to_s
          end
        end
      end

      context "#maintenance_loan_amount" do
        context "for students who started 2016-2017 living at home with parents" do
          setup do
            @course_start = '2016-2017'
            @residence = 'at-home'
          end

          should "give the maximum amount of £6,904 if household income is £25k or below" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 25_000,
              residence: @residence
            )
            assert_equal Money.new(6_904).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "reduce the maximum amount (£6,904) by £1 for every complete £8.59 of income above £25k" do
            # Samples taken from the document provided
            {
              30_000 => 6_322,
              35_000 => 5_740,
              40_000 => 5_158,
              42_875 => 4_824,
              45_000 => 4_576,
              50_000 => 3_994,
              55_000 => 3_412,
              58_201 => 3_039
            }.each do |household_income, loan_amount|
              calculator = StudentFinanceCalculator.new(
                course_start: @course_start,
                household_income: household_income,
                residence: @residence
              )
              assert_equal Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          should "cap the reductions and give the minimum loan of £3,039 for high household income students" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 500_000,
              residence: @residence
            )
            assert_equal Money.new(3_039).to_s, calculator.maintenance_loan_amount.to_s
          end
        end

        context "for students who started 2016-2017 living away not in london" do
          setup do
            @course_start = '2016-2017'
            @residence = 'away-outside-london'
          end

          should "give the maximum amount of £8,200 if household income is £25k or below" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 25_000,
              residence: @residence
            )
            assert_equal Money.new(8_200).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "reduce the maximum amount (£8,200) by £1 for every complete £8.49 of income above £25k" do
            # Samples taken from the document provided
            {
              30_000 => 7_612,
              35_000 => 7_023,
              40_000 => 6_434,
              42_875 => 6_095,
              45_000 => 5_845,
              50_000 => 5_256,
              55_000 => 4_667,
              60_000 => 4_078,
              62_180 => 3_821
            }.each do |household_income, loan_amount|
              calculator = StudentFinanceCalculator.new(
                course_start: @course_start,
                household_income: household_income,
                residence: @residence
              )
              assert_equal Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          should "cap the reductions and give the minimum loan of £3,821 for high household income students" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 500_000,
              residence: @residence
            )
            assert_equal Money.new(3_821).to_s, calculator.maintenance_loan_amount.to_s
          end
        end

        context "for students who started 2016-2017 living away in london" do
          setup do
            @course_start = '2016-2017'
            @residence = 'away-in-london'
          end

          should "give the maximum amount of £10,702 if household income is £25k or below" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 25_000,
              residence: @residence
            )
            assert_equal Money.new(10_702).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "reduce the maximum amount (£10,702) by £1 for every complete £8.34 of income above £25k" do
            # Samples taken from the document provided
            {
              30_000 => 10_103,
              35_000 => 9_503,
              40_000 => 8_904,
              42_875 => 8_559,
              45_000 => 8_304,
              50_000 => 7_705,
              55_000 => 7_105,
              60_000 => 6_506,
              65_000 => 5_906,
              69_803 => 5_330
            }.each do |household_income, loan_amount|
              calculator = StudentFinanceCalculator.new(
                course_start: @course_start,
                household_income: household_income,
                residence: @residence
              )
              assert_equal Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          should "cap the reductions and give the minimum loan of £5,330 for high household income students" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 500_000,
              residence: @residence
            )
            assert_equal Money.new(5_330).to_s, calculator.maintenance_loan_amount.to_s
          end
        end

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
            assert_equal Money.new(2872).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "reduce the max amount (£5740) by £0.5 for each £1 of maintenance grant for students living away" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'away-outside-london'
            )
            assert_equal Money.new(4047).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "reduce the max amount (£8009) by £0.5 for each £1 of maintenance grant for students living away in London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'away-in-london'
            )
            assert_equal Money.new(6316).to_s, calculator.maintenance_loan_amount.to_s
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
            assert_equal Money.new(4565).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "give maximum loan £5740 for students living away" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'away-outside-london'
            )
            assert_equal Money.new(5740).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "give maximum loan £8009 for students living away in London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'away-in-london'
            )
            assert_equal Money.new(8009).to_s, calculator.maintenance_loan_amount.to_s
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
            assert_equal Money.new(3823).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "reduce the max amount (£5740) by £1 for each full £9.90 of income above £42875 for students living away" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'away-outside-london'
            )
            assert_equal Money.new(4998).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "reduce the max amount (£8009) by £1 for each full £9.90 of income above £42875 for students living away in London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'away-in-london'
            )
            assert_equal Money.new(7267).to_s, calculator.maintenance_loan_amount.to_s
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
            assert_equal Money.new(2967).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "apply the 65% of max load amount minimum and give 0.65 * £5740 for students living away" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'away-outside-london'
            )
            assert_equal Money.new(3731).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "apply the 65% of max load amount minimum and give 0.65 * £8009 for students living away in London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'away-in-london'
            )
            assert_equal Money.new(5205).to_s, calculator.maintenance_loan_amount.to_s
          end
        end
      end
    end
  end
end
