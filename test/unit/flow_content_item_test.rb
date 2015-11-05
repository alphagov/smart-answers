require_relative '../test_helper'

module SmartAnswer
  class FlowContentItemTest < ActiveSupport::TestCase
    include GovukContentSchemaTestHelpers::TestUnit

    setup do
      load_path = fixture_file('smart_answer_flows')
      SmartAnswer::FlowRegistry.stubs(:instance).returns(stub("Flow registry", find: @flow, load_path: load_path))
    end

    test '#payload returns a valid content-item' do
      presenter = FlowRegistrationPresenter.new(stub('flow', name: 'bridge-of-death', content_id: '3e6f33b8-0723-4dd5-94a2-cab06f23a685'))
      content_item = FlowContentItem.new(presenter)

      payload = content_item.payload

      assert_valid_against_schema(payload, 'placeholder')
    end

    test '#base_path is the name of the flow' do
      presenter = FlowRegistrationPresenter.new(stub('flow', name: 'bridge-of-death', content_id: '25b98dfb-fabe-4b16-b587-072c8233f6bc'))
      content_item = FlowContentItem.new(presenter)

      base_path = content_item.payload[:base_path]

      assert_equal "/bridge-of-death", base_path
    end
  end
end
