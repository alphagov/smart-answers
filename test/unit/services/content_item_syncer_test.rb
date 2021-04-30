require "test_helper"

class ContentItemSyncerTest < ActiveSupport::TestCase
  context "#sync" do
    setup do
      setup_fixture_flows

      content_id = SecureRandom.uuid
      @flow = SmartAnswer::FlowRegistry.instance.find("bridge-of-death")
      @flow.content_id(content_id)
      @draft_request = stub_publishing_api_put_content(content_id, {})
      @publishing_request = stub_publishing_api_publish(content_id, {})
    end

    teardown do
      teardown_fixture_flows
    end

    should "create a preview for a draft smart answer" do
      @flow.status(:draft)
      ContentItemSyncer.new.sync([@flow])

      assert_requested @draft_request
      assert_not_requested @publishing_request
    end

    should "publish a published smart answer" do
      @flow.status(:published)
      ContentItemSyncer.new.sync([@flow])

      assert_requested @draft_request
      assert_requested @publishing_request
    end
  end
end
