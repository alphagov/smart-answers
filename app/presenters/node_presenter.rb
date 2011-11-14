class NodePresenter
  include ActionView::Helpers::NumberHelper
  
  def initialize(i18n_prefix, node, state = nil)
    @i18n_prefix = i18n_prefix
    @node = node
    @state = state || SmartAnswer::State.new(nil)
  end
  
  def translate!(subkey)
    I18n.translate!("#{@i18n_prefix}.#{@node.name}.#{subkey}", state_for_interpolation)
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
  
  def subtitle
    translate!('subtitle')
  rescue I18n::MissingTranslationData
    nil
  end
  
  def has_subtitle?
    !! subtitle
  end
  
  def title
    translate!('title')
  rescue I18n::MissingTranslationData
    @node.name.to_s.humanize
  end
  
  def body
    Govspeak::Document.new(translate!('body')).to_html.html_safe
  end
  
  def has_body?
    body && true
  rescue I18n::MissingTranslationData
    false
  end

  def hint
    translate!('hint')
  rescue I18n::MissingTranslationData
    nil
  end
  
  def has_hint?
    !! hint
  end
  
  def options
    @node.options.map do |option|
      label = begin
        translate!("options.#{option}")
      rescue I18n::MissingTranslationData
        begin
          I18n.translate!("#{@i18n_prefix}.options.#{option}", @state.to_hash)
        rescue I18n::MissingTranslationData
          option
        end
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