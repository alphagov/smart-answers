module SmartAnswer
  module ErbRenderer::FormatCaptureHelper
    class InvalidFormatType < RuntimeError; end

    DEFAULT_FORMATS = {
      govspeak: [/^body$/, /^post_body$/, /^next_steps$/],
      text: [/^title$/, /^meta_description$/, /^hint$/, /^label$/, /^suffix_label$/, /^error_*./],
    }.freeze

    def render_content_for(name, options = {}, &block)
      format = options.fetch(:format, default_format(name))

      case format
      when :govspeak
        govspeak_for(name, &block)
      when :html
        html_for(name, &block)
      when :text
        text_for(name, &block)
      else
        raise InvalidFormatType
      end
    end

    def text_for(name, &block)
      content = capture_content(&block)
      content = strip_leading_spaces(content)
      content = normalize_blank_lines(content)
      content_for(name, content.strip)
    end

    def govspeak_for(name, &block)
      content_for(name, render_govspeak(capture_content(&block)))
    end

    def html_for(name, &block)
      content_for(name, capture_content(&block).html_safe)
    end

  private

    def capture_content(&block)
      raise "Expected a block" unless block

      capture(&block) || ""
    end

    def default_format(name)
      DEFAULT_FORMATS.each do |format, patterns|
        return format if patterns.any? { |pattern| pattern.match?(name) }
      end

      :govspeak
    end

    def render_govspeak(content)
      content = strip_leading_spaces(content)
      content = Govspeak::Document.new(content, sanitize: false).to_html

      if content.present?
        render("govuk_publishing_components/components/govspeak") { content.html_safe }
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
