# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class CalculateStatutorySickPayTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'calculate-statutory-sick-pay'
  end

  context "Already getting maternity allowance" do
    context "Getting statutory maternity pay" do
      should "go to result A1" do
        add_response "statutory_maternity_pay"
        assert_current_node :already_getting_maternity # A1
      end
    end

    context "Getting maternity allowance" do
      should "go to result A1" do
        add_response "maternity_allowance"
        assert_current_node :already_getting_maternity # A1
      end
    end

    context "Not getting maternity allowance" do
      setup do
        add_response "ordinary_statutory_paternity_pay,statutory_adoption_pay"
      end

      should "set adoption warning state variable" do
        assert_state_variable :paternity_maternity_warning, true
      end
      should "take you to Q2" do
        assert_current_node :employee_tell_within_limit? # Q2
      end
    end
    context "Not getting maternity allowance" do
      setup do
        add_response "additional_statutory_paternity_pay"
      end

      should "set adoption warning state variable" do
        assert_state_variable :paternity_maternity_warning, true
      end
      should "take you to Q2" do
        assert_current_node :employee_tell_within_limit? # Q2
      end

      context "employee didn't tell employer within time limit" do
        setup do
          add_response :no
        end
        should "ask if employee works different days of the week" do
          assert_current_node :employee_work_different_days?
        end

        context "answer no" do
          setup do
            add_response :no
          end
          should "ask when the first sick day was" do
            assert_current_node :first_sick_day?
          end

          context "answer 2 March 2014" do
            setup do
              add_response Date.parse('2 March 2014')
            end
            should "ask when the last sick day was" do
              assert_current_node :last_sick_day?
            end

            context "answer 2 June 2014" do
              setup do
                add_response Date.parse('2 June 2014')
              end
              should "ask if employer paid 8 weeks of earnings" do
                assert_current_node :paid_at_least_8_weeks?
              end

              context "answer before_payday" do
                setup do
                  add_response 'before_payday'
                end
                should "ask how often employee is paid" do
                  assert_current_node :how_often_pay_employee_pay_patterns?
                end

                context "answer irregularly" do
                  setup do
                    add_response 'irregularly'
                  end
                  should "ask how much they would have been paid on first payday" do
                    assert_current_node :pay_amount_if_not_sick?
                  end

                  context "answer £3000" do
                    setup do
                      add_response '3000'
                    end
                    should "ask how many days earnings cover" do
                      assert_current_node :contractual_days_covered_by_earnings?
                    end

                    context "answer 17 days" do
                      setup do
                        add_response '17'
                      end
                      should "ask if employee was off sick the previous 8 weeks for 4 days" do
                        assert_current_node :off_sick_4_days?
                      end

                      context "answer no" do
                        setup do
                          add_response 'no'
                        end
                        should "ask which days of the week they usually work" do
                          assert_current_node :usual_work_days?
                        end

                        context "answer monday to friday" do
                          setup do
                            add_response '1,2,3,4,5'
                          end
                          should "go to entitled_to_sick_pay outcome" do
                            assert_current_node :entitled_to_sick_pay
                            assert_phrase_list :proof_of_illness, [:enough_notice]
                            assert_phrase_list :paternity_adoption_warning, [:paternity_warning]
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end # answer no to employer told in time

      context "employee told employer within time limit" do
        setup do
          add_response :yes
        end
        should "take you to Q3" do
          assert_current_node :employee_work_different_days? # Q3
        end

        context "employee works different days of the week" do
          setup do
            add_response :yes
          end
          should "go to result A4" do
            assert_current_node :not_regular_schedule # A4
          end
        end

        context "employee works regular days" do
          setup do
            add_response :no
          end
          should "take them to Q4" do
            assert_current_node :first_sick_day? # Q4
          end

          context "answering first sick day" do
            setup do
              add_response '02/04/2013'
            end

            should "store response and move to Q5" do
              assert_state_variable :sick_start_date, ' 2 April 2013'
              assert_current_node :last_sick_day? # Q5
            end

            context "answering last sick day" do
              context "last sick day is less than 3 days after first" do
                setup do
                  add_response '04/04/2013'
                end
                should "take you to result A2" do
                  assert_current_node :must_be_sick_for_4_days # A2
                end
              end

              context "last sick day is 3 days or more after first" do
                setup do
                  add_response '10/04/2013'
                end
                should "store last sick day" do
                  assert_state_variable :sick_end_date, '10 April 2013'
                end

                should "ask had you paid employee at least 8 weeks" do # Q5.1
                  assert_current_node :paid_at_least_8_weeks?
                end
                # new 8 weeks question with three branches
                context "answer yes, paid at least 8 weeks" do
                  setup do
                    add_response 'eight_weeks_more'
                  end
                  should "ask how often you pay employees" do # Q 5.2
                    assert_current_node :how_often_pay_employee_pay_patterns?
                    assert_state_variable :eight_weeks_earnings, 'eight_weeks_more'
                  end

                  context "answer weekly" do
                    setup do
                      add_response 'weekly'
                    end
                    should "ask for last payday before start sick date" do # Q6
                      assert_current_node :last_payday_before_sickness?
                      assert_state_variable :pay_pattern, 'weekly'
                    end
                    context "enter last payday before start of sickness" do
                      setup do
                        add_response '31/03/2013'
                      end
                      should "ask for last normal payday before payday offset" do # Q6.1
                        assert_current_node :last_payday_before_offset?

                      end
                      context "enter last payday before offset" do
                        setup do
                          add_response '31/01/2013'
                        end
                        should "ask for total amount paid" do # Q 6.2
                          assert_current_node :total_employee_earnings?
                        end
                        context "enter total amount paid between paydays" do
                          setup do
                            add_response '4000'
                          end
                          should "ask about PIW" do # Q11
                            assert_current_node :off_sick_4_days?
                          end

                          context "answer yes" do
                            setup do
                              add_response :yes
                            end
                            should "ask for start date of linked period of sickness" do # Q11.1
                              assert_current_node :linked_sickness_start_date?
                            end
                            context "enter previous sickness start date" do
                              setup do
                                add_response ' 1/01/2013'
                              end
                              should "ask how many days sick the employee had in this previous period" do # Q12
                                assert_current_node :how_many_days_sick?
                              end
                              context "answer 6 days" do
                                setup do
                                  add_response '6'
                                end
                                should "ask which days of the week do they work" do # Q13
                                  assert_current_node :usual_work_days?
                                end
                                context "answer weekdays" do
                                  setup do
                                    add_response '1,2,3,4,5'
                                  end
                                  should "take you to result A6" do # A6
                                    assert_current_node :entitled_to_sick_pay
                                  end
                                end
                              end
                            end
                          end
                          context "answer no" do
                            setup do
                              add_response 'no'
                            end
                            should "ask which days of the week they work" do # Q13
                              assert_current_node :usual_work_days?
                            end
                            context "answer weekdays" do
                              setup do
                                add_response '1,2,3,4,5'
                              end
                              should "take you to result 6 without first days (no PIW)" do
                                assert_current_node :entitled_to_sick_pay
                                assert_phrase_list :entitled_to_esa, [:esa]
                                assert_phrase_list :paternity_adoption_warning, [:paternity_warning]
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end

                context "answer no, employee is new and fell sick before payday" do
                  setup do
                    add_response 'before_payday'
                  end
                  should "ask how often you pay employees" do # Q 5.2
                    assert_current_node :how_often_pay_employee_pay_patterns?
                  end
                  context "answer monthly" do
                    setup do
                      add_response 'monthly'
                    end
                    should "ask how much you would have paid on their first payday" do # Q7
                      assert_current_node :pay_amount_if_not_sick?
                    end
                    context "answer £2000" do
                      setup do
                        add_response '2000'
                      end
                      should "ask how many days the period covers" do # Q7.1
                        assert_current_node :contractual_days_covered_by_earnings?
                      end
                      context "answer 30" do
                        setup do
                          add_response '30'
                        end
                        should "ask abou PIW" do # Q11.1
                          assert_current_node :off_sick_4_days?
                        end

                        context "answer yes" do
                          setup do
                            add_response 'yes'
                          end
                          should "ask for start date of linked sickness" do # Q11
                            assert_current_node :linked_sickness_start_date?
                          end
                          context "enter previous sickness start date" do
                            setup do
                              add_response '12/03/2013'
                            end
                            should "ask how many previous sick days were taken" do # Q12
                              assert_current_node :how_many_days_sick?
                            end
                            context "answer 4" do
                              setup do
                                add_response '4'
                              end
                              should "ask which days they work" do # Q13
                                assert_current_node :usual_work_days?
                              end
                              context "answer three days a week" do
                                setup do
                                  add_response '1,2,3'
                                end
                                should "take you to result A6" do
                                  assert_current_node :entitled_to_sick_pay
                                end
                              end
                            end
                          end
                        end
                        context "answer no" do
                          setup do
                            add_response 'no'
                          end
                          should "ask which days of the week they work" do # Q13
                            assert_current_node :usual_work_days?
                          end
                          context "answer weekdays" do
                            setup do
                              add_response '1,2,3,4,5'
                            end
                            should "take you to result 6 without first days (no PIW)" do
                              assert_current_node :entitled_to_sick_pay
                            end
                          end
                        end
                      end
                    end
                  end
                end

                context "answer no, paid less than 8 weeks earnings" do
                  setup do
                    add_response :eight_weeks_less
                  end
                  should "ask what total earnings before sick start date" do # Q8
                    assert_current_node :total_earnings_before_sick_period?
                  end
                  context "answer £3000" do
                    setup do
                      add_response '3000'
                    end
                    should "ask how many days does this period cover" do # Q8.1
                      assert_current_node :days_covered_by_earnings?
                    end
                    context "answer 35 days" do
                      setup do
                        add_response '35'
                      end
                      should "ask the PIW question" do # Q11
                        assert_current_node :off_sick_4_days?
                      end
                      context "answer yes" do
                        setup do
                          add_response 'yes'
                        end
                        should "ask for start date of previous sickness" do # Q 11.1
                          assert_current_node :linked_sickness_start_date?
                        end
                        context "enter previous sickness start date" do
                          setup do
                            add_response '24/03/2013'
                          end
                          should "ask how many previous sick days were taken" do # Q12
                            assert_current_node :how_many_days_sick?
                          end
                          context "answer 5 days" do
                            setup do
                              add_response '5'
                            end
                            should "ask which days they work" do # Q13
                              assert_current_node :usual_work_days?
                            end
                            context "answer weekdays" do
                              setup do
                                add_response '1,2,3,4,5'
                              end
                              should "take you to result A6" do
                                assert_current_node :entitled_to_sick_pay
                              end
                            end
                          end
                        end
                      end
                      context "answer no" do
                        setup do
                          add_response 'no'
                        end
                        should "ask which days of the week they work" do # Q13
                          assert_current_node :usual_work_days?
                        end
                        context "answer weekdays" do
                          setup do
                            add_response '1,2,3,4,5'
                          end
                          should "take you to result 6 without first days (no PIW)" do
                            assert_current_node :entitled_to_sick_pay
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end # answer yes to employer told in time
    end
  end
  context "average weekly earnings is less than the LEL on sick start date" do
    setup do
      add_response 'none' # Q1
      add_response 'yes' # Q2
      add_response 'no' # Q3
      add_response '10/06/2013' # Q4
      add_response '20/06/2013' # Q5
      add_response 'before_payday' # Q5.1
      add_response 'weekly' # Q5.2
      add_response '100' # Q7
      add_response '7' # Q7.1
      add_response 'no' # Q11
    end
    should "take you to result A5 as awe < LEL (as of 10/06/2013)" do
      assert_state_variable :employee_average_weekly_earnings, 100
      assert_current_node :not_earned_enough
    end
  end

  context "no SSP payable as sickness period is < 4 days" do
    setup do
      add_response 'none'
      add_response 'yes'
      add_response 'no'
      add_response '10/06/2013'
      add_response '12/06/2013'
    end
    should "take you to result A7 - must be sick for at least 4 days in a row" do
      assert_current_node :must_be_sick_for_4_days
    end
  end

  context "no SSP payable as already had maximum" do
    setup do
      add_response 'none'
      add_response 'yes'
      add_response 'no'
      add_response '10/06/2013'
      add_response '20/06/2013'
      add_response 'eight_weeks_more'
      add_response 'monthly'
      add_response '31/05/2013'
      add_response '31/03/2013'
      add_response '4000'
      add_response 'yes'
      add_response '01/01/2013'
      add_response '183'
      add_response '1,2,3,4,5'
    end
    should "take you to result A8 as already claimed > 28 weeks (max amount)" do
      assert_current_node :maximum_entitlement_reached
    end
  end

  context "tabular output for final SSP calculation" do
    should "have the adjusted rates in place for the week crossing through 6th April" do
      add_response :ordinary_statutory_paternity_pay
      add_response :yes
      add_response :no
      add_response Date.parse("2013-01-07")
      add_response Date.parse("2013-05-03")
      add_response :eight_weeks_more
      add_response :monthly
      add_response Date.parse("2012-12-28")
      add_response Date.parse("2012-10-26")
      add_response 1600.0
      add_response :yes
      add_response Date.parse("2012-11-11")
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
                             " 6 April 2013|£86.28",
                             "13 April 2013|£86.70",
                             "20 April 2013|£86.70",
                             "27 April 2013|£86.70",
                             " 4 May 2013|£43.35"].join("\n")
    end

    should "have consistent rates for all weekly rates that are produced" do
      add_response :ordinary_statutory_paternity_pay
      add_response :yes
      add_response :no
      add_response Date.parse("2013-01-07")
      add_response Date.parse("2013-05-03")
      add_response :eight_weeks_more
      add_response :monthly
      add_response Date.parse("2012-12-28")
      add_response Date.parse("2012-10-26")
      add_response 1250.75
      add_response :yes
      add_response Date.parse("2012-11-09")
      add_response 23
      add_response "2,3,4"

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
                             " 6 April 2013|£85.85",
                             "13 April 2013|£86.70",
                             "20 April 2013|£86.70",
                             "27 April 2013|£86.70",
                             " 4 May 2013|£86.70"].join("\n")
    end

    should "show formatted weekly payment amounts with adjusted 3 days start amount (ordinary statutory paternity pay)" do
      add_response :ordinary_statutory_paternity_pay
      add_response :yes
      add_response :no
      add_response Date.parse("2013-01-07")
      add_response Date.parse("2013-05-03")
      add_response :eight_weeks_more
      add_response :irregularly
      add_response Date.parse("2012-12-28")
      add_response Date.parse("2012-10-26")
      add_response 3000.0
      add_response :no
      add_response "1,2,3,4"

      assert_current_node :entitled_to_sick_pay
      assert_state_variable :formatted_sick_pay_weekly_amounts,
                            ["12 January 2013|£21.47",
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
                             " 6 April 2013|£85.85",
                             "13 April 2013|£86.70",
                             "20 April 2013|£86.70",
                             "27 April 2013|£86.70",
                             " 4 May 2013|£86.70"].join("\n")

    end

    should "show formatted weekly payment amounts with adjusted 3 days start amount (additional statutory paternity pay)" do
      add_response :additional_statutory_paternity_pay
      add_response :yes
      add_response :no
      add_response Date.parse("2013-01-07")
      add_response Date.parse("2013-05-03")
      add_response :eight_weeks_more
      add_response :irregularly
      add_response Date.parse("2012-12-28")
      add_response Date.parse("2012-10-26")
      add_response 3000.0
      add_response :no
      add_response "1,2,3,4"

      assert_current_node :entitled_to_sick_pay
      assert_state_variable :formatted_sick_pay_weekly_amounts,
                            ["12 January 2013|£21.47",
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
                             " 6 April 2013|£85.85",
                             "13 April 2013|£86.70",
                             "20 April 2013|£86.70",
                             "27 April 2013|£86.70",
                             " 4 May 2013|£86.70"].join("\n")

    end
  end
end
