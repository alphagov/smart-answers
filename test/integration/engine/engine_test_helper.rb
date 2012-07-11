require_relative '../../integration_test_helper'
require 'gds_api/test_helpers/panopticon'

class EngineIntegrationTest < ActionDispatch::IntegrationTest
  include GdsApi::TestHelpers::Panopticon

  setup do
    fixture_flows_path = Rails.root.join(*%w{test fixtures flows})
    FLOW_REGISTRY_OPTIONS[:load_path] = fixture_flows_path

    stub_panopticon_default_artefact
  end

  teardown do
    FLOW_REGISTRY_OPTIONS.delete(:load_path)
  end
end
