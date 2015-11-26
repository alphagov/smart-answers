class QuestionPresenter < NodePresenter
  extend Forwardable
  delegate [
    :translate!,
    :translate_and_render,
    :translate_option
  ] => :@renderer

  def use_erb_template?
    true
  end

  def initialize(i18n_prefix, node, state = nil, options = {})
    super(i18n_prefix, node, state)
    @renderer = options[:renderer]
    helpers = options[:helpers] || []
    @renderer ||= SmartAnswer::ErbRenderer.new(
      template_directory: @node.template_directory.join('questions'),
      template_name: @node.filesystem_friendly_name,
      locals: @state.to_hash,
      helpers: [SmartAnswer::FormattingHelper] + helpers
    )
  end

  def title
    @renderer.single_line_of_content_for(:title)
  end

  def error
    if @state.error.present?
      error_message_for(@state.error) || error_message_for('error_message') || I18n.translate('flow.defaults.error_message')
    end
  end

  def error_message_for(key)
    message = @renderer.single_line_of_content_for(key.to_sym)
    message.blank? ? nil : message
  end

  def hint
    @renderer.single_line_of_content_for(:hint)
  end

  def label
    @renderer.single_line_of_content_for(:label)
  end

  def suffix_label
    @renderer.single_line_of_content_for(:suffix_label)
  end

  def has_labels?
    label.present? || suffix_label.present?
  end

  def body(html: true)
    @renderer.content_for(:body, html: html)
  end

  def post_body
    @renderer.content_for(:post_body, html: true)
  end

  def options
    @node.options.map do |option|
      OpenStruct.new(label: render_option(option), value: option)
    end
  end

  def render_option(key)
    @renderer.option_text(key.to_sym)
  end

  def to_response(input)
    @node.to_response(input)
  end

  def response_label(value)
    value
  end

  def partial_template_name
    "#{@node.class.name.demodulize.underscore}_question"
  end

  def multiple_responses?
    false
  end
end
