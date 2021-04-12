require_relative "../test_helper"

module SmartAnswer
  class StartPageContentItemTest < ActiveSupport::TestCase
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
      content_item = StartPageContentItem.new(presenter)

      assert_equal "content-id", content_item.content_id
    end

    test "#payload returns a valid content-item" do
      presenter = stub_flow_registration_presenter
      content_item = StartPageContentItem.new(presenter)

      assert_valid_against_schema(content_item.payload, "transaction")
    end

    test "#base_path is the name of the presenter with a prepended slash" do
      presenter = stub_flow_registration_presenter
      content_item = StartPageContentItem.new(presenter)

      assert_equal "/flow-name", content_item.payload[:base_path]
    end

    test "#payload title is the title of the presenter" do
      presenter = stub_flow_registration_presenter
      content_item = StartPageContentItem.new(presenter)

      assert_equal "flow-title", content_item.payload[:title]
    end

    test "#payload description is the meta_description of the presenter" do
      presenter = stub_flow_registration_presenter
      content_item = StartPageContentItem.new(presenter)

      assert_equal "flow-description", content_item.payload[:description]
    end

    test "#payload details hash includes includes the introductory paragraph as govspeak" do
      presenter = stub_flow_registration_presenter
      content_item = StartPageContentItem.new(presenter)

      assert_equal "start-page-body", content_item.payload[:details][:introductory_paragraph][0][:content]
      assert_equal "text/govspeak", content_item.payload[:details][:introductory_paragraph][0][:content_type]
    end

    test "#payload details hash includes more information as govspeak" do
      presenter = stub_flow_registration_presenter
      content_item = StartPageContentItem.new(presenter)

      assert_equal "start-page-post-body", content_item.payload[:details][:more_information][0][:content]
      assert_equal "text/govspeak", content_item.payload[:details][:more_information][0][:content_type]
    end

    test "#payload details hash includes the link to the flow" do
      presenter = stub_flow_registration_presenter
      content_item = StartPageContentItem.new(presenter)

      assert_equal "/flow-name/y", content_item.payload[:details][:transaction_start_link]
    end

    test "#payload details hash includes the text to be used for the start button" do
      presenter = stub_flow_registration_presenter
      content_item = StartPageContentItem.new(presenter)

      assert_equal "start-button-text", content_item.payload[:details][:start_button_text]
    end

    test "#payload schema_name is generic_with_external_related_links" do
      presenter = stub_flow_registration_presenter
      content_item = StartPageContentItem.new(presenter)

      assert_equal "transaction", content_item.payload[:schema_name]
    end

    test "#payload document_type is transaction" do
      presenter = stub_flow_registration_presenter
      content_item = StartPageContentItem.new(presenter)

      assert_equal "transaction", content_item.payload[:document_type]
    end

    test "#payload publishing_app is smartanswers" do
      presenter = stub_flow_registration_presenter
      content_item = StartPageContentItem.new(presenter)

      assert_equal "smartanswers", content_item.payload[:publishing_app]
    end

    test "#payload rendering_app is frontend" do
      presenter = stub_flow_registration_presenter
      content_item = StartPageContentItem.new(presenter)

      assert_equal "frontend", content_item.payload[:rendering_app]
    end

    test "#payload locale is en" do
      presenter = stub_flow_registration_presenter
      content_item = StartPageContentItem.new(presenter)

      assert_equal "en", content_item.payload[:locale]
    end

    test "#payload public_updated_at timestamp is the current datetime" do
      now = Time.zone.now
      Time.stubs(:now).returns(now)

      presenter = stub_flow_registration_presenter
      content_item = StartPageContentItem.new(presenter)

      assert_equal now.iso8601, content_item.payload[:public_updated_at]
    end

    test "#payload registers an exact route using the name of the smart answer" do
      presenter = stub_flow_registration_presenter
      content_item = StartPageContentItem.new(presenter)

      expected_route = { type: "exact", path: "/flow-name" }
      assert content_item.payload[:routes].include?(expected_route)
    end
  end
end
