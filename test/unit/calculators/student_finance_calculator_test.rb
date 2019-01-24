require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class StudentFinanceCalculatorTest < ActiveSupport::TestCase
      test "StudentFinanceCalculator is valid and setup properly" do
        calculator = StudentFinanceCalculator.new(
          course_start: '2018-2019',
          household_income: 25_000,
          residence: 'at-home',
          course_type: 'uk-full-time'
        )
        assert_instance_of StudentFinanceCalculator, calculator

        assert_equal '2018-2019', calculator.course_start
        assert_equal 25000, calculator.household_income
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

        calculator.course_start = '2018-2019'
        calculator.household_income = 25_000
        calculator.residence = 'at-home'
        calculator.course_type = 'uk-full-time'

        assert_equal '2018-2019', calculator.course_start
        assert_equal 25000, calculator.household_income
        assert_equal 'at-home', calculator.residence
        assert_equal 'uk-full-time', calculator.course_type
      end

      context "childcare_grant" do
        context "for one child" do
          context "in 2018-2019" do
            should "be 164.70" do
              calculator = StudentFinanceCalculator.new(
                course_start: "2018-2019",
                household_income: 25_000,
                residence: :unused_variable
              )
              assert_equal 164.70, calculator.childcare_grant_one_child
            end
          end
        end
        context "for more than one child" do
          context "in 2018-2019" do
            should "be 282.36" do
              calculator = StudentFinanceCalculator.new(
                course_start: "2018-2019",
                household_income: 25_000,
                residence: :unused_variable
              )
              assert_equal 282.36, calculator.childcare_grant_more_than_one_child
            end
          end
        end
      end

      context "#parent_learning_allowance" do
        should "be 1669 in 2018-2019" do
          calculator = StudentFinanceCalculator.new(
            course_start: "2018-2019",
            household_income: 25_000,
            residence: :unused_variable
          )
          assert_equal 1669, calculator.parent_learning_allowance
        end
      end

      context "#adult_dependant_allowance" do
        should "be 2925 in 2018-2019" do
          calculator = StudentFinanceCalculator.new(
            course_start: "2018-2019",
            household_income: 25_000,
            residence: :unused_variable
          )
          assert_equal 2925, calculator.adult_dependant_allowance
        end
      end

      context "#tuition_fee_maximum" do
        setup do
          @calculator = StudentFinanceCalculator.new(
            course_start: :unused_variable,
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
              residence: :unused_variable
            )
            assert_equal 6935, calculator.tuition_fee_maximum_part_time
          end
        end
      end

      context "#doctor_or_dentist?" do
        setup do
          @calculator = StudentFinanceCalculator.new(
            household_income: 15_000,
            residence: :unused_variable,
            course_type: "uk-full-time",
          )
        end

        context "2018-2019" do
          setup do
            @calculator.course_start = "2018-2019"
          end

          should "return true if course is doctor-or-dentist" do
            @calculator.doctor_or_dentist = true
            assert_equal true, @calculator.doctor_or_dentist?
          end

          should "return false if course is not doctor-or-dentist" do
            @calculator.doctor_or_dentist = false
            assert_equal false, @calculator.doctor_or_dentist?
          end
        end
      end

      context "#maintenance_loan_amount" do
        context "for students who started 2018-2019 living at home with parents" do
          setup do
            @course_start = '2018-2019'
            @residence = 'at-home'
          end

          should "give the maximum amount of £7,097 if household income is £25k or below" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 25_000,
              residence: @residence,
              course_type: "uk-full-time",
            )
            assert_equal SmartAnswer::Money.new(7324).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "reduce the maximum amount (£7,324) by £1 for every complete £8.10 of income above £25k" do
            # Samples taken from the document provided
            {
              30_000 => 6_707,
              35_000 => 6_090,
              40_000 => 5_473,
              42_875 => 5_118,
              45_000 => 4_855,
              50_000 => 4_238,
              55_000 => 3_621,
              58_215 => 3_224,
              60_000 => 3_224,
              65_000 => 3_224
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

          should "cap the reductions and give the minimum loan of £3,224 for high household income students" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 500_000,
              residence: @residence,
              course_type: "uk-full-time",
            )
            assert_equal SmartAnswer::Money.new(3_224).to_s, calculator.maintenance_loan_amount.to_s
          end
        end

        context "for students who started 2018-2019 living away not in london" do
          setup do
            @course_start = '2018-2019'
            @residence = 'away-outside-london'
          end

          should "give the maximum amount of £8,700 if household income is £25k or below" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 25_000,
              residence: @residence,
              course_type: "uk-full-time",
            )
            assert_equal SmartAnswer::Money.new(8_700).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "reduce the maximum amount (£8,700) by £1 for every complete £8.01 of income above £25k" do
            # Samples taken from the document provided
            {
              30_000 => 8_076,
              35_000 => 7_452,
              40_000 => 6_828,
              42_875 => 6_469,
              45_000 => 6_204,
              50_000 => 5_579,
              55_000 => 4_955,
              60_000 => 4_331,
              62_215 => 4_054,
              65_000 => 4_054,
              70_000 => 4_054,
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

          should "cap the reductions and give the minimum loan of £4,054 for high household income students" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 500_000,
              residence: @residence,
              course_type: "uk-full-time",
            )
            assert_equal SmartAnswer::Money.new(4_054).to_s, calculator.maintenance_loan_amount.to_s
          end
        end

        context "for students who started 2018-2019 living away in london" do
          setup do
            @course_start = '2018-2019'
            @residence = 'away-in-london'
          end

          should "give the maximum amount of £11,354 if household income is £25k or below" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 25_000,
              residence: @residence,
              course_type: "uk-full-time",
            )
            assert_equal SmartAnswer::Money.new(11_354).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "reduce the maximum amount (£11,354) by £1 for every complete £7.87 of income above £25k" do
            # Samples taken from the document provided
            {
               30_000 => 10_719,
               35_000 => 10_084,
               40_000 => 9_449,
               42_875 => 9_083,
               45_000 => 8_813,
               50_000 => 8_178,
               55_000 => 7_543,
               60_000 => 6_907,
               65_000 => 6_272,
               69_860 => 5_654,
               70_000 => 5_654,
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

          should "cap the reductions and give the minimum loan of £5,654 for high household income students" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 500_000,
              residence: @residence,
              course_type: "uk-full-time",
            )
            assert_equal SmartAnswer::Money.new(5_654).to_s, calculator.maintenance_loan_amount.to_s
          end
        end

        context "for 2018-2019 part-time students" do
          setup do
            @course_start = '2018-2019'
            @course_type = 'uk-part-time'
          end

          should "be weighted by course intensity" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 45_000,
              residence: 'away-in-london',
              course_type: @course_type,
              part_time_credits: 12,
              full_time_credits: 20,
            )
            assert_equal SmartAnswer::Money.new(4_406.50).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "be zero if course intensity is less than 25%" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 45_000,
              residence: 'away-in-london',
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
              residence: 'away-outside-london',
              course_type: @course_type,
              part_time_credits: 15,
              full_time_credits: 15,
            )
            assert_equal SmartAnswer::Money.new(4331).to_s, calculator.maintenance_loan_amount.to_s
          end
        end
      end

      context "#reduced_maintenance_loan_for_healthcare" do
        context "for 2018-2019" do
          setup do
            @course_start = '2018-2019'
            @household_income = 25_000
            @course_type = 'uk-full-time'
          end

          should "be £3263 for students living away from home in London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              course_type: @course_type,
              residence: 'away-in-london',
            )

            assert_equal 3263, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £2324 for students living away from home outside London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              course_type: @course_type,
              residence: 'away-outside-london'
            )

            assert_equal 2324, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £1744 for students living away from home outside London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              course_type: @course_type,
              residence: 'at-home'
            )

            assert_equal 1744, calculator.reduced_maintenance_loan_for_healthcare
          end
        end

        context "for 2019-2020" do
          setup do
            @course_start = '2019-2020'
            @household_income = 25_000
            @course_type = "uk-full-time"
            @dental_or_medical_course = true
            @doctor_or_dentist = true
          end

          should "be £3354 for students living away from home in London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              course_type: @course_type,
              residence: 'away-in-london',
              dental_or_medical_course: @dental_or_medical_course,
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 3354, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £2389 for students living away from home outside London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              course_type: @course_type,
              residence: 'away-outside-london',
              dental_or_medical_course: @dental_or_medical_course,
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 2389, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £1793 for students living away from home outside London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              course_type: @course_type,
              residence: 'at-home',
              dental_or_medical_course: @dental_or_medical_course,
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 1793, calculator.reduced_maintenance_loan_for_healthcare
          end
        end
      end

      context "#course_start_years" do
        context "for students" do
          should "be 2018 and 2019" do
            calculator = StudentFinanceCalculator.new(
              course_start: "2018-2019"
            )

            assert_equal [2018, 2019], calculator.course_start_years
          end
        end
      end
    end
  end
end
