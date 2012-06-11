# encoding: UTF-8

module FlowTestHelper
  def setup_for_testing_flow(flow_slug)
    @flow_registry ||= SmartAnswer::FlowRegistry.new(:show_drafts => true)
    @flow = @flow_registry.find(flow_slug)
    @responses = []
  end

  def add_response(resp)
    @responses << resp.to_s
  end

  # Deprecated
  def node_for_responses(responses)
    @flow.process(responses).current_node
  end

  def current_state
    state = @flow.process(@responses)
    raise SmartAnswer::InvalidResponse.new(state.error) if state.error
    state
  end

  def assert_current_node(node_name)
    assert_equal node_name, current_state.current_node
    assert @flow.node_exists?(node_name), "Node #{node_name} does not exist."
  end

  def assert_state_variable(name, value)
    assert_equal value, current_state.send(name)
  end
end
