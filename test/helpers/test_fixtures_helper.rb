module TestFixturesHelper
  def use_test_smartdown_flow_fixtures
    suppress_warnings do
      SmartdownAdapter::Registry.const_set(:FLOW_REGISTRY_OPTIONS, {}) unless SmartdownAdapter::Registry::FLOW_REGISTRY_OPTIONS
      SmartdownAdapter::Registry::FLOW_REGISTRY_OPTIONS[:load_path] = Rails.root.join('test/fixtures/smartdown_flows')
      SmartdownAdapter::Registry.reset_instance
    end
    SmartdownAdapter::PluginFactory.stubs(:plugin_path).returns(Rails.root.join('test/fixtures/smartdown_plugins'))
    SmartdownAdapter::PluginFactory.stubs(:extendable_path).returns(Rails.root.join('test/fixtures/smartdown_plugins/shared'))
  end

  def stop_using_test_smartdown_flow_fixtures
    suppress_warnings do
      SmartdownAdapter::Registry.const_set(:FLOW_REGISTRY_OPTIONS, {}) unless SmartdownAdapter::Registry::FLOW_REGISTRY_OPTIONS
      SmartdownAdapter::Registry::FLOW_REGISTRY_OPTIONS.delete(:load_path)
      SmartdownAdapter::Registry.reset_instance
    end
  end
end
