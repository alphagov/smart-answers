require "test_helper"
require "support/flow_test_helper"

class RegisterADeathFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    testing_flow RegisterADeathFlow
  end

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: where_did_the_death_happen?" do
    setup { testing_node :where_did_the_death_happen? }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of scotland_result for a 'scotland' response" do
        assert_next_node :scotland_result, for_response: "scotland"
      end

      should "have a next node of northern_ireland_result for a 'northern_ireland' response" do
        assert_next_node :northern_ireland_result, for_response: "northern_ireland"
      end

      should "have a next node of did_the_person_die_at_home_hospital? for a 'england_wales' response" do
        assert_next_node :did_the_person_die_at_home_hospital?, for_response: "england_wales"
      end

      should "have a next node of death_abroad_result for a 'overseas' response" do
        assert_next_node :death_abroad_result, for_response: "overseas"
      end
    end
  end

  context "question: did_the_person_die_at_home_hospital?" do
    setup do
      testing_node :did_the_person_die_at_home_hospital?
      add_responses where_did_the_death_happen?: "england_wales"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of was_death_expected? for any response" do
        assert_next_node :was_death_expected?, for_response: "at_home_hospital"
      end
    end
  end

  context "question: was_death_expected?" do
    setup do
      testing_node :was_death_expected?
      add_responses where_did_the_death_happen?: "england_wales",
                    did_the_person_die_at_home_hospital?: "at_home_hospital"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of uk_result for any response" do
        assert_next_node :uk_result, for_response: "yes"
      end
    end
  end
end
