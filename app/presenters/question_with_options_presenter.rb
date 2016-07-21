class QuestionWithOptionsPresenter < QuestionPresenter
  def options
    @node.options.map do |option|
      OpenStruct.new(label: render_option(option), value: option)
    end
  end

  def render_option(key)
    @renderer.option_text(key.to_sym)
  end
end
