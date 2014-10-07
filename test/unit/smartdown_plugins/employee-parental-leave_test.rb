# encoding: utf-8
require 'test_helper'
require 'smartdown_plugins/employee-parental-leave'

module SmartdownPlugins

  class EmployeeParentalLeaveTest < ActiveSupport::TestCase

    test "claim_date_maternity_allowance returns a date 14 weeks before given date" do
      date = Smartdown::Model::Answer::Date.new("2014-1-1")
      expected = Smartdown::Model::Answer::Date.new("2013-9-25")
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.claim_date_maternity_allowance(date)
    end

    test "earliest_start returns a date 14 days after the given placement_date" do
      placement_date = Smartdown::Model::Answer::Date.new("2014-1-1" )
      expected = Smartdown::Model::Answer::Date.new("2013-10-16")
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.earliest_start(placement_date)
    end

    test "earnings_test_start_date returns a date 66 weeks before given date" do
      placement_date = Smartdown::Model::Answer::Date.new("2014-1-1")
      expected = Smartdown::Model::Answer::Date.new("2012-9-26")
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.earnings_test_start_date(placement_date)
    end

    test "end_of_14_week_maternity_allowance returns a date 14 weeks after the given date" do
      date = Smartdown::Model::Answer::Date.new("2014-1-1")
      expected = Smartdown::Model::Answer::Date.new("2014-4-9")
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.end_of_14_week_maternity_allowance(date)
    end

    test "end_of_additional_leave returns a date 52 weeks after the given date_leave_1" do
      date_leave_1 = Smartdown::Model::Answer::Date.new("2014-1-1")
      expected = Smartdown::Model::Answer::Date.new("2014-12-31")
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.end_of_additional_leave(date_leave_1)
    end

    test "end_of_additional_paternity_leave returns a date 1 year after the given date" do
      date = Smartdown::Model::Answer::Date.new("2014-1-1")
      expected = Smartdown::Model::Answer::Date.new("2015-1-1")
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.end_of_additional_paternity_leave(date)
    end

    test "end_of_additional_paternity_pay_from_leave returns a date 52 weeks after the given date_leave_1" do
      date_leave_1 = Smartdown::Model::Answer::Date.new("2014-1-1")
      expected = Smartdown::Model::Answer::Date.new("2014-12-31")
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.end_of_additional_paternity_pay_from_leave(date_leave_1)
    end

    test "end_of_additional_paternity_pay_from_match_or_due_date returns a date 28 weeks after the given date" do
      date = Smartdown::Model::Answer::Date.new("2014-1-1")
      expected = Smartdown::Model::Answer::Date.new("2014-7-16")
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.end_of_additional_paternity_pay_from_match_or_due_date(date)
    end

    test "end_of_adoption_pay returns a date 39 weeks after the given date" do
      date = Smartdown::Model::Answer::Date.new("2014-1-1")
      expected = Smartdown::Model::Answer::Date.new("2014-10-1")
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.end_of_adoption_pay(date)
    end

    test "end_of_maternity_allowance returns a date 28 weeks after the given date" do
      date = Smartdown::Model::Answer::Date.new("2014-1-1")
      expected = Smartdown::Model::Answer::Date.new("2014-7-16")
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.end_of_maternity_allowance(date)
    end

    test "end_of_maternity_pay returns a date 39 weeks after the given date" do
      date = Smartdown::Model::Answer::Date.new("2014-1-1")
      expected = Smartdown::Model::Answer::Date.new("2014-10-1")
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.end_of_maternity_pay(date)
    end

    test "end_of_ordinary_leave returns a date 26 weeks after the given date_leave_1" do
      date_leave_1 = Smartdown::Model::Answer::Date.new("2014-1-1")
      expected = Smartdown::Model::Answer::Date.new("2014-7-2")
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.end_of_ordinary_leave(date_leave_1)
    end

    test "end_of_paternity_leave returns a date 2 weeks after the given date_leave_2" do
      date_leave_2 = Smartdown::Model::Answer::Date.new("2014-1-1")
      expected = Smartdown::Model::Answer::Date.new("2014-1-15")
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.end_of_paternity_leave(date_leave_2)
    end

    test "end_of_shared_parental_leave returns a date 1 year after the given date" do
      date = Smartdown::Model::Answer::Date.new("2014-1-1")
      expected = Smartdown::Model::Answer::Date.new("2015-1-1")
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.end_of_shared_parental_leave(date)
    end

    test "latest_pat_leave returns a date 56 days after the given date" do
      date = Smartdown::Model::Answer::Date.new("2014-1-1")
      expected = Smartdown::Model::Answer::Date.new("2014-2-26")
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.latest_pat_leave(date)
    end

    test "lower_earnings_start returns a date 23 weeks after the given date" do
      date = Smartdown::Model::Answer::Date.new("2014-1-1")
      expected = Smartdown::Model::Answer::Date.new("2013-7-24")
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.lower_earnings_start(date)
    end

    test "minimum_start_date returns a date 41 weeks before the given date" do
      date = Smartdown::Model::Answer::Date.new("2014-1-1")
      expected = Smartdown::Model::Answer::Date.new("2013-3-20")
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.minimum_start_date(date)
    end

    test "minimum_end_date returns a date 15 weeks before the given date" do
      date = Smartdown::Model::Answer::Date.new("2014-1-1")
      expected = Smartdown::Model::Answer::Date.new("2013-9-18")
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.minimum_end_date(date)
    end

    test "notice_date_sap returns a date 28 days before the given date_leave_1" do
      date = Smartdown::Model::Answer::Date.new("2014-1-1")
      expected = Smartdown::Model::Answer::Date.new("2013-12-4")
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.notice_date_sap(date)
    end

    test "notice_date_smp returns a date 28 days before the given date" do
      date = Smartdown::Model::Answer::Date.new("2014-1-1")
      expected = Smartdown::Model::Answer::Date.new("2013-12-4")
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.notice_date_smp(date)
    end

    test "paternity_leave_notice_date returns a date 15 weeks before the Monday before the given date" do
      date = Smartdown::Model::Answer::Date.new("2014-9-25") # A Thursday
      expected = Smartdown::Model::Answer::Date.new("2014-6-9") # A Monday, 15 weeks before Monday 2014-9-22.
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.paternity_leave_notice_date(date)
    end

    test "paternity_pay_notice_date returns a date 28 days before the given date_leave_2" do
      date_leave_2 = Smartdown::Model::Answer::Date.new("2014-1-1")
      expected = Smartdown::Model::Answer::Date.new("2013-12-4")
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.paternity_pay_notice_date(date_leave_2)
    end

    test "qualifying_week returns a date 7 days after the given match_date" do
      match_date = Smartdown::Model::Answer::Date.new("2014-1-1")
      expected = Smartdown::Model::Answer::Date.new("2014-1-8")
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.qualifying_week(match_date)
    end

    test "rate_of_paternity_pay returns 138.18 when 90% of the given weekly salary is higher than £138.18" do
      salary_2 = Smartdown::Model::Answer::Salary.new("200-week")
      assert_equal 138.18, SmartdownPlugins::EmployeeParentalLeave.rate_of_paternity_pay(salary_2)
    end

    test "rate_of_paternity_pay returns 90% of the given weekly salary when it is less than £138.18" do
      salary_2 = Smartdown::Model::Answer::Salary.new("150-week")
      assert_equal 135.0, SmartdownPlugins::EmployeeParentalLeave.rate_of_paternity_pay(salary_2)
    end

    test "rate_of_maternity_allowance returns 138.18 when 90% of the given weekly salary is higher than £138.18" do
      salary_1 = Smartdown::Model::Answer::Salary.new("200-week")
      assert_equal 138.18, SmartdownPlugins::EmployeeParentalLeave.rate_of_maternity_allowance(salary_1)
    end

    test "rate_of_maternity_allowance returns 90% of the given weekly salary when it is less than £138.18" do
      salary_1 = Smartdown::Model::Answer::Salary.new("150-week")
      assert_equal 135.0, SmartdownPlugins::EmployeeParentalLeave.rate_of_maternity_allowance(salary_1)
    end

    test "rate_of_sap returns 138.18 when 90% of the given weekly salary is higher than £138.18" do
      salary_1 = Smartdown::Model::Answer::Salary.new("200-week")
      assert_equal 138.18, SmartdownPlugins::EmployeeParentalLeave.rate_of_sap(salary_1)
    end

    test "rate_of_sap returns 90% of the given weekly salary when it is less than £138.18" do
      salary_1 = Smartdown::Model::Answer::Salary.new("150-week")
      assert_equal 135.0, SmartdownPlugins::EmployeeParentalLeave.rate_of_sap(salary_1)
    end

    test "rate_of_shpp returns 138.18 when 90% of the given weekly salary is higher than £138.18" do
      salary_1 = Smartdown::Model::Answer::Salary.new("200-week")
      assert_equal 138.18, SmartdownPlugins::EmployeeParentalLeave.rate_of_shpp(salary_1)
    end

    test "rate_of_shpp returns 90% of the given weekly salary when it is less than £138.18" do
      salary_1 = Smartdown::Model::Answer::Salary.new("150-week")
      assert_equal 135.0, SmartdownPlugins::EmployeeParentalLeave.rate_of_shpp(salary_1)
    end

    test "rate_of_smp_6_weeks returns 90% of the given weekly salary" do
      salary_1 = Smartdown::Model::Answer::Salary.new("150-week")
      assert_equal 135.0, SmartdownPlugins::EmployeeParentalLeave.rate_of_sap(salary_1)
    end

    test "rate_of_smp_33_weeks returns 90% of the given weekly salary when it is less than £138.18" do
      salary_1 = Smartdown::Model::Answer::Salary.new("150-week")
      assert_equal 135.0, SmartdownPlugins::EmployeeParentalLeave.rate_of_smp_33_weeks(salary_1)
    end

    test "rate_of_smp_33_weeks returns 138.18 when 90% of the given weekly salary is higher than £138.18" do
      salary_1 = Smartdown::Model::Answer::Salary.new("200-week")
      assert_equal 138.18, SmartdownPlugins::EmployeeParentalLeave.rate_of_smp_33_weeks(salary_1)
    end

    test "start_of_additional_leave returns a date 26 weeks and 1 day after the given date_leave_1" do
      date_leave_1 = Smartdown::Model::Answer::Date.new("2014-1-1")
      expected = Smartdown::Model::Answer::Date.new("2014-7-3")
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.start_of_additional_leave(date_leave_1)
    end

    test "start_of_additional_paternity_leave returns a date 20 weeks after the given date" do
      date = Smartdown::Model::Answer::Date.new("2014-1-1")
      expected = Smartdown::Model::Answer::Date.new("2014-5-21")
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.start_of_additional_paternity_leave(date)
    end

    test "start_of_maternity_allowance returns a date 11 weeks before the given date" do
      date = Smartdown::Model::Answer::Date.new("2014-1-1")
      expected = Smartdown::Model::Answer::Date.new("2013-10-16")
      assert_equal expected, SmartdownPlugins::EmployeeParentalLeave.start_of_maternity_allowance(date)
    end

    test "total_maternity_allowance returns the rate_of_maternity_allowance * 39" do
      salary_1 = Smartdown::Model::Answer::Salary.new("200-week")
      SmartdownPlugins::EmployeeParentalLeave.stubs(:rate_of_maternity_allowance).with(salary_1).returns(138.18)
      assert_equal 138.18 * 39, SmartdownPlugins::EmployeeParentalLeave.total_maternity_allowance(salary_1)
    end

    test "total_sap returns the rate_of_sap * 39" do
      salary_1 = Smartdown::Model::Answer::Salary.new("200-week")
      SmartdownPlugins::EmployeeParentalLeave.stubs(:rate_of_sap).with(salary_1).returns(138.18)
      assert_equal 138.18 * 39, SmartdownPlugins::EmployeeParentalLeave.total_sap(salary_1)
    end

    test "total_smp returns the rate_of_smp_6_weeks * 6 + rate_of_smp_33_weeks * 33 (totaling 39 weeks)" do
      salary_1 = Smartdown::Model::Answer::Salary.new("200-week")
      SmartdownPlugins::EmployeeParentalLeave.stubs(:rate_of_smp_6_weeks).with(salary_1).returns(1.0)
      SmartdownPlugins::EmployeeParentalLeave.stubs(:rate_of_smp_33_weeks).with(salary_1).returns(100.0)
      assert_equal 3306.0, SmartdownPlugins::EmployeeParentalLeave.total_smp(salary_1)
    end
  end
end
