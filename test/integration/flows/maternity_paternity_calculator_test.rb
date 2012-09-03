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
        @two_months_from_now = 2.months.since(Date.today).strftime("%Y-%m-%d")
        add_response @two_months_from_now
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
        context "answer 2 months from now" do
          setup do
            add_response @two_months_from_now
          end
          ## QM4
          should "ask if the employee worked for you before or on this date" do
            assert_current_node :did_the_employee_work_for_you?
          end
          context "answer yes" do
            setup do
              add_response :yes
            end
            ## QM5
            should "ask if the employee is on your payroll" do
              assert_current_node :is_the_employee_on_your_payroll?
            end
            context "answer yes" do
              setup do
                add_response :yes
              end
              ## QM6
              should "ask what the employees average weekly earnings are" do
                assert_current_node :employees_average_weekly_earnings?
              end
            end
          end
        end
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
  end
end
