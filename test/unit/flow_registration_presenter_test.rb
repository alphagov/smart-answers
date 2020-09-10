require_relative "../test_helper"

require File.expand_path("../fixtures/smart_answer_flows/flow-sample", __dir__)

class FlowRegistrationPresenterTest < ActiveSupport::TestCase
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

  context "need_content_id" do
    should "use the flow's need_content_id" do
      assert_equal "dccab509-bd3b-4f92-9af6-30f88485ac41", @presenter.need_content_id
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

  context "publish?" do
    should "return true for a published flow" do
      @flow.status(:published)
      assert @presenter.publish?
    end

    should "return false true for a draft flow" do
      @flow.status(:draft)
      assert_not @presenter.publish?
    end
  end
end
