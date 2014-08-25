module SmartdownAdapter
  class NodePresenter
    extend Forwardable

    def_delegators :@smartdown_node, :body, :devolved_body, :title, :next_steps

    def initialize(smartdown_node)
      @smartdown_node = smartdown_node
    end

    def has_body?
      !!body
    end

    def has_devolved_body?
      !!devolved_body
    end

    def has_title?
      !!title
    end

    def has_next_steps?
      !!next_steps
    end
  end
end
