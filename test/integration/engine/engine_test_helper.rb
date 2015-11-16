require_relative '../../integration_test_helper'
require_relative '../../helpers/fixture_flows_helper'
require_relative '../../helpers/i18n_test_helper'
require 'gds_api/test_helpers/content_api'

class EngineIntegrationTest < ActionDispatch::IntegrationTest
  include GdsApi::TestHelpers::ContentApi
  include FixtureFlowsHelper
  include I18nTestHelper

  setup do
    setup_fixture_flows
    stub_content_api_default_artefact

    use_all_fixture_flow_translation_files
  end

  teardown do
    teardown_fixture_flows

    reset_translation_files
  end
end
