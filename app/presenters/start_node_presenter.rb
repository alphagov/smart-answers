class StartNodePresenter < NodePresenter
  def initialize(node, state = nil, options = {})
    super(node, state)
    @renderer = options[:renderer] || SmartAnswer::ErbRenderer.new(
      template_directory: @node.template_directory,
      template_name: @node.name.to_s,
    )
  end

  def title
    @renderer.single_line_of_content_for(:title)
  end

  def ab_title
    @renderer.single_line_of_content_for(:ab_title)
  end

  def meta_description
    @renderer.single_line_of_content_for(:meta_description)
  end

  def body(html: true)
    @renderer.content_for(:body, html: html)
  end

  def ab_body(html: true)
    @renderer.content_for(:ab_body, html: html)
  end

  def post_body(html: true)
    @renderer.content_for(:post_body, html: html)
  end

  def ab_post_body(html: true)
    @renderer.content_for(:ab_post_body, html: html)
  end

  def start_button_text
    custom_button_text = @renderer.single_line_of_content_for(:start_button_text)
    custom_button_text.present? ? custom_button_text : "Start now"
  end

  def relative_erb_template_path
    @renderer.relative_erb_template_path
  end
end
