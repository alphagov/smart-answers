module SmartdownAdapter
  class NodePresenter
    extend Forwardable

    def_delegators :@smartdown_node, :title

    def initialize(smartdown_node)
      @smartdown_node = smartdown_node
    end

    def body(html: true)
      render(@smartdown_node.body, html: html)
    end

    def post_body(html: true)
      render(@smartdown_node.post_body, html: html)
    end

    def next_steps(html: true)
      render(@smartdown_node.next_steps, html: html)
    end

  private

    def render(smartdown, html:)
      return unless smartdown
      html ? markdown_to_html(smartdown) : smartdown
    end

    def markdown_to_html(markdown)
      Govspeak::Document.new(markdown).to_html.html_safe
    end
  end
end
