require_relative '../test_helper'

module SmartAnswer
  class StartNodePresenterTest < ActiveSupport::TestCase
    setup do
      start_node = Node.new(nil, :start_node_name)
      @renderer = stub('renderer')
      @presenter = StartNodePresenter.new('i18n-prefix', start_node, state = nil, renderer: @renderer)
    end

    test 'renderer is constructed using template name and directory obtained from start node' do
      start_node = stub('start-node', name: :start_node_name, template_directory: 'start-node-template-directory')

      SmartAnswer::ErbRenderer.expects(:new).with(
        has_entries(
          template_directory: 'start-node-template-directory',
          template_name: 'start_node_name'
        )
      )

      StartNodePresenter.new('i18n-prefix', start_node)
    end

    test '#title returns content rendered for title block with govspeak processing disabled' do
      @renderer.stubs(:content_for).with(:title, html: false).returns('title-text')

      assert_equal 'title-text', @presenter.title
    end

    test '#title removes trailing newline from rendered content' do
      @renderer.stubs(:content_for).returns("title-text\n")

      assert_equal 'title-text', @presenter.title
    end

    test '#title falls back to humanized node name if not title available in ERB template' do
      @renderer.stubs(:content_for).returns(nil)

      assert_equal 'Start node name', @presenter.title
    end

    test '#meta_description returns content rendered for meta_description block with govspeak processing disabled' do
      @renderer.stubs(:content_for).with(:meta_description, html: false).returns('meta-description-text')

      assert_equal 'meta-description-text', @presenter.meta_description
    end

    test '#meta_description removes trailing newline from rendered content' do
      @renderer.stubs(:content_for).returns("meta-description-text\n")

      assert_equal 'meta-description-text', @presenter.meta_description
    end

    test '#has_meta_description? returns true if meta_description for node exists' do
      @renderer.stubs(:content_for).returns('meta-description-text')

      assert @presenter.has_meta_description?
    end

    test '#has_meta_description? returns false if meta_description for node does not exist' do
      @renderer.stubs(:content_for).returns(nil)

      refute @presenter.has_meta_description?
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

    test '#has_post_body? returns true if post_body for node exists' do
      @renderer.stubs(:content_for).returns('post-body-html')

      assert @presenter.has_post_body?
    end

    test '#has_post_body? returns false if post_body for node does not exist' do
      @renderer.stubs(:content_for).returns(nil)

      refute @presenter.has_post_body?
    end
  end
end
