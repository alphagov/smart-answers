require "test_helper"
require "support/flow_test_helper"

class CalculateAgriculturalHolidayEntitlementFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup { testing_flow CalculateAgriculturalHolidayEntitlementFlow }

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: work_the_same_number_of_days_each_week?" do
    setup { testing_node :work_the_same_number_of_days_each_week? }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_many_days_per_week? for a 'same-number-of-days' response" do
        assert_next_node :how_many_days_per_week?, for_response: "same-number-of-days"
      end

      should "have a next node of what_date_does_holiday_start? for a 'different-number-of-days' response" do
        assert_next_node :what_date_does_holiday_start?, for_response: "different-number-of-days"
      end
    end
  end

  context "question: how_many_days_per_week?" do
    setup do
      testing_node :how_many_days_per_week?
      add_responses work_the_same_number_of_days_each_week?: "same-number-of-days"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of worked_for_same_employer? for any response" do
        assert_next_node :worked_for_same_employer?, for_response: "7-days"
      end
    end
  end

  context "question: what_date_does_holiday_start?" do
    setup do
      testing_node :what_date_does_holiday_start?
      add_responses work_the_same_number_of_days_each_week?: "different-number-of-days"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_many_total_days? for any date response" do
        assert_next_node :how_many_total_days?, for_response: "2021-12-01"
      end
    end
  end

  context "question: worked_for_same_employer?" do
    setup do
      testing_node :worked_for_same_employer?
      add_responses work_the_same_number_of_days_each_week?: "same-number-of-days",
                    how_many_days_per_week?: "7-days"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of done for a 'same-employer' response" do
        assert_next_node :done, for_response: "same-employer"
      end

      should "have a next node of how_many_weeks_at_current_employer? for a 'multiple-employers' response" do
        assert_next_node :how_many_weeks_at_current_employer?, for_response: "multiple-employers"
      end
    end
  end

  context "question: how_many_total_days?" do
    setup do
      travel_to("2021-12-01")
      testing_node :how_many_total_days?
      add_responses work_the_same_number_of_days_each_week?: "different-number-of-days",
                    what_date_does_holiday_start?: "2021-12-01"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid if today days worked greater than number of days since date holiday starts" do
        assert_invalid_response "365"
      end
    end

    context "next_node" do
      should "have a next node of worked_for_same_employer? for any valid response" do
        travel_to("2022-02-01") do
          assert_next_node :worked_for_same_employer?, for_response: "50"
        end
      end
    end
  end

  context "question: how_many_weeks_at_current_employer?" do
    setup do
      testing_node :how_many_weeks_at_current_employer?
      add_responses work_the_same_number_of_days_each_week?: "same-number-of-days",
                    how_many_days_per_week?: "7-days",
                    worked_for_same_employer?: "multiple-employers"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid if total weeks worked is 52 or more" do
        assert_invalid_response "52"
      end
    end

    context "next_node" do
      should "have a next node of done_with_number_formatting for any valid response" do
        assert_next_node :done_with_number_formatting, for_response: "50"
      end
    end
  end
end
