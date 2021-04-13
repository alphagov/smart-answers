require "test_helper"

require File.expand_path("../fixtures/smart_answer_flows/flow-sample", __dir__)

class ContentItemHelperTest < ActionView::TestCase
  def setup
    setup_fixture_flows
    @flow = SmartAnswer::FlowSampleFlow.build

    node = SmartAnswer::Node.new(@flow, @flow.name.underscore.to_sym)
    @start_node = StartNodePresenter.new(node)
  end

  def teardown
    teardown_fixture_flows
  end

  context "extract_flow_content" do
    should "include all flow content" do
      expected_content = [
        "FLOW_BODY",
        "QUESTION_1_TITLE",
        "QUESTION_1_BODY",
        "QUESTION_1_HINT",
        "QUESTION_2_TITLE",
        "QUESTION_2_BODY LINK TEXT →",
        "QUESTION_2_HINT",
        "OUTCOME_1_TITLE",
        "OUTCOME_1_BODY",
        "OUTCOME_2_TITLE",
        "OUTCOME_2_BODY",
        "OUTCOME_3_TITLE",
        "OUTCOME_3_BODY",
      ]
      assert_equal expected_content, extract_flow_content(@flow, @start_node)
    end
  end
end
