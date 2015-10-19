require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class PayLeaveForParentsCalculatorTest < ActiveSupport::TestCase
      setup do
        @due_date = Date.parse('2015-1-1')
        @calculator = SmartAnswer::Calculators::PayLeaveForParentsCalculator.new
      end

      test "continuity_start_date" do
        expected = Date.parse('2014-3-29')
        assert_equal expected, @calculator.continuity_start_date(@due_date)
      end

      test "continuity_end_date" do
        expected = Date.parse('2014-9-14')
        assert_equal expected, @calculator.continuity_end_date(@due_date)
      end

      test "lower_earnings_start_date" do
        expected = Date.parse("2014-7-26")
        assert_equal expected, @calculator.lower_earnings_start_date(@due_date)
      end

      test "lower_earnings_end_date" do
        expected = Date.parse("2014-9-20")
        assert_equal expected, @calculator.lower_earnings_end_date(@due_date)
      end

      test "earnings_employment_start_date" do
        expected = Date.parse("2013-9-22")
        assert_equal expected, @calculator.earnings_employment_start_date(@due_date)
      end

      test "earnings_employment_end_date" do
        expected = Date.parse("2014-12-27")
        assert_equal expected, @calculator.earnings_employment_end_date(@due_date)
      end

      test "start_of_maternity_allowance" do
        expected = Date.parse("2014-10-12")
        assert_equal expected, @calculator.start_of_maternity_allowance(@due_date)
      end

      test "earliest_start_mat_leave" do
        expected = Date.parse("2014-10-12")
        assert_equal expected, @calculator.earliest_start_mat_leave(@due_date)
      end

      test "maternity_leave_notice_date" do
        expected = Date.parse("2014-9-20")
        assert_equal expected, @calculator.maternity_leave_notice_date(@due_date)
      end

      test "paternity_leave_notice_date" do
        expected = Date.parse("2014-9-20")
        assert_equal expected, @calculator.paternity_leave_notice_date(@due_date)
      end

      context "due date in 2013-2014 range" do
        setup do
          @date = Date.parse("2014-1-1")
          @calculator = SmartAnswer::Calculators::PayLeaveForParentsCalculator.new
        end

        should "be in 2013-2014 range" do
          assert_equal true, @calculator.in_2013_2014_fin_year?(@date)
        end

        should "return £ 109 for lower_earnings_amount" do
          assert_equal 109, @calculator.lower_earnings_amount(@date)
        end
      end

      context "due date in 2014-2015 range" do
        setup do
          @date = Date.parse("2015-1-1")
          @calculator = SmartAnswer::Calculators::PayLeaveForParentsCalculator.new
        end

        should "be in 2013-2014 range" do
          assert_equal true, @calculator.in_2014_2015_fin_year?(@date)
        end

        should "return £ 111 for lower_earnings_amount" do
          assert_equal 111, @calculator.lower_earnings_amount(@date)
        end
      end

      context "due date in 2015-2016 range" do
        setup do
          @date = Date.parse("2016-1-1")
          @calculator = SmartAnswer::Calculators::PayLeaveForParentsCalculator.new
        end

        should "be in 2015-2016 range" do
          assert_equal true, @calculator.in_2015_2016_fin_year?(@date)
        end

        should "return £ 112 for lower_earnings_amount" do
          assert_equal 112, @calculator.lower_earnings_amount(@date)
        end
      end

      context "due date outside all ranges" do
        setup do
          @date = Date.parse("2022-1-1")
          @calculator = SmartAnswer::Calculators::PayLeaveForParentsCalculator.new
        end

        should "return the latest_pat_leave known lower_earnings_amount" do
          assert_equal 112, @calculator.lower_earnings_amount(@date)
        end
      end
    end
  end
end
