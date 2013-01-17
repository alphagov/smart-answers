require_relative "../../test_helper"
require_relative "flow_test_helper"

class RequestForFlexibleWorkingTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow "request-for-flexible-working"
  end

  # Q1
  should "ask if employee or employer" do
    assert_current_node :are_you_an_employee_or_employer?
  end

  context "employee" do
    setup do
      add_response :employee
    end

    should "ask which one describes you" do
      assert_current_node :which_one_of_these_describes_you?
    end

    context "selecting 'under_17' and 'care_for_adult'" do
      should "show result 1 if 'under_17' and 'care_for_adult' selected" do
        add_response "under_17,care_for_adult"
        assert_current_node :no_right_to_apply
      end

      should "show result 1 if 'under_17', 'care_for_aduly', and 'less_than_26_weeks' selected" do
        # As per the logic documentation this test is in place to make
        # sure that when 'under_17' and 'care_for_adult' are checked
        # as well as any permutation of the other options (minus
        # 'none_of_these') that we show the :no_right_to_apply outcome.
        add_response "under_17,care_for_adult,less_than_26_weeks"
        assert_current_node :no_right_to_apply
      end
    end

    context "selecting permutations of 'less_than_26_weeks', 'agency_worker', 'member_of_armed_forces', and 'request_in_last_12_months'" do
      should "show result 1 if 'less_than_26_weeks', 'agency_worker', 'member_of_armed_forces', and 'request_in_last_12_months' checked" do
        add_response "less_than_26_weeks,agency_worker,member_of_armed_forces,request_in_last_12_months"
        assert_current_node :no_right_to_apply
      end

      should "show result 1 if 'less_than_26_weeks' selected" do
        add_response "less_than_26_weeks"
        assert_current_node :no_right_to_apply
      end

      should "show result 1 if 'less_than_26_weeks' and 'agency_worker' selected" do
        add_response "less_than_26_weeks,agency_worker"
        assert_current_node :no_right_to_apply
      end

      should "show result 1 if 'member_of_armed_forces' and 'request_in_last_12_months' selected" do
        add_response "member_of_armed_forces,request_in_last_12_months"
        assert_current_node :no_right_to_apply
      end
    end

    should "show result 1 if 'none_of_these' selected" do
      add_response "none_of_these"
      assert_current_node :no_right_to_apply
    end

    context "selecting 'under_17'" do
      setup do
        add_response "under_17"
      end

      should "ask if they are responible for the child" do
        assert_current_node :responsible_for_childs_upbringing?
      end

      should "show result 1 if 'no' selected" do
        add_response "no"
        assert_current_node :no_right_to_apply
      end

      should "show result 2 if 'yes' selected" do
        add_response "yes"
        assert_current_node :right_to_apply
      end
    end

    context "selecting 'care_for_adult'" do
      setup do
        add_response "care_for_adult"
      end

      should "ask about the adult being cared for" do
        assert_current_node :do_any_of_these_describe_the_adult_youre_caring_for?
      end

      should "show result 2 if 'yes' selected" do
        add_response "yes"
        assert_current_node :right_to_apply
      end

      should "show result 1 if 'no' selected" do
        add_response "no"
        assert_current_node :no_right_to_apply
      end
    end
  end

  context "employer" do
    setup do
      add_response :employer
    end
  end
end
