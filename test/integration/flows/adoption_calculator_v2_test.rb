# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'
require_relative '../../../lib/smart_answer/date_helper'

class AdoptionCalculatorV2Test < ActiveSupport::TestCase
  include DateHelper
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'maternity-paternity-calculator-v2'
  end
  ## Q1
  should "ask what type of leave or pay you want to check" do
    assert_current_node :what_type_of_leave?
  end

  context "answer adoption" do
    setup do
      add_response :adoption
    end
    ## QA0
    should "ask if the check is for maternity or paternity leave" do
      assert_current_node :taking_paternity_leave_for_adoption?
    end
    context "answer no (i.e taking maternity leave)" do
      setup do
        add_response :no
      end
      ## QA1
      should "ask the date of the adoption match" do
        assert_current_node :date_of_adoption_match?
      end
      context "answer 15 July 2012" do
        setup do
          add_response Date.parse("15 July 2012")
        end
        ## QA2
        should "ask the date of the adoption placement" do
          assert_current_node :date_of_adoption_placement?
        end
        context "answer 17 October 2012" do
          setup do
            add_response Date.parse("17 October 2012")
          end
          ## QA3
          should "ask if the employee has a contract" do
            assert_current_node :adoption_employment_contract?
          end
          context "answer yes to contract" do
            setup do
              add_response :yes
            end
            ## QA4
            should "ask when the employee wants to start their leave" do
              assert_state_variable "employee_has_contract_adoption", 'yes'
              assert_current_node :adoption_date_leave_starts?
            end
            context "answer 17 October 2012" do
              setup do
                add_response Date.parse("17 October 2012")
              end
              ## QA5
              should "ask if the employee worked for you before ..." do
                assert_current_node :adoption_did_the_employee_work_for_you?
              end
              should "return employment_start" do
                assert_state_variable "employment_start", Date.parse("2012 Jan 28")
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
                  ## QA6.2
                  should "ask for last normal payday" do
                    assert_current_node :last_normal_payday?
                  end

                  context "answer 21 July" do
                    setup { add_response Date.parse("21 July 2012") }

                    ## QA6.3
                    should "ask for payday eight weeks" do
                      assert_current_node :payday_eight_weeks?
                    end

                    context "answer 21 May " do
                      setup { add_response Date.parse ("21 May 2012")}

                      ## QA7
                      should "ask what the average weekly earnings of the employee" do
                        assert_current_node :adoption_employees_average_weekly_earnings?
                      end
                      context "answer below the lower earning limit" do
                        should "state they are entitled to leave but not entitled to pay" do
                          add_response 100
                          assert_phrase_list :adoption_leave_info, [:adoption_leave_table]
                          assert_phrase_list :adoption_pay_info, [:adoption_not_entitled_to_pay_intro, :must_earn_over_threshold, :adoption_not_entitled_to_pay_outro]
                          assert_current_node :adoption_leave_and_pay
                        end
                      end
                      context "answer above the earning limit" do
                        should "give adoption leave and pay details" do
                          add_response 200
                          assert_phrase_list :adoption_leave_info, [:adoption_leave_table]
                          assert_phrase_list :adoption_pay_info, [:adoption_pay_table]
                          assert_current_node :adoption_leave_and_pay
                        end
                      end
                    end
                  end
                end # yes to QA6 - on payroll
                context "answer no" do
                  should " state they are entitled to leave but not entitled to pay" do
                    add_response :no
                    assert_phrase_list :adoption_leave_info, [:adoption_leave_table]
                    assert_phrase_list :adoption_pay_info, [:adoption_not_entitled_to_pay_intro, :must_be_on_payroll, :adoption_not_entitled_to_pay_outro]
                    assert_current_node :adoption_leave_and_pay
                  end
                end
              end # yes to QA5 - worked for you before
              context "answer no" do
                should "state they are not entitled to leave or pay" do
                  add_response :no
                  assert_current_node :adoption_not_entitled_to_leave_or_pay
                end
              end
            end
          end # yes to QA3 - has a contract
          # now run through the branch where there is no contract as that means not entitled to leave
          context "answer no to contract" do
            setup do
              add_response :no
            end
            should "ask when the employee wants to start their leave" do
              assert_state_variable "employee_has_contract_adoption", 'no'
              assert_current_node :adoption_date_leave_starts?
            end
            context "answer 17 October 2012" do
              setup do
                add_response Date.parse("17 October 2012")
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

                  ## QA6.2
                  should "ask for last normal payday" do
                    assert_current_node :last_normal_payday?
                  end

                  context "answer 1 July" do
                    setup { add_response Date.parse("1 July 2012") }

                    ## QA6.3
                    should "ask for payday eight weeks" do
                      assert_current_node :payday_eight_weeks?
                    end

                    context "answer 1 May " do
                      setup { add_response Date.parse ("1 May 2012")}

                      ## QA7
                      should "ask what the average weekly earnings of the employee" do
                        assert_current_node :adoption_employees_average_weekly_earnings?
                      end
                      context "answer below the lower earning limit" do
                        should "state they are not entitled to leave and not entitled to pay" do
                         add_response 100
                          assert_phrase_list :adoption_leave_info, [:adoption_not_entitled_to_leave]
                          assert_phrase_list :adoption_pay_info, [:adoption_not_entitled_to_pay_intro, :must_earn_over_threshold, :adoption_not_entitled_to_pay_outro]
                          assert_current_node :adoption_leave_and_pay
                        end
                      end
                      context "answer above the earning limit" do
                        should "not entitled to leave but entitled to pay" do
                          add_response 200
                          assert_phrase_list :adoption_leave_info, [:adoption_not_entitled_to_leave]
                          assert_phrase_list :adoption_pay_info, [:adoption_pay_table]
                          assert_current_node :adoption_leave_and_pay
                        end
                      end
                    end
                  end
                end # yes to QA6 - on payroll
                context "answer no" do
                  should " state they are not entitled to leave nor pay" do
                    add_response :no
                    assert_phrase_list :adoption_leave_info, [:adoption_not_entitled_to_leave]
                    assert_phrase_list :adoption_pay_info, [:adoption_not_entitled_to_pay_intro, :must_be_on_payroll, :adoption_not_entitled_to_pay_outro]
                    assert_current_node :adoption_leave_and_pay
                  end
                end
              end # yes to QA5 - worked for you before
              context "answer no" do
                should "state they are not entitled to leave or pay" do
                  add_response :no
                  assert_current_node :adoption_not_entitled_to_leave_or_pay
                end
              end
            end
          end # no to contract (QA3)
        end
      end
    end
  end
end
