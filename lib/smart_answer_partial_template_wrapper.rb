module SmartAnswerPartialTemplateWrapper
  include ActionView::Helpers::TagHelper

  def render(context, options, block)
    content = super(context, options, block)
    return content unless valid_path_and_format?(context)

    content_tag(
      :div,
      govspeak_to_html(content),
      data: { debug_template_path: smart_answer_partial_path }
    )
  end

private

  def valid_path_and_format?(context)
    smart_answer_partial_path? && html_format?(context)
  end

  def html_format?(context)
    context.request&.format&.symbol.to_s == "html"
  end

  def govspeak_to_html(content)
    Govspeak::Document.new(remove_leading_spaces(content))
      .to_html
      .strip
      .html_safe
  end

  def remove_leading_spaces(content)
    content.to_str.gsub(/^ +/, "")
  end

  def smart_answer_partial_path?
    under_smart_answer_flow_directory? &&
      template_identifier_file_name.include?("govspeak.erb")
  end

  def template_identifier_path
    @template_identifier_path ||= @template ? @template.identifier : @path
  end

  def template_identifier_path_name
    @template_identifier_path_name ||= Pathname.new(template_identifier_path)
  end

  def smart_answer_partial_path
    @smart_answer_partial_path ||= template_identifier_path_name
      .relative_path_from(Rails.root)
      .to_s
  end

  def template_identifier_file_name
    @template_identifier_file_name ||= template_identifier_path_name
      .basename
      .to_s
  end

  def under_smart_answer_flow_directory?
    template_identifier_path.present? &&
      template_identifier_path.include?("lib/smart_answer_flows")
  end
end
