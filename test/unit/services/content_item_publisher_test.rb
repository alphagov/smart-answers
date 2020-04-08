require "test_helper"
require "gds_api/test_helpers/publishing_api"

class ContentItemPublisherTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  setup do
    load_path = fixture_file("smart_answer_flows")
    SmartAnswer::FlowRegistry.stubs(:instance).returns(stub("Flow registry", find: @flow, load_path: load_path))
  end

  context "#sync" do
    setup do
      start_page_content_id = SecureRandom.uuid
      flow_content_id = SecureRandom.uuid
      @start_page_draft_request = stub_publishing_api_put_content(start_page_content_id, {})
      @start_page_publishing_request = stub_publishing_api_publish(start_page_content_id, {})
      @flow_draft_request = stub_publishing_api_put_content(flow_content_id, {})
      @flow_publishing_request = stub_publishing_api_publish(flow_content_id, {})
      @flow = stub("flow",
                   name: "bridge-of-death",
                   start_page_content_id: start_page_content_id,
                   flow_content_id: flow_content_id,
                   external_related_links: nil,
                   nodes: [])
    end

    should "create a preview for a draft smart answer" do
      @flow.stubs(:status).returns(:draft)
      presenter = FlowRegistrationPresenter.new(@flow)
      ContentItemPublisher.new.sync([presenter])

      assert_requested @start_page_draft_request
      assert_not_requested @start_page_publishing_request
      assert_requested @flow_draft_request
      assert_not_requested @flow_publishing_request
    end

    should "publish a published smart answer" do
      @flow.stubs(:status).returns(:published)
      presenter = FlowRegistrationPresenter.new(@flow)
      ContentItemPublisher.new.sync([presenter])

      assert_requested @start_page_draft_request
      assert_requested @start_page_publishing_request
      assert_requested @flow_draft_request
      assert_requested @flow_publishing_request
    end
  end

  context "#unpublish" do
    should "send unpublish request to content store" do
      unpublish_url = "https://publishing-api.test.gov.uk/v2/content/content-id/unpublish"
      unpublish_request = stub_request(:post, unpublish_url)

      ContentItemPublisher.new.unpublish("content-id")

      assert_requested unpublish_request
    end

    should "raise exception if content_id has not been supplied" do
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.unpublish(nil)
      end

      assert_equal "Content id has not been supplied", exception.message
    end
  end

  context "#reserve_path_for_publishing_app" do
    should "raise exception if base_path is not supplied" do
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.reserve_path_for_publishing_app(nil, "publisher")
      end

      assert_equal "The destination or path isn't supplied", exception.message
    end

    should "raise exception if publishing_app is not supplied" do
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.reserve_path_for_publishing_app("/base_path", nil)
      end

      assert_equal "The destination or path isn't supplied", exception.message
    end

    should "send a base_path publishing_app reservation request" do
      reservation_url = "https://publishing-api.test.gov.uk/paths//base_path"
      reservation_request = stub_request(:put, reservation_url)

      ContentItemPublisher.new.reserve_path_for_publishing_app("/base_path", "publisher")

      assert_requested reservation_request
    end
  end
end
