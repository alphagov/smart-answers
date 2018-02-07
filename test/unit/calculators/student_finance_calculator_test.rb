require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class StudentFinanceCalculatorTest < ActiveSupport::TestCase
      test "StudentFinanceCalculator is valid and setup properly" do
        calculator = StudentFinanceCalculator.new(
          course_start: '2017-2018',
          household_income: 15_000,
          residence: 'at-home',
          course_type: 'uk-full-time'
        )
        assert_instance_of StudentFinanceCalculator, calculator

        assert_equal '2017-2018', calculator.course_start
        assert_equal 15000, calculator.household_income
        assert_equal 'at-home', calculator.residence
        assert_equal 'uk-full-time', calculator.course_type
      end

      test "StudentFinanceCalculator instance variables can be changed after initialisation" do
        calculator = StudentFinanceCalculator.new

        assert_instance_of StudentFinanceCalculator, calculator

        assert_nil calculator.course_start
        assert_nil calculator.household_income
        assert_nil calculator.residence
        assert_nil calculator.course_type

        calculator.course_start = '2017-2018'
        calculator.household_income = 15_000
        calculator.residence = 'at-home'
        calculator.course_type = 'uk-full-time'

        assert_equal '2017-2018', calculator.course_start
        assert_equal 15000, calculator.household_income
        assert_equal 'at-home', calculator.residence
        assert_equal 'uk-full-time', calculator.course_type
      end

      context "childcare_grant" do
        context "for one child" do
          context "in 2017-2018" do
            should "be 159.59" do
              calculator = StudentFinanceCalculator.new(
                course_start: "2017-2018",
                household_income: 25_000,
                residence: :unused_variable
              )
              assert_equal 159.59, calculator.childcare_grant_one_child
            end
          end
        end
        context "for more than one child" do
          context "in 2017-2018" do
            should "be 273.60" do
              calculator = StudentFinanceCalculator.new(
                course_start: "2017-2018",
                household_income: 25_000,
                residence: :unused_variable
              )
              assert_equal 273.60, calculator.childcare_grant_more_than_one_child
            end
          end
        end
      end

      context "#parent_learning_allowance" do
        should "be 1617 in 2017-2018" do
          calculator = StudentFinanceCalculator.new(
            course_start: "2017-2018",
            household_income: 25_000,
            residence: :unused_variable
          )
          assert_equal 1617, calculator.parent_learning_allowance
        end
      end

      context "#adult_dependant_allowance" do
        should "be 2834 in 2017-2018" do
          calculator = StudentFinanceCalculator.new(
            course_start: "2017-2018",
            household_income: 25_000,
            residence: :unused_variable
          )
          assert_equal 2834, calculator.adult_dependant_allowance
        end
      end

      context "#tuition_fee_maximum" do
        context "in 2017-2018" do
          setup do
            @calculator = StudentFinanceCalculator.new(
              course_start: "2017-2018",
              household_income: 15_000,
              residence: :unused_variable,
              course_type: "uk-full-time"
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
      end

      context "maximum tuition fee" do
        context "for a full time student" do
          context "in 2017-2018" do
            should "be 9250" do
              calculator = StudentFinanceCalculator.new(
                course_start: "2017-2018",
                household_income: 25_000,
                residence: :unused_variable,
              )
              assert_equal 9250, calculator.tuition_fee_maximum_full_time
            end
          end
        end
        context "for part time student" do
          context "in 2017-2018" do
            should "be 6935" do
              calculator = StudentFinanceCalculator.new(
                course_start: "2017-2018",
                household_income: 25_000,
                residence: :unused_variable
              )
              assert_equal 6935, calculator.tuition_fee_maximum_part_time
            end
          end
        end
      end

      context "#doctor_or_dentist?" do
        setup do
          @calculator = StudentFinanceCalculator.new(
            course_start: "2017-2018",
            household_income: 15_000,
            residence: :unused_variable,
            course_type: "uk-full-time",
            dental_or_medical_course: "none-of-the-above"
          )
        end

        should "return true if course is doctor-or-dentist" do
          @calculator.dental_or_medical_course = "doctor-or-dentist"
          assert_equal true, @calculator.doctor_or_dentist?
        end

        should "return false if course is not doctor-or-dentist" do
          @calculator.dental_or_medical_course = "none-of-the-above"
          assert_equal false, @calculator.doctor_or_dentist?
        end
      end

      context "#maintenance_loan_amount" do
        context "for students who started 2017-2018 living at home with parents" do
          setup do
            @course_start = '2017-2018'
            @residence = 'at-home'
          end

          should "give the maximum amount of £7,097 if household income is £25k or below" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 25_000,
              residence: @residence
            )
            assert_equal Money.new(7_097).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "reduce the maximum amount (£7,097) by £1 for every complete £8.36 of income above £25k" do
            # Samples taken from the document provided
            {
              30_000 => 6_499,
              35_000 => 5_901,
              40_000 => 5_303,
              42_875 => 4_959,
              45_000 => 4_705,
              50_000 => 4_107,
              55_000 => 3_509,
              58_215 => 3_124,
              60_000 => 3_124,
              65_000 => 3_124
            }.each do |household_income, loan_amount|
              calculator = StudentFinanceCalculator.new(
                course_start: @course_start,
                household_income: household_income,
                residence: @residence
              )
              assert_equal Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          should "cap the reductions and give the minimum loan of £3,124 for high household income students" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 500_000,
              residence: @residence
            )
            assert_equal Money.new(3_124).to_s, calculator.maintenance_loan_amount.to_s
          end
        end

        context "for students who started 2017-2018 living away not in london" do
          setup do
            @course_start = '2017-2018'
            @residence = 'away-outside-london'
          end

          should "give the maximum amount of £8,430 if household income is £25k or below" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 25_000,
              residence: @residence
            )
            assert_equal Money.new(8_430).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "reduce the maximum amount (£8,430) by £1 for every complete £8.26 of income above £25k" do
            # Samples taken from the document provided
            {
              30_000 => 7_825,
              35_000 => 7_220,
              40_000 => 6_615,
              42_875 => 6_266,
              45_000 => 6_009,
              50_000 => 5_404,
              55_000 => 4_799,
              60_000 => 4_193,
              62_187 => 3_928,
              65_000 => 3_928,
              70_000 => 3_928
            }.each do |household_income, loan_amount|
              calculator = StudentFinanceCalculator.new(
                course_start: @course_start,
                household_income: household_income,
                residence: @residence
              )
              assert_equal Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          should "cap the reductions and give the minimum loan of £3,928 for high household income students" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 500_000,
              residence: @residence
            )
            assert_equal Money.new(3_928).to_s, calculator.maintenance_loan_amount.to_s
          end
        end

        context "for students who started 2017-2018 living away in london" do
          setup do
            @course_start = '2017-2018'
            @residence = 'away-in-london'
          end

          should "give the maximum amount of £11,002 if household income is £25k or below" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 25_000,
              residence: @residence
            )
            assert_equal Money.new(11_002).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "reduce the maximum amount (£11,002) by £1 for every complete £8.12 of income above £25k" do
            # Samples taken from the document provided
            {
               30_000 => 10_387,
               35_000 => 9_771,
               40_000 => 9_155,
               42_875 => 8_801,
               45_000 => 8_539,
               50_000 => 7_924,
               55_000 => 7_308,
               60_000 => 6_692,
               65_000 => 6_076,
               69_847 => 5_479,
               70_000 => 5_479
            }.each do |household_income, loan_amount|
              calculator = StudentFinanceCalculator.new(
                course_start: @course_start,
                household_income: household_income,
                residence: @residence
              )
              assert_equal Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          should "cap the reductions and give the minimum loan of £5,479 for high household income students" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 500_000,
              residence: @residence
            )
            assert_equal Money.new(5_479).to_s, calculator.maintenance_loan_amount.to_s
          end
        end

        context "#reduced_maintenance_loan_for_healthcare" do
          should "be £3263 for students living away from home in London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'away-in-london'
            )

            assert_equal 3263, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £2324 for students living away from home outside London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'away-outside-london'
            )

            assert_equal 2324, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £1744 for students living away from home outside London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'at-home'
            )

            assert_equal 1744, calculator.reduced_maintenance_loan_for_healthcare
          end
        end
      end
    end
  end
end
