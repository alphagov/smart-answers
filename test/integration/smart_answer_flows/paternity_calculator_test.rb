require_relative '../../test_helper'
require_relative 'flow_test_helper'
require_relative '../../../lib/smart_answer/date_helper'

require "smart_answer_flows/maternity-paternity-calculator"

class PaternityCalculatorTest < ActiveSupport::TestCase
  include DateHelper
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::MaternityPaternityCalculatorFlow
  end
  ## Q1
  should "ask what type of leave or pay you want to check" do
    assert_current_node :what_type_of_leave?
  end

  context "answer paternity" do
    setup { add_response :paternity }
    context "given the date is April 9th (post 4th April changes)" do
      setup do
        Timecop.travel("2013-04-09")
      end

      teardown do
        Timecop.return
      end

      ## QP0
      should "ask whether to check for leave or pay for adoption" do
        assert_current_node :leave_or_pay_for_adoption?
      end

      context "answer no" do
        setup { add_response :no }

        ## QP1
        should "ask for the due date" do
          assert_current_node :baby_due_date_paternity?
        end

        context "due date given as 12 June 2013" do
          setup do
            add_response Date.parse("12 June 2013")
          end

          ## QP2
          should "ask for the birth date" do
            assert_current_node :baby_birth_date_paternity?
          end

          context "birth date given as 12 June 2013" do
            setup do
              add_response Date.parse("12 June 2013")
            end

            ## QP3
            should "ask if and what context the employee is responsible for the childs upbringing" do
              assert_current_node :employee_responsible_for_upbringing?
            end

            context "is biological father or partner and responsible for upbringing" do
              setup { add_response :yes }

              ## QP4
              should "ask if employee worked for you before employment_start" do
                assert_current_node :employee_work_before_employment_start?
              end

              context "answer yes" do
                setup { add_response :yes }

                # QP5
                should "ask if employee has an employee contract" do
                  assert_current_node :employee_has_contract_paternity?
                end

                context "answer yes" do
                  setup { add_response :yes }

                  # QP6
                  should "ask if employee is on payroll" do
                    assert_current_node :employee_on_payroll_paternity?
                  end

                  context "answer yes" do
                    setup { add_response :yes }

                    #QP7
                    should "ask if employee is still employed on birth date" do
                      assert_state_variable :on_payroll, "yes"
                      assert_current_node :employee_still_employed_on_birth_date?
                    end

                    context "answer yes" do
                      setup { add_response :yes }

                      #QP8
                      should "ask for employee start date" do
                        assert_current_node :employee_start_paternity?
                        assert_state_variable :date_of_birth, Date.parse("12 June 2013")
                      end

                      context "answer 12 June 2013" do
                        setup { add_response Date.parse("12 June 2013") }

                        #QP9
                        should "ask for employee paternity length" do
                          assert_current_node :employee_paternity_length?
                          assert_state_variable :leave_start_date, Date.parse("12 June 2013")
                        end

                        context "one week" do
                          setup { add_response "one_week" }

                          #QP10
                          should "ask last normal pay day" do
                            assert_current_node :last_normal_payday_paternity?
                            assert_state_variable :leave_end_date, Date.parse("18 June 2013")
                          end

                          context "answer 2 March 2013" do
                            setup { add_response Date.parse("2 March 2013") }

                            #QP11
                            should "ask for payday eight weeks before" do
                              assert_current_node :payday_eight_weeks_paternity?
                              assert_state_variable :payday_offset, Date.parse("6 January 2013")
                            end

                            context "answer 1 November 2012" do
                              setup { add_response Date.parse("1 November 2012") }

                              # QP12
                              should "ask for frequency of pay" do
                                assert_current_node :pay_frequency_paternity?
                              end

                              context "answer monthly" do
                                setup { add_response "monthly" }

                                ##QP13
                                should "ask for earnings between relevant period" do
                                  assert_current_node :earnings_for_pay_period_paternity?
                                end

                                context "answer above 109 a week for 8 weeks" do
                                  setup { add_response "1000" }

                                  #QP14
                                  should "ask weekly or usual pay dates for SPP" do
                                    assert_current_node :how_do_you_want_the_spp_calculated?
                                  end

                                  context "answer usual pay pattern monthly" do
                                    setup { add_response "usual_paydates" }

                                    #QP16
                                    should "ask when employee paid in the month" do
                                      assert_current_node :monthly_pay_paternity?
                                    end

                                    context "answer first or last day" do
                                      should "reach the result when answering first day" do
                                        add_response "first_day_of_the_month"
                                        assert_state_variable "has_contract", "yes"
                                        assert_current_node :paternity_leave_and_pay
                                      end

                                      should "reach the result when answering last day" do
                                        add_response "last_day_of_the_month"
                                        assert_current_node :paternity_leave_and_pay
                                      end
                                    end

                                    context "answer last working day" do
                                      setup { add_response "last_working_day_of_the_month" }
                                      should "ask which days of the week are worked" do
                                        assert_current_node :days_of_the_week_paternity?
                                      end

                                      should "accept the answer and go to outcome" do
                                        add_response "2,3,5"
                                        assert_current_node :paternity_leave_and_pay
                                      end
                                    end

                                    #QP17
                                    context "answer specific date in month" do
                                      setup { add_response "specific_date_each_month" }
                                      should "ask which date" do
                                        assert_current_node :specific_date_each_month_paternity?
                                      end
                                      should "accept an answer and go to the outcome" do
                                        add_response "25"
                                        assert_current_node :paternity_leave_and_pay
                                      end
                                    end

                                    context "answer certain week day in each month" do
                                      setup { add_response "a_certain_week_day_each_month" }

                                      #QP19
                                      should "ask particular day of the month" do
                                        assert_current_node :day_of_the_month_paternity?
                                      end

                                      context "answer friday" do
                                        setup { add_response 5 }

                                        #QP20
                                        should "ask employee pay day" do
                                          assert_current_node :pay_date_options_paternity?
                                        end

                                        context "answer second" do
                                          setup { add_response "second" }

                                          should "give the result" do
                                            assert_state_variable :pay_method, 'a_certain_week_day_each_month'
                                            assert_current_node :paternity_leave_and_pay
                                          end
                                        end #QP20 end
                                      end #QP19 end particular day of the month
                                    end #QP16 end when employee paid in the month
                                  end #QP14 end usual pay dates (monthly) for SPP

                                  context "answer standard weekly" do
                                    setup { add_response "weekly_starting" }

                                    #QP14 weekly outcome
                                    should "go to outcome" do
                                      assert_current_node :paternity_leave_and_pay
                                      assert_state_variable "has_contract", "yes"
                                      assert_state_variable :pay_dates_and_pay, "18 June 2013|£103.85"
                                    end
                                  end #QP14 end SPP calculated weekly
                                end #QP13 end earings above 109 between relevant period

                                context "answer less than 109 a week for 8 weeks" do
                                  setup { add_response "10"}

                                  should "go to outcome" do

                                    assert_state_variable :has_contract, "yes"
                                    assert_state_variable :lower_earning_limit, '107.00'
                                    assert_current_node :paternity_leave_and_pay
                                  end

                                end #QP 13 end earnings less than 109 between relevant period
                              end  #QP12 end pay freqency

                              context "answer weekly" do
                                should "flow though usual pay date weekly" do
                                  add_response "weekly"
                                  add_response "5000"
                                  add_response "usual_paydates"
                                  add_response "2013-01-01"
                                  assert_state_variable :average_weekly_earnings, '625.00'
                                  assert_state_variable :pay_dates_and_pay, "18 June 2013|£136.78"
                                  assert_current_node :paternity_leave_and_pay
                                end
                              end
                            end #QP11 end 8 weeks before
                          end #QP10 end last normal payday
                        end  #QP9 end paternity length
                      end #QP8 end paternity start date
                    end #QP7 end still employed on birthdate

                    context "answer no" do
                      setup { add_response :no }

                      #QP 8
                      should "ask when leave starts" do
                        assert_current_node :employee_start_paternity?
                      end

                      context "answer 1 April 2014 weeks" do
                        setup { add_response '2014-04-01' }

                        #QP9
                        should "ask length of leave" do
                          assert_current_node :employee_paternity_length?
                        end

                        context "answer 2 weeks" do
                          setup { add_response "two_weeks" }

                          should "go to outcome" do
                            assert_current_node :paternity_not_entitled_to_leave_or_pay
                          end
                        end # QP9 leave length
                      end #QP 8 leave start
                    end #QP7 end not employed on date of birth
                  end  # yes - QP6 on payroll

                  context "answer no" do
                    setup { add_response :no }

                    #QP7
                    should "ask leave start date" do
                      assert_current_node :employee_start_paternity?
                    end

                    context "answer 1 April 2014" do
                      setup { add_response '2014-04-01' }

                      #QP9
                      should "ask length of leave" do
                        assert_current_node :employee_paternity_length?
                      end

                      context "answer 2 weeks" do
                        setup { add_response 'two_weeks'}

                        should "go to outcome" do
                          assert_current_node :paternity_not_entitled_to_leave_or_pay
                        end
                      end
                    end #QP7 employed at birth date
                  end #QP 6 end employee not on payroll but has contract

                end #QP5 end has contract

                #QP4 - no employment contract
                context "answer no" do
                  setup { add_response :no }

                  #QP6 - not on payroll
                  should "ask if employee is on payroll" do
                    assert_current_node :employee_on_payroll_paternity?
                  end

                  context "answer no" do
                    setup { add_response :no }

                    should "not be entitled to leave or pay" do
                      assert_current_node :paternity_not_entitled_to_leave_or_pay
                    end
                  end #QP6 - not on payroll

                  context "usual weekly pay pattern no contract" do
                    should "flow though usual pay date weekly" do
                      add_response "yes"
                      add_response "yes"
                      add_response "2013-06-12"
                      add_response "one_week"
                      add_response "2013-01-01"
                      add_response "2012-11-01"
                      add_response "weekly"
                      add_response "3000"
                      add_response "usual_paydates"
                      add_response "2013-03-01"
                      assert_current_node :paternity_leave_and_pay
                      # assert_current_node :next_pay_day_paternity?
                    end
                  end
                end #QP5 - no employment contract
              end # worked for you before employment start

              context "answer no" do
                setup { add_response :no }

                should "go to outcome" do
                  assert_current_node :paternity_not_entitled_to_leave_or_pay
                end
              end #QP4 did not work at employment_start
            end #QP3 end
            #Q2 - not a father, partner nor husband
            context "answer no" do
              setup { add_response :no }

              should "state that they are not entitled to leave or pay because they're not responsible for upbringing" do
                assert_current_node :paternity_not_entitled_to_leave_or_pay
              end
            end
          end
        end #due date 3 months from now
      end #QP0 - no

      context "answer no with 2013/2014 figures" do
        should "flow though usual pay date weekly" do
          add_response "no"
          add_response "2014-05-01"
          add_response "2014-05-01"
          add_response "yes"
          add_response "yes"
          add_response "yes"
          add_response "yes"
          add_response "yes"
          add_response "2014-05-01"
          add_response "two_weeks"
          add_response "2014-01-17"
          add_response "2013-11-22"
          add_response "monthly"
          add_response "500"
          assert_current_node :paternity_leave_and_pay
          assert_state_variable :relevant_period, 'Saturday, 23 November 2013 and Friday, 17 January 2014'
          assert_state_variable :to_saturday_formatted, "Saturday, 18 January 2014"
          assert_state_variable :lower_earning_limit, '109.00'
        end
      end #QP0 no with 2013/2014 figures

      context "answer no with 2014/2015 figures" do
        should "flow though usual pay date weekly" do
          add_response "no"
          add_response "2014-07-26"
          add_response "2014-07-26"
          add_response "yes"
          add_response "yes"
          add_response "yes"
          add_response "yes"
          add_response "yes"
          add_response "22014-07-26"
          add_response "two_weeks"
          add_response "2014-04-06"
          add_response "2013-04-02"
          add_response "monthly"
          add_response "500"
          assert_current_node :paternity_leave_and_pay
          assert_state_variable :relevant_period, "Wednesday, 03 April 2013 and Sunday, 06 April 2014"
          assert_state_variable :to_saturday_formatted, "Saturday, 12 April 2014"
          assert_state_variable :lower_earning_limit, '111.00'
        end
      end #QP0 no with 2014/2015 figures

      # Paternity Adoption
      context "answer adoption" do
        setup { add_response "yes" }

        context "adoption but not responsible for upbringing" do
          should "go to not entitled to leave or pay outcome" do
            add_response "2014-01-01"
            add_response "2014-02-01"
            add_response "no"
            assert_current_node :paternity_not_entitled_to_leave_or_pay
          end
        end

        context "adoption but not worked for long enough" do
          should "go to not entitled to leave or pay outcome with right phraselist" do
            add_response "2014-01-01"
            add_response "2014-02-01"
            add_response "yes"
            add_response "no"
            assert_current_node :paternity_not_entitled_to_leave_or_pay
          end
        end

        context "answer yes for most questions to get to outcome" do
          should "flow through to paternity_leave_and_pay outcome" do
            add_response "2014-01-01"
            add_response "2014-02-01"
            add_response "yes"
            add_response "yes"
            add_response "yes"
            add_response "yes"
            add_response "yes"
            add_response "2014-02-02"
            add_response "two_weeks"
            add_response "2014-01-03"
            add_response "2013-11-08"
            add_response "monthly"
            add_response "4000"
            add_response "usual_paydates"
            add_response "last_day_of_the_month"
            assert_current_node :paternity_leave_and_pay
          end
        end

        context "answer no to contract" do
          should "flow through to paternity_leave_and_pay outcome" do
            add_response "2014-01-01"
            add_response "2014-02-01"
            add_response "yes"
            add_response "yes"
            add_response "no" # no contract
            add_response "yes"
            add_response "yes"
            add_response "2014-02-02"
            add_response "two_weeks"
            add_response "2014-01-03"
            add_response "2013-11-08"
            add_response "monthly"
            add_response "4000"
            add_response "usual_paydates"
            add_response "last_day_of_the_month"
            assert_current_node :paternity_leave_and_pay
          end
        end

        context "answer not employed at matched date" do
          should "show correct paternity adoption employed on date in phrase list" do
            add_response "2014-01-01"
            add_response "2014-02-01"
            add_response "yes"
            add_response "yes"
            add_response "no" # no contract
            add_response "yes"
            add_response "no" # not employed on matched date
            assert_current_node :paternity_not_entitled_to_leave_or_pay
          end
        end
      end
    end
  end
end
