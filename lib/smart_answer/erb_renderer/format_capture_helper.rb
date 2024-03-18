module SmartAnswer
  module ErbRenderer::FormatCaptureHelper
    TEXT_CONTENT = [
      :title,
      :meta_description,
      :label,
      :suffix_label,
      /^error_/,
    ].freeze

    def text_for(name, &block)
      content = capture_content(&block)
      content = strip_leading_spaces(content)
      content = normalize_blank_lines(content)
      content_for(name, content.strip.html_safe)
    end

    def govspeak_for(name, &block)
      raise ArgumentError, text_only_error_message(name) if text_only?(name)

      content_for(name, render_govspeak(capture_content(&block)))
    end

    def html_for(name, &block)
      raise ArgumentError, text_only_error_message(name) if text_only?(name)

      content_for(name, capture_content(&block).html_safe)
    end

  private

    def capture_content(&block)
      raise "Expected a block" unless block

      capture(&block) || ""
    end

    def default_format(name)
      text_only?(name) ? :text : :govspeak
    end

    def text_only?(name)
      TEXT_CONTENT.any? do |item|
        item.is_a?(Regexp) ? name.match?(item) : name == item
      end
    end

    def text_only_error_message(name)
      "#{name} can only be used to display text. Please use #text_for"
    end

    def render_govspeak(content)
      content = strip_leading_spaces(content)
      content = Govspeak::Document.new(content, sanitize: false).to_html

      if content.present?
        render("govuk_publishing_components/components/govspeak", { disable_ga4: true }) { content.html_safe }
      else
        ""
      end
    end

    def strip_leading_spaces(string)
      string.gsub(/^ +/, "")
    end

    def normalize_blank_lines(string)
      string.gsub(/(\n$){2,}/m, "\n")
    end
  end
end
