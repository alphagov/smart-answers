require 'test_helper'

class ContentItemPublisherTest < ActiveSupport::TestCase
  test 'sending item to content store' do
    request = stub_request(:put, "http://publishing-api.dev.gov.uk/content/a-flow-name")
    presenter = FlowRegistrationPresenter.new(stub('flow', name: 'a-flow-name', content_id: '3e6f33b8-0723-4dd5-94a2-cab06f23a685'))

    ContentItemPublisher.new.publish([presenter])

    assert_requested request
  end
end
