# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class ClaimANationalInsuranceRefundTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'claim-a-national-insurance-refund'
  end

  should "ask what class of NI" do
    assert_equal :which_class?, node_for_responses([])
  end

  should "be outcome_1 for Class 1" do
    assert_equal :outcome_1, node_for_responses(['class_1'])
  end

  context "Class 2" do
    setup do
      @responses = ['class_2']
    end

    should "ask if you paid when you didn't need to" do
      assert_equal :did_you_pay_when_you_didnt_need_to?, node_for_responses(@responses)
    end

    should "be outcome_5 if yes" do
      @responses << 'yes'
      assert_equal :outcome_5, node_for_responses(@responses)
    end

    should "be outcome_1a if no" do
      @responses << 'no'
      assert_equal :outcome_1a, node_for_responses(@responses)
    end
  end

  should "be outcome_2 for Class 3" do
    assert_equal :outcome_2, node_for_responses(['class_3'])
  end

  context "Class 4" do
    setup do
      @responses = ['class_4']
    end

    should "ask if you paid when you didn't need to" do
      assert_equal :did_you_pay_when_you_didnt_need_to?, node_for_responses(@responses)
    end

    should "be outcome_3 if yes" do
      @responses << 'yes'
      assert_equal :outcome_3, node_for_responses(@responses)
    end

    should "be outcome_4 if no" do
      @responses << 'no'
      assert_equal :outcome_4, node_for_responses(@responses)
    end
  end

  should "work with symbols as well as strings" do
    assert_equal :outcome_4, node_for_responses([:class_4, :no])
  end
end

