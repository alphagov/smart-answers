module FixtureFlowsHelper
  def setup_fixture_flows
    fixture_flows_path = Rails.root.join(*%w{test fixtures smart_answer_flows})
    @preload_flows = FLOW_REGISTRY_OPTIONS[:preload_flows]
    FLOW_REGISTRY_OPTIONS[:preload_flows] = false
    FLOW_REGISTRY_OPTIONS[:smart_answer_load_path] = fixture_flows_path
    SmartAnswer::FlowRegistry.reset_instance
  end

  def teardown_fixture_flows
    FLOW_REGISTRY_OPTIONS.delete(:smart_answer_load_path)
    FLOW_REGISTRY_OPTIONS[:preload_flows] = @preload_flows
    SmartAnswer::FlowRegistry.reset_instance
  end
end
