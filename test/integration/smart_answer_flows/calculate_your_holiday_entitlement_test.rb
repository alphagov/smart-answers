require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/calculate-your-holiday-entitlement"

class CalculateYourHolidayEntitlementTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup { setup_for_testing_flow SmartAnswer::CalculateYourHolidayEntitlementFlow }

  should render_start_page

  context "question :basis of calculation?" do
    should render_question(:basis_of_calculation?)

    context "next_node" do
      should "take people who work shifts to the shift_worker_basis? question" do
        add_response "shift-worker"
        assert_next_node :shift_worker_basis?
      end

      should "take people who don't work shifts to the calculation_period? question" do
        add_response "days-worked-per-week"
        assert_next_node :calculation_period?
      end
    end
  end

  context "question :calculation period?" do
    setup { responses = { basis_of_calculation?: "days-worked-per-week" } }

    should render_question(:calculation_period?)

    context "next_node" do
      should have_next_node(:what_is_your_starting_date?).for_response("starting")
      should have_next_node(:what_is_your_starting_date?).for_response("starting-and-leaving")
      should have_next_node(:what_is_your_leaving_date?).for_response("leaving")

      context "when the response is full-year" do
        setup { add_response "full-year" }

        should "have a next node of irregular_and_annualised_done outcome for people with irregular hours" do
          replace_responses { basis_of_calculation?: "irregular-hours" }
          assert_next_node :irregular_and_annualised_done
        end

        should "have a next node of :irregular_and_annualised_done for people with annualised hours" do
          replace_responses { basis_of_calculation?: "annualised-hours" }
          assert_next_node :irregular_and_annualised_done
        end

        should "have a next node of :how_many_days_per_week? for people who work a number of days per week" do
          replace_responses { basis_of_calculation?: "days-worked-per-week" }
          assert_next_node :how_many_days_per_week?
        end

        should "have a next node of :how_many_hours_per_week? for people who work compressed hours" do
          replace_responses { basis_of_calculation?: "compressed-hours" }
          assert_next_node :how_many_hours_per_week?
        end
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

    should render_question(:how_many_days_per_week?)

    context "validation" do
      should "be invalid for a day of the week below 1" do
        add_response "0"
        assert_current_node_is_error
      end

      should "be invalid for a day of the week above 7" do
        add_response "0"
        assert_current_node_is_error
      end
    end

    context "next_node" do
      should have_next_node(:day_per_week_done).for_response("5")
    end
  end

  context "question :what_is_your_starting_date?" do
    setup do
      responses = {
        basis_of_calculation?: "days-worked-per-week",
        calculation_period?: "starting-and-leaving",
      }
    end

    should render_question(:what_is_your_starting_date?)

    context "next_node" do
      setup { add_response "2021-01-01" }

      should "have a next node of :what_is_your_leaving_date? for people with a starting-and-leaving calculation period" do
        responses[:calculation_period?] = "starting-and-leaving"
        assert_next_node :what_is_your_leaving_date?
      end

      should "have a next node of :what_is_your_leaving_date? for people with other calculation periods" do
        responses[:calculation_period?] = "full-year"
        assert_next_node :when_does_your_leave_year_start?
      end
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

    should render_question(:what_is_your_leaving_date?)

    context "validation" do
      should_reject_a_response_before(responses[:what_is_your_starting_date?])
      should_reject_a_response_more_than_a_year_after(responses[:what_is_your_starting_date?])
    end

    context "next_node" do
      context "when calculation period is not starting-and-leaving" do
        should have_next_node(:when_does_your_leave_start?).for_response("2020-10-01")
      end

      context "when calculation period is starting-and-leaving" do
        setup do
          replace_responses { calculation_period?: "starting-and-leaving" }
          add_response "2021-01-01"
        end

      should "have a next node of :how_many_days_per_week? for people calculating with days-worked-per-week" do
        replace_responses { basis_of_calculation?: "days-worked-per-week" }
        assert_next_node :how_many_days_per_week?
      end

      should "have a next node of :how_many_days_per_week? for people calculating with hours-worked-per-week" do
        replace_responses { basis_of_calculation?: "hours-worked-per-week" }
        assert_next_node :how_many_hours_per_week?
      end

      should "have a next node of :shift_worker? for shift workers" do
        replace_responses { basis_of_calculation?: "shift-workers" }
        assert_next_node :shift_worker_hours_per_shift?
      end

      should "have a next node of :irregular_and_annualised_done for people with irregular hours" do
        replace_responses { basis_of_calculation?: "irregular-hours" }
        assert_next_node :irregular_and_annualised_done
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

    should render_question(:when_does_your_leave_year_start?)

    context "validation" do
      should_reject_a_response_before(responses[:what_is_your_starting_date?])
      should_reject_a_response_before(responses[:what_is_your_leaving_date?])
      should_reject_a_response_more_than_a_year_after(responses[:what_is_your_starting_date?])
      should_reject_a_response_more_than_a_year_after(responses[:what_is_your_leaving_date?])
    end

    context "next_node" do
      setup { add_response "2021-01-01" }

      should "have a next node of :how_many_days_per_week? for people calculating with days-worked-per-week" do
        replace_responses { basis_of_calculation?: "days-worked-per-week" }
        assert_next_node :how_many_days_per_week?
      end

      should "have a next node of :how_many_days_per_week? for people calculating with hours-worked-per-week" do
        replace_responses { basis_of_calculation?: "hours-worked-per-week" }
        assert_next_node :how_many_hours_per_week?
      end

      should "have a next node of :irregular_and_annualised_done for people with irregular hours" do
        replace_responses { basis_of_calculation?: "irregular-hours" }
        assert_next_node :irregular_and_annualised_done
      end

      should "have a next node of :shift_worker? for shift workers" do
        replace_responses { basis_of_calculation?: "shift-workers" }
        assert_next_node :shift_worker_hours_per_shift?
      end
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

    should render_question(:how_many_hours_per_week?)

    context "validation" do
      should "be invalid for hours below 0" do
        add_response "0"
        assert_current_node_is_error
      end

      should "be invalid for hours above 168" do
        add_response "169"
        assert_current_node_is_error
      end
    end

    context "next_node" do
      should have_next_node(:how_many_days_per_week_for_hours?).for_response("100")
    end
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

    should render_question(:how_many_days_per_week_for_hours?)

    context "validation" do
      should "be invalid for a day of the week below 1" do
        add_response "0"
        assert_current_node_is_error
      end

      should "be invalid for a day of the week above 7" do
        add_response "0"
        assert_current_node_is_error
      end

      should "reject attempts to work more than 24 hours" do
        replace_responses { how_many_hours_per_week?: "25" }
        add_response "1"
        assert_current_node_is_error
      end
    end

    context "next_node" do
      context "when the user is working compressed hours" do
        setup { replace_responses { basis_of_calculation?: "compressed-hours" } }

        should have_next_node(:compressed_hours_done).for_response("2")
      end

      context "when the user isn't working compressed hours" do
        should have_next_node(:hours_per_week_done).for_response("2")
      end
    end
  end

  context "question :shift_worker_basis?" do
    setup do
      responses = { basis_of_calculation?: "shift-worker" }
    end

    should render_question(:shift_worker_basis?)

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

    should render_question(:shift_worker_hours_per_shift?)

    context "validation" do
      should "be invalid for hours below 0" do
        add_response "-1"
        assert_current_node_is_error
      end

      should "be invalid for hours above 24" do
        add_response "25"
        assert_current_node_is_error
      end
    end

    context "next_node" do
      should have_next_node(:shift_worker_shifts_per_shift_pattern?).for_response("8")
    end
  end

  context "question :shift_worker_shifts_per_shift_pattern?" do
    setup do
      responses = {
        basis_of_calculation?: "shift-worker",
        shift_worker_basis?: "full-year",
        shift_worker_hours_per_shift?: "8",
      }
    end

    should render_question(:shift_worker_shifts_per_shift_pattern?)

    context "validation" do
      should "reject a negative number of shifts" do
        add_response "-1"
        assert_current_node_is_error
      end
    end

    context "next_node" do
      should have_next_node(:shift_worker_days_per_shift_pattern?).for_response("2")
    end
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

    should render_question(:shift_worker_days_per_shift_pattern?)

    context "validation" do
      should_reject_a_response_before(responses[:shift_worker_shifts_per_shift_pattern?])
    end

    context "next_node" do
      should have_next_node(:shift_worker_done).for_response("2")
    end
  end
end
