require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/maternity-paternity-pay-leave"

class MaternityPaternityPayLeaveTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::MaternityPaternityPayLeaveFlow
  end

  context "birth-singleparent" do
    should "Mother self-employed, does not pass earnings and employment test" do
      add_response "no" # two_carers
      add_response "2016-1-1" # due_date
      add_response "self-employed" # employment_status_of_mother
      add_response "no" # mother_worked_at_least_26_weeks
      assert_current_node :outcome_single_birth_nothing
    end

    should "Mother employee, soon to leave job, passes lower earnings test" do
      add_response "no" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "no" # mother_still_working_on_continuity_end_date
      add_response "yes" # mother_earned_more_than_lower_earnings_limit
      add_response "yes" # mother_worked_at_least_26_weeks
      add_response "yes" # mother_earned_at_least_390
      assert_current_node :outcome_mat_allowance
    end

    should "Mother worker, does not pass earnings and employment test" do
      add_response "no" # two_carers
      add_response "2014-4-5" # due_date
      add_response "worker" # employment_status_of_mother
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "no" # mother_earned_more_than_lower_earnings_limit
      add_response "no" # mother_worked_at_least_26_weeks
      assert_current_node :outcome_single_birth_nothing
    end

    should "Mother self-employed, passes earnings and employment test" do
      add_response "no" # two_carers
      add_response "2016-1-1" # due_date
      add_response "self-employed" # employment_status_of_mother
      add_response "yes" # mother_worked_at_least_26_weeks
      assert_current_node :outcome_mat_allowance
    end

    should "Mother employee, soon to leave job, passes earnings and employment test" do
      add_response "no" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "no" # mother_still_working_on_continuity_end_date
      add_response "no" # mother_earned_more_than_lower_earnings_limit
      add_response "yes" # mother_worked_at_least_26_weeks
      add_response "yes" # mother_earned_at_least_390
      assert_current_node :outcome_mat_allowance
    end

    should "Mother employee, passes continuity test, does not pass lower earnings test, passes earnings and employment test" do
      add_response "no" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "no" # mother_earned_more_than_lower_earnings_limit
      add_response "yes" # mother_worked_at_least_26_weeks
      add_response "yes" # mother_earned_at_least_390
      assert_current_node :outcome_mat_allowance_mat_leave
    end

    should "Mother employee, passes continuity test, does not pass lower earnings test, does not pass earnings and employment test" do
      add_response "no" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "no" # mother_earned_more_than_lower_earnings_limit
      add_response "no" # mother_worked_at_least_26_weeks
      assert_current_node :outcome_mat_leave
    end

    should "Mother employee, passes continuity test, passes lower earnings test" do
      add_response "no" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "yes" # mother_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_leave_mat_pay
    end

    should "Mother worker, passes continuity test, passes lower earnings test" do
      add_response "no" # two_carers
      add_response "2016-1-1" # due_date
      add_response "worker" # employment_status_of_mother
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "yes" # mother_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_pay
    end
  end

  context "birth-twoparents-2014" do
    should "Mother self-employed, does not pass earnings and employment test;Partner self-employed" do
      add_response "yes" # two_carers
      add_response "2014-1-1" # due_date
      add_response "self-employed" # employment_status_of_mother
      add_response "self-employed" # employment_status_of_partner
      add_response "no" # mother_worked_at_least_26_weeks
      assert_current_node :outcome_birth_nothing
    end

    should "Mother worker, does not pass continuity test, passes lower earnings test;Partner worker, does not pass continuity test, does not pass lower earnings test" do
      add_response "yes" # two_carers
      add_response "2014-1-1" # due_date
      add_response "worker" # employment_status_of_mother
      add_response "worker" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "no" # mother_still_working_on_continuity_end_date
      add_response "yes" # mother_earned_more_than_lower_earnings_limit
      add_response "yes" # mother_worked_at_least_26_weeks
      add_response "yes" # mother_earned_at_least_390
      add_response "no" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "no" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_allowance
    end

    should "Mother self-employed, passes earnings and employment test;Partner self-employed" do
      add_response "yes" # two_carers
      add_response "2014-1-1" # due_date
      add_response "self-employed" # employment_status_of_mother
      add_response "self-employed" # employment_status_of_partner
      add_response "yes" # mother_worked_at_least_26_weeks
      assert_current_node :outcome_mat_allowance
    end

    should "Mother employee, does not pass continuity test, passes lower earnings test;Partner employee, does not pass continuity test, does not pass lower earnings test" do
      add_response "yes" # two_carers
      add_response "2014-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "employee" # employment_status_of_partner
      add_response "no" # mother_started_working_before_continuity_start_date
      add_response "no" # mother_still_working_on_continuity_end_date
      add_response "yes" # mother_earned_more_than_lower_earnings_limit
      add_response "yes" # mother_worked_at_least_26_weeks
      add_response "yes" # mother_earned_at_least_390
      add_response "no" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "no" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_allowance
    end

    should "Mother unemployed, does not pass earnings and employment test;Partner self-employed" do
      add_response "yes" # two_carers
      add_response "2014-1-1" # due_date
      add_response "unemployed" # employment_status_of_mother
      add_response "self-employed" # employment_status_of_partner
      add_response "no" # mother_worked_at_least_26_weeks
      add_response "no" # mother_earned_at_least_390
      assert_current_node :outcome_mat_allowance_14_weeks
    end

    should "Mother employee, passes continuity test, does not pass lower earnings test, passes earnings and employment test;Partner self-employed" do
      add_response "yes" # two_carers
      add_response "2014-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "self-employed" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "no" # mother_earned_more_than_lower_earnings_limit
      add_response "yes" # mother_worked_at_least_26_weeks
      add_response "yes" # mother_earned_at_least_390
      assert_current_node :outcome_mat_allowance_mat_leave
    end

    should "Mother employee, passes continuity test, does not pass lower earnings test, does not pass earnings and employment test;Partner self-employed" do
      add_response "yes" # two_carers
      add_response "2014-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "self-employed" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "no" # mother_earned_more_than_lower_earnings_limit
      add_response "no" # mother_worked_at_least_26_weeks
      assert_current_node :outcome_mat_leave
    end

    should "Mother employee, does not pass continuity test, passes lower earnings test;Partner employee, does not pass continuity test, passes lower earnings test" do
      add_response "yes" # two_carers
      add_response "2014-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "employee" # employment_status_of_partner
      add_response "no" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "yes" # mother_earned_more_than_lower_earnings_limit
      add_response "yes" # mother_worked_at_least_26_weeks
      add_response "yes" # mother_earned_at_least_390
      add_response "no" # partner_started_working_before_continuity_start_date
      add_response "no" # partner_still_working_on_continuity_end_date
      add_response "yes" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_allowance_mat_leave
    end

    should "Mother employee, passes continuity test, passes lower earnings test;Partner self-employed" do
      add_response "yes" # two_carers
      add_response "2014-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "self-employed" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "yes" # mother_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_leave_mat_pay
    end

    should "Mother employee, passes continuity test, passes lower earnings test;Partner employee, passes continuity test, does not pass lower earnings test" do
      add_response "yes" # two_carers
      add_response "2014-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "employee" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "yes" # mother_earned_more_than_lower_earnings_limit
      add_response "yes" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "no" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_leave_mat_pay_pat_leave
    end

    should "Mother employee, passes continuity test, does not pass lower earnings test, does not pass earnings and employment test;Partner worker, passes continuity test, passes lower earnings test" do
      add_response "yes" # two_carers
      add_response "2014-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "worker" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "no" # mother_earned_more_than_lower_earnings_limit
      add_response "no" # mother_worked_at_least_26_weeks
      add_response "yes" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "yes" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_leave_pat_pay
    end

    should "Mother employee, does not pass continuity test, does not pass lower earnings test, does not pass earnings and employment test;Partner worker, passes continuity test, passes lower earnings test" do
      add_response "yes" # two_carers
      add_response "2014-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "worker" # employment_status_of_partner
      add_response "no" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "no" # mother_earned_more_than_lower_earnings_limit
      add_response "no" # mother_worked_at_least_26_weeks
      add_response "yes" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "yes" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_leave_pat_pay
    end

    should "Mother worker, passes continuity test, passes lower earnings test;Partner self-employed" do
      add_response "yes" # two_carers
      add_response "2014-1-1" # due_date
      add_response "worker" # employment_status_of_mother
      add_response "self-employed" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "yes" # mother_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_leave_mat_pay
    end

    should "Mother worker, passes continuity test, passes lower earnings test;Partner worker, does not pass continuity test" do
      add_response "yes" # two_carers
      add_response "2014-1-1" # due_date
      add_response "worker" # employment_status_of_mother
      add_response "worker" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "yes" # mother_earned_more_than_lower_earnings_limit
      add_response "no" # partner_started_working_before_continuity_start_date
      add_response "no" # partner_still_working_on_continuity_end_date
      add_response "no" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_pay
    end

    should "Mother self-employed, does not pass earnings and employment test;Partner employee, passes continuity test, passes lower earnings test" do
      add_response "yes" # two_carers
      add_response "2014-1-1" # due_date
      add_response "self-employed" # employment_status_of_mother
      add_response "employee" # employment_status_of_partner
      add_response "no" # mother_worked_at_least_26_weeks
      add_response "yes" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "yes" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_pat_leave_pat_pay
    end

    should "Mother worker, does not pass continuity test, does not pass lower earnings test, does not pass earnings and employment test;Partner employee, passes continuity test, passes lower earnings test" do
      add_response "yes" # two_carers
      add_response "2014-1-1" # due_date
      add_response "worker" # employment_status_of_mother
      add_response "employee" # employment_status_of_partner
      add_response "no" # mother_started_working_before_continuity_start_date
      add_response "no" # mother_still_working_on_continuity_end_date
      add_response "no" # mother_earned_more_than_lower_earnings_limit
      add_response "no" # mother_worked_at_least_26_weeks
      add_response "no" # mother_earned_at_least_390
      add_response "yes" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "yes" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_pat_leave_pat_pay
    end

    should "Mother self-employed, does not pass earnings and employment test;Partner worker, passes continuity test, passes lower earnings test" do
      add_response "yes" # two_carers
      add_response "2014-1-1" # due_date
      add_response "self-employed" # employment_status_of_mother
      add_response "worker" # employment_status_of_partner
      add_response "no" # mother_worked_at_least_26_weeks
      add_response "yes" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "yes" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_pat_pay
    end

    should "Mother worker, does not pass continuity test, does not pass lower earnings test, does not pass earnings and employment test;Partner worker, passes continuity test, passes lower earnings test" do
      add_response "yes" # two_carers
      add_response "2014-1-1" # due_date
      add_response "worker" # employment_status_of_mother
      add_response "worker" # employment_status_of_partner
      add_response "no" # mother_started_working_before_continuity_start_date
      add_response "no" # mother_still_working_on_continuity_end_date
      add_response "no" # mother_earned_more_than_lower_earnings_limit
      add_response "no" # mother_worked_at_least_26_weeks
      add_response "no" # mother_earned_at_least_390
      add_response "yes" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "yes" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_pat_pay
    end
  end

  context "birth-twoparents-2016" do
    should "Mother self-employed, does not pass earnings and employment test;Partner self-employed" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "self-employed" # employment_status_of_mother
      add_response "self-employed" # employment_status_of_partner
      add_response "no" # mother_worked_at_least_26_weeks
      assert_current_node :outcome_birth_nothing
    end

    should "Mother employee, does not pass continuity test, passes lower earnings test;Partner self-employed" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "self-employed" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "no" # mother_still_working_on_continuity_end_date
      add_response "yes" # mother_earned_more_than_lower_earnings_limit
      add_response "yes" # mother_worked_at_least_26_weeks
      add_response "yes" # mother_earned_at_least_390
      assert_current_node :outcome_mat_allowance
    end

    should "Mother worker, passes continuity test, does not pass lower earnings test, does not pass earnings and employment test;Partner worker, does not pass continuity test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "worker" # employment_status_of_mother
      add_response "worker" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "no" # mother_earned_more_than_lower_earnings_limit
      add_response "no" # mother_worked_at_least_26_weeks
      add_response "no" # mother_earned_at_least_390
      add_response "no" # partner_started_working_before_continuity_start_date
      add_response "no" # partner_still_working_on_continuity_end_date
      add_response "no" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_birth_nothing
    end

    should "Mother self-employed, passes earnings and employment test;Partner self-employed" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "self-employed" # employment_status_of_mother
      add_response "self-employed" # employment_status_of_partner
      add_response "yes" # mother_worked_at_least_26_weeks
      assert_current_node :outcome_mat_allowance
    end

    should "Mother unemployed, passes earnings and employment test;Partner unemployed" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "unemployed" # employment_status_of_mother
      add_response "unemployed" # employment_status_of_partner
      add_response "yes" # mother_worked_at_least_26_weeks
      add_response "yes" # mother_earned_at_least_390
      assert_current_node :outcome_mat_allowance
    end

    should "Mother employee, does not pass continuity test, passes earnings and employment test;Partner self-employed" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "self-employed" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "no" # mother_still_working_on_continuity_end_date
      add_response "yes" # mother_earned_more_than_lower_earnings_limit
      add_response "yes" # mother_worked_at_least_26_weeks
      add_response "yes" # mother_earned_at_least_390
      assert_current_node :outcome_mat_allowance
    end

    should "Mother employee, does not pass continuity test, passes lower earnings test;Partner worker, does not pass continuity test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "worker" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "no" # mother_still_working_on_continuity_end_date
      add_response "yes" # mother_earned_more_than_lower_earnings_limit
      add_response "yes" # mother_worked_at_least_26_weeks
      add_response "yes" # mother_earned_at_least_390
      add_response "yes" # partner_started_working_before_continuity_start_date
      add_response "no" # partner_still_working_on_continuity_end_date
      add_response "no" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_allowance
    end

    should "Mother unemployed, passes earnings and employment test;Partner self-employed" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "unemployed" # employment_status_of_mother
      add_response "self-employed" # employment_status_of_partner
      add_response "no" # mother_worked_at_least_26_weeks
      add_response "no" # mother_earned_at_least_390
      assert_current_node :outcome_mat_allowance_14_weeks
    end

    should "Mother employee, passes continuity test, does not pass lower earnings test, passes earnings and employment test;Partner self-employed, passes earnings and employment test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "self-employed" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "no" # mother_earned_more_than_lower_earnings_limit
      add_response "yes" # mother_worked_at_least_26_weeks
      add_response "yes" # mother_earned_at_least_390
      assert_current_node :outcome_mat_allowance_mat_leave
    end

    should "Mother employee, passes continuity test, does not pass lower earnings test, passes earnings and employment test;Partner self-employed, does not pass earnings and employment test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "self-employed" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "no" # mother_earned_more_than_lower_earnings_limit
      add_response "yes" # mother_worked_at_least_26_weeks
      add_response "yes" # mother_earned_at_least_390
      assert_current_node :outcome_mat_allowance_mat_leave
    end

    should "Mother employee, passes continuity test, does not pass lower earnings test, does not pass earnings and employment test;Partner self-employed, passes earnings and employment test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "self-employed" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "no" # mother_earned_more_than_lower_earnings_limit
      add_response "no" # mother_worked_at_least_26_weeks
      assert_current_node :outcome_mat_leave
    end

    should "Mother employee, passes continuity test, does not pass lower earnings test, does not pass earnings and employment test;Partner self-employed, does not pass earnings and employment test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "self-employed" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "no" # mother_earned_more_than_lower_earnings_limit
      add_response "no" # mother_worked_at_least_26_weeks
      assert_current_node :outcome_mat_leave
    end

    should "Mother employee, does not pass continuity test, will still be employed, passes earnings and employment test;Partner worker, does not pass continuity test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "worker" # employment_status_of_partner
      add_response "no" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "no" # mother_earned_more_than_lower_earnings_limit
      add_response "yes" # mother_worked_at_least_26_weeks
      add_response "yes" # mother_earned_at_least_390
      add_response "no" # partner_started_working_before_continuity_start_date
      add_response "no" # partner_still_working_on_continuity_end_date
      add_response "no" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_allowance_mat_leave
    end

    should "Mother employee, passes continuity test, does not pass lower earnings test, passes earnings and employment test;Partner employee, passes continuity test, passes lower earnings test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "employee" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "no" # mother_earned_more_than_lower_earnings_limit
      add_response "yes" # mother_worked_at_least_26_weeks
      add_response "yes" # mother_earned_at_least_390
      add_response "yes" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "yes" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_allowance_mat_leave_pat_leave_pat_pay
    end

    should "Mother employee, passes continuity test, does not pass lower earnings test, passes earnings and employment test;Partner worker, passes continuity test, passes lower earnings test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "worker" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "no" # mother_earned_more_than_lower_earnings_limit
      add_response "yes" # mother_worked_at_least_26_weeks
      add_response "yes" # mother_earned_at_least_390
      add_response "yes" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "yes" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_allowance_mat_leave_pat_pay
    end

    should "Mother self-employed, passes earnings and employment test;Partner employee, passes continuity test, passes lower earnings test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "self-employed" # employment_status_of_mother
      add_response "employee" # employment_status_of_partner
      add_response "yes" # mother_worked_at_least_26_weeks
      add_response "yes" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "yes" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_allowance_pat_leave_pat_pay
    end

    should "Mother self-employed, passes earnings and employment test;Partner worker, passes continuity test, passes lower earnings test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "self-employed" # employment_status_of_mother
      add_response "worker" # employment_status_of_partner
      add_response "yes" # mother_worked_at_least_26_weeks
      add_response "yes" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "yes" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_allowance_pat_pay
    end

    should "Mother worker, does not pass continuity test, passes earnings and employment test;Partner worker, passes continuity test, passes lower earnings test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "worker" # employment_status_of_mother
      add_response "worker" # employment_status_of_partner
      add_response "no" # mother_started_working_before_continuity_start_date
      add_response "no" # mother_still_working_on_continuity_end_date
      add_response "no" # mother_earned_more_than_lower_earnings_limit
      add_response "yes" # mother_worked_at_least_26_weeks
      add_response "yes" # mother_earned_at_least_390
      add_response "yes" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "yes" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_allowance_pat_pay
    end

    should "Mother employee, does not pass continuity test, passes lower earnings test;Partner employee, passes continuity test, does not pass lower earnings test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "employee" # employment_status_of_partner
      add_response "no" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "yes" # mother_earned_more_than_lower_earnings_limit
      add_response "yes" # mother_worked_at_least_26_weeks
      add_response "yes" # mother_earned_at_least_390
      add_response "yes" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "no" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_allowance_mat_leave_pat_leave
    end

    should "Mother employee, passes continuity test, passes lower earnings test;Partner self-employed, does not pass earnings and employment test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "self-employed" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "yes" # mother_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_leave_mat_pay
    end

    should "Mother employee, passes continuity test, passes lower earnings test;Partner self-employed, passes earnings and employment test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "self-employed" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "yes" # mother_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_leave_mat_pay
    end

    should "Mother employee, passes continuity test, passes lower earnings test;Partner employee, does not pass continuity test, passes lower earnings test, passes earnings and employment test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "employee" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "yes" # mother_earned_more_than_lower_earnings_limit
      add_response "no" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "yes" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_leave
    end

    should "Mother employee, passes continuity test, passes lower earnings test;Parnter employee, passes continuity test, passes lower earnings test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "employee" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "yes" # mother_earned_more_than_lower_earnings_limit
      add_response "yes" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "yes" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_leave_mat_pay_pat_leave_pat_pay
    end

    should "Mother employee, passes continuity test, passes lower earnings test;Partner worker, passes continuity test, passes lower earnings test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "worker" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "yes" # mother_earned_more_than_lower_earnings_limit
      add_response "yes" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "yes" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_leave_mat_pay_pat_pay
    end

    should "Mother employee, passes continuity test, does not pass lower earnings test, does not pass earnings and employment test;Partner employee, passes continuity test, passes lower earnings test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "employee" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "no" # mother_earned_more_than_lower_earnings_limit
      add_response "no" # mother_worked_at_least_26_weeks
      add_response "yes" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "yes" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_leave_pat_leave_pat_pay
    end

    should "Mother employee, passes continuity test, does not pass lower earnings test, does not pass earnings and employment test;Partner worker, passes continuity test, passes lower earnings test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "worker" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "no" # mother_earned_more_than_lower_earnings_limit
      add_response "no" # mother_worked_at_least_26_weeks
      add_response "yes" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "yes" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_leave_pat_pay
    end

    should "Mother worker, passes continuity test, passes lower earnings test;Partner self-employed, does not pass earnings and employment test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "worker" # employment_status_of_mother
      add_response "self-employed" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "yes" # mother_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_leave_mat_pay
    end

    should "Mother worker, passes continuity test, passes lower earnings test;Partner self-employed, passes earnings and employment test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "worker" # employment_status_of_mother
      add_response "self-employed" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "yes" # mother_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_leave_mat_pay
    end

    should "Mother worker, passes continuity test, passes lower earnings test;Partner employee, does not pass continuity test, does not pass lower earnings test, passes earnings and employment test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "worker" # employment_status_of_mother
      add_response "employee" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "yes" # mother_earned_more_than_lower_earnings_limit
      add_response "no" # partner_started_working_before_continuity_start_date
      add_response "no" # partner_still_working_on_continuity_end_date
      add_response "no" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_pay
    end

    should "Mother worker, passes continuity test, passes lower earnings test;Partner employee, passes continuity test, passes lower earnings test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "worker" # employment_status_of_mother
      add_response "employee" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "yes" # mother_earned_more_than_lower_earnings_limit
      add_response "yes" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "yes" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_pay_pat_leave_pat_pay
    end

    should "Mother worker, passes continuity test, passes lower earnings test;Partner worker, passes continuity test, passes lower earnings test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "worker" # employment_status_of_mother
      add_response "worker" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "yes" # mother_earned_more_than_lower_earnings_limit
      add_response "yes" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "yes" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_pay_pat_pay
    end

    should "Mother self-employed, does not pass earnings and employment test;Partner employee, passes continuity test, passes lower earnings test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "self-employed" # employment_status_of_mother
      add_response "employee" # employment_status_of_partner
      add_response "no" # mother_worked_at_least_26_weeks
      add_response "yes" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "yes" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_pat_leave_pat_pay
    end

    should "Mother self-employed, does not pass earnings and employment test;Partner worker, passes continuity test, passes lower earnings test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "self-employed" # employment_status_of_mother
      add_response "worker" # employment_status_of_partner
      add_response "no" # mother_worked_at_least_26_weeks
      add_response "yes" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "yes" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_pat_pay
    end

    should "Mother employee, passes continuity test, passes lower earnings test;Partner employee, passes continuity test, does not pass lower earnings test, does not pass earnings and employment test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "employee" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "yes" # mother_earned_more_than_lower_earnings_limit
      add_response "yes" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "no" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_leave_mat_pay_pat_leave
    end

    should "Mother employee, passes continuity test, does not pass lower earnings test, does not pass earnings and employment test;Partner worker, passes continuity test, does not pass lower earnings test, passes earnings and employment test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "worker" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "no" # mother_earned_more_than_lower_earnings_limit
      add_response "no" # mother_worked_at_least_26_weeks
      add_response "yes" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "no" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_leave
    end

    should "Mother employee, passes continuity test, does not pass lower earnings test, does not pass earnings and employment test;Partner worker, does not pass continuity test, does not pass lower earnings test, passes earnings and employment test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "employee" # employment_status_of_mother
      add_response "worker" # employment_status_of_partner
      add_response "yes" # mother_started_working_before_continuity_start_date
      add_response "yes" # mother_still_working_on_continuity_end_date
      add_response "no" # mother_earned_more_than_lower_earnings_limit
      add_response "no" # mother_worked_at_least_26_weeks
      add_response "no" # partner_started_working_before_continuity_start_date
      add_response "no" # partner_still_working_on_continuity_end_date
      add_response "no" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_mat_leave
    end

    should "Mother worker, does not pass continuity test, does not pass lower earnings test, does not pass earnings and employment test;Partner worker, passes continuity test, does not pass lower earnings test" do
      add_response "yes" # two_carers
      add_response "2016-1-1" # due_date
      add_response "worker" # employment_status_of_mother
      add_response "worker" # employment_status_of_partner
      add_response "no" # mother_started_working_before_continuity_start_date
      add_response "no" # mother_still_working_on_continuity_end_date
      add_response "no" # mother_earned_more_than_lower_earnings_limit
      add_response "no" # mother_worked_at_least_26_weeks
      add_response "no" # mother_earned_at_least_390
      add_response "yes" # partner_started_working_before_continuity_start_date
      add_response "yes" # partner_still_working_on_continuity_end_date
      add_response "no" # partner_earned_more_than_lower_earnings_limit
      assert_current_node :outcome_birth_nothing
    end
  end
end
