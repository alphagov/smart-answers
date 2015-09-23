class NodePresenter
  def initialize(i18n_prefix, node, state = nil)
    @i18n_prefix = i18n_prefix
    @node = node
    @state = state || SmartAnswer::State.new(nil)
  end

  def method_missing(method, *args)
    if @node.respond_to?(method)
      @node.send(method, *args)
    else
      super
    end
  end

  def respond_to_missing?(method, include_private)
    @node.respond_to?(method, include_private)
  end
end
