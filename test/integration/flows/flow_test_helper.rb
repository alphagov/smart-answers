# encoding: UTF-8

module FlowTestHelper
  def setup_for_testing_flow(flow_slug)
    @flow_registry ||= SmartAnswer::FlowRegistry.new(:show_drafts => true)
    @flow = @flow_registry.find(flow_slug)
  end

  def node_for_responses(responses)
    @flow.process(responses).current_node
  end
end
