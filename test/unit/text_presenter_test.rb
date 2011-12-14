# coding:utf-8

require_relative '../test_helper'

module SmartAnswer
  class TextPresenterTest < ActiveSupport::TestCase
    def setup
      @old_load_path = I18n.config.load_path.dup
      example_translation_file =
        File.expand_path('../../fixtures/text_presenter_test/example.yml', __FILE__)
      I18n.config.load_path.unshift example_translation_file
      I18n.reload!
      registry = FlowRegistry.new(File.expand_path('../../fixtures/', __FILE__))
      flow = registry.flows.first
      @presenter = TextPresenter.new(flow)
    end

    def teardown
      I18n.config.load_path = @old_load_path
      I18n.reload!
    end

    test "should have title" do
      assert_equal "FLOW_TITLE", @presenter.title
    end

    test "should have a section" do
      assert_equal "SECTION", @presenter.section
    end

    test "should have description" do
      assert_equal "FLOW_DESCRIPTION", @presenter.description
    end

    test "should include body in text" do
      assert_match %r{FLOW_BODY}, @presenter.text
    end

    test "should include node titles" do
      assert_match %r{NODE_1_TITLE}, @presenter.text
      assert_match %r{NODE_2_TITLE}, @presenter.text
      assert_match %r{NODE_3_TITLE}, @presenter.text
    end

    test "should include node subtitles" do
      assert_match %r{NODE_1_SUBTITLE}, @presenter.text
      assert_match %r{NODE_2_SUBTITLE}, @presenter.text
      assert_match %r{NODE_3_SUBTITLE}, @presenter.text
    end

    test "should include node bodies" do
      assert_match %r{NODE_1_BODY}, @presenter.text
      assert_match %r{NODE_2_BODY}, @presenter.text
      assert_match %r{NODE_3_BODY}, @presenter.text
    end

    test "should include node hints" do
      assert_match %r{NODE_1_HINT}, @presenter.text
      assert_match %r{NODE_2_HINT}, @presenter.text
      assert_match %r{NODE_3_HINT}, @presenter.text
    end
  end
end
