require_relative "../test_helper"

module SmartAnswer
  class StartNodePresenterTest < ActiveSupport::TestCase
    setup do
      start_node = Node.new(nil, :start_node_name)
      @renderer = stub("renderer")
      @presenter = StartNodePresenter.new(start_node, nil, renderer: @renderer)
    end

    test "renderer is constructed using template name and directory obtained from start node" do
      start_node = stub("start-node", name: :start_node_name, template_directory: "start-node-template-directory")

      SmartAnswer::ErbRenderer.expects(:new).with(
        has_entries(
          template_directory: "start-node-template-directory",
          template_name: "start_node_name",
        ),
      )

      StartNodePresenter.new(start_node)
    end

    test "#title returns single line of content rendered for title block" do
      @renderer.stubs(:single_line_of_content_for).with(:title).returns("title-text")

      assert_equal "title-text", @presenter.title
    end

    test "#meta_description returns single line of content rendered for meta_description block" do
      @renderer.stubs(:single_line_of_content_for).with(:meta_description).returns("meta-description-text")

      assert_equal "meta-description-text", @presenter.meta_description
    end

    test "#body returns content rendered for body block with govspeak processing enabled by default" do
      @renderer.stubs(:content_for).with(:body, html: true).returns("body-html")

      assert_equal "body-html", @presenter.body
    end

    test "#body returns content rendered for body block with govspeak processing disabled" do
      @renderer.stubs(:content_for).with(:body, html: false).returns("body-govspeak")

      assert_equal "body-govspeak", @presenter.body(html: false)
    end

    test "#post_body returns content rendered for post_body block with govspeak processing enabled by default" do
      @renderer.stubs(:content_for).with(:post_body, html: true).returns("post-body-html")

      assert_equal "post-body-html", @presenter.post_body
    end

    test "#post_body returns content rendered for post_body block with govspeak processing disabled" do
      @renderer.stubs(:content_for).with(:post_body, html: false).returns("post-body-govspeak")

      assert_equal "post-body-govspeak", @presenter.post_body(html: false)
    end

    test "#start_button_text returns single line of content rendered for start_button_text block" do
      @renderer.stubs(:single_line_of_content_for).with(:start_button_text).returns("start-button-text")

      assert_equal "start-button-text", @presenter.start_button_text
    end

    test '#start_button_text returns "Start now" when there is no custom button text' do
      @renderer.stubs(:single_line_of_content_for).with(:start_button_text).returns("")

      assert_equal "Start now", @presenter.start_button_text
    end

    test "#relative_erb_template_path delegates to renderer" do
      @renderer.stubs(:relative_erb_template_path).returns("relative-erb-template-path")

      assert_equal "relative-erb-template-path", @presenter.relative_erb_template_path
    end
  end
end
