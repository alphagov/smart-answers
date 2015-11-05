require 'test_helper'

class ContentItemPublisherTest < ActiveSupport::TestCase
  setup do
    load_path = fixture_file('smart_answer_flows')
    SmartAnswer::FlowRegistry.stubs(:instance).returns(stub("Flow registry", find: @flow, load_path: load_path))
  end

  test 'sending item to content store' do
    request = stub_request(:put, "http://publishing-api.dev.gov.uk/content/bridge-of-death")
    presenter = FlowRegistrationPresenter.new(stub('flow', name: 'bridge-of-death', content_id: '3e6f33b8-0723-4dd5-94a2-cab06f23a685'))

    ContentItemPublisher.new.publish([presenter])

    assert_requested request
  end
end
