class NodePresenter
  include ActionView::Helpers::NumberHelper

  def initialize(i18n_prefix, node, state = nil)
    @i18n_prefix = i18n_prefix
    @node = node
    @state = state || SmartAnswer::State.new(nil)
  end

  def translate!(subkey)
    I18n.translate!("#{@i18n_prefix}.#{@node.name}.#{subkey}", state_for_interpolation)
  rescue I18n::MissingTranslationData
    nil
  end

  def translate_and_render(subkey)
    markup = translate!(subkey)
    markup && Govspeak::Document.new(markup).to_html.html_safe
  end

  def state_for_interpolation
    Hash[@state.to_hash.map { |k,v| [k, value_for_interpolation(v)] }]
  end

  def value_for_interpolation(value)
    case value
    when Date then I18n.localize(value, format: :long)
    when ::SmartAnswer::Money then
      number_to_currency(value, precision: 0)
    when ::SmartAnswer::Salary then
      number_to_currency(value.amount, precision: 0) + " per " + value.period
    else value
    end
  end

  def to_response(input)
    @node.to_response(input)
  end

  def subtitle
    translate!('subtitle')
  end

  def has_subtitle?
    !! subtitle
  end

  def title
    translate!('title') || @node.name.to_s.humanize
  end

  def error_message
    translate!('error_message')
  end

  def has_error_message?
    !! error_message
  end

  def body
    translate_and_render('body')
  end

  def has_body?
    !!body
  end

  def hint
    translate!('hint')
  end

  def has_hint?
    !! hint
  end

  def next_steps
    translate_and_render('next_steps')
  end

  def has_next_steps?
    !! next_steps
  end

  def options
    @node.options.map do |option|
      label =
        translate!("options.#{option}") ||
        begin
          I18n.translate!("#{@i18n_prefix}.options.#{option}", @state.to_hash)
        rescue I18n::MissingTranslationData
          option
        end
      OpenStruct.new(label: label, value: option)
    end
  end

  def method_missing(method, *args)
    if @node.respond_to?(method)
      @node.send(method, *args)
    else
      super
    end
  end

  def respond_to_missing?(method, include_private)
    @node.respond_to?(method, include_private)
  end
end
