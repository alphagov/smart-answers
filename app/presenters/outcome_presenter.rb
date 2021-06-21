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
        SmartAnswer::MarriageAbroadHelper,
      ] + helpers,
    )
  end

  def title
    @renderer.content_for(:title)
  end

  def description
    @renderer.content_for(:description)
  end

  def heading_title
    title_as_heading? ? title : @flow_presenter.title
  end

  def title_as_heading?
    @renderer.use_title_as_h1
  end

  def body
    @renderer.content_for(:body)
  end

  def next_steps
    @renderer.content_for(:next_steps)
  end

  def view_template_path
    @node.view_template_path || "smart_answers/result"
  end
end
