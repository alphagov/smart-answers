require "test_helper"
require "support/flow_test_helper"
require "support/flows/maternity_paternity_calculator_flow_test_helper"

class MaternityPaternityCalculatorFlow::AdoptionCalculatorFlowTest < ActiveSupport::TestCase
  include FlowTestHelper
  include MaternityPaternityCalculatorFlowTestHelper

  setup { testing_flow MaternityPaternityCalculatorFlow }

  context "question: taking_paternity_or_maternity_leave_for_adoption?" do
    setup do
      testing_node :taking_paternity_or_maternity_leave_for_adoption?
      add_responses what_type_of_leave?: "adoption"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of where_does_the_employee_live? for a 'paternity' response" do
        assert_next_node :where_does_the_employee_live?, for_response: "paternity"
      end

      should "have a next node of adoption_is_from_overseas? for a 'maternity' response" do
        assert_next_node :adoption_is_from_overseas?, for_response: "maternity"
      end
    end
  end

  context "question: adoption_is_from_overseas?" do
    setup do
      testing_node :adoption_is_from_overseas?
      add_responses what_type_of_leave?: "adoption",
                    taking_paternity_or_maternity_leave_for_adoption?: "maternity"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of date_of_adoption_match?" do
        assert_next_node :date_of_adoption_match?, for_response: "yes"
      end
    end
  end

  context "question: date_of_adoption_match?" do
    setup do
      testing_node :date_of_adoption_match?
      add_responses what_type_of_leave?: "adoption",
                    taking_paternity_or_maternity_leave_for_adoption?: "maternity",
                    adoption_is_from_overseas?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of date_of_adoption_placement?" do
        assert_next_node :date_of_adoption_placement?, for_response: "2021-01-01"
      end
    end
  end

  context "question: date_of_adoption_placement?" do
    setup do
      testing_node :date_of_adoption_placement?
      add_responses what_type_of_leave?: "adoption",
                    taking_paternity_or_maternity_leave_for_adoption?: "maternity",
                    adoption_is_from_overseas?: "yes",
                    date_of_adoption_match?: "2021-01-01"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid for a date before the match date" do
        assert_invalid_response "2020-12-01"
      end
    end

    context "next_node" do
      should "have a next node of adoption_date_leave_starts? if adoption is from overseas" do
        add_responses adoption_is_from_overseas?: "yes"
        assert_next_node :adoption_date_leave_starts?, for_response: "2021-02-01"
      end

      should "have a next node of adoption_did_the_employee_work_for_you? if adoption is not from overseas" do
        add_responses adoption_is_from_overseas?: "no"
        assert_next_node :adoption_did_the_employee_work_for_you?, for_response: "2021-02-01"
      end
    end
  end

  context "question: adoption_did_the_employee_work_for_you?" do
    setup do
      testing_node :adoption_did_the_employee_work_for_you?
      add_responses what_type_of_leave?: "adoption",
                    taking_paternity_or_maternity_leave_for_adoption?: "maternity",
                    adoption_is_from_overseas?: "no",
                    date_of_adoption_match?: "2021-01-01",
                    date_of_adoption_placement?: "2021-02-01"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of adoption_is_the_employee_on_your_payroll? if responses is 'yes' and then adoption "\
             "is from overseas" do
        add_responses adoption_is_from_overseas?: "yes",
                      adoption_date_leave_starts?: "2021-02-01",
                      adoption_employment_contract?: "yes"
        assert_next_node :adoption_is_the_employee_on_your_payroll?, for_response: "yes"
      end

      should "have a next node of adoption_employment_contract? if responses is 'yes' and then adoption is not from "\
             "overseas" do
        add_responses adoption_is_from_overseas?: "no"
        assert_next_node :adoption_employment_contract?, for_response: "yes"
      end

      should "have a next node of adoption_not_entitled_to_leave_or_pay? if response is 'no'" do
        assert_next_node :adoption_not_entitled_to_leave_or_pay, for_response: "no"
      end
    end
  end

  context "question: adoption_employment_contract?" do
    setup do
      testing_node :adoption_employment_contract?
      @overseas_responses = maternity_adoption_responses(overseas: true, up_to: :adoption_date_leave_starts?)
      @not_overseas_responses = maternity_adoption_responses(up_to: :adoption_did_the_employee_work_for_you?)
    end

    should "render the question" do
      add_responses @overseas_responses
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of adoption_did_the_employee_work_for_you? if the adoption is from overseas" do
        add_responses @overseas_responses
        assert_next_node :adoption_did_the_employee_work_for_you?, for_response: "yes"
      end

      should "have a next node of adoption_is_the_employee_on_your_payroll? if the adoption is not from overseas" do
        add_responses @not_overseas_responses
        assert_next_node :adoption_is_the_employee_on_your_payroll?, for_response: "yes"
      end
    end
  end

  context "question: adoption_is_the_employee_on_your_payroll?" do
    setup do
      testing_node :adoption_is_the_employee_on_your_payroll?
      @overseas_responses = maternity_adoption_responses(overseas: true, up_to: :adoption_did_the_employee_work_for_you?)
      @not_overseas_responses = maternity_adoption_responses(up_to: :adoption_employment_contract?)
    end

    should "render the question" do
      add_responses @overseas_responses
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of adoption_not_entitled_to_leave_or_pay? if the response is 'no' and previously " \
             "responded 'no' adoption_employment_contract?" do
        add_responses @overseas_responses.merge(adoption_employment_contract?: "no")
        assert_next_node :adoption_not_entitled_to_leave_or_pay, for_response: "no"
      end

      should "have a next node of last_normal_payday_adoption? if the adoption is from overseas" do
        add_responses @overseas_responses
        assert_next_node :last_normal_payday_adoption?, for_response: "no"
      end

      should "have a next node of adoption_date_leave_starts? if the adoption is not from overseas" do
        add_responses @not_overseas_responses
        assert_next_node :adoption_date_leave_starts?, for_response: "no"
      end
    end
  end

  context "question: adoption_date_leave_starts?" do
    setup do
      testing_node :adoption_date_leave_starts?
      @overseas_responses = maternity_adoption_responses(overseas: true, up_to: :date_of_adoption_placement?, placement_date: "2021-02-01")
      @not_overseas_responses = maternity_adoption_responses(up_to: :adoption_is_the_employee_on_your_payroll?, placement_date: "2021-02-01")
    end

    should "render the question" do
      add_responses @overseas_responses
      assert_rendered_question
    end

    context "validation" do
      should "be invalid if response is before the earliest start date" do
        # This date is variable based on overseas or not, however going -1 year satisfies both
        add_responses @overseas_responses
        assert_invalid_response "2020-02-01"
      end

      should "be invalid if response is after the latest start date" do
        # This date is variable based on overseas or not, however going +1 month satisfies both
        add_responses @overseas_responses
        assert_invalid_response "2021-03-01"
      end
    end

    context "next_node" do
      should "have a next node of of adoption_employment_contract? if the adoption is from overseas" do
        add_responses @overseas_responses
        assert_next_node :adoption_employment_contract?, for_response: "2021-02-01"
      end

      should "have a next node of adoption_leave_and_pay if the adoption is not from overseas and there is a " \
             "'yes' contract response and 'no' payroll response" do
        add_responses @not_overseas_responses.merge(
          adoption_employment_contract?: "yes",
          adoption_is_the_employee_on_your_payroll?: "no",
        )
        assert_next_node :adoption_leave_and_pay, for_response: "2021-02-01"
      end

      should "have a next node of last_normal_payday_adoption? if the adoption is not from overseas and there are " \
             "different contract and payroll responses" do
        add_responses @not_overseas_responses.merge(
          adoption_employment_contract?: "no",
          adoption_is_the_employee_on_your_payroll?: "yes",
        )
        assert_next_node :last_normal_payday_adoption?, for_response: "2021-02-01"
      end
    end
  end

  context "question: last_normal_payday_adoption?" do
    setup do
      testing_node :last_normal_payday_adoption?
      add_responses maternity_adoption_responses(up_to: :adoption_date_leave_starts?, match_date: "2021-01-01")
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid for a payday after the Saturday that follows the match date" do
        # 2021-01-01 is a Friday, so the 3rd is a Sunday
        assert_invalid_response "2021-01-03"
      end
    end

    context "next_node" do
      should "have a next node of payday_eight_weeks_adoption? for a date before the match date" do
        assert_next_node :payday_eight_weeks_adoption?, for_response: "2020-12-31"
      end
    end
  end

  context "question: payday_eight_weeks_adoption?" do
    setup do
      testing_node :payday_eight_weeks_adoption?
      add_responses maternity_adoption_responses(last_normal_payday: "2021-01-01",
                                                 up_to: :last_normal_payday_adoption?)
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid for a payday within 8 weeks of the last normal payday" do
        date = Date.parse("2021-01-01") - 7.weeks
        assert_invalid_response date.to_s
      end
    end

    context "next_node" do
      should "have a next node of pay_frequency_adoption? for a last payday greater than 8 weeks earlier" do
        date = Date.parse("2021-01-01") - 9.weeks
        assert_next_node :pay_frequency_adoption?, for_response: date.to_s
      end
    end
  end

  context "question: pay_frequency_adoption?" do
    setup do
      testing_node :pay_frequency_adoption?
      add_responses maternity_adoption_responses(up_to: :payday_eight_weeks_adoption?)
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of earnings_for_pay_period_adoption?" do
        assert_next_node :earnings_for_pay_period_adoption?, for_response: "weekly"
      end
    end
  end

  context "question: earnings_for_pay_period_adoption?" do
    setup do
      testing_node :earnings_for_pay_period_adoption?
      add_responses maternity_adoption_responses(up_to: :pay_frequency_adoption?)
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_many_payments_weekly? when pay is under a lower limit" do
        assert_next_node :adoption_leave_and_pay, for_response: "1"
      end

      should "have a next node of how_many_payments_weekly? when pay frequency is weekly" do
        add_responses pay_frequency_adoption?: "weekly"
        assert_next_node :how_many_payments_weekly?, for_response: "1000"
      end

      should "have a next node of how_many_payments_every_2_weeks? when pay frequency is every 2 weeks" do
        add_responses pay_frequency_adoption?: "every_2_weeks"
        assert_next_node :how_many_payments_every_2_weeks?, for_response: "2000"
      end

      should "have a next node of how_many_payments_every_4_weeks? when pay frequency is every 4 weeks" do
        add_responses pay_frequency_adoption?: "every_4_weeks"
        assert_next_node :how_many_payments_every_4_weeks?, for_response: "4000"
      end

      should "have a next node of how_many_payments_monthly? when pay frequency is monthly" do
        add_responses pay_frequency_adoption?: "monthly"
        assert_next_node :how_many_payments_monthly?, for_response: "4000"
      end
    end
  end

  context "question: how_do_you_want_the_sap_calculated?" do
    setup do
      testing_node :how_do_you_want_the_sap_calculated?
      add_responses maternity_adoption_responses(up_to: :how_many_payments_weekly?)
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of adoption_leave_and_pay when the response is 'weekly_starting'" do
        assert_next_node :adoption_leave_and_pay, for_response: "weekly_starting"
      end

      should "have a next node of monthly_pay_paternity? when response is 'usual_paydates' and the pay pattern " \
             "responses is monthly" do
        add_responses pay_frequency_adoption?: "monthly", how_many_payments_monthly?: "2"
        assert_next_node :monthly_pay_paternity?, for_response: "usual_paydates"
      end

      should "have a next node of next_pay_day_paternity? when response is 'usual_paydates' and the pay pattern " \
             "responses is multiple weeks" do
        add_responses pay_frequency_adoption?: "every_2_weeks", how_many_payments_every_2_weeks?: "4"
        assert_next_node :next_pay_day_paternity?, for_response: "usual_paydates"
      end
    end
  end

  context "outcome: adoption_leave_and_pay" do
    setup { testing_node :adoption_leave_and_pay }

    should "render guidance when an employee doesn't have a contract" do
      add_responses maternity_adoption_responses.merge(adoption_employment_contract?: "no")

      assert_rendered_outcome text: "The employee is not entitled to Statutory Adoption Leave because they don’t " \
                                    "have an employment contract with you."
    end

    should "render leave entitlement for an employee with a contract" do
      add_responses maternity_adoption_responses(placement_date: "2021-02-01").merge(adoption_employment_contract?: "yes")

      assert_rendered_outcome text: "The employee is entitled to up to 52 weeks Statutory Adoption Leave"
      assert_match(/Start\s*1 February 2021/, @test_flow.outcome_text)
      assert_match(/End\s*30 January 2022/, @test_flow.outcome_text)
    end

    should "render when an employee is entitled to statutory adoption pay" do
      add_responses maternity_adoption_responses(pay_frequency: "weekly", pay_per_frequency: 1_000, placement_date: "2024-05-01")

      assert_rendered_outcome text: "The employee is entitled to up to 39 weeks Statutory Adoption Pay (SAP)"

      # 90% of 1000 a week for 6 weeks + (39 - 6) * 184.03 statutory (rate for 2024)
      # = (900 * 6) + (33 * 184.03)
      assert_match(/Total SAP:\s*£11,472.99/, @test_flow.outcome_text)
    end

    should "render when an employee is entitled to statutory adoption pay and exactly on the threshold" do
      add_responses(
        what_type_of_leave?: "adoption",
        taking_paternity_or_maternity_leave_for_adoption?: "maternity",
        adoption_is_from_overseas?: "no",
        date_of_adoption_match?: "2022-12-15",
        date_of_adoption_placement?: "2022-12-15",
        adoption_did_the_employee_work_for_you?: "yes",
        adoption_employment_contract?: "yes",
        adoption_is_the_employee_on_your_payroll?: "yes",
        adoption_date_leave_starts?: "2022-12-15",
        last_normal_payday_adoption?: "2022-11-30",
        payday_eight_weeks_adoption?: "2022-09-30",
        pay_frequency_adoption?: "monthly",
        earnings_for_pay_period_adoption?: "1066.0",
        how_many_payments_monthly?: "2",
        how_do_you_want_the_sap_calculated?: "weekly_starting",
      )

      # lower limit for 2021 - 2022 is £123/w, 1066/m
      assert_rendered_outcome text: "The employee is entitled to up to 39 weeks Statutory Adoption Pay (SAP)"

      assert_match(/Total SAP:\s*£4,317.30/, @test_flow.outcome_text)
    end

    should "render when an employee is not entitled to statutory adoption pay due to no payroll" do
      add_responses maternity_adoption_responses.merge(adoption_is_the_employee_on_your_payroll?: "no")

      assert_rendered_outcome text: "you must be liable for their secondary Class 1 National Insurance " \
                                    "contributions - you are if they’re on your payroll"
    end

    should "render when an employee is not entitled to statutory adoption pay due to insufficient pay" do
      add_responses maternity_adoption_responses(pay_frequency: "weekly",
                                                 pay_per_frequency: 120,
                                                 placement_date: "2023-08-01",
                                                 last_normal_payday: "2023-04-01",
                                                 payday_eight_weeks: "2022-02-01")

      # lower limit for 2022 - 2023 is £123
      assert_rendered_outcome text: "their average weekly earnings (£120) between Wednesday, 02 February 2022 and " \
                                    "Saturday, 01 April 2023 must be at least £123"
    end
  end

  context "outcome: adoption_not_entitled_to_leave_or_pay" do
    setup { testing_node :adoption_not_entitled_to_leave_or_pay }

    should "render guidance when an adoption is from overseas" do
      add_responses maternity_adoption_responses(overseas: true, placement_date: "2021-05-01", up_to: :date_of_adoption_placement?)
                      .merge(adoption_date_leave_starts?: "2021-05-01",
                             adoption_employment_contract?: "no",
                             adoption_did_the_employee_work_for_you?: "no")

      # for overseas the lowest date is 26 weeks before leave start date (01-05-2021)
      assert_rendered_outcome text: "they must have started working for you on 31 October 2020."
    end

    should "render guidance when an adoption is not from overseas" do
      add_responses maternity_adoption_responses(match_date: "2021-01-01", up_to: :date_of_adoption_placement?)
                      .merge(adoption_did_the_employee_work_for_you?: "no")

      # for non-overseas the lowest date is 25 weeks before the match date to the nearest Saturday
      assert_rendered_outcome text: "they must have started working for you on 11 July 2020."
    end
  end
end
