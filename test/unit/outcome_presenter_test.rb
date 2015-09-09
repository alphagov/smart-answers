require_relative '../test_helper'

module SmartAnswer
  class OutcomePresenterTest < ActiveSupport::TestCase
    test '#erb_template_path returns the default erb template path built using both the flow and outcome node name' do
      outcome = Outcome.new('outcome-name', flow_name: 'flow-name')
      presenter = OutcomePresenter.new('i18n-prefix', outcome)

      expected_path = Rails.root.join('lib', 'smart_answer_flows', 'flow-name', 'outcome-name.govspeak.erb')
      assert_equal expected_path, presenter.erb_template_path
    end

    test '#erb_template_path returns the erb template path supplied in the options' do
      outcome = Outcome.new('outcome-name')

      options = { erb_template_directory: Pathname.new('/erb-template-directory') }
      presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, options)

      expected_path = Pathname.new('/erb-template-directory').join('outcome-name.govspeak.erb')
      assert_equal expected_path, presenter.erb_template_path
    end

    test '#title returns content rendered for title block with govspeak processing disabled' do
      outcome = Outcome.new('outcome-name')
      renderer = stub('renderer')
      renderer.stubs(:content_for).with(:title, govspeak: false).returns('title-text')

      presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, renderer: renderer)

      assert_equal 'title-text', presenter.title
    end

    test '#title removes trailing newline from rendered content' do
      outcome = Outcome.new('outcome-name')
      renderer = stub('renderer')
      renderer.stubs(:content_for).returns("title-text\n")

      presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, renderer: renderer)

      assert_equal 'title-text', presenter.title
    end

    test '#body returns content rendered for body block with govspeak processing enabled by default' do
      outcome = Outcome.new('outcome-name')
      renderer = stub('renderer')
      renderer.stubs(:content_for).with(:body, html: true).returns('body-html')

      presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, renderer: renderer)

      assert_equal 'body-html', presenter.body
    end

    test '#body returns content rendered for body block with govspeak processing disabled' do
      outcome = Outcome.new('outcome-name')
      renderer = stub('renderer')
      renderer.stubs(:content_for).with(:body, html: false).returns('body-govspeak')

      presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, renderer: renderer)

      assert_equal 'body-govspeak', presenter.body(html: false)
    end

    test '#next_steps returns content rendered for next_steps block with govspeak processing enabled by default' do
      outcome = Outcome.new('outcome-name')
      renderer = stub('renderer')
      renderer.stubs(:content_for).with(:next_steps, html: true).returns('next-steps-html')

      presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, renderer: renderer)

      assert_equal 'next-steps-html', presenter.next_steps
    end

    test '#next_steps returns content rendered for next_steps block with govspeak processing disabled' do
      outcome = Outcome.new('outcome-name')
      renderer = stub('renderer')
      renderer.stubs(:content_for).with(:next_steps, html: false).returns('next-steps-govspeak')

      presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, renderer: renderer)

      assert_equal 'next-steps-govspeak', presenter.next_steps(html: false)
    end
  end
end
