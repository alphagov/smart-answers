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
  end
end
