require_relative '../test_helper'

module SmartAnswer
  class OutcomePresenterTest < ActiveSupport::TestCase
    test '#body_erb_template_path returns the default erb template path built using both the flow and outcome node name' do
      options = { flow_name: 'flow-name' }
      outcome = Outcome.new('outcome-name', options)
      presenter = OutcomePresenter.new('i18n-prefix', outcome)

      expected_path = Rails.root.join('lib', 'smart_answer_flows', 'flow-name', 'outcome-name_body.govspeak.erb')
      assert_equal expected_path, presenter.body_erb_template_path
    end

    test '#body_erb_template_path returns the erb template path supplied in the options' do
      outcome = Outcome.new('outcome-name')

      state = nil
      options = { erb_template_directory: Pathname.new('/erb-template-directory'), body_erb_template_name: 'template.erb' }
      presenter = OutcomePresenter.new('i18n-prefix', outcome, state, options)

      expected_path = Pathname.new('/erb-template-directory').join('template.erb')
      assert_equal expected_path, presenter.body_erb_template_path
    end

    test "#body returns nil when the erb template doesn't exist" do
      options = { use_outcome_templates: true }
      outcome = Outcome.new('outcome-name', options)

      state = nil
      options = { erb_template_directory: Pathname.new('/path/to/non-existent'), body_erb_template_name: 'template.erb' }
      presenter = OutcomePresenter.new('i18n-prefix', outcome, state, options)

      assert_equal nil, presenter.body
    end

    test "#body trims newlines by default" do
      erb_template = '<% if true %>
Hello world
<% end %>
'

      with_erb_template_file("body", erb_template) do |presenter_options|
        options = { use_outcome_templates: true }
        outcome = Outcome.new('outcome-name', options)

        state = nil
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, presenter_options)

        assert_equal "<p>Hello world</p>\n", presenter.body
      end
    end

    test '#body makes the state variables available to the ERB template' do
      erb_template = '<%= state_variable %>'

      with_erb_template_file("body", erb_template) do |presenter_options|
        options = { use_outcome_templates: true }
        outcome = Outcome.new('outcome-name', options)

        state = stub(to_hash: { state_variable: 'state-variable' })
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, presenter_options)

        assert_match 'state-variable', presenter.body
      end
    end

    test "#body raises an exception if the ERB template references a non-existent state variable" do
      erb_template = '<%= non_existent_state_variable %>'

      with_erb_template_file("body", erb_template) do |presenter_options|
        options = { use_outcome_templates: true }
        outcome = Outcome.new('outcome-name', options)

        state = stub(to_hash: {})
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, presenter_options)

        e = assert_raises(ActionView::Template::Error) do
          presenter.body
        end
        assert_match "undefined local variable or method `non_existent_state_variable'", e.message
      end
    end

    test '#body makes the ActionView::Helpers::NumberHelper methods available to the ERB template' do
      erb_template = '<%= number_with_delimiter(123456789) %>'

      with_erb_template_file("body", erb_template) do |presenter_options|
        options = { use_outcome_templates: true }
        outcome = Outcome.new('outcome-name', options)

        state = nil
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, presenter_options)

        assert_match '123,456,789', presenter.body
      end
    end

    test '#body passes output of ERB template through Govspeak' do
      erb_template = '^information^'

      with_erb_template_file("body", erb_template) do |presenter_options|
        options = { use_outcome_templates: true }
        outcome = Outcome.new('outcome-name', options)

        state = nil
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, presenter_options)

        nodes = Capybara.string(presenter.body)
        assert nodes.has_css?(".application-notice", text: "information"), "Does not have information callout"
      end
    end

    test '#body delegates to NodePresenter when not using outcome templates' do
      options = { use_outcome_templates: false }
      outcome = Outcome.new('outcome-name', options)
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

      state = nil
      options = { erb_template_directory: Pathname.new('/erb-template-directory'), title_erb_template_name: 'template.erb' }
      presenter = OutcomePresenter.new('i18n-prefix', outcome, state, options)

      expected_path = Pathname.new('/erb-template-directory').join('template.erb')
      assert_equal expected_path, presenter.title_erb_template_path
    end

    test "#title returns nil when the erb template doesn't exist" do
      options = { use_outcome_templates: true }
      outcome = Outcome.new('outcome-name', options)

      state = nil
      options = { erb_template_directory: Pathname.new('/path/to/non-existent'), title_erb_template_name: 'template.erb' }
      presenter = OutcomePresenter.new('i18n-prefix', outcome, state, options)

      assert_equal nil, presenter.title
    end

    test '#title trims a single newline from the end of the string' do
      erb_template = "title-text\n\n"

      with_erb_template_file("title", erb_template) do |presenter_options|
        options = { use_outcome_templates: true }
        outcome = Outcome.new('outcome-name', options)

        state = nil
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, presenter_options)

        assert_equal "title-text\n", presenter.title
      end
    end

    test '#title makes the state variables available to the ERB template' do
      erb_template = '<%= state_variable %>'

      with_erb_template_file("title", erb_template) do |presenter_options|
        options = { use_outcome_templates: true }
        outcome = Outcome.new('outcome-name', options)

        state = stub(to_hash: { state_variable: 'state-variable' })
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, presenter_options)

        assert_match 'state-variable', presenter.title
      end
    end

    test "#title raises an exception if the ERB template references a non-existent state variable" do
      erb_template = '<%= non_existent_state_variable %>'

      with_erb_template_file("title", erb_template) do |presenter_options|
        options = { use_outcome_templates: true }
        outcome = Outcome.new('outcome-name', options)

        state = stub(to_hash: {})
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, presenter_options)

        e = assert_raises(ActionView::Template::Error) do
          presenter.title
        end
        assert_match "undefined local variable or method `non_existent_state_variable'", e.message
      end
    end

    test '#title calls translate! to return the title when not using outcome templates' do
      options = { use_outcome_templates: false }
      outcome = Outcome.new('outcome-name', options)
      presenter = OutcomePresenter.new('i18n-prefix', outcome)

      presenter.stubs(:translate!).with('title').returns('outcome-presenter-title')
      assert_equal 'outcome-presenter-title', presenter.title
    end

    private

    def with_erb_template_file(suffix, erb_template)
      Tempfile.open(["template_", "_#{suffix}.txt.erb"]) do |erb_template_file|
        erb_template_file.write(erb_template)
        erb_template_file.rewind

        options = {
          :erb_template_directory => Pathname.new(File.dirname(erb_template_file.path)),
          :"#{suffix}_erb_template_name" => File.basename(erb_template_file.path)
        }

        yield options
      end
    end
  end
end
