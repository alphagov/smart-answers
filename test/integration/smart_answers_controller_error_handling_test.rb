require_relative "../integration_test_helper"

class SmartAnswersControllerErrorHandlingTest < ActionDispatch::IntegrationTest
  setup do
    @flow_registry = stub("flow-registry")
    SmartAnswer::FlowRegistry.stubs(:instance).returns(@flow_registry)
  end

  context "when SmartAnswer::InvalidNode raised" do
    setup do
      flow = stub("flow", name: "flow-name")
      flow.stubs(:process).raises(SmartAnswer::InvalidNode)
      @flow_registry.stubs(:find).returns(flow)
    end

    should "set response status code to 404" do
      get "/flow-name"
      assert_response 404
    end
  end

  context "when SmartAnswer::InvalidNode raised" do
    setup do
      @flow_registry.stubs(:find).raises(SmartAnswer::FlowRegistry::NotFound)
    end

    should "set response status code to 404" do
      get "/flow-name"
      assert_response 404
    end
  end
end
