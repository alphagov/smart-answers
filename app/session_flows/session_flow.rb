
class SessionFlow

  FLOWS = {
    coronavirus_find_support: CoronavirusFindSupportFlow
  }

  def self.call(*args)
    new(*args).flow
  end

  attr_reader :flow_name, :node_name

  def initialize(flow_name, node_name)
    @flow_name = flow_name.to_sym
    @node_name = node_name.to_sym
  end

  def flow
    flow = FLOWS[flow_name]
    flow.new(node_name)
  end
end

