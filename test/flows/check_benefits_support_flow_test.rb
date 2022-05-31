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

  context "question: disability_or_health_condition" do
    setup do
      testing_node :disability_or_health_condition
      add_responses where_do_you_live: "england",
                    over_state_pension_age: "yes",
                    are_you_working: "yes_over_16_hours_per_week"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of carer_disability_or_health_condition if there is no conditon" do
        assert_next_node :carer_disability_or_health_condition, for_response: "no"
      end

      should "have a next node of disability_affecting_work if there is a conditon" do
        assert_next_node :disability_affecting_work, for_response: "yes"
      end
    end
  end

  context "question: disability_affecting_work" do
    setup do
      testing_node :disability_affecting_work
      add_responses where_do_you_live: "england",
                    over_state_pension_age: "yes",
                    are_you_working: "yes_over_16_hours_per_week",
                    disability_or_health_condition: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of carer_disability_or_health_condition" do
        assert_next_node :carer_disability_or_health_condition, for_response: "yes_limits_work"
      end
    end
  end

  context "question: carer_disability_or_health_condition" do
    setup do
      testing_node :carer_disability_or_health_condition
      add_responses where_do_you_live: "england",
                    over_state_pension_age: "yes",
                    are_you_working: "yes_over_16_hours_per_week",
                    disability_or_health_condition: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of children_living_with_you if not an unpaid carer" do
        assert_next_node :children_living_with_you, for_response: "no"
      end

      should "have a next node of unpaid_care_hours if an unpaid carer" do
        assert_next_node :unpaid_care_hours, for_response: "yes"
      end
    end
  end

  context "question: unpaid_care_hours" do
    setup do
      testing_node :unpaid_care_hours
      add_responses where_do_you_live: "england",
                    over_state_pension_age: "yes",
                    are_you_working: "yes_over_16_hours_per_week",
                    disability_or_health_condition: "yes",
                    disability_affecting_work: "yes_unable_to_work",
                    carer_disability_or_health_condition: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of children_living_with_you" do
        assert_next_node :children_living_with_you, for_response: "yes"
      end
    end
  end
end
