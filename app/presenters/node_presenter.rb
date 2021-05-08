class NodePresenter
  delegate :outcome?, :name, :slug, :view_template_path, to: :@node

  def initialize(node, state = nil, _options = {})
    @node = node
    @state = state || SmartAnswer::State.new(nil, nil)
  end
end
