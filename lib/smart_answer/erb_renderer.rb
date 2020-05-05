module SmartAnswer
  class ErbRenderer
    delegate :content_for, to: :rendered_view

    def initialize(template_directory:, template_name:, locals: {}, helpers: [])
      @template_directory = template_directory
      @template_name = template_name
      @locals = locals
      default_view_paths = ActionController::Base.view_paths.paths.map(&:to_s)
      lookup_context = ActionView::LookupContext.new(
        [@template_directory, FlowRegistry.instance.load_path] + default_view_paths,
      )
      @view = ActionView::Base.with_empty_template_cache.new(lookup_context)
      helpers.each { |helper| @view.extend(helper) }
      @view.extend(Helpers::QuestionOptionsHelper)
      @view.extend(Helpers::FormatCaptureHelper)
    end

    def option_text(key)
      rendered_view
      @view.options.fetch(key).html_safe
    end

    def erb_template_path
      @template_directory.join(erb_template_name)
    end

    def relative_erb_template_path
      erb_template_path.relative_path_from(Rails.root).to_s
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
  end
end
