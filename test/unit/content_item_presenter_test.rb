require_relative "../test_helper"
require "govuk_schemas/assert_matchers"

module SmartAnswer
  class ContentItemPresenterPresenterTest < ActiveSupport::TestCase
    include GovukSchemas::AssertMatchers

    setup do
      setup_fixture_flows
      @flow = SmartAnswer::FlowRegistry.instance.find("bridge-of-death")
    end

    teardown do
      teardown_fixture_flows
    end

    test "#payload returns a valid content-item" do
      content_item = ContentItemPresenter.new(@flow)

      assert_valid_against_publisher_schema(content_item.payload, "smart_answer")
    end

    test "#payload includes flow specific data" do
      payload = ContentItemPresenter.new(@flow).payload

      assert_equal "/bridge-of-death", payload[:base_path]
      assert_equal "The Bridge of Death", payload[:title]
      assert_equal "The Gorge of Eternal Peril!!!", payload[:description]
      assert_match %r{He who would cross the Bridge of Death}, payload.dig(:details, :hidden_search_terms, 0)
    end

    context "when the ContentBlockDetector finds associated content blocks" do
      setup do
        @content_id = SecureRandom.uuid
        content_block_1 = stub("content_block", content_id: @content_id)
        content_block_2 = stub("content_block", content_id: @content_id)

        detector = stub("detector", content_blocks: [content_block_1, content_block_2])
        ContentBlockDetector.expects(:new).with(@flow).returns(detector)
      end

      should "include an array of unique content IDs in the payload" do
        payload = ContentItemPresenter.new(@flow).payload

        assert_equal [@content_id], payload[:links][:embed]
      end
    end

    context "when the ContentBlockDetector does not find associated content blocks" do
      setup do
        detector = stub("detector", content_blocks: [])
        ContentBlockDetector.expects(:new).with(@flow).returns(detector)
      end

      should "not include any links" do
        payload = ContentItemPresenter.new(@flow).payload

        assert_nil payload[:links]
      end
    end
  end
end
