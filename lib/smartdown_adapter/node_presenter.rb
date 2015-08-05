module SmartdownAdapter
  class NodePresenter
    extend Forwardable

    def_delegators :@smartdown_node, :title

    def initialize(smartdown_node)
      @smartdown_node = smartdown_node
    end

    def body
      @smartdown_node.body && markdown_to_html(@smartdown_node.body)
    end

    def post_body
      @smartdown_node.post_body && markdown_to_html(@smartdown_node.post_body)
    end

    def next_steps
      @smartdown_node.next_steps && markdown_to_html(@smartdown_node.next_steps)
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

    def markdown_to_html markdown
      Govspeak::Document.new(markdown).to_html.html_safe
    end
  end
end
