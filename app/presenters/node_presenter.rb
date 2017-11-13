class NodePresenter
  extend Forwardable
  delegate [:outcome?] => :@node

  def initialize(node, state = nil, options = {})
    @node = node
    @state = state || SmartAnswer::State.new(nil)
    @options = options
  end
end
