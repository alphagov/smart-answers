require_relative "../test_helper"

module SmartAnswer
  class QuestionPresenterTest < ActiveSupport::TestCase
    setup do
      @question = Question::Base.new(nil, :question_name?)

      @renderer = stub("renderer")

      @presenter = QuestionPresenter.new(@question, nil, nil, renderer: @renderer)
    end

    test "renderer is constructed using template name and directory obtained from question node" do
      question_directory = Pathname.new("question-template-directory")
      question = stub("question", template_name: "question_name", template_directory: question_directory)

      SmartAnswer::ErbRenderer.expects(:new).with(
        has_entries(
          template_directory: responds_with(:to_s, "question-template-directory/questions"),
          template_name: "question_name",
        ),
      )

      QuestionPresenter.new(question, nil)
    end

    test "#title returns single line of content rendered for title block" do
      @renderer.stubs(:content_for).with(:title).returns("title-text")

      assert_equal "title-text", @presenter.title
    end

    test "#hint returns single line of content rendered for hint block" do
      @renderer.stubs(:content_for).with(:hint).returns("hint-text")

      assert_equal "hint-text", @presenter.hint
    end

    test "#label returns single line of content rendered for label block" do
      @renderer.stubs(:content_for).with(:label).returns("label-text")

      assert_equal "label-text", @presenter.label
    end

    test "#suffix_label returns single line of content rendered for suffix_label block" do
      @renderer.stubs(:content_for).with(:suffix_label).returns("suffix-label-text")

      assert_equal "suffix-label-text", @presenter.suffix_label
    end

    test "#suffix_label return nil if text empty" do
      @renderer.stubs(:content_for).with(:suffix_label).returns(" ")

      assert_nil @presenter.suffix_label
    end

    test "#prefix_label returns single line of content rendered for prefix_label block" do
      @renderer.stubs(:content_for).with(:prefix_label).returns("prefix-label-text")

      assert_equal "prefix-label-text", @presenter.prefix_label
    end

    test "#prefix_label return nil if text empty" do
      @renderer.stubs(:content_for).with(:prefix_label).returns(" ")

      assert_nil @presenter.prefix_label
    end

    test "#body returns content rendered for body block" do
      @renderer.stubs(:content_for).with(:body).returns("body-html")

      assert_equal "body-html", @presenter.body
    end

    test "#post_body returns content rendered for post_body block" do
      @renderer.stubs(:content_for).with(:post_body).returns("post-body-html")

      assert_equal "post-body-html", @presenter.post_body
    end

    test "#caption returns single line of content rendered for caption block" do
      @renderer.stubs(:hide_caption).returns(false)
      @renderer.stubs(:content_for).with(:caption).returns("caption-text")

      assert_equal "caption-text", @presenter.caption
    end

    test "#error returns nil if there is no error" do
      state = stub("state", error: nil)
      presenter = QuestionPresenter.new(@question, nil, state, renderer: @renderer)

      assert_nil presenter.error
    end

    test "#error returns error message for specific key if it exists" do
      state = stub("state", error: "error_key")
      presenter = QuestionPresenter.new(@question, nil, state, renderer: @renderer)
      presenter.stubs(:error_message_for).with("error_key").returns("error-message-text")

      assert_equal "error-message-text", presenter.error
    end

    test "#error returns error message for fallback key if specific key does not exist" do
      state = stub("state", error: "error_key")
      presenter = QuestionPresenter.new(@question, nil, state, renderer: @renderer)
      presenter.stubs(:error_message_for).with("error_key").returns(nil)
      presenter.stubs(:error_message_for).with("error_message").returns("fallback-error-message-text")

      assert_equal "fallback-error-message-text", presenter.error
    end

    test "#error returns default error message for fallback key does not exist" do
      state = stub("state", error: "error_key")
      presenter = QuestionPresenter.new(@question, nil, state, renderer: @renderer)
      presenter.stubs(:error_message_for).with("error_key").returns(nil)
      presenter.stubs(:error_message_for).with("error_message").returns(nil)

      assert_equal "Please answer this question", presenter.error
    end

    test "#error_message_for returns single line of content rendered for error_key block" do
      @renderer.stubs(:content_for).with(:error_key).returns("error-message-text")

      assert_equal "error-message-text", @presenter.error_message_for("error_key")
    end

    test "#error_message_for returns nil if rendered content is blank" do
      @renderer.stubs(:content_for).returns("    ")

      assert_nil @presenter.error_message_for("error_key")
    end

    test "#caption returns the given caption when a caption is given" do
      @renderer.stubs(:hide_caption).returns(false)
      @renderer.stubs(:content_for).with(:caption).returns("caption-text")

      assert_equal "caption-text", @presenter.caption
    end

    test "#caption returns the caption when both a title and a caption are given" do
      @renderer.stubs(:hide_caption).returns(false)
      @renderer.stubs(:content_for).with(:title).returns("title-text")
      @renderer.stubs(:content_for).with(:caption).returns("caption-text")

      assert_equal "caption-text", @presenter.caption
    end

    test "#view_template_path returns the question view template name" do
      assert_equal "smart_answers/question", @presenter.view_template_path
    end
  end
end
