module TestFixturesHelper
  def use_test_smartdown_flow_fixtures
    FLOW_REGISTRY_OPTIONS[:smartdown_load_path] = Rails.root.join('test/fixtures/smartdown_flows')
    @preload_flows = FLOW_REGISTRY_OPTIONS[:preload_flows]
    FLOW_REGISTRY_OPTIONS[:preload_flows] = false
    SmartdownAdapter::Registry.reset_instance
    SmartdownAdapter::PluginFactory.stubs(:plugin_path).returns(Rails.root.join('test/fixtures/smartdown_plugins'))
    SmartdownAdapter::PluginFactory.stubs(:extendable_path).returns(Rails.root.join('test/fixtures/smartdown_plugins/shared'))
  end

  def stop_using_test_smartdown_flow_fixtures
    FLOW_REGISTRY_OPTIONS[:preload_flows] = @preload_flows
    FLOW_REGISTRY_OPTIONS.delete(:smartdown_load_path)
    SmartdownAdapter::Registry.reset_instance
  end
end
