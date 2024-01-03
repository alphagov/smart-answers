require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class StudentFinanceCalculatorTest < ActiveSupport::TestCase
      test "StudentFinanceCalculator is valid and setup properly" do
        calculator = StudentFinanceCalculator.new(
          course_start: "2023-2024",
          household_income: 25_000,
          residence: "at-home",
          course_type: "uk-full-time",
        )
        assert_instance_of StudentFinanceCalculator, calculator

        assert_equal "2023-2024", calculator.course_start
        assert_equal 25_000, calculator.household_income
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

        calculator.course_start = "2023-2024"
        calculator.household_income = 25_000
        calculator.residence = "at-home"
        calculator.course_type = "uk-full-time"

        assert_equal "2023-2024", calculator.course_start
        assert_equal 25_000, calculator.household_income
        assert_equal "at-home", calculator.residence
        assert_equal "uk-full-time", calculator.course_type
      end

      context "#eligible_for_childcare_grant_one_child?" do
        should "have low household income and no dependencies" do
          calculator = StudentFinanceCalculator.new(
            household_income: 18_786,
          )
          assert_not calculator.eligible_for_childcare_grant_one_child?
        end

        should "have high household income and no dependencies" do
          calculator = StudentFinanceCalculator.new(
            household_income: 18_787,
          )
          assert_not calculator.eligible_for_childcare_grant_one_child?
        end

        should "have low household income and children" do
          calculator = StudentFinanceCalculator.new(
            household_income: 18_786,
            uk_ft_circumstances: %w[children-under-17],
          )
          assert calculator.eligible_for_childcare_grant_one_child?
        end

        should "have high household income and children" do
          calculator = StudentFinanceCalculator.new(
            household_income: 19_800,
            uk_ft_circumstances: %w[children-under-17],
          )
          assert_not calculator.eligible_for_childcare_grant_one_child?
        end
      end

      context "#eligible_for_childcare_grant_more_than_one_child?" do
        should "have low household income and no dependencies" do
          calculator = StudentFinanceCalculator.new(
            household_income: 26_649,
          )
          assert_not calculator.eligible_for_childcare_grant_more_than_one_child?
        end

        should "have high household income and no dependencies" do
          calculator = StudentFinanceCalculator.new(
            household_income: 26_650,
          )
          assert_not calculator.eligible_for_childcare_grant_more_than_one_child?
        end

        should "have low household income and children" do
          calculator = StudentFinanceCalculator.new(
            household_income: 26_649,
            uk_ft_circumstances: %w[children-under-17],
          )
          assert calculator.eligible_for_childcare_grant_more_than_one_child?
        end

        should "have high household income and children" do
          calculator = StudentFinanceCalculator.new(
            household_income: 28_460,
            uk_ft_circumstances: %w[children-under-17],
          )
          assert_not calculator.eligible_for_childcare_grant_more_than_one_child?
        end
      end

      context "#eligible_for_parent_learning_allowance?" do
        should "have low household income and no dependencies" do
          calculator = StudentFinanceCalculator.new(
            household_income: 18_441,
          )
          assert_not calculator.eligible_for_parent_learning_allowance?
        end

        should "have high household income and no dependencies" do
          calculator = StudentFinanceCalculator.new(
            household_income: 18_442,
          )
          assert_not calculator.eligible_for_parent_learning_allowance?
        end

        should "have low household income and adult dependant" do
          calculator = StudentFinanceCalculator.new(
            household_income: 18_441,
            uk_ft_circumstances: %w[children-under-17],
          )
          assert calculator.eligible_for_parent_learning_allowance?
        end

        should "have high household income and adult dependant" do
          calculator = StudentFinanceCalculator.new(
            household_income: 18_840,
            uk_ft_circumstances: %w[children-under-17],
          )
          assert_not calculator.eligible_for_parent_learning_allowance?
        end
      end

      context "#eligible_for_adult_dependant_allowance?" do
        should "have low household income and no dependencies" do
          calculator = StudentFinanceCalculator.new(
            household_income: 14_933,
          )
          assert_not calculator.eligible_for_adult_dependant_allowance?
        end

        should "have high household income and no dependencies" do
          calculator = StudentFinanceCalculator.new(
            household_income: 14_934,
          )
          assert_not calculator.eligible_for_adult_dependant_allowance?
        end

        should "have low household income and adult dependant" do
          calculator = StudentFinanceCalculator.new(
            household_income: 14_933,
            uk_ft_circumstances: %w[dependant-adult],
          )
          assert calculator.eligible_for_adult_dependant_allowance?
        end

        should "have high household income and adult dependant" do
          calculator = StudentFinanceCalculator.new(
            household_income: 15_654,
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
            course_type: "uk-full-time",
          )
        end

        should "be £9250 for uk or eu full-time student" do
          assert_equal 9250, @calculator.tuition_fee_maximum
        end

        should "be £6935 for uk or eu part-time student" do
          @calculator.course_type = "uk-part-time"
          assert_equal 6935, @calculator.tuition_fee_maximum
        end
      end

      context "maximum tuition fee" do
        context "for a full time student" do
          should "be £9250" do
            calculator = StudentFinanceCalculator.new(
              household_income: 25_000,
              residence: :unused_variable,
              course_type: "uk-full-time",
            )
            assert_equal 9250, calculator.tuition_fee_maximum_full_time
          end
        end
        context "for part time student" do
          should "be £6935" do
            calculator = StudentFinanceCalculator.new(
              household_income: 25_000,
              residence: :unused_variable,
            )
            assert_equal 6935, calculator.tuition_fee_maximum_part_time
          end
        end
      end

      context "in 2023-2024" do
        current_year = "2023-2024"

        context "childcare_grant" do
          context "for one child" do
            should "be £188.90" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: :unused_variable,
              )
              assert_equal 188.90, calculator.childcare_grant_one_child
            end
          end

          context "for more than one child" do
            should "be £323.85" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: :unused_variable,
              )
              assert_equal 323.85, calculator.childcare_grant_more_than_one_child
            end
          end
        end

        context "#parent_learning_allowance" do
          should "be £1915" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: 25_000,
              residence: :unused_variable,
            )
            assert_equal 1_915, calculator.parent_learning_allowance
          end
        end

        context "#adult_dependant_allowance" do
          should "be £3354" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: 25_000,
              residence: :unused_variable,
            )
            assert_equal 3_354, calculator.adult_dependant_allowance
          end
        end

        context "#maintenance_loan_amount" do
          context "for students who started 2023-2024 living at home with parents" do
            setup do
              @residence = "at-home"
            end

            should "give the maximum amount of £8400 if household income is £25k or below" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: @residence,
                course_type: "uk-full-time",
              )
              assert_equal SmartAnswer::Money.new(8_400).to_s, calculator.maintenance_loan_amount.to_s
            end

            should "reduce the maximum amount £8400 by £1 for every complete £7.08 of income above £25k to a minimum of £3698" do
              # Samples taken from the document provided
              {
                30_000 => 7_694,
                35_000 => 6_988,
                40_000 => 6_282,
                42_875 => 5_876,
                45_000 => 5_576,
                50_000 => 4_869,
                55_000 => 4_163,
                58_215 => 3_709,
                60_000 => 3_698,
                65_000 => 3_698,
              }.each do |household_income, loan_amount|
                calculator = StudentFinanceCalculator.new(
                  course_start: current_year,
                  household_income:,
                  residence: @residence,
                  course_type: "uk-full-time",
                )
                assert_equal SmartAnswer::Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
              end
            end

            should "cap the reductions and give the minimum loan of £3698 for high household income students" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 500_000,
                residence: @residence,
                course_type: "uk-full-time",
              )
              assert_equal SmartAnswer::Money.new(3_698).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          context "for students who started 2023-2024 living away not in london" do
            setup do
              @residence = "away-outside-london"
            end

            should "give the maximum amount of £9978 if household income is £25k or below" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: @residence,
                course_type: "uk-full-time",
              )
              assert_equal SmartAnswer::Money.new(9_978).to_s, calculator.maintenance_loan_amount.to_s
            end

            should "reduce the maximum amount of £9978 by £1 for every complete £7.01 of income above £25k to a minimum of £4651" do
              # Samples taken from the document provided
              {
                30_000 => 9_265,
                35_000 => 8_552,
                40_000 => 7_839,
                42_875 => 7_429,
                45_000 => 7_125,
                50_000 => 6_412,
                55_000 => 5_699,
                60_000 => 4_986,
                62_215 => 4_670,
                65_000 => 4_651,
                70_000 => 4_651,
              }.each do |household_income, loan_amount|
                calculator = StudentFinanceCalculator.new(
                  course_start: current_year,
                  household_income:,
                  residence: @residence,
                  course_type: "uk-full-time",
                )
                assert_equal SmartAnswer::Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
              end
            end

            should "cap the reductions and give the minimum loan of £4,651 for high household income students" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 500_000,
                residence: @residence,
                course_type: "uk-full-time",
              )
              assert_equal SmartAnswer::Money.new(4_651).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          context "for students who started 2023-2024 living away in london" do
            setup do
              @residence = "away-in-london"
            end

            should "give the maximum amount of £13002 if household income is £25k or below" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: @residence,
                course_type: "uk-full-time",
              )
              assert_equal SmartAnswer::Money.new(13_002).to_s, calculator.maintenance_loan_amount.to_s
            end

            should "reduce the maximum amount of £13002 by £1 for every complete £6.89 of income above £25k to a minimum of £6485" do
              # Samples taken from the document provided
              {
                30_000 => 12_277,
                35_000 => 11_551,
                40_000 => 10_825,
                42_875 => 10_408,
                45_000 => 10_100,
                50_000 => 9_374,
                55_000 => 8_648,
                60_000 => 7_923,
                65_000 => 7_197,
                69_860 => 6_492,
                70_000 => 6_485,
              }.each do |household_income, loan_amount|
                calculator = StudentFinanceCalculator.new(
                  course_start: current_year,
                  household_income:,
                  residence: @residence,
                  course_type: "uk-full-time",
                )
                assert_equal SmartAnswer::Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
              end
            end

            should "cap the reductions and give the minimum loan of £6,485 for high household income students" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 500_000,
                residence: @residence,
                course_type: "uk-full-time",
              )
              assert_equal SmartAnswer::Money.new(6_485).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          context "for 2023-2024 part-time students" do
            setup do
              @course_type = "uk-part-time"
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
            @course_type = "uk-full-time"
            @doctor_or_dentist = true
          end

          should "be £3658 for students living away from home in London" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              course_type: @course_type,
              residence: "away-in-london",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 3658, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £2605 for students living away from home outside London" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              course_type: @course_type,
              residence: "away-outside-london",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 2605, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £1955 for students living at home" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              course_type: @course_type,
              residence: "at-home",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 1955, calculator.reduced_maintenance_loan_for_healthcare
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
            should "be £323.85" do
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
                course_type: "uk-full-time",
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
                  course_type: "uk-full-time",
                )
                assert_equal SmartAnswer::Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
              end
            end

            should "cap the reductions and give the minimum loan of £3790 for high household income students" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 500_000,
                residence: @residence,
                course_type: "uk-full-time",
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
                course_type: "uk-full-time",
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
                  course_type: "uk-full-time",
                )
                assert_equal SmartAnswer::Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
              end
            end

            should "cap the reductions and give the minimum loan of £4,767 for high household income students" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 500_000,
                residence: @residence,
                course_type: "uk-full-time",
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
                course_type: "uk-full-time",
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
                  course_type: "uk-full-time",
                )
                assert_equal SmartAnswer::Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
              end
            end

            should "cap the reductions and give the minimum loan of £6,647 for high household income students" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 500_000,
                residence: @residence,
                course_type: "uk-full-time",
              )
              assert_equal SmartAnswer::Money.new(6_647).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          context "for 2024-2025 part-time students" do
            setup do
              @course_type = "uk-part-time"
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
            @course_type = "uk-full-time"
            @doctor_or_dentist = true
          end

          should "be £3749 for students living away from home in London" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              course_type: @course_type,
              residence: "away-in-london",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 3749, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £2670 for students living away from home outside London" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              course_type: @course_type,
              residence: "away-outside-london",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 2670, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £2004 for students living at home" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              course_type: @course_type,
              residence: "at-home",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 2004, calculator.reduced_maintenance_loan_for_healthcare
          end
        end
      end

      context "#course_start_years" do
        context "for students" do
          should "be 2023 and 2024" do
            calculator = StudentFinanceCalculator.new(
              course_start: "2023-2024",
            )

            assert_equal [2023, 2024], calculator.course_start_years
          end

          should "be 2024 and 2025" do
            calculator = StudentFinanceCalculator.new(
              course_start: "2024-2025",
            )

            assert_equal [2024, 2025], calculator.course_start_years
          end
        end
      end
    end
  end
end
