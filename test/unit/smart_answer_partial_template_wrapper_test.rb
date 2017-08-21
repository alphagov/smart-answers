require "test_helper"

class SmartAnswerPartialTemplateWrapperTest < ActionView::TestCase
  context "#render" do
    setup do
      @sample_renderer = SampleRenderer.new
      @context = SmartAnswersController.new
      @context.request = ActionDispatch::TestRequest.create
    end

    context "without wrapping div" do
      setup do
        @path = "/root/path/to/partial.html"
        @sample_renderer.template = OpenStruct.new(identifier: @path)
      end

      should "return partial html content" do
        assert_equal "<h1>Hello</h1>", @sample_renderer.render(@context, {}, nil)
      end

      should "return partial govspeak content when partial isn't under smart answer path" do
        TestRenderer.any_instance.stubs(:render).returns("## Hello")

        assert_equal "## Hello", @sample_renderer.render(@context, {}, nil)
      end

      should "return partial govspeak content when request format isn't html" do
        path = "/root/lib/smart_answer_flows/m/partial.govspeak.erb"
        @sample_renderer.template = OpenStruct.new(identifier: path)
        TestRenderer.any_instance.stubs(:render).returns("## Hello")
        Mime::Type.any_instance.stubs(:symbol).returns(:text)

        assert_equal "## Hello", @sample_renderer.render(@context, {}, nil)
      end
    end

    context "with wrapping div" do
      setup do
        @path = "/root/lib/smart_answer_flows/m/partial.govspeak.erb"
        @sample_renderer.template = OpenStruct.new(identifier: @path)
      end

      should "return partial content when request is html and under smart answer path" do
        assert_match(
          /^<div data-debug-template-path=\".*#{@path}\"><h1>Hello<\/h1><\/div>/,
          @sample_renderer.render(@context, {}, nil)
        )
      end

      should "return html content for partials containing govspeak" do
        TestRenderer.any_instance.stubs(:render).returns("## Hello")

        assert_match(
          /^<div data-debug-template-path=\".*#{@path}\"><h2 id=\"hello\">Hello<\/h2><\/div>/,
          @sample_renderer.render(@context, {}, nil)
        )
      end
    end
  end
end

class TestRenderer
  attr_accessor :template

  def render(*)
    "<h1>Hello</h1>"
  end
end

class SampleRenderer < TestRenderer
  include SmartAnswerPartialTemplateWrapper
end
