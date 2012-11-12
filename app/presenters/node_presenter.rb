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

  def state_for_interpolation( nested = false )
    Hash[@state.to_hash.map { |k,v| [k, value_for_interpolation(v, nested)] }]
  end

  def value_for_interpolation(value, nested = false)
    case value
    when Date then I18n.localize(value, format: :long)
    when ::SmartAnswer::Money then
      number_to_currency(value, precision: ((value.to_f == value.to_f.round) ? 0 : 2 ))
    when ::SmartAnswer::Salary then
      number_to_currency(value.amount, precision: 0) + " per " + value.period
    when ::SmartAnswer::PhraseList then
      if nested == false
        value.phrase_keys.map do |phrase_key|
          I18n.translate!("#{@i18n_prefix}.phrases.#{phrase_key}", state_for_interpolation( true )) rescue phrase_key
        end.join("\n\n")
      else
        false
      end
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

  def has_title?
    !! title
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

  def label
    translate!('label')
  end

  def has_label?
    !! label
  end

  def suffix_label
    translate!('suffix_label')
  end

  def has_suffix_label?
    !! suffix_label
  end

  def has_labels?
    !! label or !! suffix_label
  end
  
  def next_steps
    translate_and_render('next_steps')
  end

  def has_next_steps?
    !! next_steps
  end

  def options
    @node.options.map do |option|
      OpenStruct.new(label: translate_option(option), value: option)
    end
  end

  def translate_option(option)
    translate!("options.#{option}") ||
    begin
      I18n.translate!("#{@i18n_prefix}.options.#{option}", @state.to_hash)
    rescue I18n::MissingTranslationData
      option
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
