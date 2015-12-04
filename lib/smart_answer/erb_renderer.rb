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

    def initialize(action_view:, template_name:, locals: {})
      @template_name = template_name
      @locals = locals
      @captures = ActionView::OutputFlow.new
      action_view.view_flow = @captures
      action_view.render(template: erb_template_name, locals: @locals)
      @options = action_view.options
    end

    def single_line_of_content_for(key)
      content_for(key, html: false).chomp.html_safe
    end

    def content_for(key, html: true)
      content = @captures.get(key) || ''
      content = strip_leading_spaces(content.to_str)
      html ? GovspeakPresenter.new(content).html : normalize_blank_lines(content).html_safe
    end

    def option_text(key)
      @options.fetch(key).html_safe
    end

    private

    def erb_template_name
      "#{@template_name}.govspeak.erb"
    end

    def strip_leading_spaces(string)
      string.gsub(/^ +/, '')
    end

    def normalize_blank_lines(string)
      string.gsub(/(\n$){2,}/m, "\n")
    end
  end
end
