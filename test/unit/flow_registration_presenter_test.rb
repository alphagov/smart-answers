# coding:utf-8
require_relative "../test_helper"

require File.expand_path('../../fixtures/flow-sample', __FILE__)

class FlowRegistrationPresenterTest < ActiveSupport::TestCase
  def setup
    @old_load_path = I18n.config.load_path.dup
    example_translation_file =
      File.expand_path('../../fixtures/flow_registraion_presenter_sample/flow_sample.yml', __FILE__)
    I18n.config.load_path.unshift example_translation_file
    I18n.reload!

    load_path = fixture_file('smart_answer_flows')
    SmartAnswer::FlowRegistry.instance.stubs(:load_path).returns(load_path)

    @flow = SmartAnswer::FlowSampleFlow.build
    @presenter = FlowRegistrationPresenter.new(@flow)
  end

  def teardown
    I18n.config.load_path = @old_load_path
    I18n.reload!
  end

  context "slug" do
    should "use the flow name" do
      assert_equal "flow-sample", @presenter.slug
    end
  end

  context "content_id" do
    should "use the flow content_id" do
      assert_equal "f26e566e-2557-4921-b944-9373c32255f1", @presenter.content_id
    end
  end

  context "title" do
    should "should use the title translation" do
      assert_equal "FLOW_TITLE", @presenter.title
    end
  end

  context "need_id" do
    should "use the flow's need_id" do
      assert_equal 4242, @presenter.need_id
    end
  end

  context "paths" do
    should "generate and /flow.name.json" do
      assert_equal ["/flow-sample.json"], @presenter.paths
    end
  end

  context "prefixes" do
    should "generate /flow.name" do
      assert_equal ["/flow-sample"], @presenter.prefixes
    end
  end

  context "description" do
    should "use the meta.description translation" do
      assert_equal "FLOW_DESCRIPTION", @presenter.description
    end
  end

  context "indexable_content" do
    should "include all node titles" do
      @content = @presenter.indexable_content
      assert_match %r{NODE_1_TITLE}, @content
      assert_match %r{NODE_2_TITLE}, @content
      assert_match %r{NODE_3_TITLE}, @content
    end

    should "include the flow body and all node bodies" do
      @content = @presenter.indexable_content
      assert_match %r{FLOW_BODY}, @content
      assert_match %r{NODE_1_BODY}, @content
      assert_match %r{NODE_2_BODY}, @content
      assert_match %r{NODE_3_BODY}, @content
    end

    should "include all node hints" do
      @content = @presenter.indexable_content
      assert_match %r{NODE_1_HINT}, @content
      assert_match %r{NODE_2_HINT}, @content
      assert_match %r{NODE_3_HINT}, @content
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
      interpolation_example_translation_file =
        File.expand_path('../../fixtures/flow_registraion_presenter_sample/flow_sample_interpolation.yml', __FILE__)
      I18n.config.load_path = @old_load_path.dup
      I18n.config.load_path.unshift interpolation_example_translation_file
      I18n.reload!
      @content = @presenter.indexable_content
      assert_match %r{FLOW_BODY}, @content
      assert_match %r{NODE_1_BODY}, @content
      assert_match %r{NODE_3_BODY}, @content
    end
  end

  context "state" do
    should "always return live, because the FlowRegistry decides what to register" do
      assert_equal 'live', @presenter.state
    end
  end
end
