require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/calculate-your-holiday-entitlement"

class CalculateYourHolidayEntitlementTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::CalculateYourHolidayEntitlementFlow
  end

  context "start page" do
    should see_start_page.with_title("Calculate holiday entitlement")
  end

  context "question :basis of calculation?" do
    should see_question(:basis_of_calculation?).with_title("Is the holiday entitlement based on:")

    should "take people who work shifts to the shift_worker_basis? question" do
      add_response "shift-worker"
      assert_equal :shift_worker_basis?, next_node_name
    end

    should "take people who don't work shifts to the calculation_period? question" do
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

      should "take people with irregular hours to the :irregular_and_annualised_done outcome" do
        responses[:basis_of_calculation?] = "irregular-hours"
        assert_equal :irregular_and_annualised_done, next_node
      end

      should "take people with annualised hours to the :irregular_and_annualised_done outcome" do
        responses[:basis_of_calculation?] = "annualised-hours"
        assert_equal :irregular_and_annualised_done, next_node
      end

      should "take people who want a days worked per week calculation to the :how_many_days_per_week? question" do
        responses[:basis_of_calculation?] = "days-worked-per-week"
        assert_equal :how_many_days_per_week?, next_node
      end

      should "take people who want other types of calculation to the :how_many_hours_per_week? question" do
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

    context "when given an invalid day of the week" do
      should_not accept_answer(0)
      should_not accept_answer(8)
    end

    should accept_answer(5).with_next_node(:days_per_week_done)
  end

  context "question :what_is_your_starting_date?" do
    setup do
      responses = {
        basis_of_calculation?: "days-worked-per-week",
        calculation_period?: "starting-and-leaving",
      }
    end

    should see_question(:what_is_your_starting_date?).with_title("What was the employment start date?")

    add_response "2021-01-01"

    should "take people who want a starting and leaving calculation to the :what_is_your_leaving_date? question" do
      responses[:calculation_period?] = "starting-and-leaving"
      assert_equal :what_is_your_leaving_date?, next_node
    end

    should "take people who want other types of calculation to the :when_does_your_leave_year_start? question" do
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

    should_not_accept_a_response_before(responses[:what_is_your_starting_date?])
    should_not_accept_a_response_more_than_a_year_from(responses[:what_is_your_starting_date?])

    should accept_answer("2020-10-01").with_next_node(:when_does_your_leave_year_start?)

    context "when calculation_period? is starting-and-leaving" do
      setup do
        responses[:calculation_period?] = "starting-and-leaving"
        add_response "2021-01-01"
      end

      should "take people who want a days worked per week calculation to the :how_many_days_per_week? question" do
        responses[:basis_of_calculation?] = "days-worked-per-week"
        assert_equal :how_many_days_per_week?, next_node
      end

      should "take people who want an hours worked per week calculation to the :how_many_hours_per_week? question" do
        responses[:basis_of_calculation?] = "hours-worked-per-week"
        assert_equal :how_many_hours_per_week?, next_node
      end

      should "take people who work shifts to the :shift_worker_hours_per_shift? question" do
        responses[:basis_of_calculation?] = "shift-worker"
        assert_equal :shift_worker_hours_per_shift?, next_node
      end

      should "take people with irregular hours to the :irregular_and_annualised_done outcome" do
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

    add_response "2021-01-01"

    should_not_accept_a_response_before(responses[:what_is_your_starting_date?])
    should_not_accept_a_response_before(responses[:what_is_your_leaving_date?])

    should_not_accept_a_response_more_than_a_year_from(responses[:what_is_your_starting_date?])
    should_not_accept_a_response_more_than_a_year_from(responses[:what_is_your_leaving_date?])

    should "take people who want a days worked per week calculation to the :how_many_days_per_week? question" do
      responses[:basis_of_calculation?] = "days-worked-per-week"
      assert_equal :how_many_days_per_week?, next_node
    end

    should "take people who want an hours worked per week calculation to the :how_many_hours_per_week? question" do
      responses[:basis_of_calculation?] = "hours-worked-per-week"
      assert_equal :how_many_hours_per_week?, next_node
    end

    should "take people with compressed hours to the :how_many_hours_per_week? question" do
      responses[:basis_of_calculation?] = "compressed-hours"
      assert_equal :how_many_hours_per_week?, next_node
    end

    should "take people with irregular hours to the :irregular_and_annualised_done outcome" do
      responses[:basis_of_calculation?] = "irregular-hours"
      assert_equal :irregular_and_annualised_done, next_node
    end

    should "take people with annualised hours to the :irregular_and_annualised_done outcome" do
      responses[:basis_of_calculation?] = "annualised-hours"
      assert_equal :irregular_and_annualised_done, next_node
    end

    should "take people who work shifts to the :shift_worker_hours_per_shift? question" do
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

    context "when given an invalid number of hours per week" do
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

    context "when given an invalid day of the week" do
      should_not accept_answer(0)
      should_not accept_answer(8)
    end

    context "validate the hours worked per day is less than 24" do
      should "reject a period of greater than 24 hours" do
        responses[:how_many_hours_per_week?] = 25
        should_not accept_answer(1)
      end

      should "accept less than 24 hours in a day" do
        responses[:how_many_hours_per_week?] = 23
        should accept_answer(1).with_next_node(:hours_per_week_done)
      end
    end

    should "take people with compressed hours to the :compressed_hours_done outcome" do
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

    context "when given an invalid number of hours per day" do
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

    context "when given an invalid number of shifts per shift pattern" do
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

    should_not_accept_a_response_before(response[:shift_worker_shifts_per_shift_pattern?])

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

    should see_outcome(:compressed_hours_done).with_text("The statutory holiday entitlement is 224 hours and 0 minutes holiday for the year.")
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
