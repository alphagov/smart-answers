require_relative "../test_helper"
require_relative "../helpers/fixture_flows_helper"

require File.expand_path('../../fixtures/smart_answer_flows/flow-sample', __FILE__)

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
      @flow.external_related_links([title: 'a-title', url: 'a-description'])

      assert_equal [title: 'a-title', url: 'a-description'], @presenter.external_related_links
    end

    should "return empty list if no external links" do
      assert_equal [], @presenter.external_related_links
    end
  end

  context "indexable_content" do
    should "include all question node titles" do
      @content = @presenter.indexable_content
      assert_match %r{QUESTION_1_TITLE}, @content
      assert_match %r{QUESTION_2_TITLE}, @content
    end

    should "include all outcome node titles" do
      @content = @presenter.indexable_content
      assert_match %r{OUTCOME_1_TITLE}, @content
      assert_match %r{OUTCOME_2_TITLE}, @content
      assert_match %r{OUTCOME_3_TITLE}, @content
    end

    should "include the flow body and question node bodies" do
      @content = @presenter.indexable_content
      assert_match %r{FLOW_BODY}, @content
      assert_match %r{QUESTION_1_BODY}, @content
      assert_match %r{QUESTION_2_BODY}, @content
    end

    should "include outcome node bodies" do
      @content = @presenter.indexable_content
      assert_match %r{OUTCOME_1_BODY}, @content
      assert_match %r{OUTCOME_2_BODY}, @content
      assert_match %r{OUTCOME_3_BODY}, @content
    end

    should "include all question hints" do
      @content = @presenter.indexable_content
      assert_match %r{QUESTION_1_HINT}, @content
      assert_match %r{QUESTION_2_HINT}, @content
    end

    should "omit HTML" do
      @content = @presenter.indexable_content
      assert_no_match %r{<}, @content
      assert_match %r{LINK TEXT}, @content
    end

    should "decode HTML entities" do
      @content = @presenter.indexable_content
      assert_no_match %r{&rarr;}, @content
      assert_match %r{→}, @content
    end

    should "ignore any interpolation errors" do
      @flow.multiple_choice(:question_with_interpolation)
      @flow.outcome(:outcome_with_interpolation)
      @content = @presenter.indexable_content
      assert_match %r{FLOW_BODY}, @content
      assert_match %r{QUESTION_1_BODY}, @content
      assert_match %r{QUESTION_2_BODY}, @content
      assert_match %r{QUESTION_WITH_INTERPOLATION_BODY}, @content
      assert_match %r{OUTCOME_WITH_INTERPOLATION_BODY}, @content
    end
  end

  context "state" do
    should "always return live, because the FlowRegistry decides what to register" do
      assert_equal 'live', @presenter.state
    end
  end
end
