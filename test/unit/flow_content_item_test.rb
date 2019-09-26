require_relative "../test_helper"

module SmartAnswer
  class FlowContentItemTest < ActiveSupport::TestCase
    include GovukContentSchemaTestHelpers::TestUnit

    setup do
      load_path = fixture_file("smart_answer_flows")
      SmartAnswer::FlowRegistry.stubs(:instance).returns(stub("Flow registry", find: @flow, load_path: load_path))
    end

    def stub_flow_registration_presenter
      stub("flow-registration-presenter",
           slug: "flow-slug",
           title: "flow-title",
           external_related_links: [])
    end

    test "#content_id is the flow_content_id of the presenter" do
      presenter = stub_flow_registration_presenter
      presenter.stubs(:flow_content_id).returns("flow-content-id")
      content_item = FlowContentItem.new(presenter)

      assert_equal "flow-content-id", content_item.content_id
    end

    test "#payload returns a valid content-item" do
      presenter = stub_flow_registration_presenter
      content_item = FlowContentItem.new(presenter)

      assert_valid_against_schema(content_item.payload, "generic_with_external_related_links")
    end

    test "#payload returns a valid content-item with external related links" do
      presenter = stub_flow_registration_presenter
      presenter.stubs(:external_related_links).returns(
        [{ title: "hmrc", url: "https://hmrc.gov.uk" }],
      )
      content_item = FlowContentItem.new(presenter)

      assert_valid_against_schema(content_item.payload, "generic_with_external_related_links")
    end

    test "#base_path is the slug of the presenter with a prepended slash and appended /y" do
      presenter = stub_flow_registration_presenter
      content_item = FlowContentItem.new(presenter)

      assert_equal "/flow-slug/y", content_item.payload[:base_path]
    end

    test "#payload title is the title of the presenter" do
      presenter = stub_flow_registration_presenter
      content_item = FlowContentItem.new(presenter)

      assert_equal "flow-title", content_item.payload[:title]
    end

    test "#payload details hash includes external_related_links" do
      presenter = stub_flow_registration_presenter
      presenter.stubs(:external_related_links).returns(%w[link-1])
      content_item = FlowContentItem.new(presenter)

      assert_equal "link-1", content_item.payload[:details][:external_related_links][0]
    end

    test "#payload schema_name is generic_with_external_related_links" do
      presenter = stub_flow_registration_presenter
      content_item = FlowContentItem.new(presenter)

      assert_equal "generic_with_external_related_links", content_item.payload[:schema_name]
    end

    test "#payload document_type is smart_answer" do
      presenter = stub_flow_registration_presenter
      content_item = FlowContentItem.new(presenter)

      assert_equal "smart_answer", content_item.payload[:document_type]
    end

    test "#payload publishing_app is smartanswers" do
      presenter = stub_flow_registration_presenter
      content_item = FlowContentItem.new(presenter)

      assert_equal "smartanswers", content_item.payload[:publishing_app]
    end

    test "#payload rendering_app is smartanswers" do
      presenter = stub_flow_registration_presenter
      content_item = FlowContentItem.new(presenter)

      assert_equal "smartanswers", content_item.payload[:rendering_app]
    end

    test "#payload locale is en" do
      presenter = stub_flow_registration_presenter
      content_item = FlowContentItem.new(presenter)

      assert_equal "en", content_item.payload[:locale]
    end

    test "#payload public_updated_at timestamp is the current datetime" do
      now = Time.now
      Time.stubs(:now).returns(now)

      presenter = stub_flow_registration_presenter
      content_item = FlowContentItem.new(presenter)

      assert_equal now.iso8601, content_item.payload[:public_updated_at]
    end

    test "#payload registers a prefix route using the slug of the smart answer with /y appended" do
      presenter = stub_flow_registration_presenter
      content_item = FlowContentItem.new(presenter)

      expected_route = { type: "prefix", path: "/flow-slug/y" }
      assert content_item.payload[:routes].include?(expected_route)
    end
  end
end
