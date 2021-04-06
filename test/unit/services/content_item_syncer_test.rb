require "test_helper"

class ContentItemSyncerTest < ActiveSupport::TestCase
  setup do
    load_path = fixture_file("smart_answer_flows")
    SmartAnswer::FlowRegistry.stubs(:instance).returns(stub("Flow registry", load_path: load_path))
  end

  context "#sync" do
    setup do
      content_id = SecureRandom.uuid
      @draft_request = stub_publishing_api_put_content(content_id, {})
      @publishing_request = stub_publishing_api_publish(content_id, {})
      @flow = stub(
        "flow",
        name: "bridge-of-death",
        content_id: content_id,
        response_store: nil,
        nodes: [],
      )
    end

    should "create a preview for a draft smart answer" do
      @flow.stubs(:status).returns(:draft)
      presenter = FlowPresenter.new({}, @flow)
      ContentItemSyncer.new.sync([presenter])

      assert_requested @draft_request
      assert_not_requested @publishing_request
    end

    should "publish a published smart answer" do
      @flow.stubs(:status).returns(:published)
      presenter = FlowPresenter.new({}, @flow)
      ContentItemSyncer.new.sync([presenter])

      assert_requested @draft_request
      assert_requested @publishing_request
    end
  end
end
