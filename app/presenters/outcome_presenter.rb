class OutcomePresenter < NodePresenter
  def initialize(node, flow_presenter, state = nil, options = {})
    super(node, flow_presenter, state)
    helpers = options[:helpers] || []
    @renderer = options[:renderer] || SmartAnswer::ErbRenderer.new(
      template_directory: @node.template_directory.join("outcomes"),
      template_name: @node.name.to_s,
      locals: @state.to_hash,
      helpers: [
        SmartAnswer::FormattingHelper,
        SmartAnswer::OverseasPassportsHelper,
      ] + helpers,
    )
  end

  def title
    @renderer.content_for(:title)
  end

  def description
    @renderer.content_for(:description)
  end

  def body
    @renderer.content_for(:body)
  end

  def next_steps
    @renderer.content_for(:next_steps)
  end

  def banner
    @renderer.content_for(:banner)
  end

  def view_template_path
    @node.view_template_path || "smart_answers/result"
  end

  def add_app_component_stylesheets?
    base_path == "/check-uk-visa" && @node.slug == "outcome-work-y" ||
      base_path == "/check-benefits-financial-support" && @node.slug == "results" ||
      base_path == "/next-steps-for-your-business" && @node.slug == "results"
  end

private

  def base_path
    "/#{@flow_presenter.name}"
  end
end
