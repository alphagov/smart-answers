require_relative "../test_helper"

module MockCaptureHelper
  def content_for(_name, content, _options, &_block)
    content
  end

  def capture(&block)
    block.call
  end

  def render(*_args, &block)
    "<g>" + block.call + "</g>"
  end
end

class MockClass
  include MockCaptureHelper
end

module SmartAnswer
  class FormatCaptureHelperTest < ActiveSupport::TestCase
    def assert_captured_content(content, format, expected)
      options = format.present? ? { format: format } : {}
      args = [:name, expected, options]

      MockClass.any_instance.expects(:content_for).with(*args)

      @test_obj.content_for(:name, options) { content }
    end

    context "class is extended by helper" do
      setup do
        @test_obj = MockClass.new
        @test_obj.extend(SmartAnswer::ErbRenderer::FormatCaptureHelper)
      end

      should "call super with same arguments when no block given" do
        MockClass.any_instance.expects(:content_for).with(:name, "content", { option: :option })

        @test_obj.content_for(:name, "content", { option: :option }, &nil)
      end

      should "call super with contents as options when no content given" do
        MockClass.any_instance.expects(:content_for).with(:name, "", { option: :option })

        @test_obj.content_for(:name, { option: :option }) { "" }
      end

      should "render govspeak by default" do
        assert_captured_content("content", nil, "<g><p>content</p></g>")
      end

      should "render plain text when format set" do
        assert_captured_content("content", :text, "content")
      end

      should "render html when format set" do
        assert_captured_content("<p>content</p>", :html, "<p>content</p>")
      end

      should "does not modify content when unknown format set" do
        assert_captured_content("  content  ", :unknown, "  content  ")
      end

      should "remove leading spaces on content for text" do
        assert_captured_content("  content", :text, "content")
      end

      should "remove more than 2 newlines from text" do
        assert_captured_content("content\n\n\n\nmore content", :text, "content\n\nmore content")
      end

      should "trim newlines from text" do
        assert_captured_content("\n\n\n\ncontent\n\n\n\n", :text, "content")
      end

      should "remove leading spaces from govspeak" do
        assert_captured_content("  content", :govspeak, "<g><p>content</p></g>")
      end

      should "remove extra trailing newlines from govspeak" do
        assert_captured_content("content\n\n\n\n", :govspeak, "<g><p>content</p>\n</g>")
      end

      should "not wrap empty content with govspeak html tags" do
        assert_captured_content("", :govspeak, "")
      end
    end
  end
end
