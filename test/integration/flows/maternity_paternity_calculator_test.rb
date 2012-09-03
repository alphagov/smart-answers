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
  
  ##
  ## Maternity flow
  ##
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
          context "answer no" do
            should "" do
              add_response :no
              assert_current_node :not_entitled_to_statutory_maternity_pay
            end
          end
        end
      end # Yes to employee has contract?
      ## Employee has contract?
      context "answer no" do
        should "state that the employee is not entitled to maternity leave or pay" do
          add_response :no
          assert_current_node :not_entitled_to_statutory_maternity_leave
        end
      end
    end
  end # Maternity flow
  
  
  ##
  ## Paternity flow
  ##
  context "answer paternity" do
    setup do
      add_response :paternity
    end
    ## QP0
    should "ask whether to check for leave or pay for adoption" do
      assert_current_node :leave_or_pay_for_adoption?
    end

    context "answer no" do
      setup do
        add_response :no
      end
      ## QP1
      should "ask for the due date" do
        assert_current_node :baby_due_date_paternity?
      end

      context "due date given as 3 months from now" do
        setup { add_response 3.months.since(Date.today).strftime("%Y-%m-%d") }
        
        ## QP2 
        should "ask if and what context the employee is responsible for the childs upbringing" do
          assert_current_node :employee_responsible_for_upbringing?
        end

        context "is biological father" do
          setup { add_response :biological_father? }
          
          ## QP3
          should "ask if employee worked for you before employment_start" do
            assert_current_node :employee_work_before_employment_start? 
          end

          context "answer yes" do
            setup { add_response :yes }

            should "ask if employee has an employee contract" do
              assert_current_node :employee_has_contract_paternity?
            end

            context "answer yes" do
              setup { add_response :yes }

              should "ask if employee will be employed at employment_end" do
                assert_current_node :employee_employed_at_employment_end_paternity?
              end
            end
          end

          context "answer no" do
            # TODO: write test
          end
        end
        context "is mother's husband or partner" do
          setup { add_response :mothers_husband_or_partner? }
          ## QP3
          should "ask if employee worked for you before employment_start" do
            assert_current_node :employee_work_before_employment_start? 
          end
        end
      end

     end


    context "answer yes" do
      setup { add_response :yes }
      ## QP1
      should "ask for the child was matched with employee" do
        assert_current_node :employee_date_matched_paternity_adoption?
      end
    end
  end # Paternity flow
  
  ##
  ## Adoption flow
  ##
  context "answer adoption" do
    setup do
      add_response :adoption
    end
    ## QA0
    should "ask if the check is for maternity or paternity leave" do
      assert_current_node :maternity_or_paternity_leave_for_adoption?
    end
    context "answer maternity" do
      setup do
        add_response :maternity
      end
      ## QA1
      should "ask the date of the adoption match" do
        assert_current_node :date_of_adoption_match?
      end
      context "answer 1 month ago" do
        setup do
          add_response 1.month.ago.strftime("%Y-%m-%d")
        end
        ## QA2
        should "ask the date of the adoption placement" do
          assert_current_node :date_of_adoption_placement?
        end
        context "answer 1 month from now" do
          setup do
            add_response 1.month.since(Date.today).strftime("%Y-%m-%d")
          end
          ## QA3
          should "ask if the employee has a contract" do
            assert_current_node :adoption_employment_contract?
          end
          context "answer yes" do
            setup do
              add_response :yes
            end
            ## QA4
            should "ask when the employee wants to start their leave" do
              assert_current_node :adoption_date_leave_starts?
            end
            context "answer 1 month form now" do
              setup do
                add_response 1.month.since(Date.today).strftime("%Y-%m-%d")
              end
              ## QA5
              should "ask if the employee worked for you before ..." do
                assert_current_node :adoption_did_the_employee_work_for_you?
              end
              context "answer yes" do
                setup do
                  add_response :yes
                end
                ## QA6
                should "ask if the employee is on your payroll" do
                  assert_current_node :adoption_is_the_employee_on_your_payroll?
                end
                context "answer yes" do
                  setup do
                    add_response :yes
                  end
                  ## QA7
                  should "ask what the average weekly earnings of the employee" do
                    assert_current_node :adoption_employees_average_weekly_earnings?
                  end
                end
                context "answer no" do
                  should " state they are not entitled to pay" do
                    add_response :no
                    assert_current_node :adoption_not_entitled_to_pay
                  end
                end
              end
              context "answer no" do
                should "state they are not entitled to leave" do
                  add_response :no
                  assert_current_node :adoption_not_entitled_to_leave_or_pay
                end
              end
            end
          end
          context "answer no" do
            should "state that they are not entitled to leave or pay" do
              add_response :no
              assert_current_node :adoption_not_entitled_to_leave
            end
          end
        end
      end
    end
  end
end
