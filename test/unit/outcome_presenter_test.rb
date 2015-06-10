require_relative '../test_helper'

module SmartAnswer
  class OutcomePresenterTest < ActiveSupport::TestCase
    test '#body_erb_template_path returns the default erb template path built using both the flow and outcome node name' do
      outcome = Outcome.new('outcome-name', flow_name: 'flow-name')
      presenter = OutcomePresenter.new('i18n-prefix', outcome)

      expected_path = Rails.root.join('lib', 'smart_answer_flows', 'flow-name', 'outcome-name_body.govspeak.erb')
      assert_equal expected_path, presenter.body_erb_template_path
    end

    test '#body_erb_template_path returns the erb template path supplied in the options' do
      outcome = Outcome.new('outcome-name')

      options = { erb_template_directory: Pathname.new('/erb-template-directory') }
      presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, options)

      expected_path = Pathname.new('/erb-template-directory').join('outcome-name_body.govspeak.erb')
      assert_equal expected_path, presenter.body_erb_template_path
    end

    test "#body returns nil when the erb template doesn't exist" do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      options = { erb_template_directory: Pathname.new('/path/to/non-existent') }
      presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, options)

      assert_equal nil, presenter.body
    end

    test "#body trims newlines by default" do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = '<% if true %>
Hello world
<% end %>
'

      with_body_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, erb_template_directory: erb_template_directory)

        assert_equal "<p>Hello world</p>\n", presenter.body
      end
    end

    test '#body makes the state variables available to the ERB template' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = '<%= state_variable %>'

      with_body_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        state = stub(to_hash: { state_variable: 'state-variable' })
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, erb_template_directory: erb_template_directory)

        assert_match 'state-variable', presenter.body
      end
    end

    test "#body raises an exception if the ERB template references a non-existent state variable" do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = '<%= non_existent_state_variable %>'

      with_body_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
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

      erb_template = '<%= number_with_delimiter(123456789) %>'

      with_body_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, erb_template_directory: erb_template_directory)

        assert_match '123,456,789', presenter.body
      end
    end

    test '#body passes output of ERB template through Govspeak' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = '^information^'

      with_body_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, erb_template_directory: erb_template_directory)

        nodes = Capybara.string(presenter.body)
        assert nodes.has_css?(".application-notice", text: "information"), "Does not have information callout"
      end
    end

    test '#body delegates to NodePresenter when not using outcome templates' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: false)
      presenter = OutcomePresenter.new('i18n-prefix', outcome)

      presenter.stubs(:translate_and_render).with('body').returns('node-presenter-body')
      assert_equal 'node-presenter-body', presenter.body
    end

    test '#title_erb_template_path returns the default erb template path built using both the flow and outcome node name' do
      options = { flow_name: 'flow-name' }
      outcome = Outcome.new('outcome-name', options)
      presenter = OutcomePresenter.new('i18n-prefix', outcome)

      expected_path = Rails.root.join('lib', 'smart_answer_flows', 'flow-name', 'outcome-name_title.txt.erb')
      assert_equal expected_path, presenter.title_erb_template_path
    end

    test '#title_erb_template_path returns the erb template path supplied in the options' do
      outcome = Outcome.new('outcome-name')

      options = { erb_template_directory: Pathname.new('/erb-template-directory') }
      presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, options)

      expected_path = Pathname.new('/erb-template-directory').join('outcome-name_title.txt.erb')
      assert_equal expected_path, presenter.title_erb_template_path
    end

    test "#title returns nil when the erb template doesn't exist" do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      options = { erb_template_directory: Pathname.new('/path/to/non-existent') }
      presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, options)

      assert_equal nil, presenter.title
    end

    test '#title trims a single newline from the end of the string' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = "title-text\n\n"

      with_title_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state = nil, erb_template_directory: erb_template_directory)

        assert_equal "title-text\n", presenter.title
      end
    end

    test '#title makes the state variables available to the ERB template' do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = '<%= state_variable %>'

      with_title_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
        state = stub(to_hash: { state_variable: 'state-variable' })
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, erb_template_directory: erb_template_directory)

        assert_match 'state-variable', presenter.title
      end
    end

    test "#title raises an exception if the ERB template references a non-existent state variable" do
      outcome = Outcome.new('outcome-name', use_outcome_templates: true)

      erb_template = '<%= non_existent_state_variable %>'

      with_title_erb_template_file("outcome-name", erb_template) do |erb_template_directory|
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

    private

    def with_title_erb_template_file(outcome_name, erb_template, &block)
      with_erb_template_file("#{outcome_name}_title.txt.erb", erb_template, &block)
    end

    def with_body_erb_template_file(outcome_name, erb_template, &block)
      with_erb_template_file("#{outcome_name}_body.govspeak.erb", erb_template, &block)
    end

    def with_erb_template_file(erb_template_filename, erb_template)
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
