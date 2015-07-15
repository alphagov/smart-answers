require_relative '../../test_helper'
require_relative 'flow_test_helper'
require_relative '../../../lib/smart_answer/date_helper'

require "smart_answer_flows/maternity-paternity-calculator"

class AdoptionCalculatorTest < ActiveSupport::TestCase
  include DateHelper
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::MaternityPaternityCalculatorFlow
  end
  ## Q1
  should "ask what type of leave or pay you want to check" do
    assert_current_node :what_type_of_leave?
  end

  context "answer adoption" do
    setup { add_response :adoption }
    ## QA0
    should "ask if the check is for maternity or paternity leave" do
      assert_current_node :taking_paternity_leave_for_adoption?
    end
    context "answer no (i.e taking maternity leave)" do
      setup { add_response :no }
      ## QA1
      should "ask the date of the adoption match" do
        assert_current_node :date_of_adoption_match?
      end
      context "answer 2 January 2014" do
        setup { add_response Date.parse("2 January 2014") }
        ## QA2
        should "ask the date of the adoption placement" do
          assert_current_node :date_of_adoption_placement?
        end
        context "answer 2 February 2014" do
          setup { add_response Date.parse("2 February 2014") }
          ## QA3
          should "ask if the employee worked for you . . " do
            assert_current_node :adoption_did_the_employee_work_for_you?
          end
          context "answer yes - worked long enough" do
            setup { add_response :yes }
            ## QA4
            should "ask if the employee has a contract" do
              assert_current_node :adoption_employment_contract?
            end
            context "answer yes to contract" do
              setup { add_response :yes }
              ## QA5
              should "ask if the employee is on your payroll" do
                assert_state_variable "employee_has_contract_adoption", 'yes'
                assert_current_node :adoption_is_the_employee_on_your_payroll?
              end
              context "answer yes" do
                setup { add_response :yes }
                ## QA6
                should "ask when does leave start" do
                  assert_current_node :adoption_date_leave_starts?
                end
                context "give leave start date of 20 January 2014" do
                  setup { add_response Date.parse("20 January 2014") }
                  ## QA7
                  should "ask for last normal payday" do
                    assert_current_node :last_normal_payday_adoption?
                  end
                  context "answer 3 January" do
                    setup { add_response Date.parse("3 January 2014") }
                    ## QA8
                    should "ask for payday eight weeks" do
                      assert_current_node :payday_eight_weeks_adoption?
                    end
                    context "answer 8 November" do
                      setup { add_response Date.parse("8 November 2013") }
                      ## QA9
                      should "ask for the pay frequency" do
                        assert_current_node :pay_frequency_adoption?
                      end
                      context "answer monthly" do
                        setup { add_response "monthly" }
                        ## QA10
                        should "ask for earnings in relavent period" do
                          assert_current_node :earnings_for_pay_period_adoption?
                        end
                        context "answer £3000" do
                          setup { add_response 3000 }
                          ## QA11
                          should "ask how sap should be calculated" do
                            assert_state_variable :pay_pattern, "monthly"
                            assert_current_node :how_do_you_want_the_sap_calculated?
                          end
                          context "answer weekly_starting" do
                            setup { add_response "weekly_starting" }
                            # QA12
                            should "go to outcome" do
                              assert_current_node :adoption_leave_and_pay
                              assert_state_variable :average_weekly_earnings, "346.15"
                              assert_phrase_list :adoption_leave_info, [:adoption_leave_table]
                              assert_phrase_list :adoption_pay_info, [:adoption_pay_table]
                            end
                          end # weekly_starting
                          context "answer based on usual paydates" do
                            setup { add_response "usual_paydates" }
                            # QP16 - shared with paternity calculator
                            should "ask when in the month the employee is paid" do
                              assert_current_node :monthly_pay_paternity?
                            end
                            context "answer first day of the month" do
                              setup { add_response "first_day_of_the_month" }
                              should "go to outcome and show leave and pay results" do
                                assert_current_node :adoption_leave_and_pay
                                assert_phrase_list :adoption_leave_info, [:adoption_leave_table]
                                assert_phrase_list :adoption_pay_info, [:adoption_pay_table]
                              end
                            end # first day in month
                            context "answer specific day in month" do
                              setup { add_response "specific_date_each_month" }
                              # QP17 - shared with paternity calculator
                              should "ask what date in month employee is paid" do
                                assert_current_node :specific_date_each_month_paternity?
                              end
                              context "answer 20th" do
                                setup { add_response 20 }
                                should "go to outcome and show leave and pay tables" do
                                  assert_current_node :adoption_leave_and_pay
                                  assert_phrase_list :adoption_leave_info, [:adoption_leave_table]
                                  assert_phrase_list :adoption_pay_info, [:adoption_pay_table]
                                end
                              end
                            end # specific day in month
                            context "answer last working day of the month" do
                              setup { add_response "last_working_day_of_the_month" }
                              # QP18 - shared with paternity calculator
                              should "ask what days the employee works" do
                                assert_current_node :days_of_the_week_paternity?
                              end
                              context "answer monday to thursday" do
                                setup { add_response "1,2,3,4" }
                                should "go to outcome and show pay and leave tables" do
                                  assert_current_node :adoption_leave_and_pay
                                  assert_phrase_list :adoption_leave_info, [:adoption_leave_table]
                                  assert_phrase_list :adoption_pay_info, [:adoption_pay_table]
                                end
                              end
                            end # last working day of the month
                            context "answer a certain weekday in each month" do
                              setup { add_response "a_certain_week_day_each_month" }
                              #QP19 - shared with paternity calculator
                              should "ask what day of the month employee is paid" do
                                assert_current_node :day_of_the_month_paternity?
                              end
                              context "answer wednesday" do
                                setup { add_response 3 }
                                # QP20 - shared with paternity calculator
                                should "ask if employee paid on 1st, 2nd, 3rd or last Wednesday" do
                                  assert_current_node :pay_date_options_paternity?
                                  assert_state_variable :pay_day_in_week, "Wednesday"
                                end
                                context "answer last" do
                                  setup { add_response "last" }
                                  should "go to outcome and show pay tables" do
                                    assert_current_node :adoption_leave_and_pay
                                    assert_phrase_list :adoption_leave_info, [:adoption_leave_table]
                                    assert_phrase_list :adoption_pay_info, [:adoption_pay_table]
                                  end
                                end
                              end
                            end # a certain weekday in each month
                          end # usual paydates
                        end
                      end # pay employee monthly
                    end
                  end
                end
              end # on payroll
              context "answer not on payroll but has contract" do
                setup do
                  add_response :no
                  add_response Date.parse("20 January 2014") # leave start date
                end
                should "go to outcome . . . . " do
                  assert_current_node :adoption_leave_and_pay
                end
              end # not on payroll but has contract
            end # has contract
            context "answer no to contract" do
              setup do
                add_response :no # no contract
                add_response :no # not on payroll
              end
              should "go to outcome with not entitled to leave or pay phraselists" do
                assert_current_node :adoption_not_entitled_to_leave_or_pay
                assert_phrase_list :adoption_pay_info, [:adoption_not_entitled_to_pay_intro, :must_be_on_payroll, :adoption_not_entitled_to_pay_outro]
              end
            end # no contract and not on payroll
            context "answer no to contract" do
              setup do
                add_response :no
                add_response :yes # on payroll
                add_response Date.parse("20 January 2014")
                add_response Date.parse("3 January 2014")
                add_response Date.parse("8 November 2013")
                add_response "monthly"
                add_response 3000
                add_response "weekly_starting"
              end
              should "go through to outcome show pay table but not entitled to leave" do
                assert_current_node :adoption_leave_and_pay
                assert_phrase_list :adoption_leave_info, [:adoption_not_entitled_to_leave]
                assert_phrase_list :adoption_pay_info, [:adoption_pay_table]
              end
            end # no contract but on payroll
          end # worked long enough
          context "answer no - not worked long enough" do
            setup { add_response :no }
            should "go to outcome not entitled to leave or pay" do
              assert_current_node :adoption_not_entitled_to_leave_or_pay
            end
          end # not worked long enough
        end
      end
    end
  end
end
