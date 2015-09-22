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

  def test_sending_correct_data_to_panopticon
    stub_request(:put, "http://panopticon.dev.gov.uk/artefacts/a-smart-answer.json").
      with(body: {
        slug: "a-smart-answer",
        owning_app: "smartanswers",
        kind: "smart-answer",
        name: "The Smart Answer.",
        description: nil,
        state: nil,
    })

    registerable = OpenStruct.new(
      slug: 'a-smart-answer',
      title: 'The Smart Answer.',
    )

    silence_logging do
      PanopticonRegisterer.new([registerable]).register
    end
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
