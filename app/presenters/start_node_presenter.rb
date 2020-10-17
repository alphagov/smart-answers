class StartNodePresenter < NodePresenter
  def initialize(node, state = nil, options = {})
    super(node, state)
    @renderer = options[:renderer] || SmartAnswer::ErbRenderer.new(
      template_directory: @node.template_directory,
      template_name: @node.name.to_s,
    )
  end

  def title
    @renderer.content_for(:title)
  end

  def ab_title
    @renderer.content_for(:ab_title)
  end

  def meta_description
    @renderer.content_for(:meta_description)
  end

  def body
    @renderer.content_for(:body)
  end

  def ab_body
    @renderer.content_for(:ab_body)
  end

  def post_body
    @renderer.content_for(:post_body)
  end

  def ab_post_body
    @renderer.content_for(:ab_post_body)
  end

  def start_button_text
    custom_button_text = @renderer.content_for(:start_button_text)
    custom_button_text.presence || "Start now"
  end
end
