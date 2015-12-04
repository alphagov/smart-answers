class OutcomePresenter < NodePresenter
  def initialize(node, action_view, state = nil, options = {})
    super(node, state)
    @renderer = options[:renderer] || SmartAnswer::ErbRenderer.new(
      action_view: action_view,
      template_name: @node.name.to_s,
      locals: @state.to_hash
    )
  end

  def title
    @renderer.single_line_of_content_for(:title)
  end

  def body(html: true)
    @renderer.content_for(:body, html: html)
  end

  def next_steps(html: true)
    @renderer.content_for(:next_steps, html: html)
  end
end
