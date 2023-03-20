require "test_helper"
require "support/flow_test_helper"
require "support/flows/maternity_paternity_calculator_flow_test_helper"

class MaternityPaternityCalculatorFlow::MaternityCalculatorFlowTest < ActiveSupport::TestCase
  include FlowTestHelper
  include MaternityPaternityCalculatorFlowTestHelper

  setup { testing_flow MaternityPaternityCalculatorFlow }

  context "question: baby_due_date_maternity?" do
    setup do
      testing_node :baby_due_date_maternity?
      add_responses what_type_of_leave?: "maternity"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of date_leave_starts?" do
        assert_next_node :date_leave_starts?, for_response: "2021-01-08"
      end
    end
  end

  context "question: date_leave_starts?" do
    setup do
      testing_node :date_leave_starts?
      add_responses what_type_of_leave?: "maternity",
                    baby_due_date_maternity?: "2021-01-08"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid for a leave date that is before the earliest start date" do
        # 1 year is safely before the current time period of 11 weeks
        assert_invalid_response "2020-01-08"
      end
    end

    context "next_node" do
      should "have a next node of did_the_employee_work_for_you_between?" do
        assert_next_node :did_the_employee_work_for_you_between?, for_response: "2021-01-01"
      end
    end
  end

  context "question: did_the_employee_work_for_you_between?" do
    setup do
      testing_node :did_the_employee_work_for_you_between?
      add_responses what_type_of_leave?: "maternity",
                    baby_due_date_maternity?: "2021-01-08",
                    date_leave_starts?: "2021-01-01"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of last_normal_payday? for a 'yes' response" do
        assert_next_node :last_normal_payday?, for_response: "yes"
      end

      should "have a next node of does_the_employee_work_for_now? for a 'no' response" do
        assert_next_node :does_the_employee_work_for_you_now?, for_response: "no"
      end
    end
  end

  context "question: does_the_employee_work_for_you_now?" do
    setup do
      testing_node :does_the_employee_work_for_you_now?
      add_responses what_type_of_leave?: "maternity",
                    baby_due_date_maternity?: "2021-01-08",
                    date_leave_starts?: "2021-01-01",
                    did_the_employee_work_for_you_between?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of maternity_leave_and_pay_result" do
        assert_next_node :maternity_leave_and_pay_result, for_response: "yes"
      end
    end
  end

  context "question: last_normal_payday?" do
    setup do
      testing_node :last_normal_payday?
      add_responses what_type_of_leave?: "maternity",
                    baby_due_date_maternity?: "2021-01-08",
                    date_leave_starts?: "2021-01-01",
                    did_the_employee_work_for_you_between?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid for a payday within 15 weeks of the start date" do
        date = Date.parse("2021-01-08") - 13.weeks
        assert_invalid_response date.to_s
      end
    end

    context "next_node" do
      should "have a next node of payday_eight_weeks? for a payday greater than 15 weeks earlier" do
        date = Date.parse("2021-01-08") - 16.weeks
        assert_next_node :payday_eight_weeks?, for_response: date.to_s
      end
    end
  end

  context "question: payday_eight_weeks?" do
    setup do
      testing_node :payday_eight_weeks?
      add_responses maternity_responses(up_to: :last_normal_payday?, last_normal_payday: "2020-09-01")
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid for a payday within 8 weeks of the last normal payday" do
        date = Date.parse("2020-09-01") - 7.weeks
        assert_invalid_response date.to_s
      end
    end

    context "next_node" do
      should "have a next node of pay_frequency? for a last payday greater than 8 weeks earlier" do
        date = Date.parse("2020-09-01") - 9.weeks
        assert_next_node :pay_frequency?, for_response: date.to_s
      end
    end
  end

  context "question: pay_frequency?" do
    setup do
      testing_node :pay_frequency?
      add_responses maternity_responses(up_to: :payday_eight_weeks?)
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of earnings_for_pay_period?" do
        assert_next_node :earnings_for_pay_period?, for_response: "weekly"
      end
    end
  end

  context "question: earnings_for_pay_period?" do
    setup do
      testing_node :earnings_for_pay_period?
      add_responses maternity_responses(up_to: :pay_frequency?)
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_many_payments_weekly? when pay frequency is weekly" do
        add_responses pay_frequency?: "weekly"
        assert_next_node :how_many_payments_weekly?, for_response: "100"
      end

      should "have a next node of how_many_payments_every_2_weeks? when pay frequency is every 2 weeks" do
        add_responses pay_frequency?: "every_2_weeks"
        assert_next_node :how_many_payments_every_2_weeks?, for_response: "100"
      end

      should "have a next node of how_many_payments_every_4_weeks? when pay frequency is every 4 weeks" do
        add_responses pay_frequency?: "every_4_weeks"
        assert_next_node :how_many_payments_every_4_weeks?, for_response: "100"
      end

      should "have a next node of how_many_payments_monthly? when pay frequency is monthly" do
        add_responses pay_frequency?: "monthly"
        assert_next_node :how_many_payments_monthly?, for_response: "100"
      end
    end
  end

  context "question: how_do_you_want_the_smp_calculated?" do
    setup do
      testing_node :how_do_you_want_the_smp_calculated?
      add_responses maternity_responses(up_to: :how_many_payments_every_2_weeks?, pay_frequency: "every_2_weeks")
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of maternity_leave_and_pay_result for a 'weekly_starting' response" do
        assert_next_node :maternity_leave_and_pay_result, for_response: "weekly_starting"
      end

      should "have a next node of when_is_your_employees_next_pay_day? for a 'usual_paydates' response" do
        assert_next_node :when_is_your_employees_next_pay_day?, for_response: "usual_paydates"
      end

      should "have a next node of when_in_the_month_is_the_employee_paid? for a 'usual_paydates' response and a " \
             "monthly pay frequency" do
        add_responses pay_frequency?: "monthly", how_many_payments_monthly?: "2"
        assert_next_node :when_in_the_month_is_the_employee_paid?, for_response: "usual_paydates"
      end
    end
  end

  context "question: when_is_your_employees_next_pay_day?" do
    setup do
      testing_node :when_is_your_employees_next_pay_day?
      add_responses maternity_responses(pay_frequency: "weekly")
                      .merge(how_do_you_want_the_smp_calculated?: "usual_paydates")
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of maternity_leave_and_pay_result" do
        assert_next_node :maternity_leave_and_pay_result, for_response: "2020-10-01"
      end
    end
  end

  context "question: when_in_the_month_is_the_employee_paid?" do
    setup do
      testing_node :when_in_the_month_is_the_employee_paid?
      add_responses maternity_responses(pay_frequency: "monthly")
                      .merge(how_do_you_want_the_smp_calculated?: "usual_paydates")
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      %w[first_day_of_the_month last_day_of_the_month].each do |response|
        should "have a next node of maternity_leave_and_pay_result for a '#{response}' response" do
          assert_next_node :maternity_leave_and_pay_result, for_response: response
        end
      end

      should "have a next node of what_specific_date_each_month_is_the_employee_paid? for a " \
             "'specific_date_each_month' response" do
        assert_next_node :what_specific_date_each_month_is_the_employee_paid?, for_response: "specific_date_each_month"
      end

      should "have a next node of what_days_does_the_employee_work? for a 'last_working_day_of_the_month' response" do
        assert_next_node :what_days_does_the_employee_work?, for_response: "last_working_day_of_the_month"
      end

      should "have a next node of what_particular_day_of_the_month_is_the_employee_paid? for a " \
             "'a_certain_week_day_each_month' response" do
        assert_next_node :what_particular_day_of_the_month_is_the_employee_paid?,
                         for_response: "a_certain_week_day_each_month"
      end
    end
  end

  context "question: what_specific_date_each_month_is_the_employee_paid?" do
    setup do
      testing_node :what_specific_date_each_month_is_the_employee_paid?
      add_responses maternity_responses(pay_frequency: "monthly")
                      .merge(how_do_you_want_the_smp_calculated?: "usual_paydates",
                             when_in_the_month_is_the_employee_paid?: "specific_date_each_month")
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid for a number below 1" do
        assert_invalid_response "0"
      end

      should "be invalid for a number above 31" do
        assert_invalid_response "32"
      end
    end

    context "next_node" do
      should "have a next node of maternity_leave_and_pay_result" do
        assert_next_node :maternity_leave_and_pay_result, for_response: "1"
      end
    end
  end

  context "question: what_days_does_the_employee_work?" do
    setup do
      testing_node :what_days_does_the_employee_work?
      add_responses maternity_responses(pay_frequency: "monthly")
                      .merge(how_do_you_want_the_smp_calculated?: "usual_paydates",
                             when_in_the_month_is_the_employee_paid?: "last_working_day_of_the_month")
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of maternity_leave_and_pay_result" do
        assert_next_node :maternity_leave_and_pay_result, for_response: "0,2,4"
      end
    end
  end

  context "question: what_particular_day_of_the_month_is_the_employee_paid?" do
    setup do
      testing_node :what_particular_day_of_the_month_is_the_employee_paid?
      add_responses maternity_responses(pay_frequency: "monthly")
                      .merge(how_do_you_want_the_smp_calculated?: "usual_paydates",
                             when_in_the_month_is_the_employee_paid?: "a_certain_week_day_each_month")
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of which_week_in_month_is_the_employee_paid?" do
        assert_next_node :which_week_in_month_is_the_employee_paid?, for_response: "Tuesday"
      end
    end
  end

  context "question: which_week_in_month_is_the_employee_paid?" do
    setup do
      testing_node :which_week_in_month_is_the_employee_paid?
      add_responses maternity_responses(pay_frequency: "monthly")
                      .merge(how_do_you_want_the_smp_calculated?: "usual_paydates",
                             when_in_the_month_is_the_employee_paid?: "a_certain_week_day_each_month",
                             what_particular_day_of_the_month_is_the_employee_paid?: "Tuesday")
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of maternity_leave_and_pay_result" do
        assert_next_node :maternity_leave_and_pay_result, for_response: "last"
      end
    end
  end

  context "outcome: maternity_leave_and_pay_result" do
    setup { testing_node :maternity_leave_and_pay_result }

    should "render eligibility for leave guidance when an employee has a contract" do
      add_responses maternity_responses

      assert_rendered_outcome text: "The employee is entitled to up to 52 weeks Statutory Maternity Leave"
    end

    should "render eligibility for leave guidance when an employee is currently employed" do
      add_responses maternity_responses(up_to: :date_leave_starts?)
                      .merge(did_the_employee_work_for_you_between?: "no",
                             does_the_employee_work_for_you_now?: "yes")

      assert_rendered_outcome text: "The employee is entitled to up to 52 weeks Statutory Maternity Leave"
    end

    should "render ineligibility for leave guidance when an employee hasn't had a contract" do
      add_responses maternity_responses(up_to: :date_leave_starts?)
                      .merge(did_the_employee_work_for_you_between?: "no",
                             does_the_employee_work_for_you_now?: "no")

      assert_rendered_outcome text: "The employee is not entitled to Statutory Maternity Leave"
    end

    should "render when an employee is entitled to statutory maternity pay" do
      add_responses maternity_responses(pay_frequency: "weekly", pay_per_frequency: 1_000, due_date: "2023-05-01")

      assert_rendered_outcome text: "The employee is entitled to up to 39 weeks Statutory Maternity Pay (SMP)"

      # 90% of 1000 a week for 6 weeks + (39 - 6) * 172.48 statutory (rate for 2023)
      # = 900 * 6 + 33 * 172.48
      assert_match(/Total SMP:\s*£11,091.84/, @test_flow.outcome_text)
    end

    should "render when an employee is not entitled to statutory maternity pay and have average earnings" do
      add_responses maternity_responses(pay_frequency: "weekly", pay_per_frequency: 1)

      assert_rendered_outcome text: "Their average weekly earnings are £1 (you can’t round this figure up or " \
                                    "down). To qualify:"
    end

    should "render when an employee is not entitled to statutory maternity pay and doesn't have average earnings" do
      add_responses maternity_responses(up_to: :date_leave_starts?)
                      .merge(did_the_employee_work_for_you_between?: "no",
                             does_the_employee_work_for_you_now?: "no")
      assert_rendered_outcome text: "The employee is not entitled to Statutory Maternity Pay. To qualify:"
    end

    should "render when an employee is not entitled to statutory maternity pay as they don't earn over a threshold" do
      add_responses maternity_responses(pay_frequency: "weekly",
                                        pay_per_frequency: 120,
                                        due_date: "2022-08-01",
                                        last_normal_payday: "2022-04-01",
                                        payday_eight_weeks: "2021-02-01")

      # lower limit for 2021 - 2022 is £123
      assert_rendered_outcome text: "their average weekly earnings (£120) between Tuesday, 02 February 2021 and " \
                                    "Friday, 01 April 2022 must be at least £123"
    end

    should "render when an employee is not entitled to statutory maternity pay as they haven't worked long enough "\
           "and aren't on the payroll" do
      add_responses maternity_responses(up_to: :date_leave_starts?)
                      .merge(did_the_employee_work_for_you_between?: "no",
                             does_the_employee_work_for_you_now?: "yes")

      assert_rendered_outcome text: "they must have worked continually for you between"
    end
  end
end
