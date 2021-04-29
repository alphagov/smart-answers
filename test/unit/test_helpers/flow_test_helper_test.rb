require_relative "../../test_helper"
require_relative "../../integration/smart_answer_flows/flow_test_helper"

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
    state_resolver = stub("state_resolver", state_from_params: :state)
    SmartAnswer::StateResolver.expects(:new).once.returns(state_resolver)
    includer = FlowTestHelperIncluder.new(stub("flow"), %i[yes no])
    includer.current_state
    includer.current_state
  end

  test "busts current_state cache when responses change" do
    state_resolver = stub("state_resolver", state_from_params: :state)
    SmartAnswer::StateResolver.expects(:new).twice.returns(state_resolver)
    responses = %i[yes no]
    includer = FlowTestHelperIncluder.new(stub("flow"), responses)
    includer.current_state
    responses << :maybe
    includer.current_state
  end
end
