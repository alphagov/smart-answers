require_relative '../../test_helper'
require_relative '../../integration/smart_answer_flows/flow_test_helper'

class FlowTestHelperTest < ActiveSupport::TestCase

  class FlowTestHelperIncluder
    include FlowTestHelper
    attr_accessor :responses

    def initialize(flow, responses)
      @flow = flow
      @responses = responses
    end
  end


  test "caches current_state" do
    flow = mock('flow')
    flow.expects(:process).once.returns(:state)
    includer = FlowTestHelperIncluder.new(flow, [:yes, :no])
    includer.current_state
    includer.current_state
  end

  test "busts current_state cache when responses change" do
    flow = mock('flow')
    flow.expects(:process).twice.returns(:state)
    responses = [:yes, :no]
    includer = FlowTestHelperIncluder.new(flow, responses)
    includer.current_state
    responses << :maybe
    includer.current_state
  end
end
