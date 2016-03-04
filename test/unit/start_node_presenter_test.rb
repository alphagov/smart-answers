require_relative '../test_helper'

module SmartAnswer
  class StartNodePresenterTest < ActiveSupport::TestCase
    setup do
      start_node = Node.new(nil, :start_node_name)
      @renderer = stub('renderer')
      @presenter = StartNodePresenter.new(start_node, state = nil, renderer: @renderer)
    end

    test 'renderer is constructed using template name and directory obtained from start node' do
      start_node = stub('start-node', name: :start_node_name, template_directory: 'start-node-template-directory')

      SmartAnswer::ErbRenderer.expects(:new).with(
        has_entries(
          template_directory: 'start-node-template-directory',
          template_name: 'start_node_name'
        )
      )

      StartNodePresenter.new(start_node)
    end

    test '#title returns single line of content rendered for title block' do
      @renderer.stubs(:single_line_of_content_for).with(:title).returns('title-text')

      assert_equal 'title-text', @presenter.title
    end

    test '#meta_description returns single line of content rendered for meta_description block' do
      @renderer.stubs(:single_line_of_content_for).with(:meta_description).returns('meta-description-text')

      assert_equal 'meta-description-text', @presenter.meta_description
    end

    test '#body returns content rendered for body block with govspeak processing enabled by default' do
      @renderer.stubs(:content_for).with(:body, html: true).returns('body-html')

      assert_equal 'body-html', @presenter.body
    end

    test '#body returns content rendered for body block with govspeak processing disabled' do
      @renderer.stubs(:content_for).with(:body, html: false).returns('body-govspeak')

      assert_equal 'body-govspeak', @presenter.body(html: false)
    end

    test '#post_body returns content rendered for post_body block with govspeak processing enabled by default' do
      @renderer.stubs(:content_for).with(:post_body, html: true).returns('post-body-html')

      assert_equal 'post-body-html', @presenter.post_body
    end

    test '#post_body returns content rendered for post_body block with govspeak processing disabled' do
      @renderer.stubs(:content_for).with(:post_body, html: false).returns('post-body-govspeak')

      assert_equal 'post-body-govspeak', @presenter.post_body(html: false)
    end
  end
end
