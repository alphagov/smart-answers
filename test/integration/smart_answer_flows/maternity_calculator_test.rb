require_relative '../../test_helper'
require_relative 'flow_test_helper'
require_relative '../../../lib/smart_answer/date_helper'

require "smart_answer_flows/maternity-paternity-calculator"

class MaternityCalculatorTest < ActiveSupport::TestCase
  include DateHelper
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::MaternityPaternityCalculatorFlow
  end
  ## Q1
  should "ask what type of leave or pay you want to check" do
    assert_current_node :what_type_of_leave?
  end

  context "answer maternity" do
    setup do
      add_response :maternity
    end

    context "given the date is April 9th (after changes)" do
      setup do
        Timecop.travel("2013-04-09")
      end

      teardown do
        Timecop.return
      end

      ## QM1
      should "ask when the baby due date is" do
        assert_current_node :baby_due_date_maternity?
      end

      context "test lower earning limits returned" do
        should "return lower_earning_limit of £107" do
          dd = Date.parse("1 January 2013")
          add_response dd
          add_response :yes
          add_response 1.month.ago(dd)
          add_response :yes
          add_response :yes
          add_response Date.parse("10 September 2012")
          add_response Date.parse("10 July 2012")
          add_response "weekly"
          add_response "200"
          add_response "weekly_starting"
          assert_state_variable "lower_earning_limit", sprintf("%.2f", 107)
        end
        should "return lower_earning_limit of £102" do
          dd = Date.parse("1 January 2012")
          add_response dd
          add_response :yes
          add_response 1.month.ago(dd)
          add_response :yes
          add_response :yes
          add_response Date.parse("10 September 2011")
          add_response Date.parse("10 July 2011")
          add_response "weekly"
          add_response "200"
          add_response "weekly_starting"
          assert_state_variable "lower_earning_limit", sprintf("%.2f", 102)
        end
      end

      context "answer 21 November 2012" do
        setup do
          @dd = Date.parse("21 November 2012")
          #FIXME qw should be 15 weeks before due date...
   @qw = 15.weeks.ago(@dd - @dd.wday)..15.weeks.ago((@dd - @dd.wday) + 6)
          add_response @dd
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
          context "answer 21 November 2012" do
            setup do
              add_response Date.parse("21 November 2012")
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

                ## QM5.2
                should "ask when the last normal payday" do
                  assert_current_node :last_normal_payday?
                end
                should "be wrong as lastpayday is after" do
                  add_response @qw.last + 2
                  assert_current_node_is_error
                end
                context "answer 2 days before Saturday of qualifying week" do
                  setup do
                    add_response @qw.last - 2
                  end
                  ## QM5.3
                  should "ask when before lastpayday I was paid" do
                    assert_current_node :payday_eight_weeks?
                  end

                  context "answer 8 weeks before qualifying week" do
                    setup do
                      add_response 8.weeks.ago(@qw.last - 2)
                    end

                    ## QM5.4
                    should "ask how often you pay the employee" do
                      assert_current_node :pay_frequency?
                    end

                    context "answer weekly" do
                      setup do
                        add_response 'weekly'
                      end
                      ## QM5.5
                      should "ask what the employees earnings are for the period" do
                        assert_current_node :earnings_for_pay_period?
                        ##TODO relevant period calculation
                        assert_state_variable :pay_pattern, 'weekly'
                      end

                      context "answer 1083.20" do
                        setup do
                          add_response 1083.20
                        end

                        should "calculate and present the result" do
                          assert_current_node :how_do_you_want_the_smp_calculated?
                        end

                        context "usual pay dates" do
                          setup do
                            add_response "usual_paydates"
                          end

                          should "ask when the next pay day is" do
                            assert_current_node :when_is_your_employees_next_pay_day?
                            assert_state_variable :pay_start_date, Date.parse("21 November 2012")
                          end

                          context "next pay date is 11th August 2012" do
                            setup do
                              add_response Date.parse("11 August 2012")
                            end

                            should "show the result node" do
                              assert_current_node :maternity_leave_and_pay_result
                              assert_state_variable :pay_method, "weekly"
                            end

                            should "calculate dates and pay amounts" do
                              leave_start = Date.parse("21 November 2012")
                              start_of_week = leave_start - leave_start.wday
                              assert_state_variable "leave_start_date", leave_start
                              assert_state_variable "leave_end_date", 52.weeks.since(leave_start) - 1
                              assert_state_variable "notice_of_leave_deadline", 15.weeks.ago(start_of_week).end_of_week + 6
                              assert_state_variable "pay_start_date", leave_start
                              assert_state_variable "pay_end_date", 39.weeks.since(leave_start) - 1
                              assert_state_variable "average_weekly_earnings", 135.4
                              assert_state_variable "smp_a", "121.86"
                              assert_state_variable "smp_b", "121.86"
                              assert_state_variable "total_smp", "4752.93"
                            end
                          end
                        end

                        context "weekly calculations" do
                          setup do
                            add_response "weekly_starting"
                          end

                          should "go straight to the SMP result" do
                            assert_current_node :maternity_leave_and_pay_result
                            assert_state_variable :pay_method, 'weekly_starting'
                          end
                        end
                      end
                    end

                    context "ask for next pay day if specific subset of pay frequencies" do
                      should "ask for the next pay date if pay frequency is weekly" do
                        add_response "weekly"
                        add_response 1083.20
                        add_response "usual_paydates"
                        assert_current_node :when_is_your_employees_next_pay_day?
                      end

                      should "ask for the next pay date if pay frequency is fortnightly" do
                        add_response "every_2_weeks"
                        add_response 1083.20
                        add_response "usual_paydates"
                        assert_current_node :when_is_your_employees_next_pay_day?
                      end

                      should "ask for the next pay date if pay frequency is every 4 weeks" do
                        add_response "every_4_weeks"
                        add_response 1083.20
                        add_response "usual_paydates"
                        assert_current_node :when_is_your_employees_next_pay_day?
                      end

                      context "weekly frequency with usual paydates" do
                        setup do
                          add_response "monthly"
                          add_response 1083.20
                          add_response "usual_paydates"
                        end

                        should "ask when in the month an employee is paid" do
                          assert_current_node :when_in_the_month_is_the_employee_paid?
                        end

                        should "calculate the SMP for first day of the month" do
                          add_response "first_day_of_the_month"
                          assert_current_node :maternity_leave_and_pay_result
                          assert_state_variable :monthly_pay_method, 'first_day_of_the_month'
                        end

                        should "calculate the SMP for last day of the month" do
                          add_response "last_day_of_the_month"
                          assert_current_node :maternity_leave_and_pay_result
                          assert_state_variable :pay_method, "last_day_of_the_month"
                        end

                        context "specific date each month" do
                          setup do
                            add_response "specific_date_each_month"
                          end

                          should "ask what specific date each month the employee gets paid" do
                            assert_current_node :what_specific_date_each_month_is_the_employee_paid?
                          end
                        end

                        context "last working day of the month" do
                          setup do
                            add_response "last_working_day_of_the_month"
                          end

                          should "store this as pay_day_in_month" do
                            assert_state_variable :monthly_pay_method, 'last_working_day_of_the_month'
                          end

                          should "ask what days the employee works" do
                            assert_current_node :what_days_does_the_employee_work?
                          end

                          should "calculate SMP once day provided" do
                            add_response "0,1,3"
                            assert_current_node :maternity_leave_and_pay_result
                          end
                        end

                        context "a certain week day each month" do
                          setup do
                            add_response "a_certain_week_day_each_month"
                          end

                          should "ask what particular day of the month the employee is paid" do
                            assert_current_node :what_particular_day_of_the_month_is_the_employee_paid?
                          end

                          context "answer Sunday" do
                            setup do
                              add_response "Sunday"
                            end
                            should "ask which" do
                              assert_current_node :which_week_in_month_is_the_employee_paid?
                            end
                            context "answer the second week" do
                              should "calculate the SMP" do
                                add_response "second"
                                assert_current_node :maternity_leave_and_pay_result
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end

              context "answer no" do
                should "state that you they are not entitled to pay" do
                  add_response :no
                  assert_state_variable "not_entitled_to_pay_reason", :must_be_on_payroll
                  assert_current_node :maternity_leave_and_pay_result
                end
              end #answer no to QM5 on payroll

            end #answer yes to QM4
            context "answer no" do
              should "state that you they are not entitled to pay" do
                add_response :no
                assert_state_variable "not_entitled_to_pay_reason", :not_worked_long_enough
                assert_current_node :maternity_leave_and_pay_result
              end
            end
          end
        end # answer Yes to QM2 employee has contract?

        context "no contract" do # means they can't get leave but they may still be able to get pay.
          setup do
            add_response :no
          end
          should "ask when the employee wants to start their leave" do
            assert_current_node :date_leave_starts?
          end
          context "answer 21 November 2012" do
            setup do
              ld = Date.parse("21 November 2012")
              add_response ld
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
              should 'render the question title with an interpolated date' do
                nodes = Capybara.string(current_question.to_s)
                assert nodes.has_content?('Was the employee (or will they be) on your payroll on')
              end
              context "answer yes" do
                setup do
                  add_response :yes
                end
                ## QM5.2
                should "ask when the last normal payday" do
                  assert_current_node :last_normal_payday?
                end

                context "answer 2 days before Saturday of qualifying week" do
                  setup do
                    add_response Date.parse("11 August 2012") - 2
                  end

                  should "ask the date of the pay before the 8 week offset" do
                    assert_current_node :payday_eight_weeks?
                  end

                  context "answer 8 weeks before qualifying week" do
                    setup do
                      add_response 8.weeks.ago(Date.parse("11 August 2012") - 2)
                    end

                    should "ask how often you pay the employee" do
                      assert_current_node :pay_frequency?
                    end

                    context "answer weekly with earnings below threshold" do
                      should "calculate awe and state that they must earn over the minimum threshold" do
                        add_response "weekly"
                        add_response "799"
                        add_response "weekly_starting"

                        assert_current_node :maternity_leave_and_pay_result
                        assert_state_variable :below_threshold, true
                        assert_state_variable :not_entitled_to_pay_reason, :must_earn_over_threshold
                      end
                    end
                    context "answer weekly" do
                      setup do
                        add_response :weekly
                      end

                      should "ask how much the employee was paid in this period" do
                        assert_current_node :earnings_for_pay_period?
                      end

                      context "answer 1083.20" do
                        setup do
                          add_response "1083.20"
                          add_response "weekly_starting"
                        end

                        should "calculate the dates and payment amounts" do
                          leave_start = Date.parse("21 November 2012")
                          start_of_week = leave_start - leave_start.wday
                          assert_state_variable "average_weekly_earnings", 135.40
                          assert_state_variable "leave_start_date", leave_start
                          assert_state_variable "leave_end_date", 52.weeks.since(leave_start) - 1
                          assert_state_variable "notice_of_leave_deadline", next_saturday(15.weeks.ago(start_of_week))
                          assert_state_variable "pay_start_date", leave_start
                          assert_state_variable "pay_end_date", 39.weeks.since(leave_start) - 1
                          assert_state_variable "smp_a", "121.86"
                          assert_state_variable "smp_b", "121.86"
                          assert_state_variable "total_smp", "4752.93"
                        end

                      end
                    end
                    context "answer every 2 weeks" do
                      setup do
                        add_response :every_2_weeks
                      end

                      should "ask how much the employee was paid in this period" do
                        assert_current_node :earnings_for_pay_period?
                      end

                      context "answer 2601.60" do
                        setup do
                          add_response "2601.60"
                          add_response "weekly_starting"
                        end

                        should "calculate the dates and payment amounts" do
                          assert_state_variable "average_weekly_earnings", 325.20
                          assert_state_variable "smp_a", (325.20 * 0.9).round(2).to_s
                          assert_state_variable "smp_b", "135.45" # Uses the statutory maternity rate
                        end
                      end
                    end

                    context "answer every 4 weeks" do
                      setup do
                        add_response :every_4_weeks
                      end

                      should "ask how much the employee was paid in this period" do
                        assert_current_node :earnings_for_pay_period?
                      end

                      context "answer 2100.80" do
                        setup do
                          add_response "2100.80"
                          add_response "weekly_starting"
                        end

                        should "calculate the dates and payment amounts" do
                          assert_state_variable "average_weekly_earnings", 262.60
                          assert_state_variable "smp_a", "236.34"
                          assert_state_variable "smp_b", "135.45" # Uses the statutory maternity rate
                        end
                      end
                    end

                    context "answer every month" do
                      setup { add_response :monthly }

                      should "ask how much the employee was paid in this period" do
                        assert_current_node :earnings_for_pay_period?
                      end

                      context "answer 1807.78" do
                        setup do
                          add_response "1807.78"
                          add_response "weekly_starting"
                        end

                        should "calculate the dates and payment amounts" do
                          assert_state_variable "average_weekly_earnings", 208.59
                          assert_state_variable "smp_a", "187.73"
                          assert_state_variable "smp_b", "135.45" # Uses the statutory maternity rate
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end # no to QM2 employee has contract?
      end
      context "calculate maternity with unfeasible pay dates" do
        setup do
          add_response Date.parse("2013-02-22")
          add_response :yes
          add_response Date.parse("2013-01-25")
          add_response :yes
          add_response :yes
          add_response Date.parse("2012-11-09")
          add_response Date.parse("2012-09-14")
          add_response :monthly
          add_response "3000"
          add_response "usual_paydates"
          add_response "specific_date_each_month"
          add_response "32"
        end
        should "be invalid" do
          assert_current_node_is_error
        end
      end
      context "calculate maternity with monthly pay date after 28th" do
        setup do
          add_response Date.parse("2013-02-22")
          add_response :yes
          add_response Date.parse("2013-01-25")
          add_response :yes
          add_response :yes
          add_response Date.parse("2012-11-09")
          add_response Date.parse("2012-09-14")
          add_response :monthly
          add_response "3000"
          add_response "usual_paydates"
          add_response "specific_date_each_month"
          add_response "29"
        end
        should "assume values over 28 as the last day of the month" do
          assert_state_variable :pay_method, 'last_day_of_the_month'
        end
      end
      context "calculate maternity with £4000 earnings" do
        setup do
          add_response Date.parse("2013-02-22")
          add_response :yes
          add_response Date.parse("2013-01-25")
          add_response :yes
          add_response :yes
          add_response Date.parse("2012-11-09")
          add_response Date.parse("2012-09-14")
          add_response :monthly
          add_response 4000
          add_response "weekly_starting"
        end

        should "be a saturday when providing the notice leave deadline" do
          assert_state_variable "notice_of_leave_deadline", Date.parse("2012-11-10")
        end

        should "be 23rd January 2014 for leave end date" do
          assert_state_variable "leave_end_date", Date.parse("2014-01-23")
        end

        should "be 24th October 2013 for pay end date" do
          assert_state_variable "pay_end_date", Date.parse("2013-10-24")
        end

        should "have a notice request pay date 28 days before the start date" do
          assert_state_variable "pay_start_date", Date.parse("2013-01-25")
          assert_state_variable "notice_request_pay", Date.parse("2012-12-28")
        end
      end
    end # April 9th

    context "check for correct LEL Saturday, 12 April 2014 monthly" do
      setup do
        add_response Date.parse("2014-07-26")
          add_response :yes
          add_response Date.parse("2014-06-29")
          add_response :yes
          add_response :yes
          add_response Date.parse("2014-04-06")
          add_response Date.parse("2014-02-07")
          add_response :monthly
          add_response 956
          add_response "weekly_starting"
      end

      should "have LEL of 111" do
        assert_state_variable :to_saturday_formatted, "Saturday, 12 April 2014"
        assert_state_variable "lower_earning_limit", sprintf("%.2f", 111)
        assert_current_node :maternity_leave_and_pay_result
      end
    end

    context "check for correct LEL Saturday, 05 April 2014 monthly" do
      setup do
        add_response Date.parse("2014-07-19")
          add_response :yes
          add_response Date.parse("2014-06-22")
          add_response :yes
          add_response :yes
          add_response Date.parse("2014-03-31")
          add_response Date.parse("2014-02-03")
          add_response :monthly
          add_response 956
          add_response "weekly_starting"
      end

      should "have LEL of 109" do
        assert_state_variable :to_saturday_formatted, "Saturday, 05 April 2014"
        assert_state_variable "lower_earning_limit", sprintf("%.2f", 109)
        assert_current_node :maternity_leave_and_pay_result
      end
    end

    context "check for correct LEL Saturday, 05 April 2014 weekly_starting" do
      setup do
        add_response Date.parse("2014-07-19")
          add_response :yes
          add_response Date.parse("2014-06-22")
          add_response :yes
          add_response :yes
          add_response Date.parse("2014-04-04")
          add_response Date.parse("2014-02-07")
          add_response :weekly
          add_response 880
          add_response "weekly_starting"
      end

      should "have LEL of 109" do
        assert_state_variable :to_saturday_formatted, "Saturday, 05 April 2014"
        assert_state_variable "lower_earning_limit", sprintf("%.2f", 109)
        assert_current_node :maternity_leave_and_pay_result
      end
    end

    context "check for correct LEL Saturday, 05 April 2014 usual_paydates" do
      setup do
        add_response Date.parse("2014-07-19")
          add_response :yes
          add_response Date.parse("2014-06-22")
          add_response :yes
          add_response :yes
          add_response Date.parse("2014-04-04")
          add_response Date.parse("2014-02-07")
          add_response :weekly
          add_response 880
          add_response "usual_paydates"
          add_response Date.parse('2014-06-27')
      end

      should "have LEL of 109" do
        assert_state_variable :to_saturday_formatted, "Saturday, 05 April 2014"
        assert_state_variable "lower_earning_limit", sprintf("%.2f", 109)
        assert_current_node :maternity_leave_and_pay_result
      end
    end

    context "check for correct LEL Saturday, 21 December 2013" do
      setup do
        add_response Date.parse("2014-04-05")
          add_response :yes
          add_response Date.parse("2014-01-12")
          add_response :yes
          add_response :yes
          add_response Date.parse("2013-12-20")
          add_response Date.parse("2013-10-25")
          add_response :every_2_weeks
          add_response 880
          add_response "usual_paydates"
          add_response Date.parse('2014-01-17')
      end

      should "have LEL of 109" do
        assert_state_variable :to_saturday_formatted, "Saturday, 21 December 2013"
        assert_state_variable "lower_earning_limit", sprintf("%.2f", 109)
        assert_current_node :maternity_leave_and_pay_result
      end
    end

    context "check for correct LEL Saturday, 30 March 2013" do
      setup do
        add_response Date.parse("2013-07-11")
          add_response :yes
          add_response Date.parse("2013-06-13")
          add_response :yes
          add_response :yes
          add_response Date.parse("2013-03-29")
          add_response Date.parse("2013-02-01")
          add_response :weekly
          add_response 864
          add_response "weekly_starting"
      end

      should "have LEL of 107" do
        assert_state_variable :to_saturday_formatted, "Saturday, 30 March 2013"
        assert_state_variable "lower_earning_limit", sprintf("%.2f", 107)
        assert_current_node :maternity_leave_and_pay_result
      end
    end

  end
end
