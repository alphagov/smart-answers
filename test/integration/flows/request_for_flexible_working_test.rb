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

    context "not caring" do
      should "not be allowed to apply" do
        add_response :neither
        assert_current_node :no_right_to_apply
      end
    end

    context "caring for child" do
      setup do
        add_response :caring_for_child
      end
      
      should "ask what the relationship is" do
        assert_current_node :relationship_with_child?
      end

      context "parent and responsible for child" do
        should "be allowed to apply" do
          add_response "relationship,responsible_for_upbringing"
          assert_current_node :right_to_apply
        end
      end

      context "relationship but not responsible for child" do
        should "not be allowd to apply" do
          add_response "relationship"
          assert_current_node :no_right_to_apply
        end
      end
    end

    context "caring for adult" do
      setup do
        add_response :caring_for_adult
      end

      should "ask what the relationship is" do
        assert_current_node :relationship_with_adult?
      end

      context "not one of these" do
        should "not be allowed to apply" do
          add_response :not_one_of_these
          assert_current_node :no_right_to_apply
        end
      end

      context "one of these" do
        should "allowed to apply" do
          add_response :one_of_these
          assert_current_node :right_to_apply
        end
      end
    end
  end

  context "in armed forces" do
    should "not be allowed to apply" do
      add_response "employee,armed_forces"
      assert_current_node :no_right_to_apply
    end
  end
end