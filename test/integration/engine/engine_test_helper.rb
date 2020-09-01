require_relative "../../integration_test_helper"

class EngineIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    setup_fixture_flows
  end

  teardown do
    teardown_fixture_flows
  end
end
