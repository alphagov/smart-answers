wrapper = PartialTemplateWrapper.new
partial_renderer = PartialTemplateRenderInterceptor[wrapper]
ActionView::PartialRenderer.prepend(partial_renderer)
