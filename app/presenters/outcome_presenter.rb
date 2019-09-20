class OutcomePresenter < NodePresenter
  def initialize(node, state = nil, options = {}, params = {})
    super(node, state)
    @params = params
    helpers = options[:helpers] || []
    @renderer = options[:renderer] || SmartAnswer::ErbRenderer.new(
      template_directory: @node.template_directory.join("outcomes"),
      template_name: @node.name.to_s,
      locals: @state.to_hash,
      helpers: [
        SmartAnswer::FormattingHelper,
        SmartAnswer::OverseasPassportsHelper,
        SmartAnswer::MarriageAbroadHelper,
      ] + helpers,
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

  def relative_erb_template_path
    @renderer.relative_erb_template_path
  end
end
