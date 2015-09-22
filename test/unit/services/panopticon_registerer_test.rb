require 'test_helper'

class PanopticonRegistererTest < ActiveSupport::TestCase
  def test_sending_item_to_panopticon
    request = stub_request(:put, %r[http://panopticon.dev.gov.uk/])
    registerables = [OpenStruct.new, OpenStruct.new]

    PanopticonRegisterer.new(registerables).register

    assert_requested(request, times: 2)
  end
end
