require_relative "../test_helper"

module SmartAnswer
  class ValueQuestionPresenterTest < ActiveSupport::TestCase
    setup do
      @question = Question::Base.new(nil, :question_name?)
      @renderer = stub("renderer")
      @presenter = ValueQuestionPresenter.new(@question, nil, renderer: @renderer)
    end

    test "#hint_text returns single line of content rendered for hint block" do
      @renderer.stubs(:content_for).with(:body).returns("")
      @renderer.stubs(:single_line_of_content_for).with(:hint).returns("hint-text")
      @renderer.stubs(:single_line_of_content_for).with(:suffix_label).returns("")

      assert_equal "hint-text", @presenter.hint_text
    end

    test "#hint_text also returns body and suffix_label if present" do
      @renderer.stubs(:content_for).with(:body).returns("body")
      @renderer.stubs(:single_line_of_content_for).with(:hint).returns("hint-text")
      @renderer.stubs(:single_line_of_content_for).with(:suffix_label).returns("suffix")

      assert_equal "body, hint-text, suffix", @presenter.hint_text
    end
  end
end
