class NodePresenter
  def initialize(i18n_prefix, node, state = nil)
    @i18n_prefix = i18n_prefix
    @node = node
    @state = state || SmartAnswer::State.new(nil)
  end
  
  def translate!(subkey)
    args = "#{@i18n_prefix}.#{@node.name}.#{subkey}", @state.to_hash
    I18n.translate!(*args)
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