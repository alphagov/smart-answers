require_relative '../integration_test_helper'
require 'gds_api/test_helpers/content_api'

class SmartAnswersControllerErrorHandlingTest < ActionDispatch::IntegrationTest
  include GdsApi::TestHelpers::ContentApi

  setup do
    @flow_registry = stub('flow-registry')
    SmartAnswer::FlowRegistry.stubs(:instance).returns(@flow_registry)
    stub_content_api_default_artefact
  end

  context 'when SmartAnswer::InvalidNode raised' do
    setup do
      flow = stub('flow', name: 'flow-name')
      flow.stubs(:process).raises(SmartAnswer::InvalidNode)
      @flow_registry.stubs(:find).returns(flow)
    end

    should 'set response status code to 404' do
      get '/flow-name'
      assert_response 404
    end
  end

  context 'when SmartAnswer::InvalidNode raised' do
    setup do
      @flow_registry.stubs(:find).raises(SmartAnswer::FlowRegistry::NotFound)
    end

    should 'set response status code to 404' do
      get '/flow-name'
      assert_response 404
    end
  end
end
