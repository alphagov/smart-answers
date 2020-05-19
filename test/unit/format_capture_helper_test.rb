require_relative "../test_helper"

module SmartAnswer
  class FormatCaptureHelperTest < ActiveSupport::TestCase
    setup do
      mock_actionview_class = Class.new do
        def content_for(name, content = nil, _options = {}, &_block)
          @content_for ||= {}
          if content
            @content_for[name] = content
          else
            @content_for[name]
          end
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

    context "#text_for" do
      should "remove leading spaces on content" do
        @test_obj.text_for(:name) { "  content" }
        assert_match @test_obj.content_for(:name), "content"
      end

      should "remove more than 2 newlines from text" do
        @test_obj.text_for(:name) { "content\n\n\n\nmore content" }
        assert_match @test_obj.content_for(:name), "content\n\nmore content"
      end

      should "trim newlines from text" do
        @test_obj.text_for(:name) { "\ncontent\n" }
        assert_match @test_obj.content_for(:name), "content"
      end

      should "not be HTML safe" do
        @test_obj.text_for(:name) { "Text" }
        assert_not @test_obj.content_for(:name).html_safe?
      end
    end

    context "#govspeak_for" do
      should "render govspeak and wrap it in the govspeak component" do
        @test_obj.govspeak_for(:name) { "content" }
        assert_match @test_obj.content_for(:name), "<govspeak><p>content</p>\n</govspeak>"
      end

      should "not wrap empty content in the govspeak component" do
        @test_obj.govspeak_for(:name) { "" }
        assert_match @test_obj.content_for(:name), ""
      end

      should "strip leading spaces" do
        @test_obj.govspeak_for(:name) { "  content" }
        assert_match @test_obj.content_for(:name), "<govspeak><p>content</p>\n</govspeak>"
      end
    end

    context "#html_for" do
      should "not alter the html passed in" do
        @test_obj.html_for(:name) { "<p>content</p>" }
        assert_match @test_obj.content_for(:name), "<p>content</p>"
      end

      should "be set set as HTML safe" do
        @test_obj.html_for(:name) { "<p>content</p>" }
        assert @test_obj.content_for(:name).html_safe?
      end
    end

    context "#render_content_for" do
      should "render govspeak when specified" do
        @test_obj.render_content_for(:name, format: :govspeak) { "content" }
        assert_match @test_obj.content_for(:name), "<govspeak><p>content</p>\n</govspeak>"
      end

      should "render html when specified" do
        @test_obj.render_content_for(:name, format: :html) { "<p>content</p>" }
        assert_equal @test_obj.content_for(:name), "<p>content</p>"
      end

      should "render text when specified" do
        @test_obj.render_content_for(:name, format: :text) { "text" }
        assert_equal @test_obj.content_for(:name), "text"
      end

      should "default to rendering govspeak" do
        @test_obj.render_content_for(:name) { "content" }
        assert_match @test_obj.content_for(:name), "<govspeak><p>content</p>\n</govspeak>"
      end

      should "render text when the field defaults to text" do
        @test_obj.render_content_for(:title) { "content" }
        assert_match @test_obj.content_for(:title), "content"
      end

      should "raise an error when given an unknown format" do
        assert_raises SmartAnswer::ErbRenderer::FormatCaptureHelper::InvalidFormatType do
          @test_obj.render_content_for(:title, { format: :invalid }) { "content" }
        end
      end
    end
  end
end
