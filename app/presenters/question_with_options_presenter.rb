class QuestionWithOptionsPresenter < QuestionPresenter
  def options
    unless @node.options_block.nil?
      @node.option_keys = @state.instance_exec(&@node.options_block)
    end

    @node.option_keys.map { |option_key| option_attributes(option_key) }
  end

  def option_attributes(key)
    option = @renderer.option(key.to_sym)

    if option.is_a?(String)
      { label: option, value: key }
    else
      option.merge({ value: key })
    end
  end
end
