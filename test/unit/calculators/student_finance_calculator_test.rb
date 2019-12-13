require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class StudentFinanceCalculatorTest < ActiveSupport::TestCase
      test "StudentFinanceCalculator is valid and setup properly" do
        calculator = StudentFinanceCalculator.new(
          course_start: "2020-2021",
          household_income: 25_000,
          residence: "at-home",
          course_type: "uk-full-time",
        )
        assert_instance_of StudentFinanceCalculator, calculator

        assert_equal "2020-2021", calculator.course_start
        assert_equal 25000, calculator.household_income
        assert_equal "at-home", calculator.residence
        assert_equal "uk-full-time", calculator.course_type
      end

      test "StudentFinanceCalculator instance variables can be changed after initialisation" do
        calculator = StudentFinanceCalculator.new

        assert_instance_of StudentFinanceCalculator, calculator

        assert_nil calculator.course_start
        assert_nil calculator.household_income
        assert_nil calculator.residence
        assert_nil calculator.course_type

        calculator.course_start = "2020-2021"
        calculator.household_income = 25_000
        calculator.residence = "at-home"
        calculator.course_type = "uk-full-time"

        assert_equal "2020-2021", calculator.course_start
        assert_equal 25000, calculator.household_income
        assert_equal "at-home", calculator.residence
        assert_equal "uk-full-time", calculator.course_type
      end

      context "childcare_grant" do
        context "for one child" do
          context "in 2020-2021" do
            should "be 174.22" do
              calculator = StudentFinanceCalculator.new(
                course_start: "2020-2021",
                household_income: 25_000,
                residence: :unused_variable,
              )
              assert_equal 174.22, calculator.childcare_grant_one_child
            end
          end
        end
        context "for more than one child" do
          context "in 2020-2021" do
            should "be 298.69" do
              calculator = StudentFinanceCalculator.new(
                course_start: "2020-2021",
                household_income: 25_000,
                residence: :unused_variable,
              )
              assert_equal 298.69, calculator.childcare_grant_more_than_one_child
            end
          end
        end
      end

      context "#parent_learning_allowance" do
        should "be 1766 in 2018-2019" do
          calculator = StudentFinanceCalculator.new(
            course_start: "2020-2021",
            household_income: 25_000,
            residence: :unused_variable,
          )
          assert_equal 1766, calculator.parent_learning_allowance
        end
      end

      context "#adult_dependant_allowance" do
        should "be 3094 in 2020-2021" do
          calculator = StudentFinanceCalculator.new(
            course_start: "2020-2021",
            household_income: 25_000,
            residence: :unused_variable,
          )
          assert_equal 3094, calculator.adult_dependant_allowance
        end
      end

      context "#tuition_fee_maximum" do
        setup do
          @calculator = StudentFinanceCalculator.new(
            course_start: :unused_variable,
            household_income: 15_000,
            residence: :unused_variable,
            course_type: "uk-full-time",
          )
        end

        should "be 9250 for uk or eu full-time student" do
          assert_equal 9250, @calculator.tuition_fee_maximum
        end

        should "be 6935 for uk or eu part-time student" do
          @calculator.course_type = "uk-part-time"
          assert_equal 6935, @calculator.tuition_fee_maximum
        end
      end

      context "maximum tuition fee" do
        context "for a full time student" do
          should "be 9250" do
            calculator = StudentFinanceCalculator.new(
              household_income: 25_000,
              residence: :unused_variable,
              course_type: "uk-full-time",
            )
            assert_equal 9250, calculator.tuition_fee_maximum_full_time
          end
        end
        context "for part time student" do
          should "be 6935" do
            calculator = StudentFinanceCalculator.new(
              household_income: 25_000,
              residence: :unused_variable,
            )
            assert_equal 6935, calculator.tuition_fee_maximum_part_time
          end
        end
      end

      context "#maintenance_loan_amount" do
        context "for students who started 2020-2021 living at home with parents" do
          setup do
            @course_start = "2020-2021"
            @residence = "at-home"
          end

          should "give the maximum amount of £7747 if household income is £25k or below" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 25_000,
              residence: @residence,
              course_type: "uk-full-time",
            )
            assert_equal SmartAnswer::Money.new(7747).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "reduce the maximum amount (£7747) by £1 for every complete £7.66 of income above £25k" do
            # Samples taken from the document provided
            {
              30_000 => 7_095,
              35_000 => 6_442,
              40_000 => 5_789,
              42_875 => 5_414,
              45_000 => 5_137,
              50_000 => 4_484,
              55_000 => 3_831,
              58_215 => 3_411,
              60_000 => 3_410,
              65_000 => 3_410,
            }.each do |household_income, loan_amount|
              calculator = StudentFinanceCalculator.new(
                course_start: @course_start,
                household_income: household_income,
                residence: @residence,
                course_type: "uk-full-time",
              )
              assert_equal SmartAnswer::Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          should "cap the reductions and give the minimum loan of £3410 for high household income students" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 500_000,
              residence: @residence,
              course_type: "uk-full-time",
            )
            assert_equal SmartAnswer::Money.new(3_410).to_s, calculator.maintenance_loan_amount.to_s
          end
        end

        context "for students who started 2020-2021 living away not in london" do
          setup do
            @course_start = "2020-2021"
            @residence = "away-outside-london"
          end

          should "give the maximum amount of £9203 if household income is £25k or below" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 25_000,
              residence: @residence,
              course_type: "uk-full-time",
            )
            assert_equal SmartAnswer::Money.new(9_203).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "reduce the maximum amount (£9203) by £1 for every complete £7.58 of income above £25k" do
            # Samples taken from the document provided
            {
              30_000 => 8_544,
              35_000 => 7_884,
              40_000 => 7_225,
              42_875 => 6_845,
              45_000 => 6_565,
              50_000 => 5_905,
              55_000 => 5_246,
              60_000 => 4_586,
              62_215 => 4_294,
              65_000 => 4_289,
              70_000 => 4_289,
            }.each do |household_income, loan_amount|
              calculator = StudentFinanceCalculator.new(
                course_start: @course_start,
                household_income: household_income,
                residence: @residence,
                course_type: "uk-full-time",
              )
              assert_equal SmartAnswer::Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          should "cap the reductions and give the minimum loan of £4,289 for high household income students" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 500_000,
              residence: @residence,
              course_type: "uk-full-time",
            )
            assert_equal SmartAnswer::Money.new(4_289).to_s, calculator.maintenance_loan_amount.to_s
          end
        end

        context "for students who started 2020-2021 living away in london" do
          setup do
            @course_start = "2020-2021"
            @residence = "away-in-london"
          end

          should "give the maximum amount of £12010 if household income is £25k or below" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 25_000,
              residence: @residence,
              course_type: "uk-full-time",
            )
            assert_equal SmartAnswer::Money.new(12_010).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "reduce the maximum amount (£12010) by £1 for every complete £7.46 of income above £25k" do
            # Samples taken from the document provided
            {
               30_000 => 11_340,
               35_000 => 10_670,
               40_000 => 10_000,
               42_875 => 9_614,
               45_000 => 9_330,
               50_000 => 8_659,
               55_000 => 7_989,
               60_000 => 7_319,
               65_000 => 6_649,
               69_860 => 5_997,
               70_000 => 5_981,
            }.each do |household_income, loan_amount|
              calculator = StudentFinanceCalculator.new(
                course_start: @course_start,
                household_income: household_income,
                residence: @residence,
                course_type: "uk-full-time",
              )
              assert_equal SmartAnswer::Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          should "cap the reductions and give the minimum loan of £5,981 for high household income students" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 500_000,
              residence: @residence,
              course_type: "uk-full-time",
            )
            assert_equal SmartAnswer::Money.new(5_981).to_s, calculator.maintenance_loan_amount.to_s
          end
        end

        context "for 2020-2021 part-time students" do
          setup do
            @course_start = "2020-2021"
            @course_type = "uk-part-time"
          end

          should "be weighted by course intensity" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 45_000,
              residence: "away-in-london",
              course_type: @course_type,
              part_time_credits: 12,
              full_time_credits: 20,
            )
            assert_equal SmartAnswer::Money.new(4_665.0).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "be zero if course intensity is less than 25%" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 45_000,
              residence: "away-in-london",
              course_type: @course_type,
              part_time_credits: 2,
              full_time_credits: 10,
            )
            assert_equal SmartAnswer::Money.new(0).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "be the same as a full-time course if intensity is 100%" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 60_000,
              residence: "away-outside-london",
              course_type: @course_type,
              part_time_credits: 15,
              full_time_credits: 15,
            )
            assert_equal SmartAnswer::Money.new(4586).to_s, calculator.maintenance_loan_amount.to_s
          end
        end
      end

      context "#reduced_maintenance_loan_for_healthcare" do
        context "for 2020-2021" do
          setup do
            @course_start = "2020-2021"
            @household_income = 25_000
            @course_type = "uk-full-time"
            @doctor_or_dentist = true
          end

          should "be £3451 for students living away from home in London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              course_type: @course_type,
              residence: "away-in-london",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 3451, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £2458 for students living away from home outside London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              course_type: @course_type,
              residence: "away-outside-london",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 2458, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £1845 for students living away from home outside London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              course_type: @course_type,
              residence: "at-home",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 1845, calculator.reduced_maintenance_loan_for_healthcare
          end
        end

        context "for 2019-2020" do
          setup do
            @course_start = "2019-2020"
            @household_income = 25_000
            @course_type = "uk-full-time"
            @doctor_or_dentist = true
          end

          should "be £3354 for students living away from home in London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              course_type: @course_type,
              residence: "away-in-london",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 3354, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £2389 for students living away from home outside London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              course_type: @course_type,
              residence: "away-outside-london",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 2389, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £1793 for students living away from home outside London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              course_type: @course_type,
              residence: "at-home",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 1793, calculator.reduced_maintenance_loan_for_healthcare
          end
        end
      end

      context "#course_start_years" do
        context "for students" do
          should "be 2020 and 2021" do
            calculator = StudentFinanceCalculator.new(
              course_start: "2020-2021",
            )

            assert_equal [2020, 2021], calculator.course_start_years
          end
        end
      end
    end
  end
end
