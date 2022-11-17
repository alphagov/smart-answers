require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class StudentFinanceCalculatorTest < ActiveSupport::TestCase
      test "StudentFinanceCalculator is valid and setup properly" do
        calculator = StudentFinanceCalculator.new(
          course_start: "2021-2022",
          household_income: 25_000,
          residence: "at-home",
          course_type: "uk-full-time",
        )
        assert_instance_of StudentFinanceCalculator, calculator

        assert_equal "2021-2022", calculator.course_start
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

        calculator.course_start = "2021-2022"
        calculator.household_income = 25_000
        calculator.residence = "at-home"
        calculator.course_type = "uk-full-time"

        assert_equal "2021-2022", calculator.course_start
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
            household_income: 19_283,
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
            household_income: 27_501,
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
            household_income: 18_637,
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
            household_income: 15_273,
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

      context "in 2021-2022" do
        current_year = "2021-2022"

        context "childcare_grant" do
          context "for one child" do
            should "be £179.62" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: :unused_variable,
              )
              assert_equal 179.62, calculator.childcare_grant_one_child
            end
          end

          context "for more than one child" do
            should "be £307.95" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: :unused_variable,
              )
              assert_equal 307.95, calculator.childcare_grant_more_than_one_child
            end
          end
        end

        context "#parent_learning_allowance" do
          should "be £1821" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: 25_000,
              residence: :unused_variable,
            )
            assert_equal 1821, calculator.parent_learning_allowance
          end
        end

        context "#adult_dependant_allowance" do
          should "be £3190" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: 25_000,
              residence: :unused_variable,
            )
            assert_equal 3190, calculator.adult_dependant_allowance
          end
        end

        context "#maintenance_loan_amount" do
          context "for students who started 2021-2022 living at home with parents" do
            setup do
              @residence = "at-home"
            end

            should "give the maximum amount of £7987 if household income is £25k or below" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: @residence,
                course_type: "uk-full-time",
              )
              assert_equal SmartAnswer::Money.new(7987).to_s, calculator.maintenance_loan_amount.to_s
            end

            should "reduce the maximum amount £7987 by £1 for every complete £7.43 of income above £25k" do
              # Samples taken from the document provided
              {
                30_000 => 7_315,
                35_000 => 6_642,
                40_000 => 5_969,
                42_875 => 5_582,
                45_000 => 5_296,
                50_000 => 4_623,
                55_000 => 3_950,
                58_215 => 3_517,
                60_000 => 3_516,
                65_000 => 3_516,
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

            should "cap the reductions and give the minimum loan of £3516 for high household income students" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 500_000,
                residence: @residence,
                course_type: "uk-full-time",
              )
              assert_equal SmartAnswer::Money.new(3_516).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          context "for students who started 2021-2022 living away not in london" do
            setup do
              @residence = "away-outside-london"
            end

            should "give the maximum amount of £9488 if household income is £25k or below" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: @residence,
                course_type: "uk-full-time",
              )
              assert_equal SmartAnswer::Money.new(9_488).to_s, calculator.maintenance_loan_amount.to_s
            end

            should "reduce the maximum amount of £9488 by £1 for every complete £7.36 of income above £25k" do
              # Samples taken from the document provided
              {
                30_000 => 8_809,
                35_000 => 8_130,
                40_000 => 7_450,
                42_875 => 7_060,
                45_000 => 6_771,
                50_000 => 6_092,
                55_000 => 5_412,
                60_000 => 4_733,
                62_215 => 4_432,
                65_000 => 4_422,
                70_000 => 4_422,
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

            should "cap the reductions and give the minimum loan of £4,422 for high household income students" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 500_000,
                residence: @residence,
                course_type: "uk-full-time",
              )
              assert_equal SmartAnswer::Money.new(4_422).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          context "for students who started 2021-2022 living away in london" do
            setup do
              @residence = "away-in-london"
            end

            should "give the maximum amount of £12382 if household income is £25k or below" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: @residence,
                course_type: "uk-full-time",
              )
              assert_equal SmartAnswer::Money.new(12_382).to_s, calculator.maintenance_loan_amount.to_s
            end

            should "reduce the maximum amount of £12382 by £1 for every complete £7.24 of income above £25k" do
              # Samples taken from the document provided
              {
                30_000 => 11_692,
                35_000 => 11_001,
                40_000 => 10_311,
                42_875 => 9_914,
                45_000 => 9_620,
                50_000 => 8_929,
                55_000 => 8_239,
                60_000 => 7_548,
                65_000 => 6_858,
                69_860 => 6_186,
                70_000 => 6_167,
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

            should "cap the reductions and give the minimum loan of £6,166 for high household income students" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 500_000,
                residence: @residence,
                course_type: "uk-full-time",
              )
              assert_equal SmartAnswer::Money.new(6_166).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          context "for 2021-2022 part-time students" do
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
              assert_equal SmartAnswer::Money.new(4_810.0).to_s, calculator.maintenance_loan_amount.to_s
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
              assert_equal SmartAnswer::Money.new(4733).to_s, calculator.maintenance_loan_amount.to_s
            end
          end
        end

        context "#reduced_maintenance_loan_for_healthcare" do
          setup do
            @household_income = 25_000
            @course_type = "uk-full-time"
            @doctor_or_dentist = true
          end

          should "be £3558 for students living away from home in London" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              course_type: @course_type,
              residence: "away-in-london",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 3558, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £2534 for students living away from home outside London" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              course_type: @course_type,
              residence: "away-outside-london",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 2534, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £1902 for students living at home" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              course_type: @course_type,
              residence: "at-home",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 1902, calculator.reduced_maintenance_loan_for_healthcare
          end
        end

        context "#reduced_maintenance_loan_for_healthcare" do
          setup do
            @household_income = 25_000
            @course_type = "uk-full-time"
            @doctor_or_dentist = true
          end

          should "be £3558 for students living away from home in London" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              course_type: @course_type,
              residence: "away-in-london",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 3558, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £2534 for students living away from home outside London" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              course_type: @course_type,
              residence: "away-outside-london",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 2534, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £1845 for students living at home" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              course_type: @course_type,
              residence: "at-home",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 1902, calculator.reduced_maintenance_loan_for_healthcare
          end
        end
      end

      context "in 2022 - 2023" do
        current_year = "2022-2023"

        context "childcare_grant" do
          context "for one child" do
            should "be £183.75" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: :unused_variable,
              )
              assert_equal 183.75, calculator.childcare_grant_one_child
            end
          end

          context "for more than one child" do
            should "be £315.03" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: :unused_variable,
              )
              assert_equal 315.03, calculator.childcare_grant_more_than_one_child
            end
          end
        end

        context "#parent_learning_allowance" do
          should "be £1863" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: 25_000,
              residence: :unused_variable,
            )
            assert_equal 1863, calculator.parent_learning_allowance
          end
        end

        context "#adult_dependant_allowance" do
          should "be £3263" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: 25_000,
              residence: :unused_variable,
            )
            assert_equal 3263, calculator.adult_dependant_allowance
          end
        end

        context "#maintenance_loan_amount" do
          context "for students who started 2022-2023 living at home with parents" do
            setup do
              @residence = "at-home"
            end

            should "give the maximum amount of 8171 if household income is £25k or below" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: @residence,
                course_type: "uk-full-time",
              )
              assert_equal SmartAnswer::Money.new(8171).to_s, calculator.maintenance_loan_amount.to_s
            end

            should "reduce the maximum amount (£8171) by £1 for every complete £7.27 of income above £25k" do
              {
                30_000 => 7484,
                35_000 => 6796,
                40_000 => 6108,
                42_875 => 5713,
                45_000 => 5420,
                50_000 => 4733,
                55_000 => 4045,
                58_215 => 3603,
                60_000 => 3597,
                65_000 => 3597,
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

            should "cap the reductions and give the minimum loan of £3597 for high household income students" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 500_000,
                residence: @residence,
                course_type: "uk-full-time",
              )
              assert_equal SmartAnswer::Money.new(3597).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          context "for students who started 2022-2023 living away not in london" do
            setup do
              @residence = "away-outside-london"
            end

            should "give the maximum amount of 9706 if household income is £25k or below" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: @residence,
                course_type: "uk-full-time",
              )
              assert_equal SmartAnswer::Money.new(9_706).to_s, calculator.maintenance_loan_amount.to_s
            end

            should "reduce the maximum amount (£9706) by £1 for every complete £7.20 of income above £25k" do
              # Samples taken from the document provided
              {
                30_000 => 9012,
                35_000 => 8318,
                40_000 => 7623,
                42_875 => 7224,
                45_000 => 6929,
                50_000 => 6234,
                55_000 => 5540,
                60_000 => 4845,
                62_215 => 4538,
                65_000 => 4524,
                70_000 => 4524,
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

            should "cap the reductions and give the minimum loan of £4,524 for high household income students" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 500_000,
                residence: @residence,
                course_type: "uk-full-time",
              )
              assert_equal SmartAnswer::Money.new(4_524).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          context "for students who started 2022-2023 living away in london" do
            setup do
              @residence = "away-in-london"
            end

            should "give the maximum amount of £12667 if household income is £25k or below" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 25_000,
                residence: @residence,
                course_type: "uk-full-time",
              )
              assert_equal SmartAnswer::Money.new(12_667).to_s, calculator.maintenance_loan_amount.to_s
            end

            should "reduce the maximum amount (£12667) by £1 for every complete £7.08 of income above £25k" do
              # Samples taken from the document provided
              {
                30_000 => 11_961,
                35_000 => 11_255,
                40_000 => 10_549,
                42_875 => 10_143,
                45_000 => 9843,
                50_000 => 9136,
                55_000 => 8430,
                60_000 => 7724,
                65_000 => 7018,
                69_860 => 6331,
                70_000 => 6312,
                75_000 => 6308,
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

            should "cap the reductions and give the minimum loan of £6166 for high household income students" do
              calculator = StudentFinanceCalculator.new(
                course_start: current_year,
                household_income: 500_000,
                residence: @residence,
                course_type: "uk-full-time",
              )
              assert_equal SmartAnswer::Money.new(6308).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          context "for 2022-2023 part-time students" do
            setup do
              @course_type = "uk-part-time"
            end

            should "be weighted by course intensity" do
              full_time_credits = 20
              {
                2 => 0.00,
                6 => 2460.75,
                7 => 3277.719,
                10 => 4921.50,
                14 => 6555.438,
                15 => 7382.25,
                20 => 9843.00,
              }.each do |part_time_credits, loan_amount|
                calculator = StudentFinanceCalculator.new(
                  course_start: current_year,
                  household_income: 45_000,
                  residence: "away-in-london",
                  course_type: @course_type,
                  part_time_credits:,
                  full_time_credits:,
                )
                assert_equal SmartAnswer::Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
              end
            end
          end
        end

        context "#reduced_maintenance_loan_for_healthcare" do
          setup do
            @household_income = 25_000
            @course_type = "uk-full-time"
            @doctor_or_dentist = true
          end

          should "be £3558 for students living away from home in London" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              course_type: @course_type,
              residence: "away-in-london",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 3558, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £2534 for students living away from home outside London" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              course_type: @course_type,
              residence: "away-outside-london",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 2534, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £1902 for students living away from home outside London" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              course_type: @course_type,
              residence: "at-home",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 1902, calculator.reduced_maintenance_loan_for_healthcare
          end
        end

        context "#loan_shortfall" do
          setup do
            @household_income = 50_000
            @course_type = "uk-full-time"
            @doctor_or_dentist = true
          end

          should "show the difference between the maximum loan amount and what the student is eligible for" do
            calculator = StudentFinanceCalculator.new(
              course_start: current_year,
              household_income: @household_income,
              course_type: @course_type,
              residence: "away-in-london",
              doctor_or_dentist: @doctor_or_dentist,
            )

            assert_equal 3531, calculator.loan_shortfall
            assert_equal 12_667, calculator.max_loan_amount
            assert_equal 9136, calculator.maintenance_loan_amount
          end
        end
      end

      context "#course_start_years" do
        context "for students" do
          should "be 2022 and 2023" do
            calculator = StudentFinanceCalculator.new(
              course_start: "2022-2023",
            )

            assert_equal [2022, 2023], calculator.course_start_years
          end
        end
      end
    end
  end
end
