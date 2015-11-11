require_relative '../../integration_test_helper'
require_relative '../../helpers/i18n_test_helper'
require 'gds_api/test_helpers/content_api'

class EngineIntegrationTest < ActionDispatch::IntegrationTest
  include GdsApi::TestHelpers::ContentApi
  include I18nTestHelper

  setup do
    fixture_flows_path = Rails.root.join(*%w{test fixtures smart_answer_flows})
    @preload_flows = FLOW_REGISTRY_OPTIONS[:preload_flows]
    FLOW_REGISTRY_OPTIONS[:preload_flows] = false
    FLOW_REGISTRY_OPTIONS[:smart_answer_load_path] = fixture_flows_path
    SmartAnswer::FlowRegistry.reset_instance
    stub_content_api_default_artefact

    use_all_fixture_flow_translation_files
  end

  teardown do
    FLOW_REGISTRY_OPTIONS.delete(:smart_answer_load_path)
    FLOW_REGISTRY_OPTIONS[:preload_flows] = @preload_flows
    SmartAnswer::FlowRegistry.reset_instance

    reset_translation_files
  end
end
