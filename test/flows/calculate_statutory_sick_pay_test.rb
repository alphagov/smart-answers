require "test_helper"
require "support/flow_test_helper"

class CalculateStatutorySickPayTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup { testing_flow CalculateStatutorySickPayFlow }

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: is_your_employee_getting?" do
    setup { testing_node :is_your_employee_getting? }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of already_getting_maternity for a 'statutory_maternity_pay' response" do
        assert_next_node :already_getting_maternity, for_response: "statutory_maternity_pay"
      end

      should "have a next node of coronavirus_related? for a 'statutory_maternity_pay' response" do
        assert_next_node :coronavirus_related?, for_response: "statutory_adoption_pay"
      end
    end
  end

  context "question: coronavirus_related?" do
    setup do
      testing_node :coronavirus_related?
      add_responses is_your_employee_getting?: "statutory_adoption_pay"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of coronavirus_gp_letter? for 'yes' response" do
        assert_next_node :coronavirus_gp_letter?, for_response: "yes"
      end

      should "have a next node of employee_tell_within_limit? for 'no' response" do
        assert_next_node :employee_tell_within_limit?, for_response: "no"
      end
    end
  end

  context "question: coronavirus_gp_letter?" do
    setup do
      testing_node :coronavirus_gp_letter?
      add_responses is_your_employee_getting?: "statutory_adoption_pay",
                    coronavirus_related?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of employee_tell_within_limit? for 'yes' response" do
        assert_next_node :employee_tell_within_limit?, for_response: "yes"
      end

      should "have a next node of coronavirus_self_or_cohabitant? for 'no' response" do
        assert_next_node :coronavirus_self_or_cohabitant?, for_response: "no"
      end
    end
  end

  context "question: coronavirus_self_or_cohabitant?" do
    setup do
      testing_node :coronavirus_self_or_cohabitant?
      add_responses is_your_employee_getting?: "statutory_adoption_pay",
                    coronavirus_related?: "yes",
                    coronavirus_gp_letter?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of employee_tell_within_limit? for any response" do
        assert_next_node :employee_tell_within_limit?, for_response: "self"
      end
    end
  end

  context "question: employee_tell_within_limit?" do
    setup do
      testing_node :employee_tell_within_limit?
      add_responses is_your_employee_getting?: "statutory_adoption_pay",
                    coronavirus_related?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of employee_work_different_days? for any response" do
        assert_next_node :employee_work_different_days?, for_response: "yes"
      end
    end
  end

  context "question: employee_work_different_days?" do
    setup do
      testing_node :employee_work_different_days?
      add_responses is_your_employee_getting?: "statutory_adoption_pay",
                    coronavirus_related?: "no",
                    employee_tell_within_limit?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of not_regular_schedule for 'yes' response" do
        assert_next_node :not_regular_schedule, for_response: "yes"
      end

      should "have a next node of first_sick_day? for 'no' response" do
        assert_next_node :first_sick_day?, for_response: "no"
      end
    end
  end

  context "question: first_sick_day?" do
    setup do
      testing_node :first_sick_day?
      add_responses is_your_employee_getting?: "statutory_adoption_pay",
                    coronavirus_related?: "no",
                    employee_tell_within_limit?: "yes",
                    employee_work_different_days?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid if the first sick day is before 2011" do
        assert_invalid_response "2010-12-01"
      end

      should "be invalid if the first sick day is in the future" do
        assert_invalid_response "3000-01-01"
      end
    end

    context "next_node" do
      should "have a next node of last_sick_day? for any response" do
        assert_next_node :last_sick_day?, for_response: "2020-01-01"
      end
    end
  end

  context "question: last_sick_day?" do
    setup do
      testing_node :last_sick_day?
      add_responses is_your_employee_getting?: "statutory_adoption_pay",
                    coronavirus_related?: "no",
                    employee_tell_within_limit?: "yes",
                    employee_work_different_days?: "no",
                    first_sick_day?: "2020-01-01"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid if the last sick day is before 2011" do
        assert_invalid_response "2010-12-01"
      end

      should "be invalid if the last sick day is in the future" do
        assert_invalid_response "3000-01-01"
      end

      should "be invalid if the last sick day is before the first" do
        assert_invalid_response "2019-12-25"
      end
    end

    context "next_node" do
      should "have a next node of has_linked_sickness? for over 4 days" do
        assert_next_node :has_linked_sickness?, for_response: "2020-01-05"
      end

      should "have a next node of must_be_sick_for_4_days for under 4 days" do
        assert_next_node :must_be_sick_for_4_days, for_response: "2020-01-02"
      end
    end
  end

  context "question: has_linked_sickness?" do
    setup do
      testing_node :has_linked_sickness?
      add_responses is_your_employee_getting?: "statutory_adoption_pay",
                    coronavirus_related?: "no",
                    employee_tell_within_limit?: "yes",
                    employee_work_different_days?: "no",
                    first_sick_day?: "2020-01-01",
                    last_sick_day?: "2020-01-05"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of linked_sickness_start_date? for 'yes' response" do
        assert_next_node :linked_sickness_start_date?, for_response: "yes"
      end

      should "have a next node of paid_at_least_8_weeks? for 'no' response" do
        assert_next_node :paid_at_least_8_weeks?, for_response: "no"
      end
    end
  end

  context "question: linked_sickness_start_date?" do
    setup do
      testing_node :linked_sickness_start_date?
      add_responses is_your_employee_getting?: "statutory_adoption_pay",
                    coronavirus_related?: "no",
                    employee_tell_within_limit?: "yes",
                    employee_work_different_days?: "no",
                    first_sick_day?: "2020-01-01",
                    last_sick_day?: "2020-01-05",
                    has_linked_sickness?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid if the linked sickness start date is before 2010" do
        assert_invalid_response "2009-12-01"
      end

      should "be invalid if the linked sickness start date is in the future" do
        assert_invalid_response "3000-01-01"
      end

      should "be invalid if the linked sickness start date is after the first sick day" do
        assert_invalid_response "2020-01-02"
      end
    end

    context "next_node" do
      should "have a next node of linked_sickness_end_date? for any response" do
        assert_next_node :linked_sickness_end_date?, for_response: "2019-12-01"
      end
    end
  end

  context "question: linked_sickness_end_date?" do
    setup do
      testing_node :linked_sickness_end_date?
      add_responses is_your_employee_getting?: "statutory_adoption_pay",
                    coronavirus_related?: "no",
                    employee_tell_within_limit?: "yes",
                    employee_work_different_days?: "no",
                    first_sick_day?: "2020-01-01",
                    last_sick_day?: "2020-01-05",
                    has_linked_sickness?: "yes",
                    linked_sickness_start_date?: "2019-12-01"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid if the linked sickness end date is before 2010" do
        assert_invalid_response "2009-01-01"
      end

      should "be invalid if the linked sickness end date is in the future" do
        assert_invalid_response "3000-01-01"
      end

      should "be invalid if the linked sickness ends more than 8 weeks before first sick day" do
        assert_invalid_response "2019-10-01"
      end

      should "be invalid if the linked sickness end date is before first sick day" do
        assert_invalid_response "2020-01-01"
      end

      should "be invalid if the linked sickness end date is before the linked sickness start date" do
        assert_invalid_response "2019-11-30"
      end
    end

    context "next_node" do
      should "have a next node of paid_at_least_8_weeks? for any response" do
        assert_next_node :paid_at_least_8_weeks?, for_response: "2019-12-30"
      end
    end
  end

  context "question: paid_at_least_8_weeks?" do
    setup do
      testing_node :paid_at_least_8_weeks?
      add_responses is_your_employee_getting?: "statutory_adoption_pay",
                    coronavirus_related?: "no",
                    employee_tell_within_limit?: "yes",
                    employee_work_different_days?: "no",
                    first_sick_day?: "2020-01-01",
                    last_sick_day?: "2020-01-05",
                    has_linked_sickness?: "yes",
                    linked_sickness_start_date?: "2019-12-01",
                    linked_sickness_end_date?: "2019-12-30"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_often_pay_employee_pay_patterns? for 'eight_weeks_more' response" do
        assert_next_node :how_often_pay_employee_pay_patterns?, for_response: "eight_weeks_more"
      end

      should "have a next node of total_earnings_before_sick_period? for 'eight_weeks_less' response" do
        assert_next_node :total_earnings_before_sick_period?, for_response: "eight_weeks_less"
      end

      should "have a next node of how_often_pay_employee_pay_patterns? for 'before_payday' response" do
        assert_next_node :how_often_pay_employee_pay_patterns?, for_response: "before_payday"
      end
    end
  end

  context "question: how_often_pay_employee_pay_patterns?" do
    setup do
      testing_node :how_often_pay_employee_pay_patterns?
      add_responses is_your_employee_getting?: "statutory_adoption_pay",
                    coronavirus_related?: "no",
                    employee_tell_within_limit?: "yes",
                    employee_work_different_days?: "no",
                    first_sick_day?: "2020-01-01",
                    last_sick_day?: "2020-01-05",
                    has_linked_sickness?: "yes",
                    linked_sickness_start_date?: "2019-12-01",
                    linked_sickness_end_date?: "2019-12-30",
                    paid_at_least_8_weeks?: "eight_weeks_more"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of last_payday_before_sickness? when paid at least 8 weeks of earnings" do
        assert_next_node :last_payday_before_sickness?, for_response: "weekly"
      end

      should "have a next node of last_payday_before_sickness? when not paid 8 weeks of earnings" do
        add_responses paid_at_least_8_weeks?: "before_payday"
        assert_next_node :pay_amount_if_not_sick?, for_response: "weekly"
      end
    end
  end

  context "question: last_payday_before_sickness?" do
    setup do
      testing_node :last_payday_before_sickness?
      add_responses is_your_employee_getting?: "statutory_adoption_pay",
                    coronavirus_related?: "no",
                    employee_tell_within_limit?: "yes",
                    employee_work_different_days?: "no",
                    first_sick_day?: "2020-01-01",
                    last_sick_day?: "2020-01-05",
                    has_linked_sickness?: "yes",
                    linked_sickness_start_date?: "2019-12-01",
                    linked_sickness_end_date?: "2019-12-30",
                    how_often_pay_employee_pay_patterns?: "weekly",
                    paid_at_least_8_weeks?: "eight_weeks_more"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid if the last payday before sickness is before 2010" do
        assert_invalid_response "2009-01-01"
      end

      should "be invalid if the last payday before sickness is in the future" do
        assert_invalid_response "3000-01-01"
      end

      should "be invalid if the last payday before sickness is after the first sick day" do
        assert_invalid_response "2020-01-02"
      end
    end

    context "next_node" do
      should "have a next node of last_payday_before_offset? for any valid response" do
        assert_next_node :last_payday_before_offset?, for_response: "2019-11-25"
      end
    end
  end

  context "question: last_payday_before_offset?" do
    setup do
      testing_node :last_payday_before_offset?
      add_responses is_your_employee_getting?: "statutory_adoption_pay",
                    coronavirus_related?: "no",
                    employee_tell_within_limit?: "yes",
                    employee_work_different_days?: "no",
                    first_sick_day?: "2020-01-01",
                    last_sick_day?: "2020-01-05",
                    has_linked_sickness?: "yes",
                    linked_sickness_start_date?: "2019-12-01",
                    linked_sickness_end_date?: "2019-12-30",
                    how_often_pay_employee_pay_patterns?: "weekly",
                    paid_at_least_8_weeks?: "eight_weeks_more",
                    last_payday_before_sickness?: "2019-11-25"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid if the last payday before offset is before 2010" do
        assert_invalid_response "2009-01-01"
      end

      should "be invalid if the last payday before offset is in the future" do
        assert_invalid_response "3000-01-01"
      end

      should "be invalid if the last payday before offset is more than 8 weeks before last payday before sickness" do
        assert_invalid_response "2019-10-25"
      end
    end

    context "next_node" do
      should "have a next node of total_employee_earnings? for any valid response" do
        assert_next_node :total_employee_earnings?, for_response: "2019-09-20"
      end
    end
  end

  context "question: total_employee_earnings?" do
    setup do
      testing_node :total_employee_earnings?
      add_responses is_your_employee_getting?: "statutory_adoption_pay",
                    coronavirus_related?: "no",
                    employee_tell_within_limit?: "yes",
                    employee_work_different_days?: "no",
                    first_sick_day?: "2020-01-01",
                    last_sick_day?: "2020-01-05",
                    has_linked_sickness?: "yes",
                    linked_sickness_start_date?: "2019-12-01",
                    linked_sickness_end_date?: "2019-12-30",
                    how_often_pay_employee_pay_patterns?: "weekly",
                    paid_at_least_8_weeks?: "eight_weeks_more",
                    last_payday_before_sickness?: "2019-11-25",
                    last_payday_before_offset?: "2019-09-20"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of usual_work_days? for any response" do
        assert_next_node :usual_work_days?, for_response: "35000"
      end
    end
  end

  context "question: pay_amount_if_not_sick?" do
    setup do
      testing_node :pay_amount_if_not_sick?
      add_responses is_your_employee_getting?: "statutory_adoption_pay",
                    coronavirus_related?: "no",
                    employee_tell_within_limit?: "yes",
                    employee_work_different_days?: "no",
                    first_sick_day?: "2020-01-01",
                    last_sick_day?: "2020-01-05",
                    has_linked_sickness?: "yes",
                    linked_sickness_start_date?: "2019-12-01",
                    linked_sickness_end_date?: "2019-12-30",
                    paid_at_least_8_weeks?: "before_payday",
                    how_often_pay_employee_pay_patterns?: "weekly"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of contractual_days_covered_by_earnings? for any response" do
        assert_next_node :contractual_days_covered_by_earnings?, for_response: "35000"
      end
    end
  end

  context "question: contractual_days_covered_by_earnings?" do
    setup do
      testing_node :contractual_days_covered_by_earnings?
      add_responses is_your_employee_getting?: "statutory_adoption_pay",
                    coronavirus_related?: "no",
                    employee_tell_within_limit?: "yes",
                    employee_work_different_days?: "no",
                    first_sick_day?: "2020-01-01",
                    last_sick_day?: "2020-01-05",
                    has_linked_sickness?: "yes",
                    linked_sickness_start_date?: "2019-12-01",
                    linked_sickness_end_date?: "2019-12-30",
                    paid_at_least_8_weeks?: "before_payday",
                    how_often_pay_employee_pay_patterns?: "weekly",
                    pay_amount_if_not_sick?: "35000"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid if contractual days covered by earnings is not a number" do
        assert_invalid_response "ham"
      end
    end

    context "next_node" do
      should "have a next node of usual_work_days? for any valid response" do
        assert_next_node :usual_work_days?, for_response: "5"
      end
    end
  end

  context "question: total_earnings_before_sick_period?" do
    setup do
      testing_node :total_earnings_before_sick_period?
      add_responses is_your_employee_getting?: "statutory_adoption_pay",
                    coronavirus_related?: "no",
                    employee_tell_within_limit?: "yes",
                    employee_work_different_days?: "no",
                    first_sick_day?: "2020-01-01",
                    last_sick_day?: "2020-01-05",
                    has_linked_sickness?: "yes",
                    linked_sickness_start_date?: "2019-12-01",
                    linked_sickness_end_date?: "2019-12-30",
                    paid_at_least_8_weeks?: "eight_weeks_less"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of days_covered_by_earnings? for any valid response" do
        assert_next_node :days_covered_by_earnings?, for_response: "700000"
      end
    end
  end

  context "question: days_covered_by_earnings?" do
    setup do
      testing_node :days_covered_by_earnings?
      add_responses is_your_employee_getting?: "statutory_adoption_pay",
                    coronavirus_related?: "no",
                    employee_tell_within_limit?: "yes",
                    employee_work_different_days?: "no",
                    first_sick_day?: "2020-01-01",
                    last_sick_day?: "2020-01-05",
                    has_linked_sickness?: "yes",
                    linked_sickness_start_date?: "2019-12-01",
                    linked_sickness_end_date?: "2019-12-30",
                    paid_at_least_8_weeks?: "eight_weeks_less",
                    total_earnings_before_sick_period?: "700000"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of usual_work_days? for any valid response" do
        assert_next_node :usual_work_days?, for_response: "5"
      end
    end
  end

  context "question: usual_work_days?" do
    setup do
      testing_node :usual_work_days?
      add_responses is_your_employee_getting?: "statutory_adoption_pay",
                    coronavirus_related?: "no",
                    employee_tell_within_limit?: "yes",
                    employee_work_different_days?: "no",
                    first_sick_day?: "2020-01-01",
                    last_sick_day?: "2020-01-05",
                    has_linked_sickness?: "yes",
                    linked_sickness_start_date?: "2019-12-01",
                    linked_sickness_end_date?: "2019-12-30",
                    paid_at_least_8_weeks?: "eight_weeks_less",
                    total_earnings_before_sick_period?: "700000",
                    days_covered_by_earnings?: "5"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have an outcome of not_earned_enough for any response if employee_average_weekly_earnings is less than lower_earning_limit_rate" do
        add_responses total_earnings_before_sick_period?: "70"

        assert_next_node :not_earned_enough, for_response: "4"
      end

      should "have an outcome of maximum_entitlement_reached for any response if too many previous sick days" do
        add_responses linked_sickness_start_date?: "2018-12-01",
                      linked_sickness_end_date?: "2019-12-30"

        assert_next_node :maximum_entitlement_reached, for_response: "4"
      end

      should "have an outcome of entitled_to_sick_pay for any response if ssp_payment is greater than 0" do
        assert_next_node :entitled_to_sick_pay, for_response: "3"
      end

      should "have an outcome of maximum_entitlement_reached for any response if zero days can be paid for period" do
        add_responses linked_sickness_start_date?: "2019-05-23",
                      linked_sickness_end_date?: "2019-12-29",
                      days_covered_by_earnings?: "1"

        assert_next_node :maximum_entitlement_reached, for_response: "0"
      end

      should "have an outcome of not_entitled_3_days_not_paid for any response if sick for less than three days" do
        assert_next_node :not_entitled_3_days_not_paid, for_response: "2"
      end
    end
  end

  context "outcome: entitled_to_sick_pay" do
    setup do
      testing_node :entitled_to_sick_pay
      add_responses is_your_employee_getting?: "statutory_adoption_pay",
                    coronavirus_related?: "no",
                    employee_tell_within_limit?: "no",
                    employee_work_different_days?: "no",
                    first_sick_day?: "2020-01-01",
                    last_sick_day?: "2020-01-05",
                    has_linked_sickness?: "yes",
                    linked_sickness_start_date?: "2019-12-01",
                    linked_sickness_end_date?: "2019-12-30",
                    paid_at_least_8_weeks?: "eight_weeks_less",
                    total_earnings_before_sick_period?: "700000",
                    days_covered_by_earnings?: "5",
                    usual_work_days?: "3"
    end

    should "render text when there's not enough notice of absence" do
      assert_rendered_outcome text: "You don’t have to pay until your employee tells you that they’re ill."
    end

    should "not render text when there's enough notice of absence" do
      add_responses employee_tell_within_limit?: "yes"

      assert_no_match "You don’t have to pay until your employee tells you that they’re ill.", @test_flow.outcome_text
    end

    should "render statutory paternity warning text if already receiving shared parental or statutory paternity pay" do
      assert_rendered_outcome text: "Your employee will not be able to collect Statutory Shared Parental Pay, Statutory Paternity Pay"
    end

    should "not render the statutory paternity warning text if not receiving shared parental or statutory paternity pay" do
      add_responses is_your_employee_getting?: ""

      assert_no_match "Your employee will not be able to collect Statutory Shared Parental Pay, Statutory Paternity Pay", @test_flow.outcome_text
    end
  end
end
