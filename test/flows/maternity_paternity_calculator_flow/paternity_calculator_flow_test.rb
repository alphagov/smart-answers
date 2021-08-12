require "test_helper"
require "support/flow_test_helper"
require "support/flows/maternity_paternity_calculator_flow_test_helper"

class MaternityPaternityCalculatorFlow::PaternityCalculatorFlowTest < ActiveSupport::TestCase
  include FlowTestHelper
  include MaternityPaternityCalculatorFlowTestHelper

  setup { testing_flow MaternityPaternityCalculatorFlow }

  context "question: leave_or_pay_for_adoption?" do
    setup do
      testing_node :leave_or_pay_for_adoption?
      add_responses what_type_of_leave?: "paternity"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of employee_date_matched_paternity_adoption? for a 'yes' response" do
        assert_next_node :employee_date_matched_paternity_adoption?, for_response: "yes"
      end

      should "have a next node of baby_due_date_paternity? for a 'no' response" do
        assert_next_node :baby_due_date_paternity?, for_response: "no"
      end
    end
  end

  context "question: baby_due_date_paternity?" do
    setup do
      testing_node :baby_due_date_paternity?
      add_responses what_type_of_leave?: "paternity",
                    leave_or_pay_for_adoption?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of baby_birth_date_paternity?" do
        assert_next_node :baby_birth_date_paternity?, for_response: "2020-11-01"
      end
    end
  end

  context "question: employee_date_matched_paternity_adoption?" do
    setup do
      testing_node :employee_date_matched_paternity_adoption?
      add_responses what_type_of_leave?: "paternity",
                    leave_or_pay_for_adoption?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of padoption_date_of_adoption_placement?" do
        assert_next_node :padoption_date_of_adoption_placement?, for_response: "2020-11-01"
      end
    end
  end

  context "question: baby_birth_date_paternity?" do
    setup do
      testing_node :baby_birth_date_paternity?
      add_responses what_type_of_leave?: "paternity",
                    leave_or_pay_for_adoption?: "no",
                    baby_due_date_paternity?: "2020-11-01"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of employee_responsible_for_upbringing?" do
        assert_next_node :employee_responsible_for_upbringing?, for_response: "2020-11-01"
      end
    end
  end

  context "question: padoption_date_of_adoption_placement?" do
    setup do
      testing_node :padoption_date_of_adoption_placement?
      add_responses what_type_of_leave?: "paternity",
                    leave_or_pay_for_adoption?: "yes",
                    employee_date_matched_paternity_adoption?: "2020-11-01"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of padoption_employee_responsible_for_upbringing?" do
        assert_next_node :padoption_employee_responsible_for_upbringing?, for_response: "2020-11-01"
      end
    end
  end

  context "question: employee_responsible_for_upbringing?" do
    setup do
      testing_node :employee_responsible_for_upbringing?
      add_responses what_type_of_leave?: "paternity",
                    leave_or_pay_for_adoption?: "no",
                    baby_due_date_paternity?: "2020-11-01",
                    baby_birth_date_paternity?: "2020-11-01"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of employee_work_before_employment_start? for a 'yes' response" do
        assert_next_node :employee_work_before_employment_start?, for_response: "yes"
      end

      should "have a next node of paternity_not_entitled_to_leave_or_pay for a 'no' response" do
        assert_next_node :paternity_not_entitled_to_leave_or_pay, for_response: "no"
      end
    end
  end

  context "question: padoption_employee_responsible_for_upbringing?" do
    setup do
      testing_node :padoption_employee_responsible_for_upbringing?
      add_responses what_type_of_leave?: "paternity",
                    leave_or_pay_for_adoption?: "yes",
                    employee_date_matched_paternity_adoption?: "2020-11-01",
                    padoption_date_of_adoption_placement?: "2020-11-01"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of employee_work_before_employment_start? for a 'yes' response" do
        assert_next_node :employee_work_before_employment_start?, for_response: "yes"
      end

      should "have a next node of paternity_not_entitled_to_leave_or_pay for a 'no' response" do
        assert_next_node :paternity_not_entitled_to_leave_or_pay, for_response: "no"
      end
    end
  end

  context "question: employee_work_before_employment_start?" do
    setup do
      testing_node :employee_work_before_employment_start?
      add_responses paternity_responses(up_to: :employee_responsible_for_upbringing?)
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of employee_has_contract_paternity? for a 'yes' response" do
        assert_next_node :employee_has_contract_paternity?, for_response: "yes"
      end

      should "have a next node of paternity_not_entitled_to_leave_or_pay for a 'no' response" do
        assert_next_node :paternity_not_entitled_to_leave_or_pay, for_response: "no"
      end
    end
  end

  context "question: employee_has_contract_paternity?" do
    setup do
      testing_node :employee_has_contract_paternity?
      add_responses paternity_responses(up_to: :employee_work_before_employment_start?)
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of employee_on_payroll_paternity?" do
        assert_next_node :employee_on_payroll_paternity?, for_response: "yes"
      end
    end
  end

  context "question: employee_on_payroll_paternity?" do
    setup do
      testing_node :employee_on_payroll_paternity?
      add_responses paternity_responses(up_to: :employee_has_contract_paternity?)
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of employee_still_employed_on_birth_date? for a 'yes' response" do
        assert_next_node :employee_still_employed_on_birth_date?, for_response: "yes"
      end

      should "have a next node of paternity_not_entitled_to_leave_or_pay for a 'no' response, when the employee " \
             "doesn't have contract paternity" do
        add_responses employee_has_contract_paternity?: "no"
        assert_next_node :paternity_not_entitled_to_leave_or_pay, for_response: "no"
      end

      should "have a next node of employee_start_paternity? for a 'no' response, when the employee does have " \
             "contract paternity" do
        add_responses employee_has_contract_paternity?: "yes"
        assert_next_node :employee_start_paternity?, for_response: "no"
      end
    end
  end

  context "question: employee_still_employed_on_birth_date?" do
    setup do
      testing_node :employee_still_employed_on_birth_date?
      add_responses paternity_responses(up_to: :employee_on_payroll_paternity?)
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of paternity_not_entitled_to_leave_or_pay for a 'no' response, when the employee " \
             "doesn't have contract paternity" do
        add_responses employee_has_contract_paternity?: "no"
        assert_next_node :paternity_not_entitled_to_leave_or_pay, for_response: "no"
      end

      should "have a next node of employee_start_paternity? for a 'no' response, when the employee does have " \
             "contract paternity" do
        add_responses employee_has_contract_paternity?: "yes"
        assert_next_node :employee_start_paternity?, for_response: "no"
      end

      should "have a next node of employee_start_paternity? for a 'yes' response" do
        assert_next_node :employee_start_paternity?, for_response: "yes"
      end
    end
  end

  context "question: employee_start_paternity?" do
    setup do
      testing_node :employee_start_paternity?
      add_responses paternity_responses(due_date: "2020-11-01", up_to: :employee_still_employed_on_birth_date?)
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid when it's an adoption and the response is before the adoption date" do
        add_responses leave_or_pay_for_adoption?: "yes",
                      employee_date_matched_paternity_adoption?: "2020-05-01",
                      padoption_date_of_adoption_placement?: "2020-05-01",
                      padoption_employee_responsible_for_upbringing?: "yes"
        assert_invalid_response "2020-04-01"
      end

      should "be invalid when it's not an adoption and the response is before the birth date" do
        assert_invalid_response "2020-10-01"
      end
    end

    context "next_node" do
      should "have a next node of employee_start_paternity?" do
        assert_next_node :employee_paternity_length?, for_response: "2020-11-01"
      end
    end
  end

  context "question: employee_paternity_length?" do
    setup do
      testing_node :employee_paternity_length?
      add_responses paternity_responses(up_to: :employee_start_paternity?)
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of paternity_not_entitled_to_leave_or_pay when the employee has contract " \
             "paternity and is not on on payroll" do
        add_responses employee_has_contract_paternity?: "yes",
                      employee_on_payroll_paternity?: "no"
        assert_next_node :paternity_not_entitled_to_leave_or_pay, for_response: "one_week"
      end

      should "have a next node of paternity_not_entitled_to_leave_or_pay when the employee has contract " \
             "paternity and is not employed on birth date" do
        add_responses employee_has_contract_paternity?: "yes",
                      employee_still_employed_on_birth_date?: "no"
        assert_next_node :paternity_not_entitled_to_leave_or_pay, for_response: "one_week"
      end

      should "have a next node of last_normal_payday_paternity? in other scenarios" do
        assert_next_node :last_normal_payday_paternity?, for_response: "one_week"
      end
    end
  end

  context "question: last_normal_payday_paternity?" do
    setup do
      testing_node :last_normal_payday_paternity?
      add_responses paternity_responses(up_to: :employee_paternity_length?, due_date: "2020-11-01")
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid for a payday that is within 15 weeks of the Saturday that follows the due date" do
        # 1st November is a Sunday so we subtract 15 weeks from the following Saturday
        soonest_valid_date = Date.parse("2020-11-07") - 15.weeks
        assert_invalid_response (soonest_valid_date + 1.day).to_s
      end
    end

    context "next_node" do
      should "have a next node of payday_eight_weeks_paternity?" do
        assert_next_node :payday_eight_weeks_paternity?, for_response: "2020-07-01"
      end
    end
  end

  context "question: payday_eight_weeks_paternity?" do
    setup do
      testing_node :payday_eight_weeks_paternity?
      add_responses paternity_responses(up_to: :last_normal_payday_paternity?,
                                        due_date: "2020-11-01",
                                        last_normal_payday: "2020-07-01")
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid for a payday that is within 8 weeks of payday" do
        # 8 weeks prior to last normal payday
        soonest_valid_date = Date.parse("2020-07-01") - 8.weeks
        assert_invalid_response (soonest_valid_date + 1.day).to_s
      end
    end

    context "next_node" do
      should "have a next node of pay_frequency_paternity?" do
        assert_next_node :pay_frequency_paternity?, for_response: "2020-05-01"
      end
    end
  end

  context "question: pay_frequency_paternity?" do
    setup do
      testing_node :pay_frequency_paternity?
      add_responses paternity_responses(up_to: :payday_eight_weeks_paternity?)
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of earnings_for_pay_period_paternity?" do
        assert_next_node :earnings_for_pay_period_paternity?, for_response: "weekly"
      end
    end
  end

  context "question: earnings_for_pay_period_paternity?" do
    setup do
      testing_node :earnings_for_pay_period_paternity?
      add_responses paternity_responses(up_to: :pay_frequency_paternity?)
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of paternity_leave_and_pay when they earn less than a lower limit" do
        # using £1 as a means to unambiguously be below the limit
        assert_next_node :paternity_leave_and_pay, for_response: "1"
      end

      should "have a next node of how_many_payments_weekly? when pay is sufficiently high and the pay period is " \
             "weekly" do
        add_responses pay_frequency_paternity?: "weekly"
        assert_next_node :how_many_payments_weekly?, for_response: "1000"
      end

      should "have a next node of how_many_payments_every_2_weeks? when pay is sufficiently high and the pay " \
             "period is every_2_weeks" do
        add_responses pay_frequency_paternity?: "every_2_weeks"
        assert_next_node :how_many_payments_every_2_weeks?, for_response: "2000"
      end

      should "have a next node of how_many_payments_every_4_weeks? when pay is sufficiently high and the pay " \
             "period is every_4_weeks" do
        add_responses pay_frequency_paternity?: "every_4_weeks"
        assert_next_node :how_many_payments_every_4_weeks?, for_response: "4000"
      end

      should "have a next node of how_many_payments_monthly? when pay is sufficiently high and the pay period is " \
             "monthly" do
        add_responses pay_frequency_paternity?: "monthly"
        assert_next_node :how_many_payments_monthly?, for_response: "5000"
      end
    end
  end

  context "question: how_do_you_want_the_spp_calculated?" do
    setup do
      testing_node :how_do_you_want_the_spp_calculated?
      add_responses paternity_responses(pay_frequency: "weekly", up_to: :how_many_payments_weekly?)
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of paternity_leave_and_pay for a 'weekly_starting' response" do
        assert_next_node :paternity_leave_and_pay, for_response: "weekly_starting"
      end

      should "have a next node of when_in_the_month_is_the_employee_paid? for a 'usual_paydates' response and a " \
             "monthly pay frequency" do
        add_responses pay_frequency_paternity?: "monthly",
                      earnings_for_pay_period_paternity?: "5000",
                      how_many_payments_monthly?: "2"
        assert_next_node :monthly_pay_paternity?, for_response: "usual_paydates"
      end

      should "have a next node of next_pay_day_paternity? for a 'usual_paydates' response and a different " \
             "pay frequency" do
        assert_next_node :next_pay_day_paternity?, for_response: "usual_paydates"
      end
    end
  end

  context "question: next_pay_day_paternity?" do
    setup do
      testing_node :next_pay_day_paternity?

      add_responses paternity_responses(pay_frequency: "weekly", up_to: :how_many_payments_weekly?)
                      .merge(how_do_you_want_the_spp_calculated?: "usual_paydates")
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of paternity_leave_and_pay" do
        assert_next_node :paternity_leave_and_pay, for_response: "2020-10-01"
      end
    end
  end

  # From this question onwards the nodes can be reached through the expected paternity route and also through a maternity adoption route
  context "question: monthly_pay_paternity?" do
    setup do
      testing_node :monthly_pay_paternity?

      @non_adoption_responses = paternity_responses(pay_frequency: "monthly", up_to: :how_many_payments_monthly?)
                                  .merge(how_do_you_want_the_spp_calculated?: "usual_paydates")

      @adoption_responses = maternity_adoption_responses(pay_frequency: "monthly", up_to: :how_many_payments_monthly?)
                              .merge(how_do_you_want_the_sap_calculated?: "usual_paydates")

      add_responses @non_adoption_responses
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of what_specific_date_each_month_paternity? for a 'specific_date_each_month' response" do
        assert_next_node :specific_date_each_month_paternity?, for_response: "specific_date_each_month"
      end

      should "have a next node of days_of_the_week_paternity? for a 'last_working_day_of_the_month' response" do
        assert_next_node :days_of_the_week_paternity?, for_response: "last_working_day_of_the_month"
      end

      should "have a next node of day_of_the_month_paternity? for a 'a_certain_week_day_each_month' response" do
        assert_next_node :day_of_the_month_paternity?, for_response: "a_certain_week_day_each_month"
      end

      %w[first_day_of_the_month last_day_of_the_month].each do |response|
        should "have a next node of paternity_leave_and_pay for a '#{response}' response" do
          assert_next_node :paternity_leave_and_pay, for_response: response
        end

        context "when the user is an adoption flow" do
          setup { add_responses @adoption_responses }

          should "have a next node of adoption_leave_and_pay for a '#{response}' response" do
            assert_next_node :adoption_leave_and_pay, for_response: response
          end
        end
      end
    end
  end

  context "question: specific_date_each_month_paternity?" do
    setup do
      testing_node :specific_date_each_month_paternity?

      @non_adoption_responses = paternity_responses(pay_frequency: "monthly", up_to: :how_many_payments_monthly?)
                                  .merge(how_do_you_want_the_spp_calculated?: "usual_paydates",
                                         monthly_pay_paternity?: "specific_date_each_month")

      @adoption_responses = maternity_adoption_responses(pay_frequency: "monthly", up_to: :how_many_payments_monthly?)
                              .merge(how_do_you_want_the_sap_calculated?: "usual_paydates",
                                     monthly_pay_paternity?: "specific_date_each_month")

      add_responses @non_adoption_responses
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
      should "have a next node of paternity_leave_and_pay for a paternity journey to this node" do
        assert_next_node :paternity_leave_and_pay, for_response: "1"
      end

      should "have a next node of adoption_leave_and_pay for an adoption journey to this node" do
        add_responses @adoption_responses
        assert_next_node :adoption_leave_and_pay, for_response: "1"
      end
    end
  end

  context "question: days_of_the_week_paternity?" do
    setup do
      testing_node :days_of_the_week_paternity?

      @non_adoption_responses = paternity_responses(pay_frequency: "monthly", up_to: :how_many_payments_monthly?)
                                  .merge(how_do_you_want_the_spp_calculated?: "usual_paydates",
                                         monthly_pay_paternity?: "last_working_day_of_the_month")

      @adoption_responses = maternity_adoption_responses(pay_frequency: "monthly", up_to: :how_many_payments_monthly?)
                              .merge(how_do_you_want_the_sap_calculated?: "usual_paydates",
                                     monthly_pay_paternity?: "last_working_day_of_the_month")

      add_responses @non_adoption_responses
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of paternity_leave_and_pay for a paternity journey to this node" do
        assert_next_node :paternity_leave_and_pay, for_response: "5,6"
      end

      should "have a next node of adoption_leave_and_pay for an adoption journey to this node" do
        add_responses @adoption_responses
        assert_next_node :adoption_leave_and_pay, for_response: "0,1"
      end
    end
  end

  context "question: day_of_the_month_paternity?" do
    setup do
      testing_node :day_of_the_month_paternity?
      responses = paternity_responses(pay_frequency: "monthly", up_to: :how_many_payments_monthly?)
                    .merge(how_do_you_want_the_spp_calculated?: "usual_paydates",
                           monthly_pay_paternity?: "a_certain_week_day_each_month")

      add_responses responses
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of which_week_in_month_is_the_employee_paid?" do
        assert_next_node :pay_date_options_paternity?, for_response: "2"
      end
    end
  end

  context "question: pay_date_options_paternity?" do
    setup do
      testing_node :pay_date_options_paternity?

      common_responses = { monthly_pay_paternity?: "a_certain_week_day_each_month",
                           day_of_the_month_paternity?: "2" }

      @non_adoption_responses = paternity_responses(pay_frequency: "monthly", up_to: :how_many_payments_monthly?)
                                  .merge(how_do_you_want_the_spp_calculated?: "usual_paydates")
                                  .merge(common_responses)

      @adoption_responses = maternity_adoption_responses(pay_frequency: "monthly", up_to: :how_many_payments_monthly?)
                              .merge(how_do_you_want_the_sap_calculated?: "usual_paydates")
                              .merge(common_responses)

      add_responses @non_adoption_responses
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of paternity_leave_and_pay for a paternity journey to this node" do
        assert_next_node :paternity_leave_and_pay, for_response: "first"
      end

      should "have a next node of adoption_leave_and_pay for an adoption journey to this node" do
        add_responses @adoption_responses
        assert_next_node :adoption_leave_and_pay, for_response: "first"
      end
    end
  end

  context "outcome: paternity_leave_and_pay" do
    setup do
      testing_node :paternity_leave_and_pay

      # Some of the outcomes can be reached (oddly) via maternity adoption answers
      @maternity_adoption_responses = maternity_adoption_responses(placement_date: "2021-01-01")
                                        .merge(how_do_you_want_the_sap_calculated?: "usual_paydates",
                                               next_pay_day_paternity?: "2021-01-01")
    end

    should "render guidance when an employee isn't entitled to leave due to not having a contract" do
      add_responses paternity_responses.merge(employee_has_contract_paternity?: "no")

      assert_rendered_outcome text: "The employee is not entitled to Statutory Paternity Leave because they don’t " \
                                    "have an employment contract with you."
    end

    should "render guidance when employee is entitled to leave" do
      add_responses paternity_responses

      assert_rendered_outcome text: "The employee is entitled to Statutory Paternity Leave"
    end

    should "render guidance when employee is entitled to leave and is requesting adoption leave" do
      add_responses @maternity_adoption_responses

      assert_rendered_outcome text: "The employee is entitled to Statutory Adoption Leave"
    end

    should "render when an employee is not entitled to pay due to earning below lower limit" do
      add_responses paternity_responses(pay_per_frequency: 1, due_date: "2021-01-01")

      # lower limit for 2020 - 2021 is £120,
      assert_rendered_outcome text: "their average weekly earnings (£1) between Thursday, 02 July 2020 and " \
                                    "Tuesday, 01 September 2020 must be at least £120"
    end

    context "when an employee is entitled to pay" do
      should "render when the eligiblity is for statutory adoption pay" do
        add_responses @maternity_adoption_responses

        assert_rendered_outcome text: "The employee is entitled to SAP"
      end

      should "render when the eligibility is for statutory paternity pay" do
        add_responses paternity_responses

        assert_rendered_outcome text: "The employee is entitled to SPP"
      end

      should "render shared parental guidance for maternity adoption" do
        add_responses @maternity_adoption_responses

        assert_rendered_outcome text: "The latest date for them to claim SAP"
      end

      should "render shared parental guidance for paternity adoption" do
        add_responses paternity_adoption_responses

        assert_rendered_outcome text: "The latest date for them to claim SPP"
        assert_match "/employers-paternity-pay-leave/adoption", @test_flow.outcome_body
      end

      should "render shared parental guidance for non-adoption paternity" do
        add_responses paternity_responses

        assert_rendered_outcome text: "The latest date for them to claim SPP"
        assert_match "/employers-paternity-pay-leave/notice-period", @test_flow.outcome_body
      end
    end
  end

  context "outcome: paternity_not_entitled_to_leave_or_pay" do
    setup { testing_node :paternity_not_entitled_to_leave_or_pay }

    should "render guidance when the employee is entitled to leave" do
      add_responses paternity_responses(up_to: :employee_paternity_length?)
                      .merge(employee_on_payroll_paternity?: "no")

      assert_rendered_outcome text: "The employee is entitled to Statutory Paternity Leave"
    end

    should "render guidance when the employee would have been entitled to leave, but lack a contract" do
      add_responses paternity_responses(up_to: :employee_work_before_employment_start?)
                      .merge(employee_has_contract_paternity?: "no",
                             employee_on_payroll_paternity?: "no")

      assert_rendered_outcome text: "The employee is not entitled to Statutory Paternity Leave because they don’t " \
                                    "have an employment contract with you."
    end

    should "render guidance when an employee is not entitled to pay due to not being on payroll" do
      add_responses paternity_responses(up_to: :employee_work_before_employment_start?)
                      .merge(employee_has_contract_paternity?: "no",
                             employee_on_payroll_paternity?: "no")

      assert_rendered_outcome text: "you must be liable for their secondary Class 1 National Insurance contributions " \
                                    "- you are if they’re on your payroll"
    end

    should "render guidance when an employee is not entitled to pay due to not being employed on the due date" do
      add_responses paternity_responses(up_to: :employee_on_payroll_paternity?, due_date: "2020-11-01")
                      .merge(employee_has_contract_paternity?: "no",
                             employee_still_employed_on_birth_date?: "no")

      # date matches the actual birth date
      assert_rendered_outcome text: "they must still be employed by you on  1 November 2020"
    end

    should "render guidance when an employee is not entitled to pay due to not being employed on the adoption date" do
      add_responses paternity_adoption_responses(up_to: :employee_on_payroll_paternity?, placement_date: "2020-11-01")
                      .merge(employee_has_contract_paternity?: "no",
                             employee_still_employed_on_birth_date?: "no")

      # date matches placement date
      assert_rendered_outcome text: "they must still be employed by you on Sunday, 01 November 2020"
    end

    should "render guidance when they are not entitled to leave or pay" do
      add_responses paternity_responses(up_to: :baby_birth_date_paternity?).merge(employee_responsible_for_upbringing?: "no")

      assert_rendered_outcome text: "Not entitled to Statutory Paternity Pay or Leave"
    end

    should "render guidance when they are not responsible for paternity upbringing" do
      add_responses paternity_responses(up_to: :baby_birth_date_paternity?).merge(employee_responsible_for_upbringing?: "no")

      assert_rendered_outcome text: "aren’t responsible for the child’s upbringing or the biological father or mother’s partner"
    end

    should "render guidance when they are not responsible for paternity adoption upbringing" do
      add_responses paternity_adoption_responses(up_to: :padoption_date_of_adoption_placement?)
                      .merge(padoption_employee_responsible_for_upbringing?: "no")

      assert_rendered_outcome text: "aren’t responsible for the child’s upbringing or the adopter’s partner"
    end

    should "render guidance when they havent worked long enough" do
      add_responses paternity_responses(up_to: :employee_responsible_for_upbringing?, due_date: "2020-11-01")
                      .merge(employee_work_before_employment_start?: "no")

      # Next Saturday after subtracting 40 weeks from the due date
      assert_rendered_outcome text: "they must have started working for you on or before  1 February 2020"
    end
  end
end
