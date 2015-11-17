class QuestionPresenter < NodePresenter
  extend Forwardable
  delegate [
    :translate!,
    :translate_and_render,
    :translate_option
  ] => :@renderer

  delegate :use_erb_template? => :@node

  def initialize(i18n_prefix, node, state = nil, options = {})
    super(i18n_prefix, node, state)
    @renderer = options[:renderer]
    helpers = options[:helpers] || []
    if use_erb_template?
      @renderer ||=  SmartAnswer::ErbRenderer.new(
        template_directory: @node.template_directory.join('questions'),
        template_name: @node.filesystem_friendly_name,
        locals: @state.to_hash,
        helpers: helpers
      )
    else
      @renderer ||= SmartAnswer::I18nRenderer.new(
        i18n_prefix: @i18n_prefix,
        node: @node,
        state: @state
      )
    end
  end

  def title
    if use_erb_template?
      @renderer.single_line_of_content_for(:title)
    else
      translate!('title', rescue_exception: false)
    end
  end

  def error
    if @state.error.present?
      error_message_for(@state.error) || error_message_for('error_message') || I18n.translate('flow.defaults.error_message')
    end
  end

  def error_message_for(key)
    if use_erb_template?
      message = @renderer.single_line_of_content_for(key.to_sym)
      message.blank? ? nil : message
    else
      translate!(key)
    end
  end

  def hint
    if use_erb_template?
      @renderer.single_line_of_content_for(:hint)
    else
      translate!('hint')
    end
  end

  def label
    if use_erb_template?
      @renderer.single_line_of_content_for(:label)
    else
      translate!('label')
    end
  end

  def suffix_label
    if use_erb_template?
      @renderer.single_line_of_content_for(:suffix_label)
    else
      translate!('suffix_label')
    end
  end

  def has_labels?
    label.present? || suffix_label.present?
  end

  def body(html: true)
    if use_erb_template?
      @renderer.content_for(:body, html: html)
    else
      translate_and_render('body', html: html)
    end
  end

  def post_body
    if use_erb_template?
      @renderer.content_for(:post_body, html: true)
    else
      translate_and_render('post_body', html: true)
    end
  end

  def options
    @node.options.map do |option|
      OpenStruct.new(label: render_option(option), value: option)
    end
  end

  def render_option(key)
    if use_erb_template?
      @renderer.option_text(key.to_sym)
    else
      translate_option(key)
    end
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
