class SessionFlow
  FlowNotFoundError = Class.new(StandardError)
  NodeNotFoundError = Class.new(StandardError)

  FLOWS = {
    coronavirus_find_support: CoronavirusFindSupportFlow,
  }.freeze

  def self.call(*args)
    new(*args).flow
  end

  attr_reader :flow_name, :node_name, :session

  def initialize(flow_name, node_name, session)
    @flow_name = flow_name.to_sym
    @node_name = node_name.to_sym
    @session = session
  end

  def exists?
    FLOWS.keys.include?(flow_name)
  end

  def flow
    raise FlowNotFoundError, "Flow #{flow_name} not found" unless exists?

    flow = flow_class.new(node_name, session)
    raise NodeNotFoundError, "#{node_name} not found in flow #{flow_name}" unless flow.has_node?

    flow
  end

  def flow_class
    FLOWS[flow_name]
  end
end
