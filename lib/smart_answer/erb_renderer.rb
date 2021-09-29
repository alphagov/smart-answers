module SmartAnswer
  class ErbRenderer
    def initialize(template_directory:, template_name:, locals: {}, helpers: [])
      @template_directory = template_directory
      @template_name = template_name
      @locals = locals
      default_view_paths = ActionController::Base.view_paths.paths.map(&:to_s)
      lookup_context = ActionView::LookupContext.new(
        [@template_directory, FlowRegistry.instance.load_path] + default_view_paths,
      )
      @view = ActionView::Base.with_empty_template_cache.new(lookup_context, {}, {})
      # This is required to continue supporting .govspeak.erb templates
      @view.formats = %i[govspeak html]
      helpers.each { |helper| @view.extend(helper) }
      @view.extend(ErbRenderer::QuestionOptionsHelper)
      @view.extend(ErbRenderer::FormatCaptureHelper)
    end

    delegate :hide_caption, to: :rendered_view

    def option(key)
      rendered_view
      @view.options.with_indifferent_access.fetch(key)
    end

    def content_for(name)
      rendered_view.content_for(name) || ""
    end

  private

    def rendered_view
      @rendered_view ||= @view.tap do |view|
        view.render(template: @template_name, locals: @locals)
      end
    end
  end
end
