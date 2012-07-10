require_relative '../../integration_test_helper'

class EngineIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    fixture_flows_path = Rails.root.join(*%w{test fixtures flows})
    FLOW_REGISTRY_OPTIONS[:load_path] = fixture_flows_path
  end

  teardown do
    FLOW_REGISTRY_OPTIONS.delete(:load_path)
  end
end
