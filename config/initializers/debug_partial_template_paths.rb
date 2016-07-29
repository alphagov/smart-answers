if Rails.env.production?
  SmartAnswers::Application.config.debug_partials = ENV['ENABLE_DEBUG_PARTIAL_TEMPLATE_PATHS'].present?
else
  SmartAnswers::Application.config.debug_partials = true
end

if SmartAnswers::Application.config.debug_partials
  wrapper = PartialTemplateWrapper.new
  partial_renderer = PartialTemplateRenderInterceptor[wrapper]
  ActionView::PartialRenderer.prepend(partial_renderer)
end
