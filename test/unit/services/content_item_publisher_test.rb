require "test_helper"

class ContentItemPublisherTest < ActiveSupport::TestCase
  setup do
    load_path = fixture_file("smart_answer_flows")
    SmartAnswer::FlowRegistry.stubs(:instance).returns(stub("Flow registry", find: @flow, load_path: load_path))
  end

  test "sending item to content store" do
    start_page_draft_request = stub_request(:put, "https://publishing-api.test.gov.uk/v2/content/3e6f33b8-0723-4dd5-94a2-cab06f23a685")
    start_page_publishing_request = stub_request(:post, "https://publishing-api.test.gov.uk/v2/content/3e6f33b8-0723-4dd5-94a2-cab06f23a685/publish")
    flow_draft_request = stub_request(:put, "https://publishing-api.test.gov.uk/v2/content/154829ba-ad5d-4dad-b11b-2908b7bec399")
    flow_publishing_request = stub_request(:post, "https://publishing-api.test.gov.uk/v2/content/154829ba-ad5d-4dad-b11b-2908b7bec399/publish")

    presenter = FlowRegistrationPresenter.new(stub("flow", name: "bridge-of-death", start_page_content_id: "3e6f33b8-0723-4dd5-94a2-cab06f23a685", flow_content_id: "154829ba-ad5d-4dad-b11b-2908b7bec399", external_related_links: nil, nodes: []))

    ContentItemPublisher.new.publish([presenter])

    assert_requested start_page_draft_request
    assert_requested start_page_publishing_request
    assert_requested flow_draft_request
    assert_requested flow_publishing_request
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
