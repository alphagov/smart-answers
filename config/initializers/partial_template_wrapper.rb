module PartialTemplateWrapper
  include ActionView::Helpers::TagHelper

  def render(context, options, block)
    result = super
    identifier = @template ? @template.identifier : @path
    template_path = Pathname.new(identifier).relative_path_from(Rails.root).to_s
    if result.blank? || template_path.start_with?('app/views/smart_answers')
      result
    else
      content_tag(:div, "\n" + result, {
        class: 'debug partial-template',
        markdown: 1,
        data: { path: template_path }
      })
    end
  end
end

ActionView::PartialRenderer.prepend(PartialTemplateWrapper)
