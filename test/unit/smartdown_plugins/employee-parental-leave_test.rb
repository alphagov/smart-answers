require 'test_helper'
require 'smartdown_plugins/employee-parental-leave'

module SmartdownPlugins
  class EmployeeParentalLeaveTest < ActiveSupport::TestCase
    # placeholder tests
    test "claim_date_maternity_allowance(date)" do
      assert_equal "TODO_claim_date_maternity_allowance", SmartdownPlugins::EmployeeParentalLeave.claim_date_maternity_allowance(nil)
    end

    test "earliest_start(placement_date)" do
      assert_equal "TODO_earliest_start", SmartdownPlugins::EmployeeParentalLeave.earliest_start(nil)
    end

    test "end_of_additional_leave(date_leave_1)" do
      assert_equal "TODO_end_of_additional_leave", SmartdownPlugins::EmployeeParentalLeave.end_of_additional_leave(nil)
    end

    test "end_of_additional_paternity_leave(date)" do
      assert_equal "TODO_end_of_additional_paternity_leave", SmartdownPlugins::EmployeeParentalLeave.end_of_additional_paternity_leave(nil)
    end

    test "end_of_additional_paternity_pay(date)" do
      assert_equal "TODO_end_of_additional_paternity_pay", SmartdownPlugins::EmployeeParentalLeave.end_of_additional_paternity_pay(nil)
    end

    test "end_of_adoption_pay(date)" do
      assert_equal "TODO_end_of_adoption_pay", SmartdownPlugins::EmployeeParentalLeave.end_of_adoption_pay(nil)
    end

    test "end_of_maternity_allowance(date)" do
      assert_equal "TODO_end_of_maternity_allowance", SmartdownPlugins::EmployeeParentalLeave.end_of_maternity_allowance(nil)
    end

    test "end_of_maternity_pay(date)" do
      assert_equal "TODO_end_of_maternity_pay", SmartdownPlugins::EmployeeParentalLeave.end_of_maternity_pay(nil)
    end

    test "end_of_ordinary_leave(date_leave_1)" do
      assert_equal "TODO_end_of_ordinary_leave", SmartdownPlugins::EmployeeParentalLeave.end_of_ordinary_leave(nil)
    end

    test "end_of_paternity_leave(date_leave_2)" do
      assert_equal "TODO_end_of_paternity_leave", SmartdownPlugins::EmployeeParentalLeave.end_of_paternity_leave(nil)
    end

    test "end_of_shared_parental_leave(date)" do
      assert_equal "TODO_end_of_shared_parental_leave", SmartdownPlugins::EmployeeParentalLeave.end_of_shared_parental_leave(nil)
    end

    test "latest_pat_leave(date)" do
      assert_equal "TODO_latest_pat_leave", SmartdownPlugins::EmployeeParentalLeave.latest_pat_leave(nil)
    end

    test "notice_date_sap(date)" do
      assert_equal "TODO_notice_date_sap", SmartdownPlugins::EmployeeParentalLeave.notice_date_sap(nil)
    end

    test "notice_date_smp(date)" do
      assert_equal "TODO_notice_date_sap", SmartdownPlugins::EmployeeParentalLeave.notice_date_smp(nil)
    end

    test "notice_maternity_allowance" do
      assert_equal "TODO_notice_maternity_allowance", SmartdownPlugins::EmployeeParentalLeave.notice_maternity_allowance
    end

    test "paternity_leave_notice_date(date)" do
      assert_equal "TODO_paternity_leave_notice_date", SmartdownPlugins::EmployeeParentalLeave.paternity_leave_notice_date(nil)
    end

    test "paternity_pay_notice_date(date_leave_2)" do
      assert_equal "TODO_paternity_pay_notice_date", SmartdownPlugins::EmployeeParentalLeave.paternity_pay_notice_date(nil)
    end

    test "period_of_maternity_allowance" do
      assert_equal "TODO_period_of_maternity_allowance", SmartdownPlugins::EmployeeParentalLeave.period_of_maternity_allowance
    end

    test "qualifying_week(match_date)" do
      assert_equal "TODO_qualifying_week", SmartdownPlugins::EmployeeParentalLeave.qualifying_week(nil)
    end

    test "rate_of_paternity_pay(salary_2)" do
      assert_equal "TODO_rate_of_paternity_pay", SmartdownPlugins::EmployeeParentalLeave.rate_of_paternity_pay(nil)
    end

    test "rate_of_maternity_allowance(salary_1)" do
      assert_equal "TODO_rate_of_maternity_allowance", SmartdownPlugins::EmployeeParentalLeave.rate_of_maternity_allowance(nil)
    end

    test "rate_of_sap(salary_1)" do
      assert_equal "TODO_rate_of_sap", SmartdownPlugins::EmployeeParentalLeave.rate_of_sap(nil)
    end

    test "rate_of_smp_6_weeks(salary_1)" do
      assert_equal "TODO_rate_of_smp_6_weeks", SmartdownPlugins::EmployeeParentalLeave.rate_of_smp_6_weeks(nil)
    end

    test "rate_of_smp_33_weeks(salary_1)" do
      assert_equal "TODO_rate_of_smp_33_weeks", SmartdownPlugins::EmployeeParentalLeave.rate_of_smp_33_weeks(nil)
    end

    test "start_of_additional_leave(date_leave_1)" do
      assert_equal "TODO_start_of_additional_leave", SmartdownPlugins::EmployeeParentalLeave.start_of_additional_leave(nil)
    end

    test "start_of_additional_paternity_leave(date)" do
      assert_equal "TODO_start_of_additional_paternity_leave", SmartdownPlugins::EmployeeParentalLeave.start_of_additional_paternity_leave(nil)
    end

    test "start_of_maternity_allowance(date)" do
      assert_equal "TODO_start_of_maternity_allowance", SmartdownPlugins::EmployeeParentalLeave.start_of_maternity_allowance(nil)
    end

    test "total_maternity_allowance(salary_1)" do
      assert_equal "TODO_total_maternity_allowance", SmartdownPlugins::EmployeeParentalLeave.total_maternity_allowance(nil)
    end

    test "total_sap(salary_1)" do
      assert_equal "TODO_total_sap", SmartdownPlugins::EmployeeParentalLeave.total_sap(nil)
    end

    test "total_smp(salary_1)" do
      assert_equal "TODO_total_smp", SmartdownPlugins::EmployeeParentalLeave.total_smp(nil)
    end
  end
end
