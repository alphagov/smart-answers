require_relative '../test_helper'

module SmartAnswer
  class QuestionPresenterTest < ActiveSupport::TestCase
    setup do
      @question = Question::Base.new(nil, :question_name?, use_erb_template: true)
      @renderer = stub('renderer')
      @presenter = QuestionPresenter.new('i18n-prefix', @question, state = nil, renderer: @renderer)
    end

    test 'renderer is constructed using template name and directory obtained from question node' do
      question_directory = Pathname.new('question-template-directory')
      question = stub('question', filesystem_friendly_name: 'question_name', template_directory: question_directory, use_erb_template?: true)

      SmartAnswer::ErbRenderer.expects(:new).with(
        has_entries(
          template_directory: responds_with(:to_s, 'question-template-directory/questions'),
          template_name: 'question_name'
        )
      )

      QuestionPresenter.new('i18n-prefix', question)
    end

    test '#title returns single line of content rendered for title block' do
      @renderer.stubs(:single_line_of_content_for).with(:title).returns('title-text')

      assert_equal 'title-text', @presenter.title
    end

    test '#hint returns single line of content rendered for hint block' do
      @renderer.stubs(:single_line_of_content_for).with(:hint).returns('hint-text')

      assert_equal 'hint-text', @presenter.hint
    end

    test '#label returns single line of content rendered for label block' do
      @renderer.stubs(:single_line_of_content_for).with(:label).returns('label-text')

      assert_equal 'label-text', @presenter.label
    end

    test '#suffix_label returns single line of content rendered for suffix_label block' do
      @renderer.stubs(:single_line_of_content_for).with(:suffix_label).returns('suffix-label-text')

      assert_equal 'suffix-label-text', @presenter.suffix_label
    end

    test '#body returns content rendered for body block with govspeak processing enabled by default' do
      @renderer.stubs(:content_for).with(:body, html: true).returns('body-html')

      assert_equal 'body-html', @presenter.body
    end

    test '#body returns content rendered for body block with govspeak processing disabled' do
      @renderer.stubs(:content_for).with(:body, html: false).returns('body-govspeak')

      assert_equal 'body-govspeak', @presenter.body(html: false)
    end

    test '#post_body returns content rendered for post_body block with govspeak processing enabled' do
      @renderer.stubs(:content_for).with(:post_body, html: true).returns('post-body-html')

      assert_equal 'post-body-html', @presenter.post_body
    end

    test '#options returns options with labels and values' do
      question = Question::MultipleChoice.new(nil, :question_name?, use_erb_template: true)
      question.option(:option_one)
      question.option(:option_two)

      @renderer.stubs(:option_text).with(:option_one).returns('option-one-text')
      @renderer.stubs(:option_text).with(:option_two).returns('option-two-text')
      presenter = QuestionPresenter.new('i18n-prefix', question, state = nil, renderer: @renderer)

      assert_equal %w(option_one option_two), presenter.options.map(&:value)
      assert_equal %w(option-one-text option-two-text), presenter.options.map(&:label)
    end

    test '#error returns nil if there is no error' do
      state = stub('state', error: nil)
      presenter = QuestionPresenter.new('i18n-prefix', @question, state, renderer: @renderer)

      assert_nil presenter.error
    end

    test '#error returns error message for specific key if it exists' do
      state = stub('state', error: 'error_key')
      presenter = QuestionPresenter.new('i18n-prefix', @question, state, renderer: @renderer)
      presenter.stubs(:error_message_for).with('error_key').returns('error-message-text')

      assert_equal 'error-message-text', presenter.error
    end

    test '#error returns error message for fallback key if specific key does not exist' do
      state = stub('state', error: 'error_key')
      presenter = QuestionPresenter.new('i18n-prefix', @question, state, renderer: @renderer)
      presenter.stubs(:error_message_for).with('error_key').returns(nil)
      presenter.stubs(:error_message_for).with('error_message').returns('fallback-error-message-text')

      assert_equal 'fallback-error-message-text', presenter.error
    end

    test '#error returns global default error message for fallback key does not exist' do
      state = stub('state', error: 'error_key')
      presenter = QuestionPresenter.new('i18n-prefix', @question, state, renderer: @renderer)
      presenter.stubs(:error_message_for).with('error_key').returns(nil)
      presenter.stubs(:error_message_for).with('error_message').returns(nil)

      assert_equal I18n.translate('flow.defaults.error_message'), presenter.error
    end

    test '#error_message_for returns single line of content rendered for error_key block' do
      @renderer.stubs(:single_line_of_content_for).with(:error_key).returns('error-message-text')

      assert_equal 'error-message-text', @presenter.error_message_for('error_key')
    end

    test '#error_message_for returns nil if rendered content is blank' do
      @renderer.stubs(:single_line_of_content_for).returns("    ")

      assert_nil @presenter.error_message_for('error_key')
    end
  end
end
