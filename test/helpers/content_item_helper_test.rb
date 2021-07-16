require "test_helper"

class ContentItemHelperTest < ActionView::TestCase
  def setup
    setup_fixture_flows
    @flow = RadioSampleFlow.build

    node = SmartAnswer::StartNode.new(@flow, @flow.name.underscore.to_sym)
    @start_node = node.presenter
  end

  def teardown
    teardown_fixture_flows
  end

  context "extract_flow_content" do
    should "include all flow content" do
      expected_content = [
        "Hotter or colder?",
        "Body for hotter or colder",
        "Hint for hotter or colder",
        "Frozen?",
        "Body for frozen with link →",
        "Hot outcome title",
        "Hot outcome body",
        "Cold outcome body",
        "Frozen outcome title",
        "Frozen outcome body",
      ]
      assert_equal expected_content, extract_flow_content(@flow, @start_node)
    end
  end
end
