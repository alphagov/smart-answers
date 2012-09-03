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
    context "answer 2 months from now" do
      setup do
        add_response 2.months.since(Date.today).strftime("%Y-%m-%d")
      end
      ## QM2
      should "ask if the employee has a contract with you" do
        assert_current_node :employment_contract?
      end
      context "answer yes" do
        setup do
          add_response :yes
        end
        ## QM3
        should "ask when the employee wants to start their leave" do
          assert_current_node :date_leave_starts?
        end
#        context "answer 2 months from now" do
#          setup do
#          end
#          
#          should "" do
#          end
#        end
      end
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

    context "answer yes" do
      setup do
        add_response :yes
      end
      ## QP1
      should "ask for the due date" do
        assert_current_node :baby_due_date_paternity?
      end
    end
    context "answer no" do
      setup do
        add_response :no
      end
      ## QP1
      should "ask for the child was matched with employee" do
        assert_current_node :employee_date_matched_paternity_adoption?
      end
    end
  end
end
