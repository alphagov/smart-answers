require_relative "../test_helper"

module SmartAnswer
  class StartNodePresenterTest < ActiveSupport::TestCase
    setup do
      start_node = Node.new(nil, :start_node_name)
      @renderer = stub("renderer")
      @presenter = StartNodePresenter.new(start_node, nil, nil, renderer: @renderer)
    end

    test "renderer is constructed using template name and directory obtained from start node" do
      start_node = stub("start-node", name: :start_node_name, template_directory: "start-node-template-directory")

      SmartAnswer::ErbRenderer.expects(:new).with(
        has_entries(
          template_directory: "start-node-template-directory",
          template_name: "start",
        ),
      )

      StartNodePresenter.new(start_node, nil)
    end

    test "#title returns single line of content rendered for title block" do
      @renderer.stubs(:content_for).with(:title).returns("title-text")

      assert_equal "title-text", @presenter.title
    end

    test "#meta_description returns single line of content rendered for meta_description block" do
      @renderer.stubs(:content_for).with(:meta_description).returns("meta-description-text")

      assert_equal "meta-description-text", @presenter.meta_description
    end

    test "#body returns content rendered for body block" do
      @renderer.stubs(:content_for).with(:body).returns("body-html")

      assert_equal "body-html", @presenter.body
    end

    test "#post_body returns content rendered for post_body block" do
      @renderer.stubs(:content_for).with(:post_body).returns("post-body-html")

      assert_equal "post-body-html", @presenter.post_body
    end

    test "#start_button_text returns single line of content rendered for start_button_text block" do
      @renderer.stubs(:content_for).with(:start_button_text).returns("start-button-text")

      assert_equal "start-button-text", @presenter.start_button_text
    end

    test '#start_button_text returns "Start now" when there is no custom button text' do
      @renderer.stubs(:content_for).with(:start_button_text).returns("")

      assert_equal "Start now", @presenter.start_button_text
    end

    test "#post_body_header returns custom text when supplied" do
      @renderer.stubs(:content_for).with(:post_body_header).returns("post-body-header-text")

      assert_equal "post-body-header-text", @presenter.post_body_header
    end

    test '#post_body_header returns "Before you start" when there is no custom header text' do
      @renderer.stubs(:content_for).with(:post_body_header).returns("")

      assert_equal "Before you start", @presenter.post_body_header
    end
  end
end
