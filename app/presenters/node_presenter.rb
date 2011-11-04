
class NodePresenter
  def initialize(i18n_prefix, node)
    @i18n_prefix = i18n_prefix
    @node = node
  end
  
  def translate!(subkey)
    I18n.translate!("#{@i18n_prefix}.#{@node.name}.#{subkey}")
  end
  
  def display_name
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
  
  def options
    @node.options.map do |option|
      label = begin
        translate!("options.#{option}")
      rescue I18n::MissingTranslationData
        begin
          I18n.translate!("#{@i18n_prefix}.options.#{option}")
        rescue I18n::MissingTranslationData
          option
        end
      end
      OpenStruct.new(label: label, value: option)
    end
  end
  
  def response_label(value)
    if @node.respond_to?(:options)
      options.find {|option| option.value == value}.label
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
