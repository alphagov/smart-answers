require_relative "../../integration_test_helper"
require_relative "../../helpers/fixture_flows_helper"

class EngineIntegrationTest < ActionDispatch::IntegrationTest
  include FixtureFlowsHelper

  setup do
    setup_fixture_flows
  end

  teardown do
    teardown_fixture_flows
  end
end
