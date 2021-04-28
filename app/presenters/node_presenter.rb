class NodePresenter
  delegate :outcome?, to: :@node

  def initialize(node, flow_presenter, state = nil, _options = {})
    @node = node
    @flow_presenter = flow_presenter
    @state = state || SmartAnswer::State.new(nil)
  end

  def node_name
    @node.name
  end

  def node_slug
    @node.slug
  end

  def view_template_path
    @node.view_template_path
  end
end
