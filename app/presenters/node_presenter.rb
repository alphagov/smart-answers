class NodePresenter
  delegate :outcome?, to: :@node

  def initialize(node, flow_presenter, state = nil, _options = {}, _params = {})
    @node = node
    @flow_presenter = flow_presenter
    @state = state || SmartAnswer::State.new(nil)
  end

  def node_name
    @node.name
  end
end
