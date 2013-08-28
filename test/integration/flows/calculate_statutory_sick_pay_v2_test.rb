# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class CalculateStatutorySickPayV2Test < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'calculate-statutory-sick-pay-v2'
  end

  context "Already getting maternity allowance" do
    context "Getting statutory maternity pay" do
      should "take them to outcome 1" do
        add_response "statutory_maternity_pay"
        assert_current_node :already_getting_maternity
      end
    end

    context "Getting maternity allowance" do
      should "take them to outcome 1" do
        add_response "maternity_allowance"
        assert_current_node :already_getting_maternity
      end
    end

    context "Not getting maternity allowance" do
      setup do
        add_response "ordinary_statutory_paternity_pay,statutory_adoption_pay"
      end

      should "set adoption warning state variable" do
        assert_state_variable :paternity_maternity_warning, true
      end

      should "take the user to Q2" do
        assert_current_node :employee_tell_within_limit?
      end

      context "employee didn't tell employer within time limit" do
        should "take them to answer 3" do
          add_response :no
          assert_current_node :didnt_tell_soon_enough
        end
      end

      context "employee told employer within time limit" do
        setup do
          add_response :yes
        end

        should "take them to Q3" do
          assert_current_node :employee_work_different_days?
        end

        context "employee works regular days" do
          setup do
            add_response :no
          end

          should "take them to Q4" do
            assert_current_node :first_sick_day?
          end

          context "answering first sick day" do
            setup do
              add_response "02/04/2012"
            end

            should "store response and move to Q5" do
              assert_state_variable :sick_start_date, " 2 April 2012"
              assert_current_node :last_sick_day?
            end

            context "answering last sick day" do
              context "last sick day is 3 days or more after first" do
                setup do
                  add_response "10/04/2012"
                end

                should "store last sick day" do
                  assert_state_variable :sick_end_date, "10 April 2012"
                end

                should "take user to Q6" do
                  assert_current_node :last_payday_before_sickness?
                end

                context "last pay day before sickness" do
                  context "enter date after sick start" do
                    setup do
                      add_response "11/04/2012"
                    end

                    should "raise error" do
                      assert_current_node :last_payday_before_sickness?, :error => true
                    end
                  end

                  context "enter date before sick start" do
                    setup do
                      add_response "01/04/2012"
                    end

                    should "store this date" do
                      assert_state_variable :relevant_period_to, " 1 April 2012"
                    end

                    should "store the offset as 8 weeks earlier" do
                      assert_state_variable :pay_day_offset, " 5 February 2012"
                    end

                    should "take user to next question" do
                      assert_current_node :last_payday_before_offset?
                    end

                    context "answer last payday before relevant period" do
                      context "with a valid date" do
                        setup do
                          add_response "01/02/2012"
                        end

                        should "calculate the relevant period as response + 1 day" do
                          assert_state_variable :relevant_period_from, " 2 February 2012"
                        end

                        should "ask how oftern you pay the employee" do
                          assert_current_node :how_often_pay_employee?
                        end

                        context "answer employee pay pattern" do
                          context "monthly" do
                            setup do
                              add_response :monthly
                            end

                            should "calculate the monthly_pattern_payments" do
                              assert_state_variable :monthly_pattern_payments, 2
                              assert_current_node :on_start_date_8_weeks_paid?
                            end
                          end # answering Q8 pay monthly

                          context "weekly" do
                            should "take user to Q9" do
                              add_response :weekly
                              assert_current_node :on_start_date_8_weeks_paid?
                            end
                          end # answering Q8 weekly

                          context "Answering Q9" do
                            setup do
                              add_response :monthly
                            end

                            should "take them to Q10 if they answer yes" do
                              add_response :yes
                              assert_current_node :total_employee_earnings?
                            end

                            should "take them to Q11 if they answer no" do
                              add_response :no
                              assert_current_node :employee_average_earnings?
                            end

                            context "Answering Q10" do
                              setup do
                                add_response :yes
                                add_response "100"
                              end

                              should "calculate the AWE" do
                                assert_state_variable :relevant_period_awe, 11.538461538461538, :round_dp => 6
                              end

                              should "take them to Answer 5 if value < LEL" do
                                assert_current_node :not_earned_enough
                              end
                            end
                            context "Answer no" do
                              setup do
                                add_response :no
                              end
                              should "ask the average weekly earnings over the 8 week period prior to sickness" do
                                assert_current_node :employee_average_earnings?
                              end
                              context "answer less than the lower earning limit" do
                                should "state they are not entitled to SSP" do
                                  add_response "100"
                                  assert_current_node :not_earned_enough
                                end
                              end
                              context "answer above the lower earning limit" do
                                setup do
                                  add_response "200"
                                end
                                should "ask if the employee was sick in the past 8 weeks" do
                                  assert_current_node :off_sick_4_days?
                                end
                                context "answer yes" do
                                  setup do
                                    add_response :yes
                                  end
                                  should "ask how many sick days" do
                                    assert_current_node :how_many_days_sick?
                                  end
                                  context "answer 88" do
                                    setup do
                                      add_response "88"
                                    end
                                    should "ask which days they usually work" do
                                      assert_current_node :usual_work_days?
                                    end
                                    context "answer Monday, Tuesday, Thursday" do
                                      setup do
                                        add_response "1,2,4"
                                      end
                                      should "state maximum entitlement has already been received" do
                                        assert_current_node :maximum_entitlement_reached
                                      end
                                    end # answering usual_work_days
                                  end # 88 previous sick days
                                  context "answer 80 and usually work Monday Tuesday and Thursday" do
                                    should "give the result" do
                                      add_response "80"
                                      add_response "1,2,4"
                                      assert_current_node :entitled_to_sick_pay
                                    end
                                  end # 80 previous sick days
                                end
                                context "answer no" do
                                  setup do
                                    add_response :no
                                  end
                                  should "ask which days they usually work" do
                                    assert_current_node :usual_work_days?
                                  end
                                end
                              end
                            end
                          end # Answering Q9
                        end # Answering Q8
                      end

                      context "Answering with invalid date" do
                        should "raise error" do
                          add_response "04/05/2012"
                          assert_current_node_is_error
                        end

                      end # Answering Q8 with invalid date

                    end # last payday before offset Q7
                  end
                end # last pay day before sickness Q6
              end # last sick day Q5

              context "last sick day is <3 days after first" do
                should "take user to A2" do
                  add_response "03/04/2012"
                  assert_current_node :must_be_sick_for_4_days
                end
              end

              context "last day is before first day (invalid)" do
                should "raise error" do
                  add_response "01/04/2012"
                  assert_current_node_is_error
                end
              end
            end
          end
        end

        context "employee works weird days" do
          should "take them to A4" do
            add_response :yes
            assert_current_node :not_regular_schedule
          end
        end
      end
    end

    should "produce the tabular output for an SSP calculation" do
      add_response :ordinary_statutory_paternity_pay
      add_response :yes
      add_response :no
      add_response Date.parse("2013-01-07")
      add_response Date.parse("2013-05-03")
      add_response Date.parse("2012-12-31")
      add_response Date.parse("2012-10-31")
      add_response :monthly
      add_response :yes
      add_response 1600.0
      add_response :yes
      add_response 8
      add_response "3,6"

      assert_current_node :entitled_to_sick_pay
      assert_state_variable :formatted_sick_pay_weekly_amounts,
                            ["12 January 2013|£85.85",
                             "19 January 2013|£85.85",
                             "26 January 2013|£85.85",
                             " 2 February 2013|£85.85",
                             " 9 February 2013|£85.85",
                             "16 February 2013|£85.85",
                             "23 February 2013|£85.85",
                             " 2 March 2013|£85.85",
                             " 9 March 2013|£85.85",
                             "16 March 2013|£85.85",
                             "23 March 2013|£85.85",
                             "30 March 2013|£85.85",
                             " 6 April 2013|£86.70",
                             "13 April 2013|£86.70",
                             "20 April 2013|£86.70",
                             "27 April 2013|£86.70"].join("\n")
    end
  end
end
