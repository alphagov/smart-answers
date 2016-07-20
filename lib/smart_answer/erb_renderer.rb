module SmartAnswer
  class ErbRenderer
    module QuestionOptionsHelper
      def options(options = nil)
        if options
          @options = options
        else
          @options || {}
        end
      end
    end

    def initialize(template_directory:, template_name:, locals: {}, helpers: [])
      @template_directory = template_directory
      @template_name = template_name
      @locals = locals
      @view = ActionView::Base.new([@template_directory, FlowRegistry.instance.load_path])
      helpers.each { |helper| @view.extend(helper) }
      @view.extend(QuestionOptionsHelper)
    end

    def single_line_of_content_for(key)
      result = content_for(key, html: false).chomp.html_safe
      if result.blank? || key == :meta_description
        result
      else
        template_path = erb_template_path.relative_path_from(Rails.root).to_s
        @view.content_tag(:span, result, class: 'debug single-line', data: { path: template_path, key: key })
      end
    end

    def content_for(key, html: true)
      content = rendered_view.content_for(key) || ''
      content = strip_leading_spaces(content.to_str)
      if html
        result = GovspeakPresenter.new(content).html
        if result.blank?
          result
        else
          template_path = erb_template_path.relative_path_from(Rails.root).to_s
          @view.content_tag(:div, result, class: 'debug template', data: { path: template_path, key: key })
        end
      else
        normalize_blank_lines(content).html_safe
      end
    end

    def option_text(key)
      rendered_view
      result = @view.options.fetch(key).html_safe
      template_path = erb_template_path.relative_path_from(Rails.root).to_s
      @view.content_tag(:span, result, class: 'debug option', data: { path: template_path, key: key })
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
