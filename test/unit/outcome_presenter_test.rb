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

    test "#body returns nil when the erb template doesn't exist" do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      options = { erb_template_directory: Pathname.new('/path/to/non-existent') }
      presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, options)

      assert_equal nil, presenter.body
    end

    test '#body returns nil when content_for(:body) is missing' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = ''

      with_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, erb_template_directory: erb_template_directory)

        assert_equal nil, presenter.body
      end
    end

    test '#body returns a single newline when the template is empty' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = content_for_body('')

      with_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, erb_template_directory: erb_template_directory)

        assert_equal "\n", presenter.body
      end
    end

    test "#body trims newlines by default" do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = content_for_body('<% if true %>
Hello world
<% end %>')

      with_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, erb_template_directory: erb_template_directory)

        assert_equal "<p>Hello world</p>\n", presenter.body
      end
    end

    test '#body strips spaces from the beginning of lines so that we can indent content in our content_for blocks' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = content_for_body('  <% if true %>
    line 1

    line 2
  <% end %>')

      with_erb_template_file('outcome-name', erb_template) do |erb_template_directory|
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, erb_template_directory: erb_template_directory)

        assert_equal "line 1\n\nline 2\n", presenter.body(html: false)
      end
    end

    test '#body makes the state variables available to the ERB template' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = content_for_body('<%= state_variable %>')

      with_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        state = stub(to_hash: { state_variable: 'state-variable' })
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, erb_template_directory: erb_template_directory)

        assert_match 'state-variable', presenter.body
      end
    end

    test "#body raises an exception if the ERB template references a non-existent state variable" do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = content_for_body('<%= non_existent_state_variable %>')

      with_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        state = stub(to_hash: {})
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, erb_template_directory: erb_template_directory)

        e = assert_raises(ActionView::Template::Error) do
          presenter.body
        end
        assert_match "undefined local variable or method `non_existent_state_variable'", e.message
      end
    end

    test '#body makes the ActionView::Helpers::NumberHelper methods available to the ERB template' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = content_for_body('<%= number_with_delimiter(123456789) %>')

      with_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, erb_template_directory: erb_template_directory)

        assert_match '123,456,789', presenter.body
      end
    end

    test '#body passes output of ERB template through Govspeak' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = content_for_body('^information^')

      with_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, erb_template_directory: erb_template_directory)

        nodes = Capybara.string(presenter.body)
        assert nodes.has_css?(".application-notice", text: "information"), "Does not have information callout"
      end
    end

    test '#body does not pass output of ERB template through Govspeak when HTML disabled' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = content_for_body('^information^')

      with_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, erb_template_directory: erb_template_directory)

        assert_equal "^information^\n", presenter.body(html: false)
      end
    end

    test '#body delegates to NodePresenter when not using outcome templates' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: false)
      presenter = OutcomePresenter.new('i18n-prefix', outcome)

      presenter.stubs(:translate_and_render).with('body', optionally(anything)).returns('node-presenter-body')
      assert_equal 'node-presenter-body', presenter.body
    end

    test '#body returns the same content when called multiple times' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = content_for_body('body-content')

      with_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, erb_template_directory: erb_template_directory)

        assert_equal "<p>body-content</p>\n", presenter.body
        assert_equal "<p>body-content</p>\n", presenter.body
      end
    end

    test "#title returns nil when the erb template doesn't exist" do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      options = { erb_template_directory: Pathname.new('/path/to/non-existent') }
      presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, options)

      assert_equal nil, presenter.title
    end

    test '#title returns nil when content_for(:title) is missing' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = ''

      with_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, erb_template_directory: erb_template_directory)

        assert_equal nil, presenter.title
      end
    end

    test '#title returns an empty string when the template is empty' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = content_for_title('')

      with_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, erb_template_directory: erb_template_directory)

        assert_equal '', presenter.title
      end
    end

    test '#title trims a single newline from the end of the string' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = content_for_title("title-text\n")

      with_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, erb_template_directory: erb_template_directory)

        assert_equal "title-text\n", presenter.title
      end
    end

    test '#title strips spaces from the beginning of the line so that we can indent text within content_for blocks' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = content_for_title('  indented-title-text')

      with_erb_template_file('outcome-name', erb_template) do |erb_template_directory|
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, erb_template_directory: erb_template_directory)

        assert_equal 'indented-title-text', presenter.title
      end
    end

    test '#title makes the state variables available to the ERB template' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = content_for_title('<%= state_variable %>')

      with_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        state = stub(to_hash: { state_variable: 'state-variable' })
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, erb_template_directory: erb_template_directory)

        assert_match 'state-variable', presenter.title
      end
    end

    test "#title raises an exception if the ERB template references a non-existent state variable" do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = content_for_title('<%= non_existent_state_variable %>')

      with_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        state = stub(to_hash: {})
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, erb_template_directory: erb_template_directory)

        e = assert_raises(ActionView::Template::Error) do
          presenter.title
        end
        assert_match "undefined local variable or method `non_existent_state_variable'", e.message
      end
    end

    test '#title calls translate! to return the title when not using outcome templates' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: false)
      presenter = OutcomePresenter.new('i18n-prefix', outcome)

      presenter.stubs(:translate!).with('title').returns('outcome-presenter-title')
      assert_equal 'outcome-presenter-title', presenter.title
    end

    test '#title returns the same content when called multiple times' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = content_for_title('title-content')

      with_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, erb_template_directory: erb_template_directory)

        assert_equal "title-content", presenter.title
        assert_equal "title-content", presenter.title
      end
    end

    test "#next_steps returns nil when the erb template doesn't exist" do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      options = { erb_template_directory: Pathname.new('/path/to/non-existent') }
      presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, options)

      assert_equal nil, presenter.next_steps
    end

    test '#body returns nil when content_for(:next_steps) is missing' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = ''

      with_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, erb_template_directory: erb_template_directory)

        assert_equal nil, presenter.next_steps
      end
    end

    test '#next_steps returns a single newline when the template is empty' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = content_for_next_steps('')

      with_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, erb_template_directory: erb_template_directory)

        assert_equal "\n", presenter.next_steps
      end
    end

    test "#next_steps trims newlines by default" do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = content_for_next_steps('<% if true %>
Hello world
<% end %>')

      with_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, erb_template_directory: erb_template_directory)

        assert_equal "<p>Hello world</p>\n", presenter.next_steps
      end
    end

    test '#next_steps strips spaces from the beginning of the line so that we can indent text within content_for blocks' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = content_for_next_steps('  indented-next-steps-text')

      with_erb_template_file('outcome-name', erb_template) do |erb_template_directory|
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, erb_template_directory: erb_template_directory)

        assert_equal "indented-next-steps-text\n", presenter.next_steps(html: false)
      end
    end

    test '#next_steps makes the state variables available to the ERB template' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = content_for_next_steps('<%= state_variable %>')

      with_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        state = stub(to_hash: { state_variable: 'state-variable' })
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, erb_template_directory: erb_template_directory)

        assert_match 'state-variable', presenter.next_steps
      end
    end

    test "#next_steps raises an exception if the ERB template references a non-existent state variable" do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = content_for_next_steps('<%= non_existent_state_variable %>')

      with_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        state = stub(to_hash: {})
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, erb_template_directory: erb_template_directory)

        e = assert_raises(ActionView::Template::Error) do
          presenter.next_steps
        end
        assert_match "undefined local variable or method `non_existent_state_variable'", e.message
      end
    end

    test '#next_steps makes the ActionView::Helpers::NumberHelper methods available to the ERB template' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = content_for_next_steps('<%= number_with_delimiter(123456789) %>')

      with_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, erb_template_directory: erb_template_directory)

        assert_match '123,456,789', presenter.next_steps
      end
    end

    test '#next_steps passes output of ERB template through Govspeak' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = content_for_next_steps('^information^')

      with_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, erb_template_directory: erb_template_directory)

        nodes = Capybara.string(presenter.next_steps)
        assert nodes.has_css?(".application-notice", text: "information"), "Does not have information callout"
      end
    end

    test '#next_steps does not pass output of ERB template through Govspeak when HTML disabled' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = content_for_next_steps('^information^')

      with_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, erb_template_directory: erb_template_directory)

        assert_equal "^information^\n", presenter.next_steps(html: false)
      end
    end

    test '#next_steps delegates to NodePresenter when not using outcome templates' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: false)
      presenter = OutcomePresenter.new('i18n-prefix', outcome)

      presenter.stubs(:translate_and_render).with('next_steps', optionally(anything)).returns('node-presenter-body')
      assert_equal 'node-presenter-body', presenter.next_steps
    end

    test '#next_steps returns the same content when called multiple times' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = content_for_next_steps('next-steps-content')

      with_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, erb_template_directory: erb_template_directory)

        assert_equal "<p>next-steps-content</p>\n", presenter.next_steps
        assert_equal "<p>next-steps-content</p>\n", presenter.next_steps
      end
    end

    private

    def content_for_body(template)
      "<% content_for :body do %>
      #{template}
      <% end %>"
    end

    def content_for_title(template)
      "<% content_for :title do %>
      #{template}
      <% end %>"
    end

    def content_for_next_steps(template)
      "<% content_for :next_steps do %>
      #{template}
      <% end %>"
    end

    def with_erb_template_file(outcome_name, erb_template)
      erb_template_filename = "#{outcome_name}.govspeak.erb"
      Dir.mktmpdir do |directory|
        erb_template_directory = Pathname.new(directory)

        File.open(erb_template_directory.join(erb_template_filename), "w") do |erb_template_file|
          erb_template_file.write(erb_template)
          erb_template_file.rewind

          yield erb_template_directory
        end
      end
    end
  end
end
