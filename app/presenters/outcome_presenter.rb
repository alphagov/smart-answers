class OutcomePresenter < NodePresenter
  def initialize(i18n_prefix, node, state = nil, options = {})
    super(i18n_prefix, node, state)
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
    title = @renderer.content_for(:title, html: false)
    title && title.chomp
  end

  def body(html: true)
    @renderer.content_for(:body, html: html)
  end

  def next_steps(html: true)
    @renderer.content_for(:next_steps, html: html)
  end
end
