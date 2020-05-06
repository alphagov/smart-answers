require_relative "../test_helper"

module SmartAnswer
  class FormatCaptureHelperTest < ActiveSupport::TestCase
    def assert_captured_content(content, format, expected)
      options = format.present? ? { format: format } : {}
      args = [:name, expected, options]

      @test_obj.expects(:content_for).with(*args)

      @test_obj.render_content_for(:name, options) { content }
    end

    context "actionview class is extended by helper" do
      setup do
        mock_actionview_class = Class.new do
          def content_for(_name, content, _options, &_block)
            content
          end

          def capture(&block)
            block.call
          end

          def render(component, &block)
            if component == "govuk_publishing_components/components/govspeak"
              "<govspeak>#{block.call}</govspeak>"
            else
              block.call
            end
          end
        end

        @test_obj = mock_actionview_class.new
        @test_obj.extend(SmartAnswer::ErbRenderer::FormatCaptureHelper)
      end

      should "pass all arguments to content_for" do
        @test_obj.expects(:content_for).with(:title, "contents", { option: :option })

        @test_obj.render_content_for(:title, { option: :option }) { "contents" }
      end

      should "render govspeak by default" do
        assert_captured_content("content", nil, "<govspeak><p>content</p></govspeak>")
      end

      should "render plain text when format set" do
        assert_captured_content("content", :text, "content")
      end

      should "render html when format set" do
        assert_captured_content("<p>content</p>", :html, "<p>content</p>")
      end

      should "does not modify content when unknown format set" do
        assert_raises SmartAnswer::ErbRenderer::FormatCaptureHelper::InvalidFormatType do
          @test_obj.render_content_for(:title, { format: :invalid }) { "contents" }
        end
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
        assert_captured_content("  content", :govspeak, "<govspeak><p>content</p></govspeak>")
      end

      should "remove extra trailing newlines from govspeak" do
        assert_captured_content("content\n\n\n\n", :govspeak, "<govspeak><p>content</p>\n</govspeak>")
      end

      should "not wrap empty content with govspeak html tags" do
        assert_captured_content("", :govspeak, "")
      end
    end
  end
end
