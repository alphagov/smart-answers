class NodePresenter
  include ActionView::Helpers::NumberHelper

  def initialize(i18n_prefix, node, state = nil)
    @i18n_prefix = i18n_prefix
    @node = node
    @state = state || SmartAnswer::State.new(nil)
  end

  def i18n_node_prefix
    "#{@i18n_prefix}.#{@node.name}"
  end

  def translate!(subkey)
    I18n.translate!("#{i18n_node_prefix}.#{subkey}", state_for_interpolation)
  rescue I18n::MissingTranslationData
    nil
  end

  def translate_and_render(subkey, html: true)
    markup = translate!(subkey)
    return unless markup
    html ? GovspeakPresenter.new(markup.strip).html : markup
  end

  def state_for_interpolation(nested = false)
    Hash[@state.to_hash.map { |k, v| [k, value_for_interpolation(v, nested)] }]
  end

  def value_for_interpolation(value, nested = false)
    case value
    when Date then I18n.localize(value, format: :long)
    when ::SmartAnswer::Money then
      number_to_currency(value, precision: ((value.to_f == value.to_f.round) ? 0 : 2))
    when ::SmartAnswer::Salary then
      number_to_currency(value.amount, precision: 0) + " per " + value.period
    when ::SmartAnswer::PhraseList then
      if nested == false
        value.phrase_keys.map do |phrase_key|
          begin
            I18n.translate!("#{@i18n_prefix}.phrases.#{phrase_key}", state_for_interpolation(true))
          rescue => e
            Rails.logger.warn("[Missing phrase] The phrase being rendered is not present: #{e.key}\tResponses: #{@state.responses.join('/')}") if @node.outcome?
            phrase_key
          end
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

  def has_title?
    !!title
  end

  def body(html: true)
    translate_and_render('body', html: html)
  end

  def has_body?
    !!body
  end

  #Post-body on questions is only supported on Smartdown questions
  def has_post_body?
    false
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
