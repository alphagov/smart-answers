class QuestionWithOptionsPresenter < QuestionPresenter
  def options
    @node.options.map { |option_key| option_attributes(option_key) }
  end

  def option_attributes(key)
    label = @renderer.option_text(key.to_sym)

    { label: label, value: key }
  end
end
