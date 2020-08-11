require "test_helper"

class SessionFlowTest < ActiveSupport::TestCase
  def session
    {}
  end

  context ".call" do
    should "return flow matching name" do
      flow = SessionFlow.call :coronavirus_find_support, :need_help_with, session
      assert flow.is_a?(CoronavirusFindSupportFlow)
    end

    should "raise error if flow does not exist" do
      assert_raise(SessionFlow::FlowNotFoundError) do
        SessionFlow.call :unknown, :need_help_with, session
      end
    end

    should "raise error if node does not exist" do
      assert_raise(SessionFlow::NodeNotFoundError) do
        SessionFlow.call :coronavirus_find_support, :unknown, session
      end
    end
  end
end
