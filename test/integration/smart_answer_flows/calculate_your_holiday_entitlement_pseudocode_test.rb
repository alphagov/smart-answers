require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/calculate-your-holiday-entitlement"

class CalculateYourHolidayEntitlementTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::CalculateYourHolidayEntitlementFlow
  end

  context "start page" do
    should see_start_page("calculate-your-holiday-entitlement").with_title("Calculate holiday entitlement")
  end

  context "question :basis of calculation?" do
    should see_question(:basis_of_calculation?).with_title("Is the holiday entitlement based on:")

    should "take shift workers to shift_worker_basis? question" do
      add_response "shift-worker"
      assert_equal :shift_worker_basis?, next_node_name
    end

    should "take non-shift workers to calculation_period? question" do
      add_response "days-worked-per-week"
      assert_equal :calculation_period?, next_node_name
    end
  end

  context "question :calculation period?" do
    setup do
      responses = { basis_of_calculation?: "days-worked-per-week" }
    end

    should see_question(:calculation_period?).with_title("Do you want to work out holiday:")

    should accept_answer("starting").with_next_node(:what_is_your_starting_date?)
    should accept_answer("starting-and-leaving").with_next_node(:what_is_your_starting_date?)
    should accept_answer("leaving").with_next_node(:what_is_your_leaving_date?)

    context "when the answer is full-year" do
      setup do
        responses[:calculation_period?] = "full-year"
      end

      should "take irregular-hours to :irregular_and_annualised_done" do
        responses[:basis_of_calculation?] = "irregular-hours"
        assert_equal :irregular_and_annualised_done, next_node
      end

      should "take annualised-hours to :irregular_and_annualised_done" do
        responses[:basis_of_calculation?] = "annualised-hours"
        assert_equal :irregular_and_annualised_done, next_node
      end

      should "take days-worked-per-week to :how_many_days_per_week?" do
        responses[:basis_of_calculation?] = "days-worked-per-week"
        assert_equal :how_many_days_per_week?, next_node
      end

      should "take other answers to :how_many_hours_per_week?" do
        responses[:basis_of_calculation?] = "compressed-hours"
        assert_equal :how_many_hours_per_week?, next_node
      end
    end
  end

  context "question :how_many_days_per_week?" do
    setup do
      responses = {
        basis_of_calculation?: "days-worked-per-week",
        calculation_period?: "full-year",
      }
    end

    should see_question(:how_many_days_per_week?).with_title("Number of days worked per week?")

    context "expect a day of the week number to be given" do
      should accept_answer(5).with_next_node(:days_per_week_done)

      should_not accept_answer(0)
      should_not accept_answer(8)
    end
  end

  context "question :what_is_your_starting_date?" do
    setup do
      responses = {
        basis_of_calculation?: "days-worked-per-week",
        calculation_period?: "starting-and-leaving",
      }
    end

    should see_question(:what_is_your_starting_date?).with_title("What was the employment start date?")

    should accept_answer("2021-01-01")

    should "take starting-and-leaving to :what_is_your_leaving_date?" do
      responses[:calculation_period?] = "starting-and-leaving"
      assert_equal :what_is_your_leaving_date?, next_node
    end

    should "take other answers to :when_does_your_leave_year_start?" do
      responses[:calculation_period?] = "full-year"
      assert_equal :when_does_your_leave_year_start?, next_node
    end
  end

  context "question :what_is_your_leaving_date?" do
    setup do
      responses = {
        basis_of_calculation?: "days-worked-per-week",
        calculation_period?: "leaving",
        what_is_your_starting_date?: "2021-01-01",
      }
    end

    should see_question(:what_is_your_leaving_date?).with_title("What was the employment end date?")

    context "invalid end date given" do
      should_not accept_answer("2020-01-01")
      should_not accept_answer("2023-01-01")
    end

    should accept_answer("2020-10-01").with_next_node(:when_does_your_leave_year_start?)

    context "when calculation_period? is starting-and-leaving" do
      setup do
        should accept_answer("2021-10-01")
        responses[:calculation_period?] = "starting-and-leaving"
      end

      should "take days-worked-per-week to :how_many_days_per_week?" do
        responses[:basis_of_calculation?] = "days-worked-per-week"
        assert_equal :how_many_days_per_week?, next_node
      end

      should "take hours-worked-per-week to :how_many_hours_per_week?" do
        responses[:basis_of_calculation?] = "hours-worked-per-week"
        assert_equal :how_many_hours_per_week?, next_node
      end

      should "take shift-worker to :shift_worker_hours_per_shift?" do
        responses[:basis_of_calculation?] = "shift-worker"
        assert_equal :shift_worker_hours_per_shift?, next_node
      end

      should "take irregular hours to :irregular_and_annualised_done" do
        responses[:basis_of_calculation?] = "irregular-hours"
        assert_equal :irregular_and_annualised_done, next_node
      end
    end
  end

  context "question :when_does_your_leave_year_start?" do
    setup do
      responses = {
        basis_of_calculation?: "days-worked-per-week",
        calculation_period?: "leaving",
        what_is_your_starting_date?: "2021-01-01",
        what_is_your_leaving_date?: "2021-10-01",
      }
    end

    should see_question(:when_does_your_leave_year_start?).with_title("When does the leave year start?")

    should accept_answer("2021-01-01")

    context "no start date" do
      responses[:what_is_your_starting_date?] = nil
      should_not accept_answer("2021-01-01")
    end

    context "no leave date" do
      responses[:what_is_your_leaving_date?] = nil
      should_not accept_answer("2021-01-01")
    end

    should "take days-worked-per-week to :how_many_days_per_week?" do
      responses[:basis_of_calculation?] = "days-worked-per-week"
      assert_equal :how_many_days_per_week?, next_node
    end

    should "take hours-worked-per-week to :how_many_hours_per_week?" do
      responses[:basis_of_calculation?] = "hours-worked-per-week"
      assert_equal :how_many_hours_per_week?, next_node
    end

    should "take compressed-hours to :how_many_hours_per_week?" do
      responses[:basis_of_calculation?] = "compressed-hours"
      assert_equal :how_many_hours_per_week?, next_node
    end

    should "take irregular-hours to :irregular_and_annualised_done" do
      responses[:basis_of_calculation?] = "irregular-hours"
      assert_equal :irregular_and_annualised_done, next_node
    end

    should "take annualised-hours to :irregular_and_annualised_done" do
      responses[:basis_of_calculation?] = "annualised-hours"
      assert_equal :irregular_and_annualised_done, next_node
    end

    should "take shift-worker to :shift_worker_hours_per_shift?" do
      responses[:basis_of_calculation?] = "shift-worker"
      assert_equal :shift_worker_hours_per_shift?, next_node
    end
  end

  context "question :how_many_hours_per_week?" do
    setup do
      responses = {
        basis_of_calculation?: "hours-worked-per-week",
        calculation_period?: "leaving",
        what_is_your_starting_date?: "2021-01-01",
        what_is_your_leaving_date?: "2021-10-01",
      }
    end

    should see_question(:how_many_hours_per_week?).with_title("Number of hours worked per week?")

    context "invalid no of hours given" do
      should_not accept_answer(-1)
      should_not accept_answer(169)
    end

    should accept_answer(100).with_next_node(:how_many_days_per_week_for_hours?)
  end

  context "question :how_many_days_per_week_for_hours?" do
    setup do
      responses = {
        basis_of_calculation?: "hours-worked-per-week",
        calculation_period?: "leaving",
        what_is_your_starting_date?: "2021-01-01",
        what_is_your_leaving_date?: "2021-10-01",
        how_many_hours_per_week?: "40",
      }
    end

    should see_question(:how_many_days_per_week_for_hours?).with_title("Number of days worked per week?")

    context "invalid no of hours given" do
      should_not accept_answer(8)
      should_not accept_answer(1)
    end

    should accept_answer(5).with_next_node(:hours_per_week_done)

    should "take compressed-hours to :compressed_hours_done" do
      responses[:basis_of_calculation?] = "compressed-hours"
      assert_equal :compressed_hours_done, next_node
    end
  end

  context "question :shift_worker_basis?" do
    setup do
      responses = { basis_of_calculation?: "shift-worker" }
    end

    should see_question(:shift_worker_basis?).with_title("Do you want to calculate the holiday:")

    should accept_answer("full-year").with_next_node(:shift_worker_hours_per_shift?)
    should accept_answer("starting").with_next_node(:what_is_your_starting_date?)
    should accept_answer("starting-and-leaving").with_next_node(:what_is_your_starting_date?)
    should accept_answer("leaving").with_next_node(:what_is_your_leaving_date?)
  end

  context "question :shift_worker_hours_per_shift?" do
    setup do
      responses = {
        basis_of_calculation?: "shift-worker",
        shift_worker_basis?: "full-year",
      }
    end

    should see_question(:shift_worker_hours_per_shift?).with_title("How many hours in each shift?")

    context "invalid no of hours given" do
      should_not accept_answer(-1)
      should_not accept_answer(25)
    end

    should accept_answer(8).with_next_node(:shift_worker_shifts_per_shift_pattern?)
  end

  context "question :shift_worker_shifts_per_shift_pattern?" do
    setup do
      responses = {
        basis_of_calculation?: "shift-worker",
        shift_worker_basis?: "full-year",
        shift_worker_hours_per_shift?: 8,
      }
    end

    should see_question(:shift_worker_shifts_per_shift_pattern?).with_title("How many shifts will be worked per shift pattern?")

    context "invalid no of shifts given" do
      should_not accept_answer(-1)
    end

    should accept_answer(2).with_next_node(:shift_worker_days_per_shift_pattern?)
  end

  context "question :shift_worker_days_per_shift_pattern?" do
    setup do
      responses = {
        basis_of_calculation?: "shift-worker",
        shift_worker_basis?: "full-year",
        shift_worker_hours_per_shift?: 8,
        shift_worker_shifts_per_shift_pattern?: 2,
      }
    end

    should see_question(:shift_worker_days_per_shift_pattern?).with_title("How many days in the shift pattern?")

    context "invalid no of days given" do
      should_not accept_answer(1)
    end

    should accept_answer(2).with_next_node(:shift_worker_done)
  end

  context "outcome :shift_worker_done" do
    setup do
      responses = {
        basis_of_calculation?: "shift-worker",
        calculation_period?: "full-year",
        shift_worker_hours_per_shift?: 8,
        shift_worker_shifts_per_shift_pattern?: 3,
        shift_worker_days_per_shift_pattern?: 3,
      }
    end

    should see_outcome(:shift_worker_done).with_text("The statutory holiday entitlement is 28 shifts for the year. Each shift being 8.0 hours.")
  end

  context "outcome :days_per_week_done" do
    setup do
      responses = {
        basis_of_calculation?: "days-worked-per-week",
        calculation_period?: "full-year",
        how_many_days_per_week?: 5,
      }
    end

    should see_outcome(:days_per_week_done).with_text("The statutory holiday entitlement is 28 days holiday.")
  end

  context "outcome :hours_per_week_done" do
    setup do
      responses = {
        basis_of_calculation?: "hours-worked-per-week",
        calculation_period?: "full-year",
        how_many_hours_per_week?: 40,
        how_many_days_per_week?: 5,
      }
    end

    should see_outcome(:hours_per_week_done).with_text("The statutory entitlement is 224 hours holiday.")
  end

  context "outcome :compressed_hours_done" do
    setup do
      responses = {
        basis_of_calculation?: "compressed-hours",
        calculation_period?: "full-year",
        how_many_hours_per_week?: 40,
        how_many_days_per_week?: 5,
      }
    end

    should see_outcome(:compressed_hours_done).with_text("The statutory holiday entitlement is 224 hours and 0 minutes holiday for the year. Rather than taking a day’s holiday it’s 8 hours and 0 minutes holiday for each day otherwise worked.")
  end

  context "outcome :irregular_and_annualised_done" do
    setup do
      responses = {
        basis_of_calculation?: "annualised-hours",
        calculation_period?: "full-year",
      }
    end

    should see_outcome(:irregular_and_annualised_done).with_text("The statutory holiday entitlement is 5.6 weeks holiday.")
  end
end
