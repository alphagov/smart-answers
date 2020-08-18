module SessionAnswersHelper
  def items_for_error_summary(form)
    form.errors.each_with_object([]) do |(attr, message), array|
      array << { text: message, href: "##{attr}" }
    end
  end

  def form_for_node
    form_with path: session_flow_path(flow_name, node_name), method: :put, local: true do
      yield
    end
  end

  def govuk_radio_for_node(form)
    render(
      "govuk_publishing_components/components/radio",
      heading: tag.h1(content_for(:title), class: "govuk-fieldset__heading"),
      heading_size: "xl",
      hint: tag.span(content_for(:hint), class: "govuk-caption-l"),
      name: "#{form.node_name}[]",
      items: form.radio_options,
      error_message: error_summary(form, form.node_name),
      id: form.node_name,
    )
  end

  def govuk_checkbox_for_node(form)
    render(
      "govuk_publishing_components/components/checkboxes",
      heading: tag.h1(content_for(:title), class: "govuk-fieldset__heading"),
      heading_size: "xl",
      hint_text: tag.span(content_for(:hint), class: "govuk-caption-l"),
      name: "#{node_name}[]",
      items: form.checkbox_options,
      error: error_summary(form, node_name),
      id: node_name,
    )
  end

  def error_summary(form, attribute)
    messages = form.errors[attribute]
    return if messages.empty?

    messages.to_sentence
  end

  def continue_button
    render "govuk_publishing_components/components/button", text: "Continue"
  end
end
