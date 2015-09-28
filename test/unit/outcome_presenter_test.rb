require_relative '../test_helper'

module SmartAnswer
  class OutcomePresenterTest < ActiveSupport::TestCase
    setup do
      outcome = Outcome.new(nil, :outcome_name)
      @renderer = stub('renderer')
      @presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, renderer: @renderer)
    end

    test 'renderer is constructed using template name and directory obtained from outcome node' do
      outcome = stub('outcome', name: :outcome_name, template_directory: 'outcome-template-directory')

      SmartAnswer::ErbRenderer.expects(:new).with(
        has_entries(
          template_directory: 'outcome-template-directory',
          template_name: 'outcome_name'
        )
      )

      OutcomePresenter.new('i18n-prefix', outcome)
    end

    test '#title returns content rendered for title block with govspeak processing disabled' do
      @renderer.stubs(:content_for).with(:title, html: false).returns('title-text')

      assert_equal 'title-text', @presenter.title
    end

    test '#title removes trailing newline from rendered content' do
      @renderer.stubs(:content_for).returns("title-text\n")

      assert_equal 'title-text', @presenter.title
    end

    test '#body returns content rendered for body block with govspeak processing enabled by default' do
      @renderer.stubs(:content_for).with(:body, html: true).returns('body-html')

      assert_equal 'body-html', @presenter.body
    end

    test '#body returns content rendered for body block with govspeak processing disabled' do
      @renderer.stubs(:content_for).with(:body, html: false).returns('body-govspeak')

      assert_equal 'body-govspeak', @presenter.body(html: false)
    end

    test '#next_steps returns content rendered for next_steps block with govspeak processing enabled by default' do
      @renderer.stubs(:content_for).with(:next_steps, html: true).returns('next-steps-html')

      assert_equal 'next-steps-html', @presenter.next_steps
    end

    test '#next_steps returns content rendered for next_steps block with govspeak processing disabled' do
      @renderer.stubs(:content_for).with(:next_steps, html: false).returns('next-steps-govspeak')

      assert_equal 'next-steps-govspeak', @presenter.next_steps(html: false)
    end
  end
end
