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
