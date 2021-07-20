require "test_helper"

class FlowHelperTest < ActionView::TestCase
  context "#flow" do
    should "return the flow for the current request" do
      params[:id] = "flow-name"

      flow_object = SmartAnswer::Flow.build { name "flow-name" }

      flow_registry = mock
      SmartAnswer::FlowRegistry.stubs(:instance).returns(flow_registry)
      flow_registry.expects(:find).with("flow-name").returns(flow_object)

      assert_same flow_object, flow
    end
  end

  context "#response_store" do
    context "for session based flow" do
      should "return a session response store with flow name and session" do
        params[:id] = "flow-name"

        store = mock

        flow_object = SmartAnswer::Flow.build { response_store :session }
        stubs(:flow).returns(flow_object)

        SessionResponseStore.expects(:new).with(
          flow_name: params[:id],
          session: session,
          user_response_keys: [],
          additional_keys: [],
        ).returns(store)

        assert_same store, response_store
      end
    end

    context "for non-session based flow" do
      should "return a response store" do
        store = mock
        stubs(:request).returns(stub(query_parameters: {
          "question1": "response1",
          "key": "value",
        }))

        flow_object = SmartAnswer::Flow.build do
          response_store :other
          radio :question1
        end

        stubs(:flow).returns(flow_object)

        ResponseStore.expects(:new).with(
          query_parameters: { "question1": "response1", "key": "value" },
          user_response_keys: %w[question1],
          additional_keys: [],
        ).returns(store)

        assert_same store, response_store
      end
    end
  end

  context "#content_item" do
    should "return a content item for the flow" do
      flow_object = SmartAnswer::Flow.build { name "flow-name" }
      stubs(:flow).returns(flow_object)

      content_item_object = { "content_item": "value" }
      ContentItemRetriever.expects(:fetch).with("flow-name")
        .returns(content_item_object)

      assert_same content_item_object, content_item
    end
  end
end
