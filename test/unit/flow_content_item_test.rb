require_relative '../test_helper'

module SmartAnswer
  class FlowContentItemTest < ActiveSupport::TestCase
    include GovukContentSchemaTestHelpers::TestUnit

    test '#payload returns a valid content-item' do
      presenter = FlowRegistrationPresenter.new(stub('flow', name: 'a-flow-name', content_id: '3e6f33b8-0723-4dd5-94a2-cab06f23a685'))
      content_item = FlowContentItem.new(presenter)

      payload = content_item.payload

      assert_valid_against_schema(payload, 'placeholder')
    end

    test '#base_path is the name of the flow' do
      presenter = FlowRegistrationPresenter.new(stub('flow', name: 'a-flow-name'))
      content_item = FlowContentItem.new(presenter)

      base_path = content_item.base_path

      assert_equal "/a-flow-name", base_path
    end
  end
end
