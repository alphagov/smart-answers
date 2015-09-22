require 'test_helper'

class PanopticonRegistererTest < ActiveSupport::TestCase
  def test_sending_item_to_panopticon
    request = stub_request(:put, %r[http://panopticon.dev.gov.uk/])

    PanopticonRegisterer.new.register

    assert_requested(request, times: 42)
  end
end
