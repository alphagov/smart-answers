# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class ClaimANationalInsuranceRefundTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'claim-a-national-insurance-refund'
  end

  should "ask what class of NI" do
    assert_current_node :which_class?
  end

  should "be outcome_1 for Class 1" do
    add_response :class_1
    assert_current_node :outcome_1
  end

  context "Class 2" do
    setup do
      add_response :class_2
    end

    should "ask if you paid when you didn't need to" do
      assert_current_node :did_you_pay_when_you_didnt_need_to?
    end

    should "be outcome_5 if yes" do
      add_response :yes
      assert_current_node :outcome_5
    end

    should "be outcome_1a if no" do
      add_response :no
      assert_current_node :outcome_1a
    end
  end

  should "be outcome_2 for Class 3" do
    add_response :class_3
    assert_current_node :outcome_2
  end

  context "Class 4" do
    setup do
      add_response :class_4
    end

    should "ask if you paid when you didn't need to" do
      assert_current_node :did_you_pay_when_you_didnt_need_to?
    end

    should "be outcome_3 if yes" do
      add_response :yes
      assert_current_node :outcome_3
    end

    should "be outcome_4 if no" do
      add_response :no
      assert_current_node :outcome_4
    end
  end

  should "work with symbols as well as strings" do
    @responses = [:class_4, :no]
    assert_current_node :outcome_4
  end
end

