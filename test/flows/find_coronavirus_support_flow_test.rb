require "test_helper"
require "support/flow_test_helper"

class FindCoronavirusSupportFlowFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup { testing_flow FindCoronavirusSupportFlow }

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: need_help_with" do
    setup { testing_node :need_help_with }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of nation for an empty response" do
        assert_next_node :nation, for_response: %w[none]
      end

      should "have a next node based on the response" do
        assert_next_node :feel_unsafe, for_response: %w[feeling_unsafe being_unemployed]
      end
    end
  end

  context "question group: feeling_unsafe" do
    setup do
      testing_node :feel_unsafe
      add_responses need_help_with: %w[feeling_unsafe]
    end

    should "render the question" do
      assert_rendered_question
    end

    should "have a next node of nation for response yes if there aren't any other needs_help_with questions" do
      assert_next_node :nation, for_response: "yes"
    end

    should "have a next node of nation for response concerned_about_others if there aren't any other needs_help_with questions" do
      assert_next_node :nation, for_response: "concerned_about_others"
    end

    should "have a next node of nation for response no if there aren't any other needs_help_with questions" do
      assert_next_node :nation, for_response: "no"
    end

    should "have a next node of nation for response not_sure if there aren't any other needs_help_with questions" do
      assert_next_node :nation, for_response: "not_sure"
    end

    should "have next node of next question group if other needs_help_with questions" do
      add_responses need_help_with: %w[feeling_unsafe going_to_work]

      assert_next_node :worried_about_work, for_response: "yes"
    end
  end
end
