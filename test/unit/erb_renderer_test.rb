require_relative "../test_helper"

module SmartAnswer
  class ErbRendererTest < ActiveSupport::TestCase
    test "#erb_template_path returns the combination of the template directory and name" do
      erb_template = ""
      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: "template-name")

        expected_path = erb_template_directory.join("template-name.govspeak.erb")
        assert_equal expected_path, renderer.erb_template_path
      end
    end

    test "#relative_erb_template_path returns a relative version of erb_template_path" do
      erb_template = ""
      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: "template-name")

        erb_template_path = stub("erb-template-path")
        relative_erb_template_path = Pathname.new("relative-erb-template-path")
        erb_template_path.stubs(:relative_path_from).returns(relative_erb_template_path)
        renderer.stubs(:erb_template_path).returns(erb_template_path)

        assert_equal relative_erb_template_path.to_s, renderer.relative_erb_template_path
      end
    end

    test "#content_for raises an exception when the erb template doesn't exist" do
      renderer = ErbRenderer.new(template_directory: Pathname.new("/path/to/non-existent"), template_name: "template-name")

      assert_raise(ActionView::MissingTemplate) do
        renderer.content_for(:key)
      end
    end

    test "#content_for trims newlines by default" do
      erb_template = render_content_for(
        :key,
        '<% if true %>
Hello world
<% end %>',
      )

      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: "template-name")

        assert_match(/<p>Hello world<\/p>/, renderer.content_for(:key))
      end
    end

    test "#content_for makes local variables available to the ERB template" do
      erb_template = render_content_for(:key, "<%= state_variable %>")

      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: "template-name", locals: { state_variable: "state-variable" })

        assert_match "state-variable", renderer.content_for(:key)
      end
    end

    test "#content_for raises an exception if the ERB template references a non-existent state variable" do
      erb_template = render_content_for(:key, "<%= non_existent_state_variable %>")

      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: "template-name", locals: {})

        e = assert_raises(ActionView::Template::Error) do
          renderer.content_for(:key)
        end
        assert_match "undefined local variable or method `non_existent_state_variable'", e.message
      end
    end

    test "#content_for makes the ActionView::Helpers::NumberHelper methods available to the ERB template" do
      erb_template = render_content_for(:key, "<%= number_with_delimiter(123456789) %>")

      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: "template-name")

        assert_match "123,456,789", renderer.content_for(:key)
      end
    end

    test "#content_for passes output of ERB template through Govspeak by default" do
      erb_template = render_content_for(:key, "^information^")

      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: "template-name")

        nodes = Capybara.string(renderer.content_for(:key))
        assert nodes.has_css?(".application-notice", text: "information"), "Does not have information callout"
      end
    end

    test "#content_for returns an HTML-safe string when passed through Govspeak" do
      erb_template = render_content_for(:body, "html-unsafe-string")

      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: "template-name")

        assert renderer.content_for(:body).html_safe?
      end
    end

    test "#content_for returns an HTML-safe string" do
      erb_template = render_content_for(:key, "html-unsafe-string")

      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: "template-name")

        assert renderer.content_for(:key).html_safe?
      end
    end

    test "#option_text returns option text for specified key" do
      erb_template = "<% options(option_one: 'option-one-text', option_two: 'option-two-text') %>"

      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: "template-name")

        assert_equal "option-one-text", renderer.option_text(:option_one)
        assert_equal "option-two-text", renderer.option_text(:option_two)
      end
    end

    test "#option_text raises KeyError if option key does not exist" do
      erb_template = "<% options(option_one: 'option-one-text', option_two: 'option-two-text') %>"

      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: "template-name")

        assert_raises(KeyError) do
          renderer.option_text(:option_three)
        end
      end
    end

    test "#option_text raises KeyError if no options defined in template" do
      erb_template = ""

      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: "template-name")

        assert_raises(KeyError) do
          renderer.option_text(:option_key)
        end
      end
    end

    test "#option_text returns an HTML-safe string" do
      erb_template = "<% options(option_one: 'html-unsafe-option-one-text') %>"

      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: "template-name")

        assert renderer.option_text(:option_one).html_safe?
      end
    end

  private

    def render_content_for(key, template)
      "<% render_content_for #{key.inspect} do %>\n#{template}\n<% end %>"
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
