require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class StudentFinanceCalculatorTest < ActiveSupport::TestCase
      test "StudentFinanceCalculator is valid and setup properly" do
        calculator = StudentFinanceCalculator.new(
          course_start: "2024-2025",
          household_income: 25_000,
          residence: "at-home",
          course_type: "full-time",
        )
        assert_instance_of StudentFinanceCalculator, calculator

        assert_equal "2024-2025", calculator.course_start
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

        calculator.course_start = "2024-2025"
        calculator.household_income = 25_000
        calculator.residence = "at-home"
        calculator.course_type = "full-time"

        assert_equal "2024-2025", calculator.course_start
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

      context "in 2024-2025" do
        current_year = "2024-2025"

        context "childcare_grant" do
          context "for one child" do
            should "be £193.62" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: :unused_variable,
              )
              assert_equal 193.62, calculator.childcare_grant_one_child
            end
          end

          context "for more than one child" do
            should "be £331.95" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: :unused_variable,
              )
              assert_equal 331.95, calculator.childcare_grant_more_than_one_child
            end
          end
        end

        context "#parent_learning_allowance" do
          should "be £1_963" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: 25_000,
              residence: :unused_variable,
            )
            assert_equal 1_963, calculator.parent_learning_allowance
          end
        end

        context "#adult_dependant_allowance" do
          should "be £3_438" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: 25_000,
              residence: :unused_variable,
            )
            assert_equal 3_438, calculator.adult_dependant_allowance
          end
        end

        context "#maintenance_loan_amount" do
          context "for students who started 2024-2025 living at home with parents" do
            setup do
              @residence = "at-home"
            end

            should "give the maximum amount of £8_610 if household income is £25k or below" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: @residence,
                course_type: "full-time",
              )
              assert_equal SmartAnswer::Money.new(8_610).to_s, calculator.maintenance_loan_amount.to_s
            end

            should "reduce the maximum amount £8_610 by £1 for every complete £6.91 of income above £25k to a minimum of £3_790" do
              # Samples taken from the document provided
              {
                30_000 => 7_887,
                35_000 => 7_163,
                40_000 => 6_440,
                42_875 => 6_024,
                45_000 => 5_716,
                50_000 => 4_993,
                55_000 => 4_269,
                58_215 => 3_804,
                60_000 => 3_790,
                65_000 => 3_790,
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

            should "cap the reductions and give the minimum loan of £3_790 for high household income students" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 500_000,
                residence: @residence,
                course_type: "full-time",
              )
              assert_equal SmartAnswer::Money.new(3_790).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          context "for students who started 2024-2025 living away not in london" do
            setup do
              @residence = "away-outside-london"
            end

            should "give the maximum amount of £9978 if household income is £25k or below" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: @residence,
                course_type: "full-time",
              )
              assert_equal SmartAnswer::Money.new(10_227).to_s, calculator.maintenance_loan_amount.to_s
            end

            should "reduce the maximum amount of £10_227 by £1 for every complete £6.84 of income above £25k to a minimum of £4_767" do
              # Samples taken from the document provided
              {
                30_000 => 9_497,
                35_000 => 8_766,
                40_000 => 8_035,
                42_875 => 7_614,
                45_000 => 7_304,
                50_000 => 6_573,
                55_000 => 5_842,
                60_000 => 5_111,
                62_215 => 4_787,
                65_000 => 4_767,
                70_000 => 4_767,
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

            should "cap the reductions and give the minimum loan of £4_767 for high household income students" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 500_000,
                residence: @residence,
                course_type: "full-time",
              )
              assert_equal SmartAnswer::Money.new(4_767).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          context "for students who started 2024-2025 living away in london" do
            setup do
              @residence = "away-in-london"
            end

            should "give the maximum amount of £13002 if household income is £25k or below" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: @residence,
                course_type: "full-time",
              )
              assert_equal SmartAnswer::Money.new(13_348).to_s, calculator.maintenance_loan_amount.to_s
            end

            should "reduce the maximum amount of £13_348 by £1 for every complete £6.73 of income above £25k to a minimum of £6_647" do
              {
                30_000 => 12_606,
                35_000 => 11_863,
                40_000 => 11_120,
                42_875 => 10_692,
                45_000 => 10_377,
                50_000 => 9_634,
                55_000 => 8_891,
                60_000 => 8_148,
                65_000 => 7_405,
                69_860 => 6_683,
                70_000 => 6_662,
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

            should "cap the reductions and give the minimum loan of £6_647 for high household income students" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 500_000,
                residence: @residence,
                course_type: "full-time",
              )
              assert_equal SmartAnswer::Money.new(6_647).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          context "for 2024-2025 part-time students" do
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

          should "be £3_749 for students living away from home in London" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              residence: "away-in-london",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 3_749, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £2_670 for students living away from home outside London" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              residence: "away-outside-london",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 2_670, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £2_004 for students living at home" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              residence: "at-home",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 2_004, calculator.reduced_maintenance_loan_for_healthcare
          end
        end
      end

      context "in 2024-2025" do
        current_year = "2024-2025"

        context "childcare_grant" do
          context "for one child" do
            should "be £193.62" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: :unused_variable,
              )
              assert_equal 193.62, calculator.childcare_grant_one_child
            end
          end

          context "for more than one child" do
            should "be £331.95" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: :unused_variable,
              )
              assert_equal 331.95, calculator.childcare_grant_more_than_one_child
            end
          end
        end

        context "#parent_learning_allowance" do
          should "be £1963" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: 25_000,
              residence: :unused_variable,
            )
            assert_equal 1_963, calculator.parent_learning_allowance
          end
        end

        context "#adult_dependant_allowance" do
          should "be £3438" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: 25_000,
              residence: :unused_variable,
            )
            assert_equal 3_438, calculator.adult_dependant_allowance
          end
        end

        context "#maintenance_loan_amount" do
          context "for students who started 2024-2025 living at home with parents" do
            setup do
              @residence = "at-home"
            end

            should "give the maximum amount of £8610 if household income is £25k or below" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: @residence,
                course_type: "full-time",
              )
              assert_equal SmartAnswer::Money.new(8_610).to_s, calculator.maintenance_loan_amount.to_s
            end

            should "reduce the maximum amount £8610 by £1 for every complete £6.91 of income above £25k to a minimum of £3790" do
              {
                30_000 => 7_887,
                35_000 => 7_163,
                40_000 => 6_440,
                42_875 => 6_024,
                45_000 => 5_716,
                50_000 => 4_993,
                55_000 => 4_269,
                58_215 => 3_804,
                60_000 => 3_790,
                65_000 => 3_790,
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

            should "cap the reductions and give the minimum loan of £3790 for high household income students" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 500_000,
                residence: @residence,
                course_type: "full-time",
              )
              assert_equal SmartAnswer::Money.new(3_790).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          context "for students who started 2024-2025 living away not in london" do
            setup do
              @residence = "away-outside-london"
            end

            should "give the maximum amount of £10227 if household income is £25k or below" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: @residence,
                course_type: "full-time",
              )
              assert_equal SmartAnswer::Money.new(10_227).to_s, calculator.maintenance_loan_amount.to_s
            end

            should "reduce the maximum amount of £10227 by £1 for every complete £6.84 of income above £25k to a minimum of £4767" do
              {
                30_000 => 9_497,
                35_000 => 8_766,
                40_000 => 8_035,
                42_875 => 7_614,
                45_000 => 7_304,
                50_000 => 6_573,
                55_000 => 5_842,
                60_000 => 5_111,
                62_215 => 4_787,
                65_000 => 4_767,
                70_000 => 4_767,
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

            should "cap the reductions and give the minimum loan of £4,767 for high household income students" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 500_000,
                residence: @residence,
                course_type: "full-time",
              )
              assert_equal SmartAnswer::Money.new(4_767).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          context "for students who started 2024-2025 living away in london" do
            setup do
              @residence = "away-in-london"
            end

            should "give the maximum amount of £13348 if household income is £25k or below" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: @residence,
                course_type: "full-time",
              )
              assert_equal SmartAnswer::Money.new(13_348).to_s, calculator.maintenance_loan_amount.to_s
            end

            should "reduce the maximum amount of £13348 by £1 for every complete £6.73 of income above £25k to a minimum of £6647" do
              # Samples taken from the document provided
              {
                30_000 => 12_606,
                35_000 => 11_863,
                40_000 => 11_120,
                42_875 => 10_692,
                45_000 => 10_377,
                50_000 => 9_634,
                55_000 => 8_891,
                60_000 => 8_148,
                65_000 => 7_405,
                69_860 => 6_683,
                70_000 => 6_662,
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

            should "cap the reductions and give the minimum loan of £6,647 for high household income students" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 500_000,
                residence: @residence,
                course_type: "full-time",
              )
              assert_equal SmartAnswer::Money.new(6_647).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          context "for 2024-2025 part-time students" do
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
              assert_equal SmartAnswer::Money.new(5_188.5).to_s, calculator.maintenance_loan_amount.to_s
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
              assert_equal SmartAnswer::Money.new(5111).to_s, calculator.maintenance_loan_amount.to_s
            end
          end
        end

        context "#reduced_maintenance_loan_for_healthcare" do
          setup do
            @household_income = 25_000
            @doctor_or_dentist = true
          end

          should "be £3749 for students living away from home in London" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              residence: "away-in-london",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 3749, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £2670 for students living away from home outside London" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              residence: "away-outside-london",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 2670, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £2004 for students living at home" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              residence: "at-home",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 2004, calculator.reduced_maintenance_loan_for_healthcare
          end
        end
      end

      context "#course_start_years" do
        context "for students" do
          should "be 2024 and 2025" do
            calculator = StudentFinanceCalculator.new(
              course_start: "2024-2025",
            )

            assert_equal [2024, 2025], calculator.course_start_years
          end

          should "be 2025 and 2026" do
            calculator = StudentFinanceCalculator.new(
              course_start: "2025-2026",
            )

            assert_equal [2025, 2026], calculator.course_start_years
          end
        end
      end
    end
  end
end
