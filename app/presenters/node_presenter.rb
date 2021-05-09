class NodePresenter
  delegate :landing?, :question?, :outcome?, :name, :slug, :view_template_path, to: :@node

  def initialize(node, state = nil, _options = {})
    @node = node
    @state = state || SmartAnswer::State.new(nil)
  end

  def error
    nil
  end
end
