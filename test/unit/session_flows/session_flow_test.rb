require "test_helper"

class SessionFlowTest < ActiveSupport::TestCase
  context ".call" do
    should "return flow matching name" do
      flow = SessionFlow.call :coronavirus_find_support, :need_help_with
      assert flow.is_a?(CoronavirusFindSupportFlow)
    end

    should "raise error if flow does not exist" do
      assert_raise(SessionFlow::FlowNotFoundError) do
        SessionFlow.call :unknown, :need_help_with
      end
    end

    should "raise error if node does not exist" do
      assert_raise(SessionFlow::NodeNotFoundError) do
        SessionFlow.call :coronavirus_find_support, :unknown
      end
    end
  end
end
