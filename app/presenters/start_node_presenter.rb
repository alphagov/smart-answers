class StartNodePresenter < NodePresenter
  def initialize(node, state = nil, options = {})
    super('unused-i18n-prefix', node, state)
    @renderer = options[:renderer] || SmartAnswer::ErbRenderer.new(
      template_directory: @node.template_directory,
      template_name: @node.name.to_s
    )
  end

  def title
    @renderer.single_line_of_content_for(:title)
  end

  def meta_description
    @renderer.single_line_of_content_for(:meta_description)
  end

  def body(html: true)
    @renderer.content_for(:body, html: html)
  end

  def post_body(html: true)
    @renderer.content_for(:post_body, html: html)
  end
end
