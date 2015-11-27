class OutcomePresenter < NodePresenter
  def initialize(node, state = nil, options = {})
    super(node, state)
    @renderer = options[:renderer] || SmartAnswer::ErbRenderer.new(
      template_directory: @node.template_directory.join('outcomes'),
      template_name: @node.name.to_s,
      locals: @state.to_hash,
      helpers: [
        SmartAnswer::FormattingHelper,
        SmartAnswer::OverseasPassportsHelper,
        SmartAnswer::MarriageAbroadHelper
      ]
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
