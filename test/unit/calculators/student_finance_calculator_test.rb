require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class StudentFinanceCalculatorTest < ActiveSupport::TestCase
      test "StudentFinanceCalculator is valid and setup properly" do
        calculator = StudentFinanceCalculator.new(
          course_start: "2025-2026",
          household_income: 25_000,
          residence: "at-home",
          course_type: "full-time",
        )
        assert_instance_of StudentFinanceCalculator, calculator

        assert_equal "2025-2026", calculator.course_start
        assert_equal 25_000, calculator.household_income
        assert_equal "at-home", calculator.residence
        assert_equal "full-time", calculator.course_type
      end

      test "StudentFinanceCalculator instance variables can be changed after initialisation" do
        calculator = StudentFinanceCalculator.new

        assert_instance_of StudentFinanceCalculator, calculator

        assert_nil calculator.course_start
        assert_nil calculator.household_income
        assert_nil calculator.residence
        assert_nil calculator.course_type

        calculator.course_start = "2025-2026"
        calculator.household_income = 25_000
        calculator.residence = "at-home"
        calculator.course_type = "full-time"

        assert_equal "2025-2026", calculator.course_start
        assert_equal 25_000, calculator.household_income
        assert_equal "at-home", calculator.residence
        assert_equal "full-time", calculator.course_type
      end

      context "#eligible_for_childcare_grant_one_child?" do
        should "not be eligible when on a low household income with no dependants" do
          calculator = StudentFinanceCalculator.new(
            household_income: StudentFinanceCalculator::CHILD_CARE_GRANTS_ONE_CHILD_HOUSEHOLD_INCOME,
          )
          assert_not calculator.eligible_for_childcare_grant_one_child?
        end

        should "be eligible when on a low household income with dependants" do
          calculator = StudentFinanceCalculator.new(
            household_income: StudentFinanceCalculator::CHILD_CARE_GRANTS_ONE_CHILD_HOUSEHOLD_INCOME,
            uk_ft_circumstances: %w[children-under-17],
          )
          assert calculator.eligible_for_childcare_grant_one_child?
        end

        should "not be eligible when on a high household income with dependants" do
          calculator = StudentFinanceCalculator.new(
            household_income: StudentFinanceCalculator::CHILD_CARE_GRANTS_ONE_CHILD_HOUSEHOLD_INCOME + 0.01,
            uk_ft_circumstances: %w[children-under-17],
          )
          assert_not calculator.eligible_for_childcare_grant_one_child?
        end
      end

      context "#eligible_for_childcare_grant_more_than_one_child?" do
        should "not be eligible when on a low household income with no dependants" do
          calculator = StudentFinanceCalculator.new(
            household_income: StudentFinanceCalculator::CHILD_CARE_GRANTS_MORE_THAN_ONE_CHILD_HOUSEHOLD_INCOME,
          )
          assert_not calculator.eligible_for_childcare_grant_more_than_one_child?
        end

        should "be eligible when on a low household income with dependants" do
          calculator = StudentFinanceCalculator.new(
            household_income: StudentFinanceCalculator::CHILD_CARE_GRANTS_MORE_THAN_ONE_CHILD_HOUSEHOLD_INCOME,
            uk_ft_circumstances: %w[children-under-17],
          )
          assert calculator.eligible_for_childcare_grant_more_than_one_child?
        end

        should "not be eligible when on a high household income with dependants" do
          calculator = StudentFinanceCalculator.new(
            household_income: StudentFinanceCalculator::CHILD_CARE_GRANTS_MORE_THAN_ONE_CHILD_HOUSEHOLD_INCOME + 0.01,
            uk_ft_circumstances: %w[children-under-17],
          )
          assert_not calculator.eligible_for_childcare_grant_more_than_one_child?
        end
      end

      context "#eligible_for_parent_learning_allowance?" do
        should "not be eligible when on a low household income with no dependants" do
          calculator = StudentFinanceCalculator.new(
            household_income: StudentFinanceCalculator::PARENTS_LEARNING_HOUSEHOLD_INCOME,
          )
          assert_not calculator.eligible_for_parent_learning_allowance?
        end

        should "be eligible when on a low household income with dependants" do
          calculator = StudentFinanceCalculator.new(
            household_income: StudentFinanceCalculator::PARENTS_LEARNING_HOUSEHOLD_INCOME,
            uk_ft_circumstances: %w[children-under-17],
          )
          assert calculator.eligible_for_parent_learning_allowance?
        end

        should "not be eligible when on a high household income with dependants" do
          calculator = StudentFinanceCalculator.new(
            household_income: StudentFinanceCalculator::PARENTS_LEARNING_HOUSEHOLD_INCOME + 0.01,
            uk_ft_circumstances: %w[children-under-17],
          )
          assert_not calculator.eligible_for_parent_learning_allowance?
        end
      end

      context "#eligible_for_adult_dependant_allowance?" do
        should "not be eligible when on a low household income with no dependants" do
          calculator = StudentFinanceCalculator.new(
            household_income: StudentFinanceCalculator::ADULT_DEPENDANT_HOUSEHOLD_INCOME,
          )
          assert_not calculator.eligible_for_adult_dependant_allowance?
        end

        should "be eligible when on a low household income with dependants" do
          calculator = StudentFinanceCalculator.new(
            household_income: StudentFinanceCalculator::ADULT_DEPENDANT_HOUSEHOLD_INCOME,
            uk_ft_circumstances: %w[dependant-adult],
          )
          assert calculator.eligible_for_adult_dependant_allowance?
        end

        should "not be eligible when on a high household income with dependants" do
          calculator = StudentFinanceCalculator.new(
            household_income: StudentFinanceCalculator::ADULT_DEPENDANT_HOUSEHOLD_INCOME + 0.01,
            uk_ft_circumstances: %w[dependant-adult],
          )
          assert_not calculator.eligible_for_adult_dependant_allowance?
        end
      end

      context "#tuition_fee_maximum" do
        setup do
          @calculator = StudentFinanceCalculator.new(
            course_start: :unused_variable,
            household_income: 15_000,
            residence: :unused_variable,
          )
        end

        should "be £9535 for full-time student" do
          @calculator.course_type = "full-time"
          assert_equal 9790, @calculator.tuition_fee_maximum
        end

        should "be £7145 for part-time student" do
          @calculator.course_type = "part-time"
          assert_equal 7335, @calculator.tuition_fee_maximum
        end
      end

      context "maximum tuition fee" do
        should "be £9535 for a full time student" do
          calculator = StudentFinanceCalculator.new
          assert_equal 9790, calculator.tuition_fee_maximum_full_time
        end

        should "be £7145 for part time student" do
          calculator = StudentFinanceCalculator.new
          assert_equal 7335, calculator.tuition_fee_maximum_part_time
        end
      end

      context "in 2025-2026" do
        current_year = "2025-2026"

        context "childcare_grant" do
          context "for one child" do
            should "be £199.62" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: :unused_variable,
              )
              assert_equal 199.62, calculator.childcare_grant_one_child
            end
          end

          context "for more than one child" do
            should "be £342.24" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: :unused_variable,
              )
              assert_equal 342.24, calculator.childcare_grant_more_than_one_child
            end
          end
        end

        context "#parent_learning_allowance" do
          should "be £2_024" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: 25_000,
              residence: :unused_variable,
            )
            assert_equal 2_024, calculator.parent_learning_allowance
          end
        end

        context "#adult_dependant_allowance" do
          should "be 3_545" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: 25_000,
              residence: :unused_variable,
            )
            assert_equal 3_545, calculator.adult_dependant_allowance
          end
        end

        context "#maintenance_loan_amount" do
          context "for students who started 2025-2026 living at home with parents" do
            setup do
              @residence = "at-home"
            end

            should "give the maximum amount of £8_877 if household income is £25k or below" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: @residence,
                course_type: "full-time",
              )
              assert_equal SmartAnswer::Money.new(8_877).to_s, calculator.maintenance_loan_amount.to_s
            end

            should "reduce the maximum amount £8_610 by £1 for every complete £6.71 of income above £25k to a minimum of £3907" do
              # Samples taken from the document provided
              {
                30_000 => 8_132,
                35_000 => 7_387,
                40_000 => 6_642,
                42_875 => 6_214,
                45_000 => 5_897,
                50_000 => 5_152,
                55_000 => 4_407,
                58_215 => 3_927,
                60_000 => 3_907,
                65_000 => 3_907,
              }.each do |household_income, loan_amount|
                calculator = StudentFinanceCalculator.new(
                  course_start: current_year,
                  household_income:,
                  residence: @residence,
                  course_type: "full-time",
                )
                assert_equal SmartAnswer::Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
              end
            end

            should "cap the reductions and give the minimum loan of £3_907 for high household income students" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 500_000,
                residence: @residence,
                course_type: "full-time",
              )
              assert_equal SmartAnswer::Money.new(3_907).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          context "for students who started 2025-2026 living away not in london" do
            setup do
              @residence = "away-outside-london"
            end

            should "give the maximum amount of £10544 if household income is £25k or below" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: @residence,
                course_type: "full-time",
              )
              assert_equal SmartAnswer::Money.new(10_544).to_s, calculator.maintenance_loan_amount.to_s
            end

            should "reduce the maximum amount of £10_554 by £1 for every complete £6.64 of income above £25k to a minimum of £4_915" do
              # Samples taken from the document provided
              {
                30_000 => 9_791,
                35_000 => 9_038,
                40_000 => 8_285,
                42_875 => 7_852,
                45_000 => 7_532,
                50_000 => 6_779,
                55_000 => 6_026,
                60_000 => 5_273,
                62_215 => 4_940,
                65_000 => 4_915,
                70_000 => 4_915,
              }.each do |household_income, loan_amount|
                calculator = StudentFinanceCalculator.new(
                  course_start: current_year,
                  household_income:,
                  residence: @residence,
                  course_type: "full-time",
                )
                assert_equal SmartAnswer::Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
              end
            end

            should "cap the reductions and give the minimum loan of £4_915 for high household income students" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 500_000,
                residence: @residence,
                course_type: "full-time",
              )
              assert_equal SmartAnswer::Money.new(4_915).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          context "for students who started 2025-2026 living away in london" do
            setup do
              @residence = "away-in-london"
            end

            should "give the maximum amount of 13_762 if household income is £25k or below" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: @residence,
                course_type: "full-time",
              )
              assert_equal SmartAnswer::Money.new(13_762).to_s, calculator.maintenance_loan_amount.to_s
            end

            should "reduce the maximum amount of £13_762 by £1 for every complete £6.53 of income above £25k to a minimum of £6853" do
              {
                30_000 => 12_997,
                35_000 => 12_231,
                40_000 => 11_465,
                42_875 => 11_025,
                45_000 => 10_700,
                50_000 => 9_934,
                55_000 => 9_168,
                60_000 => 8_403,
                65_000 => 7_637,
                69_860 => 6_893,
                70_000 => 6_871,
                80_000 => 6_853,
              }.each do |household_income, loan_amount|
                calculator = StudentFinanceCalculator.new(
                  course_start: current_year,
                  household_income:,
                  residence: @residence,
                  course_type: "full-time",
                )
                assert_equal SmartAnswer::Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
              end
            end

            should "cap the reductions and give the minimum loan of £6_853 for high household income students" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 500_000,
                residence: @residence,
                course_type: "full-time",
              )
              assert_equal SmartAnswer::Money.new(6_853).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          context "for 2025-2026 part-time students" do
            setup do
              @course_type = "part-time"
            end

            should "be weighted by course intensity" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 45_000,
                residence: "away-in-london",
                course_type: @course_type,
                part_time_credits: 12,
                full_time_credits: 20,
              )
              assert_equal SmartAnswer::Money.new(5_050.0).to_s, calculator.maintenance_loan_amount.to_s
            end

            should "be zero if course intensity is less than 25%" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
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
                course_start: current_year,
                household_income: 60_000,
                residence: "away-outside-london",
                course_type: @course_type,
                part_time_credits: 15,
                full_time_credits: 15,
              )
              assert_equal SmartAnswer::Money.new(4986).to_s, calculator.maintenance_loan_amount.to_s
            end
          end
        end

        context "#reduced_maintenance_loan_for_healthcare" do
          setup do
            @household_income = 25_000
            @doctor_or_dentist = true
          end

          should "be £3_194 for students living away from home in London" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              residence: "away-in-london",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 3_194, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £4_485 for students living away from home outside London" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              residence: "away-outside-london",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 4_485, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £2_396 for students living at home" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              residence: "at-home",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 2_396, calculator.reduced_maintenance_loan_for_healthcare
          end
        end
      end

      context "in 2025-2026" do
        current_year = "2025-2026"

        context "childcare_grant" do
          context "for one child" do
            should "be £199.62" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: :unused_variable,
              )
              assert_equal 199.62, calculator.childcare_grant_one_child
            end
          end

          context "for more than one child" do
            should "be £342.24" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: :unused_variable,
              )
              assert_equal 342.24, calculator.childcare_grant_more_than_one_child
            end
          end
        end

        context "#parent_learning_allowance" do
          should "be £2024" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: 25_000,
              residence: :unused_variable,
            )
            assert_equal 2_024, calculator.parent_learning_allowance
          end
        end

        context "#adult_dependant_allowance" do
          should "be £3545" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: 25_000,
              residence: :unused_variable,
            )
            assert_equal 3_545, calculator.adult_dependant_allowance
          end
        end

        context "#maintenance_loan_amount" do
          context "for students who started 2025-2026 living at home with parents" do
            setup do
              @residence = "at-home"
            end

            should "give the maximum amount of £8877 if household income is £25k or below" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: @residence,
                course_type: "full-time",
              )
              assert_equal SmartAnswer::Money.new(8_877).to_s, calculator.maintenance_loan_amount.to_s
            end

            should "reduce the maximum amount £8610 by £1 for every complete £6.71 of income above £25k to a minimum of £3907" do
              {
                30_000 => 8_132,
                35_000 => 7_387,
                40_000 => 6_642,
                42_875 => 6_214,
                45_000 => 5_897,
                50_000 => 5_152,
                55_000 => 4_407,
                58_215 => 3_927,
                60_000 => 3_907,
                65_000 => 3_907,
              }.each do |household_income, loan_amount|
                calculator = StudentFinanceCalculator.new(
                  course_start: current_year,
                  household_income:,
                  residence: @residence,
                  course_type: "full-time",
                )
                assert_equal SmartAnswer::Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
              end
            end

            should "cap the reductions and give the minimum loan of £3907 for high household income students" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 500_000,
                residence: @residence,
                course_type: "full-time",
              )
              assert_equal SmartAnswer::Money.new(3_907).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          context "for students who started 2025-2026 living away not in london" do
            setup do
              @residence = "away-outside-london"
            end

            should "give the maximum amount of £10544 if household income is £25k or below" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: @residence,
                course_type: "full-time",
              )
              assert_equal SmartAnswer::Money.new(10_544).to_s, calculator.maintenance_loan_amount.to_s
            end

            should "reduce the maximum amount of £10227 by £1 for every complete £6.64 of income above £25k to a minimum of £4915" do
              {
                30_000 => 9_791,
                35_000 => 9_038,
                40_000 => 8_285,
                42_875 => 7_852,
                45_000 => 7_532,
                50_000 => 6_779,
                55_000 => 6_026,
                60_000 => 5_273,
                62_215 => 4_940,
                65_000 => 4_915,
                70_000 => 4_915,
              }.each do |household_income, loan_amount|
                calculator = StudentFinanceCalculator.new(
                  course_start: current_year,
                  household_income:,
                  residence: @residence,
                  course_type: "full-time",
                )
                assert_equal SmartAnswer::Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
              end
            end

            should "cap the reductions and give the minimum loan of £4,915 for high household income students" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 500_000,
                residence: @residence,
                course_type: "full-time",
              )
              assert_equal SmartAnswer::Money.new(4_915).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          context "for students who started 2025-2026 living away in london" do
            setup do
              @residence = "away-in-london"
            end

            should "give the maximum amount of £13762 if household income is £25k or below" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: @residence,
                course_type: "full-time",
              )
              assert_equal SmartAnswer::Money.new(13_762).to_s, calculator.maintenance_loan_amount.to_s
            end

            should "reduce the maximum amount of £13348 by £1 for every complete £6.53 of income above £25k to a minimum of £6853" do
              # Samples taken from the document provided
              {
                30_000 => 12_997,
                35_000 => 12_231,
                40_000 => 11_465,
                42_875 => 11_025,
                45_000 => 10_700,
                50_000 => 9_934,
                55_000 => 9_168,
                60_000 => 8_403,
                65_000 => 7_637,
                69_860 => 6_893,
                70_000 => 6_871,
                80_000 => 6_853,
              }.each do |household_income, loan_amount|
                calculator = StudentFinanceCalculator.new(
                  course_start: current_year,
                  household_income:,
                  residence: @residence,
                  course_type: "full-time",
                )
                assert_equal SmartAnswer::Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
              end
            end

            should "cap the reductions and give the minimum loan of £6,853 for high household income students" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 500_000,
                residence: @residence,
                course_type: "full-time",
              )
              assert_equal SmartAnswer::Money.new(6_853).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          context "for 2025-2026 part-time students" do
            setup do
              @course_type = "part-time"
            end

            should "be weighted by course intensity" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 45_000,
                residence: "away-in-london",
                course_type: @course_type,
                part_time_credits: 12,
                full_time_credits: 20,
              )
              assert_equal SmartAnswer::Money.new(5_350).to_s, calculator.maintenance_loan_amount.to_s
            end

            should "be zero if course intensity is less than 25%" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
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
                course_start: current_year,
                household_income: 60_000,
                residence: "away-outside-london",
                course_type: @course_type,
                part_time_credits: 15,
                full_time_credits: 15,
              )
              assert_equal SmartAnswer::Money.new(5273).to_s, calculator.maintenance_loan_amount.to_s
            end
          end
        end

        context "#reduced_maintenance_loan_for_healthcare" do
          setup do
            @household_income = 25_000
            @doctor_or_dentist = true
          end

          should "be £3194 for students living away from home in London" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              residence: "away-in-london",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 3194, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £4485 for students living away from home outside London" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              residence: "away-outside-london",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 4485, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £2396 for students living at home" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              residence: "at-home",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 2396, calculator.reduced_maintenance_loan_for_healthcare
          end
        end
      end

      context "#course_start_years" do
        context "for students" do
          should "be 2025 and 2026" do
            calculator = StudentFinanceCalculator.new(
              course_start: "2025-2026",
            )

            assert_equal [2025, 2026], calculator.course_start_years
          end

          should "be 2026 and 2027" do
            calculator = StudentFinanceCalculator.new(
              course_start: "2026-2027",
            )

            assert_equal [2026, 2027], calculator.course_start_years
          end
        end
      end
    end
  end
end
