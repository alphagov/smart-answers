require "test_helper"
require "support/flow_test_helper"

class PlanAdoptionLeaveFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    testing_flow PlanAdoptionLeaveFlow
    @child_match_date = 3.months.ago
  end

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: child_match_date?" do
    setup { testing_node :child_match_date? }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of child_arrival_date?" do
        assert_next_node :child_arrival_date?, for_response: @child_match_date.to_s
      end
    end
  end

  context "question: child_arrival_date?" do
    setup do
      testing_node :child_arrival_date?
      add_responses child_match_date?: @child_match_date.to_s
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid if the response is the same as the child_match_date" do
        assert_invalid_response @child_match_date.to_s
      end

      should "be invalid if the response is before the child_match_date" do
        before_child_match_date = @child_match_date - 1.day
        assert_invalid_response before_child_match_date.to_s
      end
    end

    context "next_node" do
      should "have a next node of leave_start? for a valid response" do
        after_child_match_date = @child_match_date + 1.day
        assert_next_node :leave_start?, for_response: after_child_match_date.to_s
      end
    end
  end

  context "question: leave_start?" do
    setup do
      @child_arrival_date = @child_match_date + 1.month

      testing_node :leave_start?
      add_responses child_match_date?: @child_match_date.to_s,
                    child_arrival_date?: @child_arrival_date.to_s
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid if the response is not within 14 days of the child_arrival_date" do
        not_within_14_days = @child_arrival_date - 15.days
        assert_invalid_response not_within_14_days.to_s
      end
    end

    context "next_node" do
      should "have a next node of adoption_leave_details for a valid response" do
        within_14_days = @child_arrival_date - 14.days
        assert_next_node :adoption_leave_details, for_response: within_14_days.to_s
      end
    end
  end
end
