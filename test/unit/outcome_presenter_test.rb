require_relative '../test_helper'

module SmartAnswer
  class OutcomePresenterTest < ActiveSupport::TestCase
    test '#default_body_erb_template_path returns the default erb template path built using both the flow and outcome node name' do
      options = { flow_name: 'flow-name' }
      outcome = Outcome.new('outcome-name', options)
      presenter = OutcomePresenter.new('i18n-prefix', outcome)

      expected_path = Rails.root.join('lib', 'smart_answer_flows', 'flow-name', 'outcome-name_body.txt.erb')
      assert_equal expected_path, presenter.default_body_erb_template_path
    end

    test '#body_erb_template_path returns the default erb template path if not overridden in the options' do
      outcome = Outcome.new('outcome-name')
      presenter = OutcomePresenter.new('i18n-prefix', outcome)
      presenter.stubs(default_body_erb_template_path: 'default-erb-template-path')

      assert_equal 'default-erb-template-path', presenter.body_erb_template_path
    end

    test '#body_erb_template_path returns the erb template path supplied in the options' do
      outcome = Outcome.new('outcome-name')

      state = nil
      options = {body_erb_template_path: 'erb-template-path'}
      presenter = OutcomePresenter.new('i18n-prefix', outcome, state, options)

      assert_equal 'erb-template-path', presenter.body_erb_template_path
    end

    test '#body_erb_template_from_file returns the content of the erb template' do
      with_erb_template_file('erb-template') do |erb_template_file|
        outcome = Outcome.new('outcome-name')

        state = nil
        options = { body_erb_template_path: erb_template_file.path }
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, options)

        assert_equal 'erb-template', presenter.body_erb_template_from_file
      end
    end

    test "#body returns nil when the erb template doesn't exist" do
      options = { use_outcome_templates: true }
      outcome = Outcome.new('outcome-name', options)

      state = nil
      options = { body_erb_template_path: '/path/to/non-existent/template.erb' }
      presenter = OutcomePresenter.new('i18n-prefix', outcome, state, options)

      assert_equal nil, presenter.body
    end

    test '#body uses GovspeakPresenter to generate the html' do
      erb_template = '# level-1-heading'

      with_erb_template_file(erb_template) do |erb_template_file|
        options = { use_outcome_templates: true }
        outcome = Outcome.new('outcome-name', options)

        state = nil
        options = { body_erb_template_path: erb_template_file.path }
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, options)

        govspeak_presenter = stub(html: 'govspeak-output')
        GovspeakPresenter.stubs(:new).with(erb_template).returns(govspeak_presenter)

        assert_equal 'govspeak-output', presenter.body
      end
    end

    test "#body doesn't trim any newlines by default" do
      erb_template = '<% if true %>
Hello world
<% end %>
'

      with_erb_template_file(erb_template) do |erb_template_file|
        options = { use_outcome_templates: true }
        outcome = Outcome.new('outcome-name', options)

        state = nil
        options = { body_erb_template_path: erb_template_file.path }
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, options)

        assert_equal "\n<p>Hello world</p>\n\n", presenter.body
      end
    end

    test "#body allows newlines to be trimmed by using -%>" do
      erb_template = '<% if true -%>
Hello world
<% end -%>
'

      with_erb_template_file(erb_template) do |erb_template_file|
        options = { use_outcome_templates: true }
        outcome = Outcome.new('outcome-name', options)

        state = nil
        options = { body_erb_template_path: erb_template_file.path }
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, options)

        assert_equal "<p>Hello world</p>\n", presenter.body
      end
    end

    test '#body makes the state variables available to the ERB template' do
      erb_template = '<%= method_on_state_object %>'

      with_erb_template_file(erb_template) do |erb_template_file|
        options = { use_outcome_templates: true }
        outcome = Outcome.new('outcome-name', options)

        state = stub(method_on_state_object: 'method-on-state-object')
        options = { body_erb_template_path: erb_template_file.path }
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, options)

        assert_match 'method-on-state-object', presenter.body
      end
    end

    test '#body makes the ActionView::Helpers::NumberHelper methods available to the ERB template' do
      erb_template = '<%= number_with_delimiter(123456789) %>'

      with_erb_template_file(erb_template) do |erb_template_file|
        options = { use_outcome_templates: true }
        outcome = Outcome.new('outcome-name', options)

        state = nil
        options = { body_erb_template_path: erb_template_file.path }
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, options)

        assert_match '123,456,789', presenter.body
      end
    end

    test '#body delegates to NodePresenter when not using outcome templates' do
      options = { use_outcome_templates: false }
      outcome = Outcome.new('outcome-name', options)
      presenter = OutcomePresenter.new('i18n-prefix', outcome)

      presenter.stubs(:translate_and_render).with('body').returns('node-presenter-body')
      assert_equal 'node-presenter-body', presenter.body
    end

    test '#default_title_erb_template_path returns the default erb template path built using both the flow and outcome node name' do
      options = { flow_name: 'flow-name' }
      outcome = Outcome.new('outcome-name', options)
      presenter = OutcomePresenter.new('i18n-prefix', outcome)

      expected_path = Rails.root.join('lib', 'smart_answer_flows', 'flow-name', 'outcome-name_title.txt.erb')
      assert_equal expected_path, presenter.default_title_erb_template_path
    end

    test '#title_erb_template_path returns the default erb template path if not overridden in the options' do
      outcome = Outcome.new('outcome-name')
      presenter = OutcomePresenter.new('i18n-prefix', outcome)
      presenter.stubs(default_title_erb_template_path: 'default-title-erb-template-path')

      assert_equal 'default-title-erb-template-path', presenter.title_erb_template_path
    end

    test '#title_erb_template_path returns the erb template path supplied in the options' do
      outcome = Outcome.new('outcome-name')

      state = nil
      options = { title_erb_template_path: 'erb-template-path' }
      presenter = OutcomePresenter.new('i18n-prefix', outcome, state, options)

      assert_equal 'erb-template-path', presenter.title_erb_template_path
    end

    test '#title_erb_template_from_file returns the content of the erb template' do
      with_erb_template_file('erb-template') do |erb_template_file|
        outcome = Outcome.new('outcome-name')

        state = nil
        options = { title_erb_template_path: erb_template_file.path }
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, options)

        assert_equal 'erb-template', presenter.title_erb_template_from_file
      end
    end

    test "#title returns nil when the erb template doesn't exist" do
      options = { use_outcome_templates: true }
      outcome = Outcome.new('outcome-name', options)

      state = nil
      options = { title_erb_template_path: '/path/to/non-existent/template.erb' }
      presenter = OutcomePresenter.new('i18n-prefix', outcome, state, options)

      assert_equal nil, presenter.title
    end

    test '#title trims a single newline from the end of the string' do
      erb_template = "title-text\n"

      with_erb_template_file(erb_template) do |erb_template_file|
        options = { use_outcome_templates: true }
        outcome = Outcome.new('outcome-name', options)

        state = nil
        options = { title_erb_template_path: erb_template_file.path }
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, options)

        assert_equal "title-text", presenter.title
      end
    end

    test "#title only trims a single newline by default" do
      erb_template = '<% if true %>
Hello world
<% end %>
'

      with_erb_template_file(erb_template) do |erb_template_file|
        options = { use_outcome_templates: true }
        outcome = Outcome.new('outcome-name', options)

        state = nil
        options = { title_erb_template_path: erb_template_file.path }
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, options)

        assert_equal "\nHello world\n", presenter.title
      end
    end

    test "#title allows newlines to be trimmed by using -%>" do
      erb_template = '<% if true -%>
Hello world
<% end -%>
'

      with_erb_template_file(erb_template) do |erb_template_file|
        options = { use_outcome_templates: true }
        outcome = Outcome.new('outcome-name', options)

        state = nil
        options = { title_erb_template_path: erb_template_file.path }
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, options)

        assert_equal "Hello world", presenter.title
      end
    end

    test '#title makes the state variables available to the ERB template' do
      erb_template = '<%= method_on_state_object %>'

      with_erb_template_file(erb_template) do |erb_template_file|
        options = { use_outcome_templates: true }
        outcome = Outcome.new('outcome-name', options)

        state = stub(method_on_state_object: 'method-on-state-object')
        options = { title_erb_template_path: erb_template_file.path }
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state, options)

        assert_match 'method-on-state-object', presenter.title
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

    def with_erb_template_file(erb_template)
      begin
        erb_template_file = Tempfile.new('template.txt.erb')
        erb_template_file.write(erb_template)
        erb_template_file.rewind

        yield erb_template_file
      ensure
        erb_template_file.unlink
        erb_template_file.close
      end
    end
  end
end
