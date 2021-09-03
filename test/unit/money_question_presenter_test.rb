require_relative "../test_helper"

module SmartAnswer
  class MoneyQuestionPresenterTest < ActiveSupport::TestCase
    setup do
      @question = Question::Base.new(nil, :question_name?)

      @renderer = stub("renderer")

      @presenter = MoneyQuestionPresenter.new(@question, nil, nil, renderer: @renderer)
    end

    test "#hint_text returns single line of content rendered for hint block" do
      @renderer.stubs(:content_for).with(:body).returns("")
      @renderer.stubs(:content_for).with(:hint).returns("hint-text")
      @renderer.stubs(:content_for).with(:suffix_label).returns("")

      assert_equal "hint-text", @presenter.hint
    end

    test "#hint_text also returns body if present" do
      @renderer.stubs(:content_for).with(:body).returns("body")
      @renderer.stubs(:content_for).with(:hint).returns("hint-text")
      @renderer.stubs(:content_for).with(:suffix_label).returns("suffix")

      assert_equal "hint-text", @presenter.hint
    end

    test "#caption returns the given caption when a caption is given" do
      @renderer.stubs(:hide_caption).returns(false)
      @renderer.stubs(:content_for).with(:caption).returns("caption-text")

      assert_equal "caption-text", @presenter.caption
    end

    test "#prefix_label return '£' by default" do
      @renderer.stubs(:content_for).with(:prefix_label).returns(" ")

      assert_equal "£", @presenter.prefix_label
    end
  end
end
