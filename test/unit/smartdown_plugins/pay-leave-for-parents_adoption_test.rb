# encoding: utf-8
require 'test_helper'
require 'smartdown_plugins/pay-leave-for-parents-adoption/render_time'

module SmartdownPlugins

  class PayLeaveForParentsAdoptionTest < ActiveSupport::TestCase

    due_date = Smartdown::Model::Answer::Date.new("2015-1-1")

    test "continuity_start_date" do
      expected = Smartdown::Model::Answer::Date.new("2014-3-29")
      assert_equal expected, SmartdownPlugins::PayLeaveForParentsAdoption.continuity_start_date(due_date)
    end

    test "continuity_end_date" do
      expected = Smartdown::Model::Answer::Date.new("2014-9-14")
      assert_equal expected, SmartdownPlugins::PayLeaveForParentsAdoption.continuity_end_date(due_date)
    end

    test "earnings_employment_start_date" do
      expected = Smartdown::Model::Answer::Date.new("2013-9-22")
      assert_equal expected, SmartdownPlugins::PayLeaveForParentsAdoption.earnings_employment_start_date(due_date)
    end

    test "earnings_employment_end_date" do
      expected = Smartdown::Model::Answer::Date.new("2014-12-27")
      assert_equal expected, SmartdownPlugins::PayLeaveForParentsAdoption.earnings_employment_end_date(due_date)
    end

    test "lower_earnings_start_date" do
      expected = Smartdown::Model::Answer::Date.new("2014-7-26")
      assert_equal expected, SmartdownPlugins::PayLeaveForParentsAdoption.lower_earnings_start_date(due_date)
    end

    test "lower_earnings_end_date" do
      expected = Smartdown::Model::Answer::Date.new("2014-9-20")
      assert_equal expected, SmartdownPlugins::PayLeaveForParentsAdoption.lower_earnings_end_date(due_date)
    end

    test "earliest_start_mat_leave" do
      expected = Smartdown::Model::Answer::Date.new("2014-10-12")
      assert_equal expected, SmartdownPlugins::PayLeaveForParentsAdoption.earliest_start_mat_leave(due_date)
    end

    test "end_of_additional_paternity_leave" do
      expected = Smartdown::Model::Answer::Date.new("2016-1-1")
      assert_equal expected, SmartdownPlugins::PayLeaveForParentsAdoption.end_of_additional_paternity_leave(due_date)
    end

    test "end_of_shared_parental_leave" do
      expected = Smartdown::Model::Answer::Date.new("2016-1-1")
      assert_equal expected, SmartdownPlugins::PayLeaveForParentsAdoption.end_of_shared_parental_leave(due_date)
    end

    test "latest_pat_leave" do
      expected = Smartdown::Model::Answer::Date.new("2015-2-26")
      assert_equal expected, SmartdownPlugins::PayLeaveForParentsAdoption.latest_pat_leave(due_date)
    end

    test "maternity_leave_notice_date" do
      expected = Smartdown::Model::Answer::Date.new("2014-9-20")
      assert_equal expected, SmartdownPlugins::PayLeaveForParentsAdoption.maternity_leave_notice_date(due_date)
    end

    test "paternity_leave_notice_date" do
      expected = Smartdown::Model::Answer::Date.new("2014-9-20")
      assert_equal expected, SmartdownPlugins::PayLeaveForParentsAdoption.paternity_leave_notice_date(due_date)
    end

    test "start_of_additional_paternity_leave" do
      expected = Smartdown::Model::Answer::Date.new("2015-5-21")
      assert_equal expected, SmartdownPlugins::PayLeaveForParentsAdoption.start_of_additional_paternity_leave(due_date)
    end

    test "start_of_maternity_allowance" do
      expected = Smartdown::Model::Answer::Date.new("2014-10-12")
      assert_equal expected, SmartdownPlugins::PayLeaveForParentsAdoption.start_of_maternity_allowance(due_date)
    end


    test "rate_of_maternity_allowance returns 139.58 when 90% of the given weekly salary is higher than £139.58" do
      salary_1 = Smartdown::Model::Answer::Salary.new("200-week")
      assert_equal 139.58, SmartdownPlugins::PayLeaveForParentsAdoption.rate_of_maternity_allowance(salary_1)
    end

    test "rate_of_maternity_allowance returns 90% of the given weekly salary when it is less than £139.58" do
      salary_1 = Smartdown::Model::Answer::Salary.new("150-week")
      assert_equal 135.0, SmartdownPlugins::PayLeaveForParentsAdoption.rate_of_maternity_allowance(salary_1)
    end

    test "rate_of_paternity_pay returns 139.58 when 90% of the given weekly salary is higher than £139.58" do
      salary_2 = Smartdown::Model::Answer::Salary.new("200-week")
      assert_equal 139.58, SmartdownPlugins::PayLeaveForParentsAdoption.rate_of_paternity_pay(salary_2)
    end

    test "rate_of_paternity_pay returns 90% of the given weekly salary when it is less than £139.58" do
      salary_2 = Smartdown::Model::Answer::Salary.new("150-week")
      assert_equal 135.0, SmartdownPlugins::PayLeaveForParentsAdoption.rate_of_paternity_pay(salary_2)
    end

    test "rate_of_shpp returns 139.58 when 90% of the given weekly salary is higher than £139.58" do
      salary_1 = Smartdown::Model::Answer::Salary.new("200-week")
      assert_equal 139.58, SmartdownPlugins::PayLeaveForParentsAdoption.rate_of_shpp(salary_1)
    end

    test "rate_of_shpp returns 90% of the given weekly salary when it is less than £139.58" do
      salary_1 = Smartdown::Model::Answer::Salary.new("150-week")
      assert_equal 135.0, SmartdownPlugins::PayLeaveForParentsAdoption.rate_of_shpp(salary_1)
    end

    test "rate_of_smp_6_weeks returns 90% of the given weekly salary" do
      salary_1 = Smartdown::Model::Answer::Salary.new("150-week")
      assert_equal 135.0, SmartdownPlugins::PayLeaveForParentsAdoption.rate_of_smp_6_weeks(salary_1)
    end

    test "rate_of_smp_33_weeks returns 90% of the given weekly salary when it is less than £139.58" do
      salary_1 = Smartdown::Model::Answer::Salary.new("150-week")
      assert_equal 135.0, SmartdownPlugins::PayLeaveForParentsAdoption.rate_of_smp_33_weeks(salary_1)
    end

    test "rate_of_smp_33_weeks returns 139.58 when 90% of the given weekly salary is higher than £139.58" do
      salary_1 = Smartdown::Model::Answer::Salary.new("200-week")
      assert_equal 139.58, SmartdownPlugins::PayLeaveForParentsAdoption.rate_of_smp_33_weeks(salary_1)
    end

    test "total_aspp returns the rate_of_paternity_pay * 26" do
      salary = Smartdown::Model::Answer::Salary.new("200-week")
      SmartdownPlugins::PayLeaveForParentsAdoption.stubs(:rate_of_paternity_pay).with(salary).returns(139.58)
      assert_equal 139.58 * 26, SmartdownPlugins::PayLeaveForParentsAdoption.total_aspp(salary)
    end

    test "total_maternity_allowance returns the rate_of_maternity_allowance * 39" do
      salary_1 = Smartdown::Model::Answer::Salary.new("200-week")
      SmartdownPlugins::PayLeaveForParentsAdoption.stubs(:rate_of_maternity_allowance).with(salary_1).returns(139.58)
      assert_equal 139.58 * 39, SmartdownPlugins::PayLeaveForParentsAdoption.total_maternity_allowance(salary_1)
    end

    test "total_smp returns the rate_of_smp_6_weeks * 6 + rate_of_smp_33_weeks * 33 (totaling 39 weeks)" do
      salary_1 = Smartdown::Model::Answer::Salary.new("200-week")
      SmartdownPlugins::PayLeaveForParentsAdoption.stubs(:rate_of_smp_6_weeks).with(salary_1).returns(1.0)
      SmartdownPlugins::PayLeaveForParentsAdoption.stubs(:rate_of_smp_33_weeks).with(salary_1).returns(100.0)
      assert_equal 3306.0, SmartdownPlugins::PayLeaveForParentsAdoption.total_smp(salary_1)
    end
  end
end
