require_relative '../../integration_test_helper'
require 'gds_api/test_helpers/content_api'

class EngineIntegrationTest < ActionDispatch::IntegrationTest
  include GdsApi::TestHelpers::ContentApi

  setup do
    fixture_flows_path = Rails.root.join(*%w{test fixtures flows})
    FLOW_REGISTRY_OPTIONS[:load_path] = fixture_flows_path

    stub_content_api_default_artefact
  end

  teardown do
    FLOW_REGISTRY_OPTIONS.delete(:load_path)
  end
end
