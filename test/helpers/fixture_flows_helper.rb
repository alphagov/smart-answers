module FixtureFlowsHelper
  def setup_fixture_flows
    stub_request(:get, %r{#{Plek.new.find("content-store")}/content/(.*)})
      .to_return(status: 404, body: {}.to_json)

    fixture_flows_path = Rails.root.join("test", "fixtures", "smart_answer_flows")
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

  def stub_smart_answer_in_content_store(smart_answer_id)
    Services.content_store.stubs(:content_item)
      .with("/#{smart_answer_id}")
      .returns({})
  end
end
