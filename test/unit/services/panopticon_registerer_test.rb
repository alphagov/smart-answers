require 'test_helper'

class PanopticonRegistererTest < ActiveSupport::TestCase
  def test_sending_item_to_panopticon
    request = stub_request(:put, %r[http://panopticon.dev.gov.uk/])
    registerables = [OpenStruct.new, OpenStruct.new]

    silence_logging do
      PanopticonRegisterer.new(registerables).register
    end

    assert_requested(request, times: 2)
  end

private

  # The registerer is quite noisy.
  def silence_logging
    silence_stream $stdout do
      silence_stream $stderr do
        yield
      end
    end
  end
end
