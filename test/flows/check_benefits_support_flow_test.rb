require "test_helper"
require "support/flow_test_helper"

class CheckBenefitsSupportFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    testing_flow CheckBenefitsSupportFlow
  end

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: where_do_you_live" do
    setup { testing_node :where_do_you_live }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of over_state_pension_age" do
        assert_next_node :over_state_pension_age, for_response: "england"
      end
    end
  end

  context "question: over_state_pension_age" do
    setup do
      testing_node :over_state_pension_age
      add_responses where_do_you_live: "england"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of are_you_working" do
        assert_next_node :are_you_working, for_response: "yes"
      end
    end
  end

  context "question: are_you_working" do
    setup do
      testing_node :are_you_working
      add_responses where_do_you_live: "england",
                    over_state_pension_age: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of disability_or_health_condition" do
        assert_next_node :disability_or_health_condition, for_response: "yes_over_16_hours_per_week"
      end
    end
  end
end
