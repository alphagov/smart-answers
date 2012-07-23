require_relative "../../test_helper"
require_relative "flow_test_helper"

class RequestForFlexibleWorkingTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow "request-for-flexible-working"
  end

  should "ask to tick boxes that apply" do
    assert_current_node :tick_boxes_that_apply?
  end

  context "under continuous employment and not applied for flexible working" do
    setup do
      add_response "employee,continuous_employment,not_applied_for_flexible_working"
    end

    should "ask about child care" do
      assert_current_node :caring_for_child?
    end
  end

  context "in armed forces" do
    should "not be allowed to apply" do
      add_response "employee,armed_forces"
      assert_current_node :no_right_to_apply
    end
  end
end