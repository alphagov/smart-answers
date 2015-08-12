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

    def post_body
      @smartdown_node.post_body && markdown_to_html(@smartdown_node.post_body)
    end

    def next_steps(html: true)
      render(@smartdown_node.next_steps, html: html)
    end

    def has_body?
      !!body
    end

    def has_post_body?
      !!post_body
    end

    def has_title?
      !!title
    end

    def has_next_steps?
      !!next_steps
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
