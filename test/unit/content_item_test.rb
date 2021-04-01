require_relative "../test_helper"

module SmartAnswer
  class ContentItemTest < ActiveSupport::TestCase
    include GovukContentSchemaTestHelpers::TestUnit

    setup do
      load_path = fixture_file("smart_answer_flows")
      SmartAnswer::FlowRegistry.stubs(:instance).returns(stub("Flow registry", find: @flow, load_path: load_path))
    end

    def stub_flow_registration_presenter
      stub(
        "flow-registration-presenter",
        name: "flow-name",
        title: "flow-title",
        start_page_content_id: "content-id",
        flows_content: ["question title"],
        meta_description: "flow-description",
        start_node: stub(
          body: "start-page-body",
          post_body: "start-page-post-body",
          start_button_text: "start-button-text",
        ),
        start_page_link: "/flow-name/y",
      )
    end

    test "#content_id is the content_id of the presenter" do
      presenter = stub_flow_registration_presenter
      content_item = ContentItem.new(presenter)

      assert_equal "content-id", content_item.content_id
    end

    test "#payload returns a valid content-item" do
      presenter = stub_flow_registration_presenter
      content_item = ContentItem.new(presenter)

      assert_valid_against_schema(content_item.payload, "smart_answer")
    end

    test "#base_path is the name of the presenter with a prepended slash" do
      presenter = stub_flow_registration_presenter
      content_item = ContentItem.new(presenter)

      assert_equal "/flow-name", content_item.payload[:base_path]
    end

    test "#payload title is the title of the presenter" do
      presenter = stub_flow_registration_presenter
      content_item = ContentItem.new(presenter)

      assert_equal "flow-title", content_item.payload[:title]
    end

    test "#payload description is the meta_description of the presenter" do
      presenter = stub_flow_registration_presenter
      content_item = ContentItem.new(presenter)

      assert_equal "flow-description", content_item.payload[:description]
    end

    test "#payload schema_name is smart_answer" do
      presenter = stub_flow_registration_presenter
      content_item = ContentItem.new(presenter)

      assert_equal "smart_answer", content_item.payload[:schema_name]
    end

    test "#payload document_type is smart_answer" do
      presenter = stub_flow_registration_presenter
      content_item = ContentItem.new(presenter)

      assert_equal "smart_answer", content_item.payload[:document_type]
    end

    test "#payload publishing_app is smartanswers" do
      presenter = stub_flow_registration_presenter
      content_item = ContentItem.new(presenter)

      assert_equal "smartanswers", content_item.payload[:publishing_app]
    end

    test "#payload rendering_app is frontend" do
      presenter = stub_flow_registration_presenter
      content_item = ContentItem.new(presenter)

      assert_equal "smartanswers", content_item.payload[:rendering_app]
    end

    test "#payload locale is en" do
      presenter = stub_flow_registration_presenter
      content_item = ContentItem.new(presenter)

      assert_equal "en", content_item.payload[:locale]
    end

    test "#payload public_updated_at timestamp is the current datetime" do
      now = Time.zone.now
      Time.stubs(:now).returns(now)

      presenter = stub_flow_registration_presenter
      content_item = ContentItem.new(presenter)

      assert_equal now.iso8601, content_item.payload[:public_updated_at]
    end

    test "#payload registers an prefix route for the flow" do
      presenter = stub_flow_registration_presenter
      content_item = ContentItem.new(presenter)

      expected_route = { type: "prefix", path: "/flow-name" }
      assert content_item.payload[:routes].include?(expected_route)
    end
  end
end
