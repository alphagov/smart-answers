class QuestionPresenter < NodePresenter
  extend Forwardable
  delegate [
    :translate!,
    :translate_and_render,
    :translate_option,
    :value_for_interpolation,
    :number_with_delimiter
  ] => :@renderer

  def initialize(i18n_prefix, node, state = nil, options = {})
    super(i18n_prefix, node, state)
    @renderer = options[:renderer] || SmartAnswer::I18nRenderer.new(
      i18n_prefix: @i18n_prefix,
      node: @node,
      state: @state
    )
  end

  def title
    translate!('title') || @node.name.to_s.humanize
  end

  def error
    if @state.error.present?
      translate!(@state.error.to_sym) || error_message || I18n.translate('flow.defaults.error_message')
    end
  end

  def error_message
    translate!('error_message')
  end

  def hint
    translate!('hint')
  end

  def has_hint?
    !!hint
  end

  def label
    translate!('label')
  end

  def has_label?
    !!label
  end

  def suffix_label
    translate!('suffix_label')
  end

  def has_suffix_label?
    !!suffix_label
  end

  def has_labels?
    !!label or !!suffix_label
  end

  def body(html: true)
    translate_and_render('body', html: html)
  end

  def post_body
    nil
  end

  def options
    @node.options.map do |option|
      OpenStruct.new(label: translate_option(option), value: option)
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
