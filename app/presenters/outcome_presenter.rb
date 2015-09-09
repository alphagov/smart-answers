class OutcomePresenter < NodePresenter
  def initialize(i18n_prefix, node, state = nil, options = {})
    super(i18n_prefix, node, state)
    template_directory = options[:erb_template_directory] || @node.template_directory
    @renderer = options[:renderer] || SmartAnswer::ErbRenderer.new(
      template_directory: template_directory,
      template_name: name,
      locals: @state.to_hash,
      helpers: [
        SmartAnswer::OutcomeHelper,
        SmartAnswer::OverseasPassportsHelper,
        SmartAnswer::MarriageAbroadHelper
      ]
    )
  end

  def title
    title = @renderer.content_for(:title, govspeak: false)
    title && title.chomp
  end

  def body(html: true)
    @renderer.content_for(:body, html: html)
  end

  def next_steps(html: true)
    @renderer.content_for(:next_steps, html: html)
  end

  def erb_template_path
    @renderer.erb_template_path
  end
end
