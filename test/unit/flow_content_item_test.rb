require_relative '../test_helper'

module SmartAnswer
  class FlowContentItemTest < ActiveSupport::TestCase
    include GovukContentSchemaTestHelpers::TestUnit

    setup do
      load_path = fixture_file('smart_answer_flows')
      SmartAnswer::FlowRegistry.stubs(:instance).returns(stub("Flow registry", find: @flow, load_path: load_path))
    end

    test '#payload returns a valid content-item' do
      presenter = stub('flow-registration-presenter',
        slug: 'flow-slug',
        title: 'flow-title',
        external_related_links: []
      )
      content_item = FlowContentItem.new(presenter)

      assert_valid_against_schema(content_item.payload, 'generic_with_external_related_links')
    end

    test '#payload returns a valid content-item with external related links' do
      presenter = stub('flow-registration-presenter',
        slug: 'flow-slug',
        title: 'flow-title',
        external_related_links: [
          { title: "hmrc", url: "https://hmrc.gov.uk" }
        ]
      )
      content_item = FlowContentItem.new(presenter)

      assert_valid_against_schema(content_item.payload, 'generic_with_external_related_links')
    end

    test '#base_path is the slug of the presenter with a prepended slash' do
      presenter = stub('flow-registration-presenter',
        slug: 'flow-slug',
        title: 'flow-title',
        external_related_links: []
      )
      content_item = FlowContentItem.new(presenter)

      assert_equal "/flow-slug", content_item.payload[:base_path]
    end
  end
end
