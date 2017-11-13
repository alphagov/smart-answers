class OutcomePresenter < NodePresenter
  def initialize(node, state = nil, options = {})
    super(node, state)
    helpers = options[:helpers] || []
    @renderer = options[:renderer] || SmartAnswer::ErbRenderer.new(
      template_directory: @node.template_directory.join('outcomes'),
      template_name: @node.name.to_s,
      locals: @state.to_hash,
      helpers: [
        SmartAnswer::FormattingHelper,
        SmartAnswer::OverseasPassportsHelper,
        SmartAnswer::MarriageAbroadHelper
      ] + helpers,
      controller: options[:controller]
    )
  end

  def title
    outcome_title.text
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

  def partial_template_path
    outcome_title.partial_template_path
  end

  def wrapped_with_debug_div?
    outcome_title.wrapped_with_debug_div?
  end

private

  def outcome_title
    @outcome_title ||= SmartAnswer::Title.new(
      @renderer.single_line_of_content_for(:title)
    )
  end
end
