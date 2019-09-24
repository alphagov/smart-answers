require_relative "../test_helper"
require_relative "../helpers/fixture_flows_helper"

require File.expand_path("../fixtures/smart_answer_flows/flow-sample", __dir__)

class FlowRegistrationPresenterTest < ActiveSupport::TestCase
  include FixtureFlowsHelper

  def setup
    setup_fixture_flows
    @flow = SmartAnswer::FlowSampleFlow.build
    @presenter = FlowRegistrationPresenter.new(@flow)
  end

  def teardown
    teardown_fixture_flows
  end

  context "slug" do
    should "use the flow name" do
      assert_equal "flow-sample", @presenter.slug
    end
  end

  context "start_page_content_id" do
    should "use the flow start_page_content_id" do
      assert_equal "f26e566e-2557-4921-b944-9373c32255f1", @presenter.start_page_content_id
    end
  end

  context "title" do
    should "should use the title from the start node template" do
      assert_equal "FLOW_TITLE", @presenter.title
    end
  end

  context "need_id" do
    should "use the flow's need_id" do
      assert_equal 4242, @presenter.need_id
    end
  end

  context "description" do
    should "use the meta_description from the start node template" do
      assert_equal "FLOW_DESCRIPTION", @presenter.description
    end
  end

  context "#external_related_links" do
    should "return the external_related_links" do
      @flow.external_related_links([title: "a-title", url: "a-description"])

      assert_equal [title: "a-title", url: "a-description"], @presenter.external_related_links
    end

    should "return empty list if no external links" do
      assert_equal [], @presenter.external_related_links
    end
  end

  context "flows_content" do
    should "include all flow content" do
      expected_content = [
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
      assert_equal expected_content, @presenter.flows_content
    end
  end

  context "state" do
    should "always return live, because the FlowRegistry decides what to register" do
      assert_equal "live", @presenter.state
    end
  end
end
