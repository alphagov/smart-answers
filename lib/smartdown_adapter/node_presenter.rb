module SmartdownAdapter
  class NodePresenter
    extend Forwardable

    def_delegators :@smartdown_node, :title

    def initialize(smartdown_node)
      @smartdown_node = smartdown_node
    end

    def body
      @smartdown_node.body && Govspeak::Document.new(@smartdown_node.body).to_html.html_safe
    end

    def post_body
      @smartdown_node.post_body && Govspeak::Document.new(@smartdown_node.post_body).to_html.html_safe
    end

    def next_steps
      @smartdown_node.next_steps && Govspeak::Document.new(@smartdown_node.next_steps).to_html.html_safe
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
  end
end
