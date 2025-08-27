require_relative "../test_helper"

module SmartAnswer
  class ErbRendererTest < ActiveSupport::TestCase
    test "can render a template" do
      erb_template = %{<%= text_for(:key) { "content" } %>}
      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(
          template_directory: erb_template_directory,
          template_name: "template-name",
        )
        assert_match("content", renderer.content_for(:key))
      end
    end

    test "can render a template with a .govspeak name" do
      erb_template = %{<%= text_for(:key) { "content" } %>}
      with_erb_template_file("template-name.govspeak", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(
          template_directory: erb_template_directory,
          template_name: "template-name",
        )
        assert_match("content", renderer.content_for(:key))
      end
    end

    test "#content_for raises an exception when the erb template doesn't exist" do
      renderer = ErbRenderer.new(template_directory: Pathname.new("/path/to/non-existent"), template_name: "template-name")

      assert_raise(ActionView::MissingTemplate) do
        renderer.content_for(:key)
      end
    end

    test "#content_for makes local variables available to the ERB template" do
      erb_template = %{<%= text_for(:key) { %><%= state_variable %> <% } %>}
      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: "template-name", locals: { state_variable: "state-variable" })

        assert_match "state-variable", renderer.content_for(:key)
      end
    end

    test "#content_for raises an exception if the ERB template references a non-existent state variable" do
      erb_template = %{<%= text_for(:key) { %><%= non_existent_state_variable %> <% } %>}
      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: "template-name", locals: {})

        e = assert_raises(ActionView::Template::Error) do
          renderer.content_for(:key)
        end
        assert_match "undefined local variable or method 'non_existent_state_variable'", e.message
      end
    end

    test "#content_for returns an empty string when content is missing" do
      erb_template = ""

      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: "template-name")

        assert_equal renderer.content_for(:key), ""
      end
    end

    test "#hide_caption returns true if set as true in the view" do
      erb_template = "<% hide_caption true %>"

      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: "template-name")

        assert renderer.hide_caption
      end
    end

    test "#hide_caption returns false if set as false in the view" do
      erb_template = "<% hide_caption false %>"

      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: "template-name")

        assert_not renderer.hide_caption
      end
    end

    test "#hide_caption returns false if not set in the view" do
      erb_template = ""

      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: "template-name")

        assert_not renderer.hide_caption
      end
    end

    test "#option returns then option for specified key" do
      erb_template = "<% options(option_one: 'option-one-text', option_two: { label: 'option-two-text', hint_text: 'option-two-hint-text'}) %>"

      with_erb_template_file("template-name", erb_template) do |erb_template_directory|
        renderer = ErbRenderer.new(template_directory: erb_template_directory, template_name: "template-name")

        assert_equal "option-one-text", renderer.option(:option_one)
        assert_equal({ "label" => "option-two-text", "hint_text" => "option-two-hint-text" }, renderer.option(:option_two))
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
