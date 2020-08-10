
class CoronavirusFindSupportFlow
  NODES = {
    need_help_with: :feel_safe
  }

  attr_reader :node_name
  def initialize(node_name)
    @node_name = node_name
  end

  def next_node
    NODES[node_name.to_sym]
  end
end

