require "test_helper"
require "support/flow_test_helper"

class CalculateYourHolidayEntitlementFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup { testing_flow CalculateYourHolidayEntitlementFlow }

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question :basis of calculation?" do
    setup { testing_node :basis_of_calculation? }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "take people who work shifts to the shift_worker_basis? question" do
        assert_next_node :shift_worker_basis?, for_response: "shift-worker"
      end

      should "take people who don't work shifts to the calculation_period? question" do
        assert_next_node :calculation_period?, for_response: "days-worked-per-week"
      end
    end
  end

  context "question :calculation period?" do
    setup do
      testing_node :calculation_period?
      add_responses basis_of_calculation?: "days-worked-per-week"
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have next node what_is_your_starting_date? for a 'starting' response" do
        assert_next_node :what_is_your_starting_date?, for_response: "starting"
      end

      should "have next node what_is_your_starting_date? for a 'starting-and-leaving' response" do
        assert_next_node :what_is_your_starting_date?, for_response: "starting-and-leaving"
      end

      should "have next node what_is_your_leaving_date? for a 'leaving' response" do
        assert_next_node :what_is_your_leaving_date?, for_response: "leaving"
      end

      context "when the response is full-year" do
        setup { add_response "full-year" }

        should "have a next node of irregular_and_annualised_done outcome for people with annualised hours" do
          add_responses basis_of_calculation?: "annualised-hours"
          assert_next_node :irregular_and_annualised_done
        end

        should "have a next node of :irregular_and_annualised_done for people with annualised hours" do
          add_responses basis_of_calculation?: "annualised-hours"
          assert_next_node :irregular_and_annualised_done
        end

        should "have a next node of :how_many_days_per_week? for people who work a number of days per week" do
          add_responses basis_of_calculation?: "days-worked-per-week"
          assert_next_node :how_many_days_per_week?
        end

        should "have a next node of :how_many_hours_per_week? for people who work compressed hours" do
          add_responses basis_of_calculation?: "compressed-hours"
          assert_next_node :how_many_hours_per_week?
        end
      end
    end
  end

  context "question :how_many_days_per_week?" do
    setup do
      testing_node :how_many_days_per_week?
      add_responses basis_of_calculation?: "days-worked-per-week",
                    calculation_period?: "full-year"
    end

    should "render question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid for a day of the week below 1" do
        assert_invalid_response "0"
      end

      should "be invalid for a day of the week above 7" do
        assert_invalid_response "8"
      end
    end

    context "next_node" do
      should "have next node of days_per_week_done" do
        assert_next_node :days_per_week_done, for_response: "5"
      end
    end
  end

  context "question :what_is_your_starting_date?" do
    setup do
      testing_node :what_is_your_starting_date?
      add_responses basis_of_calculation?: "days-worked-per-week",
                    calculation_period?: "starting-and-leaving"
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      setup { add_response "2021-01-01" }

      should "have a next node of :what_is_your_leaving_date? for people with a starting-and-leaving calculation period" do
        add_responses calculation_period?: "starting-and-leaving"
        assert_next_node :what_is_your_leaving_date?
      end

      should "have a next node of :when_does_your_leave_year_start? for people with other calculation periods" do
        add_responses calculation_period?: "starting"
        assert_next_node :when_does_your_leave_year_start?
      end
    end
  end

  context "question :what_is_your_leaving_date?" do
    setup do
      testing_node :what_is_your_leaving_date?
      add_responses basis_of_calculation?: "days-worked-per-week",
                    calculation_period?: "leaving",
                    what_is_your_starting_date?: "2021-01-01"
    end

    should "render question" do
      assert_rendered_question
    end

    context "validation" do
      context "when calculation period is starting-and-leaving" do
        setup { add_responses calculation_period?: "starting-and-leaving" }

        should "be invalid for a date before starting_date" do
          assert_invalid_response "2020-12-31"
        end

        should "be invalid for a date over a year after the starting_date" do
          assert_invalid_response "2023-01-01"
        end
      end

      context "when calculation period is not starting-and-leaving" do
        should "be valid for a date before starting_date" do
          assert_valid_response "2020-12-31"
        end

        should "be valid for a date over a year after the starting_date" do
          assert_valid_response "2023-01-01"
        end
      end
    end

    context "next_node" do
      context "when calculation period is not starting-and-leaving" do
        should "have next node when_does_your_leave_year_start?" do
          assert_next_node :when_does_your_leave_year_start?, for_response: "2021-05-01"
        end
      end

      context "when calculation period is starting-and-leaving" do
        setup do
          add_responses calculation_period?: "starting-and-leaving",
                        what_is_your_leaving_date?: "2021-05-01"
        end

        should "have a next node of :how_many_days_per_week? for people calculating with days-worked-per-week" do
          add_responses basis_of_calculation?: "days-worked-per-week"
          assert_next_node :how_many_days_per_week?
        end

        should "have a next node of :how_many_days_per_week? for people calculating with hours-worked-per-week" do
          add_responses basis_of_calculation?: "hours-worked-per-week"
          assert_next_node :how_many_hours_per_week?
        end

        should "have a next node of :shift_worker? for shift workers" do
          add_responses basis_of_calculation?: "shift-worker",
                        shift_worker_basis?: "starting-and-leaving"

          assert_next_node :shift_worker_hours_per_shift?
        end

        should "have a next node of :irregular_and_annualised_done for people with annualised hours" do
          add_responses basis_of_calculation?: "annualised-hours"
          assert_next_node :irregular_and_annualised_done
        end
      end
    end
  end

  context "question :when_does_your_leave_year_start?" do
    setup do
      testing_node :when_does_your_leave_year_start?
      add_responses basis_of_calculation?: "days-worked-per-week",
                    calculation_period?: "leaving",
                    what_is_your_leaving_date?: "2021-10-01"
    end

    should "render question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid for a leave year starting after a leaving date" do
        add_responses what_is_your_leaving_date?: "2021-10-01"
        assert_invalid_response "2021-10-02"
      end

      should "be invalid for a leave start year date more than a year before the leaving date" do
        add_responses what_is_your_leaving_date?: "2021-10-02"
        assert_invalid_response "2020-10-01"
      end

      should "be invalid for a leave year starting after a start date" do
        add_responses calculation_period?: "starting",
                      what_is_your_starting_date?: "2021-09-01"
        assert_invalid_response "2021-10-01"
      end

      should "be invalid for a leave year starting more than a year after a start date" do
        add_responses calculation_period?: "starting",
                      what_is_your_starting_date?: "2021-10-01"
        assert_invalid_response "2022-11-01"
      end
    end

    context "next_node" do
      should "have a next node of :how_many_days_per_week? for people calculating with days-worked-per-week" do
        add_responses basis_of_calculation?: "days-worked-per-week",
                      when_does_your_leave_year_start?: "2021-01-01"
        assert_next_node :how_many_days_per_week?
      end

      should "have a next node of :how_many_days_per_week? for people calculating with hours-worked-per-week" do
        add_responses basis_of_calculation?: "hours-worked-per-week",
                      when_does_your_leave_year_start?: "2021-01-01"
        assert_next_node :how_many_hours_per_week?
      end

      should "have a next node of :irregular_and_annualised_done for people with annualised hours" do
        add_responses basis_of_calculation?: "annualised-hours",
                      when_does_your_leave_year_start?: "2021-01-01"
        assert_next_node :irregular_and_annualised_done
      end

      should "have a next node of :shift_worker? for shift workers" do
        add_responses basis_of_calculation?: "shift-worker",
                      shift_worker_basis?: "starting-and-leaving",
                      what_is_your_starting_date?: "2021-01-01",
                      what_is_your_leaving_date?: "2021-10-01",
                      when_does_your_leave_year_start?: "2021-03-01"
        assert_next_node :shift_worker_hours_per_shift?
      end
    end
  end

  context "question :how_many_hours_per_week?" do
    setup do
      testing_node :how_many_hours_per_week?
      add_responses basis_of_calculation?: "hours-worked-per-week",
                    calculation_period?: "leaving",
                    what_is_your_starting_date?: "2021-01-01",
                    what_is_your_leaving_date?: "2021-10-01",
                    when_does_your_leave_year_start?: "2021-01-01"
    end

    should "render question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid for hours below 1" do
        assert_invalid_response "0"
      end

      should "be invalid for hours above 168" do
        assert_invalid_response "169"
      end
    end

    context "next_node" do
      should "have next node :how_many_days_per_week_for_hours?" do
        assert_next_node :how_many_days_per_week_for_hours?, for_response: "100"
      end
    end
  end

  context "question :how_many_days_per_week_for_hours?" do
    setup do
      testing_node :how_many_days_per_week_for_hours?
      add_responses basis_of_calculation?: "hours-worked-per-week",
                    calculation_period?: "leaving",
                    what_is_your_starting_date?: "2021-01-01",
                    what_is_your_leaving_date?: "2021-10-01",
                    when_does_your_leave_year_start?: "2021-01-01",
                    how_many_hours_per_week?: "40"
    end

    should "render question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid for a day of the week below 1" do
        assert_invalid_response "0"
      end

      should "be invalid for a day of the week above 7" do
        assert_invalid_response "8"
      end

      should "reject attempts to work more than 24 hours" do
        add_responses how_many_hours_per_week?: "25"
        assert_invalid_response "25"
      end
    end

    context "next_node" do
      should "have a next node of compressed_hours_done for someone working compressed hours" do
        add_responses basis_of_calculation?: "compressed-hours"
        assert_next_node :compressed_hours_done, for_response: "2"
      end

      should "have a next node of hours_per_week_done for someone not working compressed hours" do
        assert_next_node :hours_per_week_done, for_response: "2"
      end
    end
  end

  context "question :shift_worker_basis?" do
    setup do
      testing_node :shift_worker_basis?
      add_responses basis_of_calculation?: "shift-worker"
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of shift_worker_hours_per_shift? for a 'full-year' response" do
        assert_next_node :shift_worker_hours_per_shift?, for_response: "full-year"
      end

      should "have a next node of what_is_your_starting_date? for a 'starting' response" do
        assert_next_node :what_is_your_starting_date?, for_response: "starting"
      end

      should "have a next node of what_is_your_starting_date? for a 'starting-and-leaving' response" do
        assert_next_node :what_is_your_starting_date?, for_response: "starting-and-leaving"
      end

      should "have a next node of what_is_your_leaving_date? for a 'leaving' response" do
        assert_next_node :what_is_your_leaving_date?, for_response: "leaving"
      end
    end
  end

  context "question :shift_worker_hours_per_shift?" do
    setup do
      testing_node :shift_worker_hours_per_shift?
      add_responses basis_of_calculation?: "shift-worker",
                    shift_worker_basis?: "full-year"
    end

    should "render question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid for hours below 0" do
        assert_invalid_response "-1"
      end

      should "be invalid for hours above 24" do
        assert_invalid_response "25"
      end
    end

    context "next_node" do
      should "have a next node of shift_worker_shifts_per_shift_pattern?" do
        assert_next_node :shift_worker_shifts_per_shift_pattern?, for_response: "8"
      end
    end
  end

  context "question :shift_worker_shifts_per_shift_pattern?" do
    setup do
      testing_node :shift_worker_shifts_per_shift_pattern?
      add_responses basis_of_calculation?: "shift-worker",
                    shift_worker_basis?: "full-year",
                    shift_worker_hours_per_shift?: "8"
    end

    should "render question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid for a negative number of shifts" do
        assert_invalid_response "-1"
      end
    end

    context "next_node" do
      should "have a next node of shift_worker_days_per_shift_pattern?" do
        assert_next_node :shift_worker_days_per_shift_pattern?, for_response: "2"
      end
    end
  end

  context "question :shift_worker_days_per_shift_pattern?" do
    setup do
      testing_node :shift_worker_days_per_shift_pattern?
      add_responses basis_of_calculation?: "shift-worker",
                    shift_worker_basis?: "full-year",
                    shift_worker_hours_per_shift?: "8",
                    shift_worker_shifts_per_shift_pattern?: "2"
    end

    should "render question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid when days per shift is less than shifts per shift pattern" do
        assert_invalid_response "1"
      end
    end

    context "next_node" do
      should "have a next node of shift_worker_done" do
        assert_next_node :shift_worker_done, for_response: "2"
      end
    end
  end
end
