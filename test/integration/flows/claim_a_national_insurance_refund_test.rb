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

    should "ask why you are applying for a refund" do
      assert_current_node :why_are_you_applying_for_a_refund?
    end

    should "be outcome_5 if you shouldn't have paid" do
      add_response :shouldnt_have_paid
      assert_current_node :outcome_5
    end

    should "be outcome_1a if you paid too much" do
      add_response :paid_too_much
      assert_current_node :outcome_1a
    end

    should "be outcome_6 if you qualified for low earnings exemption" do
      add_response :low_earnings_exemption
      assert_current_node :outcome_6
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

    should "ask why you are applying for a refund" do
      assert_current_node :why_are_you_applying_for_a_refund?
    end

    should "be outcome_3 if shouldn't have paid" do
      add_response :shouldnt_have_paid
      assert_current_node :outcome_3
    end

    should "be outcome_4 if paid too much" do
      add_response :paid_too_much
      assert_current_node :outcome_4
    end
  end

  should "work with symbols as well as strings" do
    @responses = [:class_4, :paid_too_much]
    assert_current_node :outcome_4
  end
end

