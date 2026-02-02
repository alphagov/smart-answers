require "test_helper"
require "support/flow_test_helper"

class MaternityPaternityPayLeaveFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    testing_flow MaternityPaternityPayLeaveFlow
  end

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: two_carers" do
    setup { testing_node :two_carers }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of where does the mother's partner live for a 'yes' response" do
        assert_next_node :where_does_the_mother_partner_live, for_response: "yes"
      end

      should "have a next node of due_date for a 'no' response" do
        assert_next_node :due_date, for_response: "no"
      end
    end
  end

  context "question: where_does_the_mother_partner_live" do
    setup do
      testing_node :where_does_the_mother_partner_live
      add_responses two_carers: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of due_date " \
               "for any response" do
        assert_next_node :due_date, for_response: "england"
      end
    end
  end

  context "question: due_date" do
    setup do
      testing_node :due_date
      add_responses two_carers: "yes",
                    where_does_the_mother_partner_live: "england"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of employment_status_of_mother " \
               "for any response" do
        assert_next_node :employment_status_of_mother, for_response: "2016-1-1"
      end
    end
  end

  context "question: employment_status_of_mother" do
    setup do
      testing_node :employment_status_of_mother
      add_responses two_carers: "yes",
                    where_does_the_mother_partner_live: "england",
                    due_date: "2016-1-1"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of employment_status_of_partner " \
               "for any response " \
               "when there are two carers" do
        assert_next_node :employment_status_of_partner, for_response: "employee"
      end

      %w[employee worker].each do |response|
        should "have a next node of mother_started_working_before_continuity_start_date " \
                 "for a '#{response}' response " \
                 "when there is a single carer" do
          add_responses two_carers: "no"
          assert_next_node :mother_started_working_before_continuity_start_date, for_response: response
        end
      end

      %w[self-employed unemployed].each do |response|
        should "have a next node of mother_worked_at_least_26_weeks " \
                 "for a '#{response}' response " \
                 "when there is a single carer" do
          add_responses two_carers: "no"
          assert_next_node :mother_worked_at_least_26_weeks, for_response: response
        end
      end
    end
  end

  context "question: employment_status_of_partner" do
    setup do
      testing_node :employment_status_of_partner
      add_responses two_carers: "yes",
                    where_does_the_mother_partner_live: "england",
                    due_date: "2016-1-1",
                    employment_status_of_mother: "employee"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      %w[employee worker].each do |mothers_employment_status|
        should "have a next node of mother_started_working_before_continuity_start_date " \
                 "for any response " \
                 "when the mothers employment status is '#{mothers_employment_status}'" do
          add_responses employment_status_of_mother: mothers_employment_status
          assert_next_node :mother_started_working_before_continuity_start_date, for_response: "employee"
        end
      end

      %w[self-employed unemployed].each do |mothers_employment_status|
        should "have a next node of mother_worked_at_least_26_weeks " \
                 "for any response " \
                 "when the mothers employment status is '#{mothers_employment_status}'" do
          add_responses employment_status_of_mother: mothers_employment_status
          assert_next_node :mother_worked_at_least_26_weeks, for_response: "employee"
        end
      end
    end
  end

  context "question: mother_started_working_before_continuity_start_date" do
    setup do
      testing_node :mother_started_working_before_continuity_start_date
      add_responses two_carers: "no",
                    due_date: "2016-1-1",
                    employment_status_of_mother: "employee"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of mother_still_working_on_continuity_end_date " \
               "for a any response " \
               "when there is a single carer" do
        assert_next_node :mother_still_working_on_continuity_end_date, for_response: "yes"
      end
    end
  end

  context "question: mother_still_working_on_continuity_end_date" do
    setup do
      testing_node :mother_still_working_on_continuity_end_date
      add_responses two_carers: "no",
                    due_date: "2016-1-1",
                    employment_status_of_mother: "employee",
                    mother_started_working_before_continuity_start_date: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of mother_earned_more_than_lower_earnings_limit " \
               "for any response" do
        assert_next_node :mother_earned_more_than_lower_earnings_limit, for_response: "yes"
      end
    end
  end

  context "question: mother_earned_more_than_lower_earnings_limit" do
    setup do
      testing_node :mother_earned_more_than_lower_earnings_limit
      add_responses two_carers: "yes",
                    where_does_the_mother_partner_live: "england",
                    due_date: "2016-1-1",
                    employment_status_of_mother: "employee",
                    employment_status_of_partner: "employee",
                    mother_started_working_before_continuity_start_date: "yes",
                    mother_still_working_on_continuity_end_date: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of partner_started_working_before_continuity_start_date " \
               "for a 'yes' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the partner is an employee" do
        assert_next_node :partner_started_working_before_continuity_start_date, for_response: "yes"
      end

      should "have a next node of partner_started_working_before_continuity_start_date " \
               "for a 'yes' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the partner is a worker" do
        add_responses employment_status_of_partner: "worker"
        assert_next_node :partner_started_working_before_continuity_start_date, for_response: "yes"
      end

      should "have a next node of outcome_mat_leave_mat_pay " \
               "for a 'yes' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the partner is self-employed" do
        add_responses employment_status_of_partner: "self-employed"
        assert_next_node :outcome_mat_leave_mat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_leave_mat_pay " \
               "for a 'yes' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the partner is unemployed" do
        add_responses employment_status_of_partner: "unemployed"
        assert_next_node :outcome_mat_leave_mat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_leave_mat_pay " \
               "for a 'yes' response " \
               "when there is a single carer " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date" do
        add_responses two_carers: "no"
        assert_next_node :outcome_mat_leave_mat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_pay " \
               "for a 'yes' response " \
               "when there is a single carer " \
               "and the mother is a worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date" do
        add_responses two_carers: "no",
                      employment_status_of_mother: "worker"
        assert_next_node :outcome_mat_pay, for_response: "yes"
      end

      should "have a next node of mother_worked_at_least_26_weeks " \
               "for any response " \
               "and the mother started working before the continuity start date " \
               "and the mother is not working on the continuity end date" do
        add_responses mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "no"
        assert_next_node :mother_worked_at_least_26_weeks, for_response: "no"
      end

      should "have a next node of mother_worked_at_least_26_weeks " \
               "for any response " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is working on the continuity end date" do
        add_responses mother_started_working_before_continuity_start_date: "no",
                      mother_still_working_on_continuity_end_date: "yes"
        assert_next_node :mother_worked_at_least_26_weeks, for_response: "no"
      end

      should "have a next node of mother_worked_at_least_26_weeks " \
               "for any response " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is not working on the continuity end date" do
        add_responses mother_started_working_before_continuity_start_date: "no",
                      mother_still_working_on_continuity_end_date: "no"
        assert_next_node :mother_worked_at_least_26_weeks, for_response: "no"
      end

      should "have a next node of mother_worked_at_least_26_weeks " \
               "for a 'no' response" do
        assert_next_node :mother_worked_at_least_26_weeks, for_response: "no"
      end
    end
  end

  context "question: mother_worked_at_least_26_weeks" do
    setup do
      testing_node :mother_worked_at_least_26_weeks
      add_responses two_carers: "no",
                    due_date: "2016-1-1",
                    employment_status_of_mother: "unemployed"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of partner_started_working_before_continuity_start_date " \
               "for a 'no' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is an employee " \
               "and the partner is an employee" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "employee",
                      employment_status_of_partner: "employee",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :partner_started_working_before_continuity_start_date, for_response: "no"
      end

      should "have a next node of partner_started_working_before_continuity_start_date " \
               "for a 'no' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is an employee " \
               "and the partner is a worker" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "employee",
                      employment_status_of_partner: "worker",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :partner_started_working_before_continuity_start_date, for_response: "no"
      end

      should "have a next node of partner_started_working_before_continuity_start_date " \
               "for a 'no' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is self-employed " \
               "and the partner is an employee" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "self-employed",
                      employment_status_of_partner: "employee",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :partner_started_working_before_continuity_start_date, for_response: "no"
      end

      should "have a next node of partner_started_working_before_continuity_start_date " \
               "for a 'no' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is self-employed " \
               "and the partner is a worker" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "self-employed",
                      employment_status_of_partner: "worker",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :partner_started_working_before_continuity_start_date, for_response: "no"
      end

      should "have a next node of outcome_mat_leave " \
               "for a 'no' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is an employee " \
               "and the partner is unemployed " \
               "and the mother did started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother did not earn more than the lower earnings limit" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "employee",
                      employment_status_of_partner: "unemployed",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_leave " \
               "for a 'no' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is an employee " \
               "and the partner is self-employed " \
               "and the mother did started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother did not earn more than the lower earnings limit" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "employee",
                      employment_status_of_partner: "self-employed",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_leave " \
               "for a 'no' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is an employee " \
               "and the partner is self-employed " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is working on the continuity end date" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "employee",
                      employment_status_of_partner: "self-employed",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_leave " \
               "for a 'no' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is an employee " \
               "and the partner is unemployed " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is working on the continuity end date" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "employee",
                      employment_status_of_partner: "unemployed",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is an employee " \
               "and the partner is self-employed " \
               "and the mother started working before the continuity start date " \
               "and the mother is not working on the continuity end date" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "employee",
                      employment_status_of_partner: "self-employed",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is an employee " \
               "and the partner is unemployed " \
               "and the mother started working before the continuity start date " \
               "and the mother is not working on the continuity end date" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "employee",
                      employment_status_of_partner: "unemployed",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is self-employed " \
               "and the partner is unemployed" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "self-employed",
                      employment_status_of_partner: "unemployed",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is self-employed " \
               "and the partner is self-employed" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "self-employed",
                      employment_status_of_partner: "self-employed",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_mat_leave " \
               "for a 'no' response " \
               "when there is a single carer " \
               "and the mother is an employee " \
               "and the mother is working on the continuity end date" do
        add_responses employment_status_of_mother: "employee",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_single_birth_nothing " \
               "for a 'no' response " \
               "when there is a single carer " \
               "and the mother is an employee " \
               "and the mother is not working on the continuity end date" do
        add_responses employment_status_of_mother: "employee",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_single_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_single_birth_nothing " \
               "for a 'no' response " \
               "when there is a single carer " \
               "and the mother is a self-employed" do
        add_responses employment_status_of_mother: "self-employed",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_single_birth_nothing, for_response: "no"
      end

      should "have a next node of partner_started_working_before_continuity_start_date " \
               "for a 'yes' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is self-employed " \
               "and the partner is an employee" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "self-employed",
                      employment_status_of_partner: "employee"
        assert_next_node :partner_started_working_before_continuity_start_date, for_response: "yes"
      end

      should "have a next node of partner_started_working_before_continuity_start_date " \
               "for a 'yes' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is self-employed " \
               "and the partner is a worker" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "self-employed",
                      employment_status_of_partner: "worker"
        assert_next_node :partner_started_working_before_continuity_start_date, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'yes' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is self-employed " \
               "and the partner is self-employed" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "self-employed",
                      employment_status_of_partner: "self-employed"
        assert_next_node :outcome_mat_allowance, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'yes' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is self-employed " \
               "and the partner is unemployed" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "self-employed",
                      employment_status_of_partner: "unemployed"
        assert_next_node :outcome_mat_allowance, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'yes' response " \
               "when there is a single carer " \
               "and the mother is self-employed " do
        add_responses employment_status_of_mother: "self-employed"
        assert_next_node :outcome_mat_allowance, for_response: "yes"
      end

      should "have a next node of outcome_single_birth_nothing " \
               "for a 'no' response " \
               "when there is a single carer " \
               "and the mother is a worker" do
        add_responses employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_single_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_single_birth_nothing " \
               "for a 'no' response " \
               "when there is a single carer " \
               "and the mother is unemployed" do
        add_responses employment_status_of_mother: "unemployed",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_single_birth_nothing, for_response: "no"
      end

      should "have a next node of mother_earned_at_least_390 " \
               "for a 'yes' response " \
               "and the mother is unemployed" do
        add_responses employment_status_of_mother: "unemployed",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :mother_earned_at_least_390, for_response: "yes"
      end

      should "have a next node of mother_earned_at_least_390 " \
               "for a 'yes' response " \
               "and the mother is a worker" do
        add_responses employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :mother_earned_at_least_390, for_response: "yes"
      end

      should "have a next node of mother_earned_at_least_390 " \
               "for a 'yes' response " \
               "and the mother is employee" do
        add_responses employment_status_of_mother: "employee",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :mother_earned_at_least_390, for_response: "yes"
      end

      should "have a next node of mother_earned_at_least_390 " \
               "for a 'no' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is unemployed" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "unemployed",
                      employment_status_of_partner: "employee",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :mother_earned_at_least_390, for_response: "no"
      end

      should "have a next node of mother_earned_at_least_390 " \
               "for a 'no' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is a worker" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "worker",
                      employment_status_of_partner: "employee",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :mother_earned_at_least_390, for_response: "no"
      end
    end
  end

  context "question: mother_earned_at_least_390" do
    setup do
      testing_node :mother_earned_at_least_390
      add_responses two_carers: "no",
                    where_does_the_mother_partner_live: "england",
                    due_date: "2016-1-1",
                    employment_status_of_mother: "unemployed",
                    mother_worked_at_least_26_weeks: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of partner_started_working_before_continuity_start_date " \
               "for any response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the partner is an employee" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_partner: "employee"
        assert_next_node :partner_started_working_before_continuity_start_date, for_response: "yes"
      end

      should "have a next node of partner_started_working_before_continuity_start_date " \
               "for any response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the partner is an worker" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_partner: "worker"
        assert_next_node :partner_started_working_before_continuity_start_date, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance_mat_leave " \
               "for 'yes' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is an employee " \
               "and the partner is an self-employed " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother earned more than the lower earnings limit" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "employee",
                      employment_status_of_partner: "self-employed",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_mat_allowance_mat_leave, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance_mat_leave " \
               "for 'yes' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is an employee " \
               "and the partner is an unemployed " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother earned more than the lower earnings limit" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "employee",
                      employment_status_of_partner: "unemployed",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_mat_allowance_mat_leave, for_response: "yes"
      end

      should "have a next node of outcome_mat_leave " \
               "for 'no' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is an employee " \
               "and the partner is an self-employed " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother earned more than the lower earnings limit" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "employee",
                      employment_status_of_partner: "self-employed",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_leave " \
               "for 'no' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is an employee " \
               "and the partner is an unemployed " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother earned more than the lower earnings limit" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "employee",
                      employment_status_of_partner: "unemployed",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance_mat_leave " \
               "for 'yes' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is an employee " \
               "and the partner is an self-employed " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is working on the continuity end date" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "employee",
                      employment_status_of_partner: "self-employed",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_mat_allowance_mat_leave, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance_mat_leave " \
               "for a 'yes' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is an employee " \
               "and the partner is an unemployed " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is working on the continuity end date" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "employee",
                      employment_status_of_partner: "unemployed",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_mat_allowance_mat_leave, for_response: "yes"
      end

      should "have a next node of outcome_mat_leave " \
               "for a 'no' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is an employee " \
               "and the partner is an self-employed " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is working on the continuity end date" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "employee",
                      employment_status_of_partner: "self-employed",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_leave " \
               "for a 'no' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is an employee " \
               "and the partner is an unemployed " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is working on the continuity end date" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "employee",
                      employment_status_of_partner: "unemployed",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'yes' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is an employee " \
               "and the partner is an self-employed " \
               "and the mother did start working before the continuity start date " \
               "and the mother is not working on the continuity end date" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "employee",
                      employment_status_of_partner: "self-employed",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_mat_allowance, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'yes' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is an employee " \
               "and the partner is an unemployed " \
               "and the mother did start working before the continuity start date " \
               "and the mother is not working on the continuity end date" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "employee",
                      employment_status_of_partner: "unemployed",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_mat_allowance, for_response: "yes"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is an employee " \
               "and the partner is an self-employed " \
               "and the mother did start working before the continuity start date " \
               "and the mother is not working on the continuity end date" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "employee",
                      employment_status_of_partner: "self-employed",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is an employee " \
               "and the partner is an unemployed " \
               "and the mother did start working before the continuity start date " \
               "and the mother is not working on the continuity end date" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "employee",
                      employment_status_of_partner: "unemployed",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'yes' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is a worker " \
               "and the partner is self-employed " \
               "and the mother worked at least 26 weeks" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "worker",
                      employment_status_of_partner: "self-employed",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_worked_at_least_26_weeks: "yes"
        assert_next_node :outcome_mat_allowance, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'yes' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is unemployed " \
               "and the partner is self-employed " \
               "and the mother worked at least 26 weeks" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "unemployed",
                      employment_status_of_partner: "self-employed",
                      mother_worked_at_least_26_weeks: "yes"
        assert_next_node :outcome_mat_allowance, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'yes' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is unemployed " \
               "and the partner is unemployed " \
               "and the mother worked at least 26 weeks" do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "unemployed",
                      employment_status_of_partner: "unemployed",
                      mother_worked_at_least_26_weeks: "yes"
        assert_next_node :outcome_mat_allowance, for_response: "yes"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is a worker " \
               "and the partner is self-employed " do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "worker",
                      employment_status_of_partner: "self-employed",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "no",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is a worker " \
               "and the partner is unemployed " do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "worker",
                      employment_status_of_partner: "unemployed",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "no",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is unemployed " \
               "and the partner is unemployed " do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "unemployed",
                      employment_status_of_partner: "unemployed",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "no",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance_14_weeks " \
               "for a 'yes' response " \
               "when there are two carers " \
               "and the partner is from England " \
               "and the mother is a unemployed " \
               "and the partner is self-employed " do
        add_responses two_carers: "yes",
                      where_does_the_mother_partner_live: "england",
                      employment_status_of_mother: "unemployed",
                      employment_status_of_partner: "self-employed",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "no",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_mat_allowance_14_weeks, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance_mat_leave " \
               "for a 'yes' response " \
               "when there is a single carer " \
               "and the mother is a employee " \
               "and the mother is working on the continuity end date " do
        add_responses employment_status_of_mother: "employee",
                      employment_status_of_partner: "unemployed",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_mat_allowance_mat_leave, for_response: "yes"
      end

      should "have a next node of outcome_mat_leave " \
               "for a 'no' response " \
               "when there is a single carer " \
               "and the mother is a employee " \
               "and the mother is working on the continuity end date " do
        add_responses employment_status_of_mother: "employee",
                      employment_status_of_partner: "unemployed",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "yes",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'yes' response " \
               "when there is a single carer " \
               "and the mother is a employee " \
               "and the mother is not working on the continuity end date " do
        add_responses employment_status_of_mother: "employee",
                      employment_status_of_partner: "unemployed",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_mat_allowance, for_response: "yes"
      end

      should "have a next node of outcome_single_birth_nothing " \
               "for a 'no' response " \
               "when there is a single carer " \
               "and the mother is a employee " \
               "and the mother is working on the continuity end date " do
        add_responses employment_status_of_mother: "employee",
                      employment_status_of_partner: "unemployed",
                      mother_started_working_before_continuity_start_date: "yes",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "no"
        assert_next_node :outcome_single_birth_nothing, for_response: "no"
      end

      %w[worker unemployed].each do |mothers_employment_status|
        should "have a next node of outcome_mat_allowance " \
                 "for a 'yes' response " \
                 "when there is a single carer " \
                 "and the mothers employment status is #{mothers_employment_status} " do
          add_responses employment_status_of_mother: mothers_employment_status,
                        mother_started_working_before_continuity_start_date: "yes",
                        mother_still_working_on_continuity_end_date: "yes",
                        mother_earned_more_than_lower_earnings_limit: "no",
                        mother_worked_at_least_26_weeks: "yes"
          assert_next_node :outcome_mat_allowance, for_response: "yes"
        end

        should "have a next node of outcome_single_birth_nothing " \
                 "for a 'no' response " \
                 "when there is a single carer " \
                 "and the mothers employment status is #{mothers_employment_status} " do
          add_responses employment_status_of_mother: mothers_employment_status,
                        mother_started_working_before_continuity_start_date: "yes",
                        mother_still_working_on_continuity_end_date: "yes",
                        mother_earned_more_than_lower_earnings_limit: "no",
                        mother_worked_at_least_26_weeks: "yes"
          assert_next_node :outcome_single_birth_nothing, for_response: "no"
        end
      end
    end
  end

  context "question: partner_started_working_before_continuity_start_date" do
    setup do
      testing_node :partner_started_working_before_continuity_start_date
      add_responses two_carers: "yes",
                    where_does_the_mother_partner_live: "england",
                    due_date: "2016-1-1",
                    employment_status_of_mother: "employee",
                    employment_status_of_partner: "employee",
                    mother_started_working_before_continuity_start_date: "yes",
                    mother_still_working_on_continuity_end_date: "yes",
                    mother_earned_more_than_lower_earnings_limit: "no",
                    mother_worked_at_least_26_weeks: "yes",
                    mother_earned_at_least_390: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of partner_still_working_on_continuity_end_date " \
               "for any response" do
        assert_next_node :partner_still_working_on_continuity_end_date, for_response: "yes"
      end
    end
  end

  context "question: partner_still_working_on_continuity_end_date" do
    setup do
      testing_node :partner_still_working_on_continuity_end_date
      add_responses two_carers: "yes",
                    where_does_the_mother_partner_live: "england",
                    due_date: "2016-1-1",
                    employment_status_of_mother: "employee",
                    employment_status_of_partner: "employee",
                    mother_started_working_before_continuity_start_date: "yes",
                    mother_still_working_on_continuity_end_date: "yes",
                    mother_earned_more_than_lower_earnings_limit: "no",
                    mother_worked_at_least_26_weeks: "yes",
                    mother_earned_at_least_390: "yes",
                    partner_started_working_before_continuity_start_date: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of partner_earned_more_than_lower_earnings_limit " \
               "for any response" do
        assert_next_node :partner_earned_more_than_lower_earnings_limit, for_response: "yes"
      end
    end
  end

  context "question: partner_earned_more_than_lower_earnings_limit after 26 July 2026, with no partner work start and end date responses" do
    setup do
      testing_node :partner_earned_more_than_lower_earnings_limit
      add_responses two_carers: "yes",
                    where_does_the_mother_partner_live: "england",
                    due_date: "2026-7-26",
                    employment_status_of_mother: "employee",
                    employment_status_of_partner: "employee",
                    mother_started_working_before_continuity_start_date: "yes",
                    mother_still_working_on_continuity_end_date: "yes",
                    mother_earned_more_than_lower_earnings_limit: "no",
                    mother_worked_at_least_26_weeks: "yes",
                    mother_earned_at_least_390: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end
  end

  context "question: partner_earned_more_than_lower_earnings_limit" do
    setup do
      testing_node :partner_earned_more_than_lower_earnings_limit
      add_responses two_carers: "yes",
                    where_does_the_mother_partner_live: "england",
                    due_date: "2016-1-1",
                    employment_status_of_mother: "employee",
                    employment_status_of_partner: "employee",
                    mother_started_working_before_continuity_start_date: "yes",
                    mother_still_working_on_continuity_end_date: "yes",
                    mother_earned_more_than_lower_earnings_limit: "no",
                    mother_worked_at_least_26_weeks: "yes",
                    mother_earned_at_least_390: "yes",
                    partner_started_working_before_continuity_start_date: "yes",
                    partner_still_working_on_continuity_end_date: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of outcome_mat_leave_mat_pay_pat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother earned more than lower earnings limit " do
        add_responses mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_leave_mat_pay_pat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance_mat_leave_pat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        assert_next_node :outcome_mat_allowance_mat_leave_pat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_leave_pat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_mat_leave_pat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance_mat_leave_pat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses mother_started_working_before_continuity_start_date: "no"
        assert_next_node :outcome_mat_allowance_mat_leave_pat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance_mat_leave_pat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses mother_started_working_before_continuity_start_date: "no",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_mat_leave_pat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance_pat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is not working on the continuity end date " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses mother_still_working_on_continuity_end_date: "no"
        assert_next_node :outcome_mat_allowance_pat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_pat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is not working on the continuity end date " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses mother_still_working_on_continuity_end_date: "no",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_pat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_pat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is not working on the continuity end date " \
               "and the mother worked at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses mother_still_working_on_continuity_end_date: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_pat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_pay_pat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother earned more than lower earnings limit " do
        add_responses employment_status_of_mother: "worker",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_pay_pat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance_pat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is not working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " do
        add_responses employment_status_of_mother: "worker",
                      mother_still_working_on_continuity_end_date: "no"
        assert_next_node :outcome_mat_allowance_pat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance_pat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " do
        add_responses employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "no"
        assert_next_node :outcome_mat_allowance_pat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance_pat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_mother: "worker"
        assert_next_node :outcome_mat_allowance_pat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_pat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother did earn at least 390 " do
        add_responses employment_status_of_mother: "worker",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_pat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_pat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_mother: "worker",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_pat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_pat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is unemployed " \
               "and the mother worked at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_mother: "unemployed",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_pat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_pat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is unemployed " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_mother: "unemployed",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_pat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_pat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is self-employed " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_mother: "self-employed",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_pat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance_pat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is unemployed " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_mother: "unemployed"
        assert_next_node :outcome_mat_allowance_pat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance_pat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is self-employed " \
               "and the mother worked at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_mother: "self-employed",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_mat_allowance_pat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance_pat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is self-employed " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_mother: "self-employed"
        assert_next_node :outcome_mat_allowance_pat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_leave_mat_pay_pat_leave " \
               "for a 'no' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother earned more than lower earnings limit " do
        add_responses mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_leave_mat_pay_pat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_leave_pat_leave " \
               "for a 'no' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " do
        assert_next_node :outcome_mat_leave_pat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance_mat_leave_pat_leave " \
               "for a 'no' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses mother_started_working_before_continuity_start_date: "no"
        assert_next_node :outcome_mat_allowance_mat_leave_pat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_leave_pat_leave " \
               "for a 'no' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses mother_started_working_before_continuity_start_date: "no",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_mat_leave_pat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_leave_pat_leave " \
               "for a 'no' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses mother_started_working_before_continuity_start_date: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_mat_leave_pat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance_pat_leave " \
               "for a 'no' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is not working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses mother_still_working_on_continuity_end_date: "no"
        assert_next_node :outcome_mat_allowance_pat_leave, for_response: "no"
      end

      should "have a next node of outcome_pat_leave " \
               "for a 'no' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is not working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses mother_still_working_on_continuity_end_date: "no",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_pat_leave, for_response: "no"
      end

      should "have a next node of outcome_pat_leave " \
               "for a 'no' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is not working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses mother_still_working_on_continuity_end_date: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_pat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_pay_pat_leave " \
               "for a 'no' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " do
        add_responses employment_status_of_mother: "worker",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_pay_pat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance_pat_leave " \
               "for a 'no' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " do
        add_responses employment_status_of_mother: "worker",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_allowance_pat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance_pat_leave " \
               "for a 'no' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " do
        add_responses employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_allowance_pat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance_pat_leave " \
               "for a 'no' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " do
        add_responses employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_allowance_pat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance_pat_leave " \
               "for a 'no' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " do
        add_responses employment_status_of_mother: "worker"
        assert_next_node :outcome_mat_allowance_pat_leave, for_response: "no"
      end

      should "have a next node of outcome_pat_leave " \
               "for a 'no' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " do
        add_responses employment_status_of_mother: "worker",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_pat_leave, for_response: "no"
      end

      should "have a next node of outcome_pat_leave " \
               "for a 'no' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " do
        add_responses employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_pat_leave, for_response: "no"
      end

      should "have a next node of outcome_pat_leave " \
               "for a 'no' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " do
        add_responses employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_pat_leave, for_response: "no"
      end

      should "have a next node of outcome_pat_leave " \
               "for a 'no' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_mother: "worker",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_pat_leave, for_response: "no"
      end

      should "have a next node of outcome_pat_leave " \
               "for a 'no' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_pat_leave, for_response: "no"
      end

      should "have a next node of outcome_pat_leave " \
               "for a 'no' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_pat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance_pat_leave " \
               "for a 'no' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is unemployed " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_mother: "unemployed"
        assert_next_node :outcome_mat_allowance_pat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance_pat_leave " \
               "for a 'no' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is self-employed " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_mother: "self-employed"
        assert_next_node :outcome_mat_allowance_pat_leave, for_response: "no"
      end

      should "have a next node of outcome_pat_leave " \
               "for a 'no' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is unemployed " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_mother: "unemployed",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_pat_leave, for_response: "no"
      end

      should "have a next node of outcome_pat_leave " \
               "for a 'no' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is unemployed " \
               "and the mother worked at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_mother: "unemployed",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_pat_leave, for_response: "no"
      end

      should "have a next node of outcome_pat_leave " \
               "for a 'no' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is self-employed " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_mother: "self-employed",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_pat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_leave " \
               "for any response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is still working on the continuity end date " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no"
        assert_next_node :outcome_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_leave " \
               "for any response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did start working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is still working on the continuity end date " do
        add_responses partner_still_working_on_continuity_end_date: "no"
        assert_next_node :outcome_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_leave " \
               "for any response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is still working on the continuity end date " do
        add_responses partner_started_working_before_continuity_start_date: "no"
        assert_next_node :outcome_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance_mat_leave " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      mother_started_working_before_continuity_start_date: "no"
        assert_next_node :outcome_mat_allowance_mat_leave, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance_mat_leave " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses partner_still_working_on_continuity_end_date: "no",
                      mother_started_working_before_continuity_start_date: "no"
        assert_next_node :outcome_mat_allowance_mat_leave, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance_mat_leave " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      mother_started_working_before_continuity_start_date: "no"
        assert_next_node :outcome_mat_allowance_mat_leave, for_response: "yes"
      end

      should "have a next node of outcome_mat_leave " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_mat_leave, for_response: "yes"
      end

      should "have a next node of outcome_mat_leave " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_mat_leave, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother did work at least 26 weeks " \
               "and the mother did earn at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      mother_still_working_on_continuity_end_date: "no"
        assert_next_node :outcome_mat_allowance, for_response: "yes"
      end

      should "have a next node of outcome_birth_nothing " \
               "for any response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother did work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "yes"
      end

      should "have a next node of outcome_mat_pay " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother did start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother did work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother did work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_allowance, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother did start working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother did work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_allowance, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother did start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother did work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker"
        assert_next_node :outcome_mat_allowance, for_response: "yes"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did earn more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_worked_at_least_26_weeks: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "yes"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother did start working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother did earn more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_worked_at_least_26_weeks: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "yes"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother did start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_worked_at_least_26_weeks: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "yes"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did earn more than lower earnings limit " \
               "and the mother did work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "yes"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother did start working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother did earn more than lower earnings limit " \
               "and the mother did work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "yes"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother did start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother did work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "yes"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did earn more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother did earn at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_birth_nothing, for_response: "yes"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother did start working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother did earn more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother did earn at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_birth_nothing, for_response: "yes"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother did start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother did earn at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_birth_nothing, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is unemployed " \
               "and the mother did work at least 26 weeks " \
               "and the mother did earn at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "unemployed"
        assert_next_node :outcome_mat_allowance, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is self-employed " \
               "and the mother did work at least 26 weeks " \
               "and the mother did earn at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "self-employed"
        assert_next_node :outcome_mat_allowance, for_response: "yes"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is unemployed " \
               "and the mother did not work at least 26 weeks " \
               "and the mother did earn at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "unemployed",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_birth_nothing, for_response: "yes"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is unemployed " \
               "and the mother did work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "unemployed",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "yes"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is unemployed " \
               "and the mother did not work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "unemployed",
                      mother_worked_at_least_26_weeks: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "yes"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is self-employed " \
               "and the mother did not work at least 26 weeks " \
               "and the mother did earn at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "self-employed",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_birth_nothing, for_response: "yes"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'yes' response " \
               "when the partner is an employee " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not working on the continuity end date " \
               "and the mother is self-employed " \
               "and the mother did not work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "self-employed",
                      mother_worked_at_least_26_weeks: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "yes"
      end

      should "have a next node of outcome_mat_leave_mat_pay_pat_pay " \
               "for a 'yes' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother earned more than lower earnings limit " do
        add_responses employment_status_of_partner: "worker",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_leave_mat_pay_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance_mat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker"
        assert_next_node :outcome_mat_allowance_mat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_mat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother did work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_mat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_mat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother did work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_mat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance_mat_leave_pat_pay " \
               "for a 'yes' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      mother_started_working_before_continuity_start_date: "no"
        assert_next_node :outcome_mat_allowance_mat_leave_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_pat_pay " \
               "for a 'yes' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did start working before the continuity start date " \
               "and the mother is not working on the continuity end date " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_pat_pay " \
               "for a 'yes' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is not working on the continuity end date " \
               "and the mother worked at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance_pat_pay " \
               "for a 'yes' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is not working on the continuity end date " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      mother_still_working_on_continuity_end_date: "no"
        assert_next_node :outcome_mat_allowance_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_pay_pat_pay " \
               "for a 'yes' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother earned more than lower earnings limit " do
        add_responses employment_status_of_partner: "worker",
                      employment_status_of_mother: "worker",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_pay_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance_pat_pay " \
               "for a 'yes' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is not working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      employment_status_of_mother: "worker",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_allowance_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance_pat_pay " \
               "for a 'yes' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_allowance_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance_pat_pay " \
               "for a 'yes' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      employment_status_of_mother: "worker"
        assert_next_node :outcome_mat_allowance_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_pat_pay " \
               "for a 'yes' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother did earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      employment_status_of_mother: "worker",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_pat_pay " \
               "for a 'yes' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is a worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      employment_status_of_mother: "worker",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance_pat_pay " \
               "for a 'yes' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is unemployed " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      employment_status_of_mother: "unemployed"
        assert_next_node :outcome_mat_allowance_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_allowance_pat_pay " \
               "for a 'yes' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is self-employed " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      employment_status_of_mother: "self-employed"
        assert_next_node :outcome_mat_allowance_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_pat_pay " \
               "for a 'yes' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is unemployed " \
               "and the mother worked at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      employment_status_of_mother: "unemployed",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_pat_pay " \
               "for a 'yes' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is unemployed " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      employment_status_of_mother: "unemployed",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_pat_pay " \
               "for a 'yes' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is self-employed " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      employment_status_of_mother: "self-employed",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_pat_pay, for_response: "yes"
      end

      should "have a next node of outcome_mat_leave_mat_pay " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is working on the continuity end date " \
               "and the mother earned more than lower earnings limit " do
        add_responses employment_status_of_partner: "worker",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_leave_mat_pay, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance_mat_leave " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker"
        assert_next_node :outcome_mat_allowance_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance_mat_leave " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did earn more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_allowance_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance_mat_leave " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_allowance_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_leave " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_leave " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did earn more than lower earnings limit " \
               "and the mother did work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_leave " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_worked_at_least_26_weeks: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance_mat_leave " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_allowance_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_leave " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_leave " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_leave " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_worked_at_least_26_weeks: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_pay " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is still working on the continuity end date " \
               "and the mother is an worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " do
        add_responses employment_status_of_partner: "worker",
                      employment_status_of_mother: "worker",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_pay, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is still working on the continuity end date " \
               "and the mother is an worker " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother did work at least 26 weeks " \
               "and the mother did earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_allowance, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is still working on the continuity end date " \
               "and the mother is an worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother did work at least 26 weeks " \
               "and the mother did earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      employment_status_of_mother: "worker",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_allowance, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is still working on the continuity end date " \
               "and the mother is an worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother did work at least 26 weeks " \
               "and the mother did earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      employment_status_of_mother: "worker"
        assert_next_node :outcome_mat_allowance, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is still working on the continuity end date " \
               "and the mother is an worker " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother did earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is still working on the continuity end date " \
               "and the mother is an worker " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother did work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is still working on the continuity end date " \
               "and the mother is an worker " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_worked_at_least_26_weeks: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is unemployed " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "unemployed"
        assert_next_node :outcome_mat_allowance, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is unemployed " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "unemployed",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is unemployed " \
               "and the mother worked at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "unemployed",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is unemployed " \
               "and the mother did not work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "unemployed",
                      mother_worked_at_least_26_weeks: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_mat_leave_mat_pay " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is still working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_leave_mat_pay, for_response: "no"
      end

      should "have a next node of outcome_mat_leave_mat_pay " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " do
        add_responses employment_status_of_partner: "worker",
                      partner_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_leave_mat_pay, for_response: "no"
      end

      should "have a next node of outcome_mat_leave_mat_pay " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_leave_mat_pay, for_response: "no"
      end

      should "have a next node of outcome_mat_leave " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is still working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no"
        assert_next_node :outcome_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_leave " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner started working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " do
        add_responses employment_status_of_partner: "worker",
                      partner_still_working_on_continuity_end_date: "no"
        assert_next_node :outcome_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_leave " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no"
        assert_next_node :outcome_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance_mat_leave " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      mother_started_working_before_continuity_start_date: "no"
        assert_next_node :outcome_mat_allowance_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_leave " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_leave " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother worked at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_leave " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did not work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_worked_at_least_26_weeks: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_mat_leave, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is still working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      mother_still_working_on_continuity_end_date: "no"
        assert_next_node :outcome_mat_allowance, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is still working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is still working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother worked at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is still working on the continuity end date " \
               "and the mother is an employee " \
               "and the mother started working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother did not work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_worked_at_least_26_weeks: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_mat_pay " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is still working on the continuity end date " \
               "and the mother is an worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      employment_status_of_mother: "worker",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_pay, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is an worker " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_allowance, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is an worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_allowance, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is an worker " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes"
        assert_next_node :outcome_mat_allowance, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is an worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker"
        assert_next_node :outcome_mat_allowance, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is an worker " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is an worker " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is an worker " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_worked_at_least_26_weeks: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is an worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is an worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is an worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_worked_at_least_26_weeks: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is an worker " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is an worker " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is an worker " \
               "and the mother did not start working before the continuity start date " \
               "and the mother is not still working on the continuity end date " \
               "and the mother earned more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_started_working_before_continuity_start_date: "no",
                      mother_still_working_on_continuity_end_date: "no",
                      mother_earned_more_than_lower_earnings_limit: "yes",
                      mother_worked_at_least_26_weeks: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is an worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is an worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother worked at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is an worker " \
               "and the mother started working before the continuity start date " \
               "and the mother is still working on the continuity end date " \
               "and the mother did not earn more than lower earnings limit " \
               "and the mother did not work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "worker",
                      mother_worked_at_least_26_weeks: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is unemployed " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 - repeat of test for line 486 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "unemployed"
        assert_next_node :outcome_mat_allowance, for_response: "no"
      end

      should "have a next node of outcome_mat_allowance " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is self-employed " \
               "and the mother worked at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "self-employed"
        assert_next_node :outcome_mat_allowance, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is unemployed " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 - repeat of test for line 488 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "unemployed",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is unemployed " \
               "and the mother worked at least 26 weeks " \
               "and the mother did not earn at least 390 - repeat of test for line 488 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "unemployed",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is unemployed " \
               "and the mother did not work at least 26 weeks " \
               "and the mother did not earn at least 390 - repeat of test for line 488 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "unemployed",
                      mother_worked_at_least_26_weeks: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is self-employed " \
               "and the mother did not work at least 26 weeks " \
               "and the mother earned at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "self-employed",
                      mother_worked_at_least_26_weeks: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end

      should "have a next node of outcome_birth_nothing " \
               "for a 'no' response " \
               "when the partner is a worker " \
               "and the partner is from England " \
               "and the partner did not start working before the continuity start date " \
               "and the partner is not still working on the continuity end date " \
               "and the mother is self-employed " \
               "and the mother did not work at least 26 weeks " \
               "and the mother did not earn at least 390 " do
        add_responses employment_status_of_partner: "worker",
                      partner_started_working_before_continuity_start_date: "no",
                      partner_still_working_on_continuity_end_date: "no",
                      employment_status_of_mother: "self-employed",
                      mother_worked_at_least_26_weeks: "no",
                      mother_earned_at_least_390: "no"
        assert_next_node :outcome_birth_nothing, for_response: "no"
      end
    end
  end

  context "outcome: outcome_mat_allowance, self-employed mother" do
    setup do
      testing_node :outcome_mat_allowance
      add_responses two_carers: "yes",
                    where_does_the_mother_partner_live: "england",
                    due_date: "2016-1-1",
                    employment_status_of_mother: "self-employed",
                    employment_status_of_partner: "self-employed",
                    mother_started_working_before_continuity_start_date: "yes",
                    mother_still_working_on_continuity_end_date: "yes",
                    mother_earned_more_than_lower_earnings_limit: "yes",
                    mother_worked_at_least_26_weeks: "yes"
    end

    should "render paternity unavailable partial when there are two carers" do
      assert_rendered_outcome text: "The mother’s partner cannot take"
    end

    should "render _mat_allowance partial weekly rate for 2013" do
      add_responses due_date: "2013-1-1"
      assert_rendered_outcome text: "£136.78, or 90%"
    end

    should "render _mat_allowance partial weekly rate for 2014" do
      add_responses due_date: "2014-1-1"
      assert_rendered_outcome text: "£138.18, or 90%"
    end

    should "render _mat_allowance partial weekly rate for 2015" do
      add_responses due_date: "2015-1-1"
      assert_rendered_outcome text: "£139.58, or 90%"
    end

    should "render _mat_allowance partial weekly rate for 2016" do
      assert_rendered_outcome text: "£139.58, or 90%"
    end

    should "render _mat_allowance partial weekly rate for 2017" do
      add_responses due_date: "2017-1-1"
      assert_rendered_outcome text: "£140.98, or 90%"
    end

    should "render _mat_allowance partial weekly rate for 2018" do
      add_responses due_date: "2018-1-1"
      assert_rendered_outcome text: "£145.18, or 90%"
    end

    should "render _mat_allowance partial weekly rate for 2019" do
      add_responses due_date: "2019-1-1"
      assert_rendered_outcome text: "£148.68, or 90%"
    end

    should "render _mat_allowance partial weekly rate for 2020" do
      add_responses due_date: "2020-1-1"
      assert_rendered_outcome text: "£151.20, or 90%"
    end

    should "render _mat_allowance partial weekly rate for 2021" do
      add_responses due_date: "2021-1-1"
      assert_rendered_outcome text: "£151.97 or 90%"
    end

    should "render _mat_allowance partial weekly rate for 2022" do
      add_responses due_date: "2022-1-1"
      assert_rendered_outcome text: "£156.66"
    end

    should "render _mat_allowance partial weekly rate for 2023" do
      add_responses due_date: "2023-1-1"
      assert_rendered_outcome text: "£172.48"
    end

    should "render _mat_allowance partial weekly rate for 2024" do
      add_responses due_date: "2024-1-1"
      assert_rendered_outcome text: "£184.03"
    end

    should "render _mat_allowance partial weekly rate for 2025" do
      add_responses due_date: "2025-1-1"
      assert_rendered_outcome text: "£187.18"
    end
  end

  context "outcome: outcome_mat_allowance, employee mother" do
    setup do
      testing_node :outcome_mat_allowance
      add_responses two_carers: "yes",
                    where_does_the_mother_partner_live: "england",
                    # due_date: "2016-1-1",
                    employment_status_of_mother: "employee",
                    employment_status_of_partner: "self-employed",
                    mother_started_working_before_continuity_start_date: "yes",
                    mother_still_working_on_continuity_end_date: "no",
                    mother_earned_more_than_lower_earnings_limit: "no",
                    mother_worked_at_least_26_weeks: "yes",
                    mother_earned_at_least_390: "yes"
    end

    should "render _mat_allowance partial weekly rate for 2022" do
      add_responses due_date: "2022-1-1"
      assert_rendered_outcome text: "£156.66"
    end

    should "render _mat_allowance partial weekly rate for 2023" do
      add_responses due_date: "2023-1-1"
      assert_rendered_outcome text: "£172.48"
    end

    should "render _mat_allowance partial weekly rate for 2024" do
      add_responses due_date: "2024-1-1"
      assert_rendered_outcome text: "£184.03"
    end

    should "render _mat_allowance partial weekly rate for 2025" do
      add_responses due_date: "2025-1-1"
      assert_rendered_outcome text: "£187.18"
    end
  end

  context "outcome: outcome_mat_allowance_14_weeks" do
    setup do
      testing_node :outcome_mat_allowance_14_weeks
      add_responses two_carers: "yes",
                    where_does_the_mother_partner_live: "england",
                    due_date: "2016-1-1",
                    employment_status_of_mother: "unemployed",
                    employment_status_of_partner: "self-employed",
                    mother_started_working_before_continuity_start_date: "yes",
                    mother_still_working_on_continuity_end_date: "yes",
                    mother_earned_more_than_lower_earnings_limit: "no",
                    mother_worked_at_least_26_weeks: "no",
                    mother_earned_at_least_390: "yes"
    end

    should "render paternity unavailable partial when there are two carers" do
      assert_rendered_outcome text: "The mother’s partner cannot take"
    end
  end

  context "outcome: outcome_mat_allowance_mat_leave" do
    setup do
      testing_node :outcome_mat_allowance_mat_leave
      add_responses two_carers: "yes",
                    where_does_the_mother_partner_live: "england",
                    due_date: "2016-1-1",
                    employment_status_of_mother: "employee",
                    employment_status_of_partner: "self-employed",
                    mother_started_working_before_continuity_start_date: "no",
                    mother_still_working_on_continuity_end_date: "yes",
                    mother_earned_more_than_lower_earnings_limit: "yes",
                    mother_worked_at_least_26_weeks: "yes",
                    mother_earned_at_least_390: "yes"
    end

    should "render paternity unavailable partial when there are two carers" do
      assert_rendered_outcome text: "The mother’s partner cannot take"
    end
  end

  context "outcome: outcome_mat_leave" do
    setup do
      testing_node :outcome_mat_leave
      add_responses two_carers: "yes",
                    where_does_the_mother_partner_live: "england",
                    due_date: "2016-1-1",
                    employment_status_of_mother: "employee",
                    employment_status_of_partner: "self-employed",
                    mother_started_working_before_continuity_start_date: "yes",
                    mother_still_working_on_continuity_end_date: "yes",
                    mother_earned_more_than_lower_earnings_limit: "no",
                    mother_worked_at_least_26_weeks: "no"
    end

    should "render paternity unavailable partial when there are two carers" do
      assert_rendered_outcome text: "The mother’s partner cannot take"
    end
  end

  context "outcome: outcome_mat_leave_mat_pay" do
    setup do
      testing_node :outcome_mat_leave_mat_pay
      add_responses two_carers: "yes",
                    where_does_the_mother_partner_live: "england",
                    due_date: "2016-1-1",
                    employment_status_of_mother: "employee",
                    employment_status_of_partner: "self-employed",
                    mother_started_working_before_continuity_start_date: "yes",
                    mother_still_working_on_continuity_end_date: "yes",
                    mother_earned_more_than_lower_earnings_limit: "yes"
    end

    should "render paternity unavailable partial when there are two carers" do
      assert_rendered_outcome text: "The mother’s partner cannot take"
    end
  end

  context "outcome: outcome_mat_pay" do
    setup do
      testing_node :outcome_mat_pay
      add_responses two_carers: "yes",
                    where_does_the_mother_partner_live: "england",
                    due_date: "2016-1-1",
                    employment_status_of_mother: "worker",
                    employment_status_of_partner: "employee",
                    mother_started_working_before_continuity_start_date: "yes",
                    mother_still_working_on_continuity_end_date: "yes",
                    mother_earned_more_than_lower_earnings_limit: "yes",
                    mother_worked_at_least_26_weeks: "yes",
                    mother_earned_at_least_390: "yes",
                    partner_started_working_before_continuity_start_date: "no",
                    partner_still_working_on_continuity_end_date: "no",
                    partner_earned_more_than_lower_earnings_limit: "yes"
    end

    should "render paternity unavailable partial when there are two carers" do
      assert_rendered_outcome text: "The mother’s partner cannot take"
    end

    should "render grace period text for paternity leave if due date is between and including 5th of April 2026 and 25th of July 2026" do
      add_responses due_date: "2026-4-5"
      assert_rendered_outcome text: "From 18 February 2026 until 25 July 2026, the partner does not need to give the usual 15 weeks notice of their baby’s due date."
    end

    should "not render grace period text for paternity leave before 5th of April 2026" do
      add_responses due_date: "2026-4-4"
      assert_no_rendered_outcome text: "From 18 February 2026 until 25 July 2026, the partner does not need to give the usual 15 weeks notice of their baby’s due date."
    end

    should "render _mat_pay partial weekly rate for 2013" do
      add_responses due_date: "2013-1-1"
      assert_rendered_outcome text: "£136.78 per week"
    end

    should "render _mat_pay partial weekly rate for 2014" do
      add_responses due_date: "2014-1-1"
      assert_rendered_outcome text: "£138.18 per week"
    end

    should "render _mat_pay partial weekly rate for 2015" do
      add_responses due_date: "2015-1-1"
      assert_rendered_outcome text: "£139.58 per week"
    end

    should "render _mat_pay partial weekly rate for 2016" do
      assert_rendered_outcome text: "£139.58 per week"
    end

    should "render _mat_pay partial weekly rate for 2017" do
      add_responses due_date: "2017-1-1"
      assert_rendered_outcome text: "£140.98 per week"
    end

    should "render _mat_pay partial weekly rate for 2018" do
      add_responses due_date: "2018-1-1"
      assert_rendered_outcome text: "£145.18 per week"
    end

    should "render _mat_pay partial weekly rate for 2019" do
      add_responses due_date: "2019-1-1"
      assert_rendered_outcome text: "£148.68 per week"
    end

    should "render _mat_pay partial weekly rate for 2020" do
      add_responses due_date: "2020-1-1"
      assert_rendered_outcome text: "£151.20 per week"
    end

    should "render _mat_pay partial weekly rate for 2021" do
      add_responses due_date: "2021-1-1"
      assert_rendered_outcome text: "£151.97 per week"
    end

    should "render _mat_pay partial weekly rate for 2022" do
      add_responses due_date: "2022-1-1"
      assert_rendered_outcome text: "£156.66 per week"
    end

    should "render _mat_pay partial weekly rate for 2023" do
      add_responses due_date: "2023-1-1"
      assert_rendered_outcome text: "£172.48 per week"
    end

    should "render _mat_pay partial weekly rate for 2024" do
      add_responses due_date: "2024-1-1"
      assert_rendered_outcome text: "£184.03 per week"
    end

    should "render _mat_pay partial weekly rate for 2025" do
      add_responses due_date: "2025-1-1"
      assert_rendered_outcome text: "£187.18 per week"
    end
  end

  context "outcome: outcome_pat_pay" do
    setup do
      testing_node :outcome_pat_pay
      add_responses two_carers: "yes",
                    where_does_the_mother_partner_live: "england",
                    due_date: "2016-1-1",
                    employment_status_of_mother: "employee",
                    employment_status_of_partner: "worker",
                    mother_started_working_before_continuity_start_date: "yes",
                    mother_still_working_on_continuity_end_date: "no",
                    mother_earned_more_than_lower_earnings_limit: "no",
                    mother_worked_at_least_26_weeks: "no",
                    mother_earned_at_least_390: "yes",
                    partner_started_working_before_continuity_start_date: "yes",
                    partner_still_working_on_continuity_end_date: "yes",
                    partner_earned_more_than_lower_earnings_limit: "yes"
    end

    should "render _pat_pay partial weekly rate for 2013" do
      add_responses due_date: "2013-1-1"
      assert_rendered_outcome text: "£136.78 per week"
    end

    should "render _pat_pay partial weekly rate for 2014" do
      add_responses due_date: "2014-1-1"
      assert_rendered_outcome text: "£138.18 per week"
    end

    should "render _pat_pay partial weekly rate for 2015" do
      add_responses due_date: "2015-1-1"
      assert_rendered_outcome text: "£139.58 per week"
    end

    should "render _pat_pay partial weekly rate for 2016" do
      assert_rendered_outcome text: "£139.58 per week"
    end

    should "render _pat_pay partial weekly rate for 2017" do
      add_responses due_date: "2017-1-1"
      assert_rendered_outcome text: "£140.98 per week"
    end

    should "render _pat_pay partial weekly rate for 2018" do
      add_responses due_date: "2018-1-1"
      assert_rendered_outcome text: "£145.18 per week"
    end

    should "render _pat_pay partial weekly rate for 2019" do
      add_responses due_date: "2019-1-1"
      assert_rendered_outcome text: "£148.68 per week"
    end

    should "render _pat_pay partial weekly rate for 2020" do
      add_responses due_date: "2020-1-1"
      assert_rendered_outcome text: "£151.20 per week"
    end

    should "render _pat_pay partial weekly rate for 2021" do
      add_responses due_date: "2021-1-1"
      assert_rendered_outcome text: "£151.97 per week"
    end

    should "render _pat_pay partial weekly rate for 2022" do
      add_responses due_date: "2022-1-1"
      assert_rendered_outcome text: "£156.66 per week"
    end

    should "render _pat_pay partial weekly rate for 2023" do
      add_responses due_date: "2023-1-1"
      assert_rendered_outcome text: "£172.48 per week"
    end

    should "render _pat_pay partial weekly rate for 2024" do
      add_responses due_date: "2024-1-1"
      assert_rendered_outcome text: "£184.03 per week"
    end

    should "render _pat_pay partial weekly rate for 2025" do
      add_responses due_date: "2025-1-1"
      assert_rendered_outcome text: "£187.18 per week"
    end

    should "render _pat_pay partial paid leave is in year 2013" do
      add_responses due_date: "2013-1-1"
      assert_rendered_outcome text: "The partner must tell their employer"
      assert_rendered_outcome text: "by 18 September 2012"
    end

    should "render _pat_pay partial paid leave on a saturday" do
      add_responses due_date: "2021-12-25"
      assert_rendered_outcome text: "The partner must tell their employer"
      assert_rendered_outcome text: "by 11 September 2021"
    end
  end

  context "outcome: outcome_pat_leave" do
    setup do
      testing_node :outcome_pat_leave
      add_responses two_carers: "yes",
                    where_does_the_mother_partner_live: "england",
                    due_date: "2016-1-1",
                    employment_status_of_mother: "worker",
                    employment_status_of_partner: "employee",
                    mother_started_working_before_continuity_start_date: "yes",
                    mother_still_working_on_continuity_end_date: "no",
                    mother_earned_more_than_lower_earnings_limit: "no",
                    mother_worked_at_least_26_weeks: "no",
                    mother_earned_at_least_390: "yes",
                    partner_started_working_before_continuity_start_date: "yes",
                    partner_still_working_on_continuity_end_date: "yes",
                    partner_earned_more_than_lower_earnings_limit: "no"
    end

    context "for births on 6 April 2024" do
      setup do
        add_responses due_date: "2024-04-6"
      end

      should "render _pat_leave partial with 56 days leave deadline" do
        assert_rendered_outcome text: "Paternity leave must be used by  1 June 2024"
      end

      should "render _pat_leave partial with 15 weeks notice period" do
        assert_rendered_outcome text: "The partner must tell their employer"
        assert_rendered_outcome text: "the baby’s due date - by 23 December 2023"
        assert_rendered_outcome text: "when they want their leave to start - by 23 December 2023"
      end
    end

    context "for births on 7 April 2024" do
      setup do
        add_responses due_date: "2024-04-07"
      end

      should "render _pat_leave partial with 364 days leave deadline" do
        assert_rendered_outcome text: "Paternity leave must be used by  6 April 2025"
      end

      should "render _pat_leave partial with 105 days notice period" do
        assert_rendered_outcome text: "The partner must tell their employer:"
        assert_rendered_outcome text: "the baby’s due date - by 24 December 2023"
        assert_rendered_outcome text: "when they want their leave to start - by 10 March 2024"
      end
    end
  end
end
