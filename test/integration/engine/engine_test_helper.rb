require_relative '../../integration_test_helper'
require_relative '../../helpers/fixture_flows_helper'
require 'gds_api/test_helpers/content_api'

class EngineIntegrationTest < ActionDispatch::IntegrationTest
  include GdsApi::TestHelpers::ContentApi
  include FixtureFlowsHelper

  setup do
    setup_fixture_flows
    stub_content_api_default_artefact
  end

  teardown do
    teardown_fixture_flows
  end
end
