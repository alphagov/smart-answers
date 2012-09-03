# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class MaternityPaternityCalculatorTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'maternity-paternity-calculator'
  end
  ## Q1
  should "ask what type of leave or pay you want to check" do
    assert_current_node :what_type_of_leave?
  end
  
  context "answer maternity" do
    setup do
      add_response :maternity
    end
    ## QM1
    should "ask when the baby due date is" do
      assert_current_node :baby_due_date_maternity?
    end
  end
  
  context "answer paternity" do
    setup do
      add_response :paternity
    end
    ## QP0
    should "ask whether to check for leave or pay for adoption" do
      assert_current_node :leave_or_pay_for_adoption?
    end
  end
end
