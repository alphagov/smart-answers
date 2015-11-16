require_relative '../test_helper'

module SmartAnswer
  class ErbRendererTest < ActiveSupport::TestCase
    test '#erb_template_path returns the combination of the template directory and name' do
      erb_template = ''
      with_erb_template_file('template-name', erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: 'template-name')

        expected_path = erb_template_directory.join('template-name.govspeak.erb')
        assert_equal expected_path, renderer.erb_template_path
      end
    end

    test "#content_for raises an exception when the erb template doesn't exist" do
      renderer = ErbRenderer.new(template_directory: Pathname.new('/path/to/non-existent'), template_name: 'template-name')

      assert_raise(ActionView::MissingTemplate) do
        renderer.content_for(:key)
      end
    end

    test '#content_for returns a single newline when content_for(key) block is not present in template' do
      erb_template = ''

      with_erb_template_file('template-name', erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: 'template-name')

        assert_equal "\n", renderer.content_for(:does_not_exist)
      end
    end

    test '#content_for returns a single newline when content_for(key) block is empty' do
      erb_template = content_for(:key, '')

      with_erb_template_file('template-name', erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: 'template-name')

        assert_equal "\n", renderer.content_for(:key)
      end
    end

    test "#content_for trims newlines by default" do
      erb_template = content_for(:key, '<% if true %>
Hello world
<% end %>')

      with_erb_template_file('template-name', erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: 'template-name')

        assert_equal "<p>Hello world</p>\n", renderer.content_for(:key)
      end
    end

    test '#content_for strips spaces from the beginning of lines so that we can indent content in our content_for blocks' do
      erb_template = content_for(:key, '  <% if true %>
    line 1

    line 2
  <% end %>')

      with_erb_template_file('template-name', erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: 'template-name')

        assert_equal "line 1\n\nline 2\n", renderer.content_for(:key, html: false)
      end
    end

    test '#content_for ensures there is only one *blank* line between paragraphs' do
      erb_template = content_for(:key, "line1\n\n\n\nline2")

      with_erb_template_file('template-name', erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: 'template-name')

        assert_equal "line1\n\nline2\n", renderer.content_for(:key, html: false)
      end
    end

    test '#content_for makes local variables available to the ERB template' do
      erb_template = content_for(:key, '<%= state_variable %>')

      with_erb_template_file('template-name', erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: 'template-name', locals: { state_variable: 'state-variable' })

        assert_match 'state-variable', renderer.content_for(:key)
      end
    end

    test "#content_for raises an exception if the ERB template references a non-existent state variable" do
      erb_template = content_for(:key, '<%= non_existent_state_variable %>')

      with_erb_template_file('template-name', erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: 'template-name', locals: {})

        e = assert_raises(ActionView::Template::Error) do
          renderer.content_for(:key)
        end
        assert_match "undefined local variable or method `non_existent_state_variable'", e.message
      end
    end

    test '#content_for makes the ActionView::Helpers::NumberHelper methods available to the ERB template' do
      erb_template = content_for(:key, '<%= number_with_delimiter(123456789) %>')

      with_erb_template_file('template-name', erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: 'template-name')

        assert_match '123,456,789', renderer.content_for(:key)
      end
    end

    test '#content_for passes output of ERB template through Govspeak by default' do
      erb_template = content_for(:key, '^information^')

      with_erb_template_file('template-name', erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: 'template-name')

        nodes = Capybara.string(renderer.content_for(:key))
        assert nodes.has_css?(".application-notice", text: "information"), "Does not have information callout"
      end
    end

    test '#content_for does not pass output of ERB template through Govspeak when HTML disabled' do
      erb_template = content_for(:key, '^information^')

      with_erb_template_file('template-name', erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: 'template-name')

        assert_equal "^information^\n", renderer.content_for(:key, html: false)
      end
    end

    test '#content_for returns an HTML-safe string when passed through Govspeak' do
      erb_template = content_for(:key, 'html-unsafe-string')

      with_erb_template_file('template-name', erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: 'template-name')

        assert renderer.content_for(:key).html_safe?
      end
    end

    test '#content_for returns an HTML-safe string when not passed through Govspeak' do
      erb_template = content_for(:key, 'html-unsafe-string')

      with_erb_template_file('template-name', erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: 'template-name')

        assert renderer.content_for(:key, html: false).html_safe?
      end
    end

    test '#content_for returns the same content when called multiple times' do
      erb_template = content_for(:key, 'body-content')

      with_erb_template_file('template-name', erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: 'template-name')

        assert_equal "<p>body-content</p>\n", renderer.content_for(:key)
        assert_equal "<p>body-content</p>\n", renderer.content_for(:key)
      end
    end

    private

    def content_for(key, template)
      "<% content_for #{key.inspect} do %>\n#{template}\n<% end %>"
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
