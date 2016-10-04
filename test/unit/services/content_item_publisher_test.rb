require 'test_helper'

class ContentItemPublisherTest < ActiveSupport::TestCase
  setup do
    load_path = fixture_file('smart_answer_flows')
    SmartAnswer::FlowRegistry.stubs(:instance).returns(stub("Flow registry", find: @flow, load_path: load_path))
  end

  test 'sending item to content store' do
    draft_request = stub_request(:put, "http://publishing-api.dev.gov.uk/v2/content/3e6f33b8-0723-4dd5-94a2-cab06f23a685")
    publishing_request = stub_request(:post, "http://publishing-api.dev.gov.uk/v2/content/3e6f33b8-0723-4dd5-94a2-cab06f23a685/publish")

    presenter = FlowRegistrationPresenter.new(stub('flow', name: 'bridge-of-death', content_id: '3e6f33b8-0723-4dd5-94a2-cab06f23a685'))

    ContentItemPublisher.new.publish([presenter])

    assert_requested draft_request
    assert_requested publishing_request
  end
end
