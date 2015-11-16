module SmartAnswer
  class ErbRenderer
    def initialize(template_directory:, template_name:, locals: {}, helpers: [])
      @template_directory = template_directory
      @template_name = template_name
      @locals = locals
      @view = ActionView::Base.new([@template_directory])
      helpers.each { |helper| @view.extend(helper) }
    end

    def content_for(key, html: true)
      content = rendered_view.content_for(key) || ''
      content = strip_leading_spaces(content.to_str)
      html ? GovspeakPresenter.new(content).html : normalize_blank_lines(content).html_safe
    end

    def erb_template_path
      @template_directory.join(erb_template_name)
    end

    private

    def erb_template_name
      "#{@template_name}.govspeak.erb"
    end

    def rendered_view
      @rendered_view ||= @view.tap do |view|
        view.render(template: erb_template_name, locals: @locals)
      end
    end

    def strip_leading_spaces(string)
      string.gsub(/^ +/, '')
    end

    def normalize_blank_lines(string)
      string.gsub(/(\n$){2,}/m, "\n")
    end
  end
end
