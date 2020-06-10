require_relative "../test_helper"

module SmartAnswer
  class ErbRendererTest < ActiveSupport::TestCase
    test "can render a template" do
      erb_template = render_content_for(:key, "content")
      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(
          template_directory: erb_template_directory,
          template_name: "template-name",
        )
        assert_match("content", renderer.content_for(:key))
      end
    end

    test "can render a template with a .govspeak name" do
      erb_template = render_content_for(:key, "content")
      with_erb_template_file("template-name.govspeak", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(
          template_directory: erb_template_directory,
          template_name: "template-name",
        )
        assert_match("content", renderer.content_for(:key))
      end
    end

    test "#relative_erb_template_path returns a template path relative to Rails.root" do
      with_erb_template_file("template-name", "") do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: "template-name")
        Rails.stubs(:root).returns(erb_template_directory)
        assert_equal "template-name.erb", renderer.relative_erb_template_path
      end
    end

    test "#content_for raises an exception when the erb template doesn't exist" do
      renderer = ErbRenderer.new(template_directory: Pathname.new("/path/to/non-existent"), template_name: "template-name")

      assert_raise(ActionView::MissingTemplate) do
        renderer.content_for(:key)
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

    test "#content_for returns an empty string when content is missing" do
      erb_template = ""

      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: "template-name")

        assert_equal renderer.content_for(:key), ""
      end
    end

    test "#option returns then option for specified key" do
      erb_template = "<% options(option_one: 'option-one-text', option_two: { label: 'option-two-text', hint_text: 'option-two-hint-text'}) %>"

      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: "template-name")

        assert_equal "option-one-text", renderer.option(:option_one)
        assert_equal({ label: "option-two-text", hint_text: "option-two-hint-text" }, renderer.option(:option_two))
      end
    end

    test "#option raises KeyError if option key does not exist" do
      erb_template = "<% options(option_one: 'option-one-text', option_two: 'option-two-text') %>"

      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: "template-name")

        assert_raises(KeyError) do
          renderer.option(:option_three)
        end
      end
    end

    test "#option raises KeyError if no options defined in template" do
      erb_template = ""

      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: "template-name")

        assert_raises(KeyError) do
          renderer.option(:option_key)
        end
      end
    end

  private

    def render_content_for(key, template)
      "<% render_content_for #{key.inspect} do %>\n#{template}\n<% end %>"
    end

    def with_erb_template_file(outcome_name, erb_template)
      erb_template_filename = "#{outcome_name}.erb"
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
