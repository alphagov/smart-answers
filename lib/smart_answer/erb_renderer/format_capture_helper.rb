module SmartAnswer
  module ErbRenderer::FormatCaptureHelper
    DEFAULT_FORMATS = {
      govspeak: [/^body$/, /^post_body$/, /^next_steps$/],
      text: [/^title$/, /^meta_description$/, /^hint$/, /^label$/, /^suffix_label$/, /^error_*./],
    }.freeze

    def content_for(name, content = nil, options = {}, &block)
      if block_given?
        options = content if content
        content = capture(&block)

        format = options.fetch(:format, default_format(name))
        content = render_content(format, content)

        block = nil
      end

      super(name, content, options, &block)
    end

  private

    def default_format(name)
      DEFAULT_FORMATS.each do |format, patterns|
        return format if patterns.any? { |pattern| pattern.match?(name) }
      end

      :govspeak
    end

    def render_content(format, content)
      case format
      when :govspeak
        render_govspeak(content)
      when :html
        render_html(content)
      when :text
        render_text(content)
      else
        content
      end
    end

    def render_govspeak(content)
      content = strip_leading_spaces(content)
      content = Govspeak::Document.new(content, sanitize: false).to_html
      content = content.chomp.html_safe

      content.present? ? render("govuk_publishing_components/components/govspeak") { content } : ""
    end

    def render_html(content)
      content.html_safe
    end

    def render_text(content)
      content = strip_leading_spaces(content)
      normalize_blank_lines(content).strip.html_safe
    end

    def strip_leading_spaces(string)
      string.gsub(/^ +/, "")
    end

    def normalize_blank_lines(string)
      string.gsub(/(\n$){2,}/m, "\n")
    end
  end
end
