# coding:utf-8
require_relative "../test_helper"

class FlowRegistraionPresenterTest < ActiveSupport::TestCase
  def setup
    @old_load_path = I18n.config.load_path.dup
    example_translation_file =
      File.expand_path('../../fixtures/flow_registraion_presenter_sample/flow_sample.yml', __FILE__)
    I18n.config.load_path.unshift example_translation_file
    I18n.reload!
    registry = SmartAnswer::FlowRegistry.new(load_path: File.expand_path('../../fixtures/flow_registraion_presenter_sample', __FILE__))
    @flow = registry.flows.first
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

  context "title" do
    should "should use the title translation" do
      assert_equal "FLOW_TITLE", @presenter.title
    end

    should "use the humanized flow name if no translation is available" do
      I18n.stubs(:translate!).raises(I18n::MissingTranslationData.new(:en, "anything", {}))
      assert_equal "Flow-sample", @presenter.title
    end
  end

  context "need_id" do
    should "use the flow's need_id" do
      assert_equal 4242, @presenter.need_id
    end
  end

  context "section" do
    should "use the translated section_name" do
      assert_equal "SECTION", @presenter.section
    end

    should "use the humanized section_slug if no translation is available" do
      I18n.stubs(:translate!).raises(I18n::MissingTranslationData.new(:en, "anything", {}))
      assert_equal "Sample", @presenter.section
    end

    should "return nil if there is no translation, and no section_slug defined" do
      I18n.stubs(:translate!).raises(I18n::MissingTranslationData.new(:en, "anything", {}))
      @flow.stubs(:section_slug).returns(nil)
      assert_equal nil, @presenter.section
    end
  end

  context "paths" do
    should "generate flow.name and flow.name.json" do
      assert_equal ["flow-sample", "flow-sample.json"], @presenter.paths
    end
  end

  context "prefixes" do
    should "generate flow.name" do
      assert_equal ["flow-sample"], @presenter.prefixes
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

    should "include all node subtitles" do
      @content = @presenter.indexable_content
      assert_match %r{NODE_1_SUBTITLE}, @content
      assert_match %r{NODE_2_SUBTITLE}, @content
      assert_match %r{NODE_3_SUBTITLE}, @content
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

  context "live" do
    should "always return true, because the FlowRegistry decides what to register" do
      assert_equal true, @presenter.live
    end
  end
end
