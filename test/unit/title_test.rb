require "test_helper"

module SmartAnswer
  class TitleTest < ActiveSupport::TestCase
    context "#wrapped_with_debug_div?" do
      should "return true if content is wrapped with debug div" do
        html = "<div data-debug-partial-template-path=\"/path\"><p>Hello</p></div>"

        assert Title.new(html).wrapped_with_debug_div?
      end

      should "return false if content isn't wrapped with debug div" do
        refute Title.new("Hello").wrapped_with_debug_div?
      end
    end

    context "#text" do
      should "return text if content is wrapped with debug div" do
        html = "<div data-debug-partial-template-path=\"/path\"><p>Hello</p></div>"

        assert_equal "Hello", Title.new(html).text
      end

      should "return unchanged content if content isn't wrapped with debug div" do
        assert_equal "Hello", Title.new("Hello").text
      end
    end

    context "#partial_template_path" do
      should "return path to partial template if content is wrapped with debug div" do
        html = "<div data-debug-partial-template-path=\"/path\"><p>Hello</p></div>"

        assert_equal "/path", Title.new(html).partial_template_path
      end

      should "return nil if content isn't wrapped with debug div" do
        assert_nil Title.new("Hello").partial_template_path
      end
    end
  end
end
