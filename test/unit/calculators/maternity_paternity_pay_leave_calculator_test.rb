require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class MaternityPaternityPayLeaveCalculatorTest < ActiveSupport::TestCase
      setup do
        @due_date = Date.parse("2015-01-01")
        @calculator = MaternityPaternityPayLeaveCalculator.new
        @calculator.due_date = @due_date
      end

      test "calculates start of year to be first Sunday in April" do
        expectations = {
          "2013" => Date.parse("2013-04-07"),
          "2014" => Date.parse("2014-04-06"),
          "2015" => Date.parse("2015-04-05"),
          "2016" => Date.parse("2016-04-03"),
          "2017" => Date.parse("2017-04-02"),
          "2018" => Date.parse("2018-04-01"),
          "2019" => Date.parse("2019-04-07"),
          "2020" => Date.parse("2020-04-05"),
          "2021" => Date.parse("2021-04-04"),
        }

        expectations.each do |year, start_date|
          assert_equal start_date, @calculator.first_day_in_year(year.to_i)
        end
      end

      test "calculates end of year to be the day before the first Sunday in next April" do
        expectations = {
          "2013" => Date.parse("2014-04-05"),
          "2014" => Date.parse("2015-04-04"),
          "2015" => Date.parse("2016-04-02"),
          "2016" => Date.parse("2017-04-01"),
          "2017" => Date.parse("2018-03-31"),
          "2018" => Date.parse("2019-04-06"),
          "2019" => Date.parse("2020-04-04"),
          "2020" => Date.parse("2021-04-03"),
          "2021" => Date.parse("2022-04-02"),
        }

        expectations.each do |year, start_date|
          assert_equal start_date, @calculator.last_day_in_year(year.to_i)
        end
      end

      test "continuity_start_date" do
        expected = Date.parse("2014-03-29")
        assert_equal expected, @calculator.continuity_start_date
      end

      test "continuity_end_date" do
        expected = Date.parse("2014-09-14")
        assert_equal expected, @calculator.continuity_end_date
      end

      test "lower_earnings_start_date" do
        expected = Date.parse("2014-07-26")
        assert_equal expected, @calculator.lower_earnings_start_date
      end

      test "lower_earnings_end_date" do
        expected = Date.parse("2014-09-20")
        assert_equal expected, @calculator.lower_earnings_end_date
      end

      test "earnings_employment_start_date" do
        expected = Date.parse("2013-09-22")
        assert_equal expected, @calculator.earnings_employment_start_date
      end

      test "earnings_employment_end_date" do
        expected = Date.parse("2014-12-27")
        assert_equal expected, @calculator.earnings_employment_end_date
      end

      test "start_of_maternity_allowance" do
        @calculator.due_date = @due_date
        expected = Date.parse("2014-10-12")
        assert_equal expected, @calculator.start_of_maternity_allowance
      end

      test "earliest_start_mat_leave" do
        @calculator.due_date = @due_date
        expected = Date.parse("2014-10-12")
        assert_equal expected, @calculator.earliest_start_mat_leave
      end

      test "maternity_leave_notice_date" do
        @calculator.due_date = @due_date
        expected = Date.parse("2014-09-20")
        assert_equal expected, @calculator.maternity_leave_notice_date
      end

      test "paternity_leave_notice_date" do
        @calculator.due_date = @due_date
        expected = Date.parse("2014-09-20")
        assert_equal expected, @calculator.paternity_leave_notice_date
      end

      context "due date in 2013-2014 range" do
        setup do
          @date = Date.parse("2014-04-04")
          @calculator = MaternityPaternityPayLeaveCalculator.new
          @calculator.due_date = @date
        end

        should "return £109 for lower_earnings_amount" do
          assert_equal 109, @calculator.lower_earnings_amount
        end
      end

      context "due date in 2014-2015 range" do
        setup do
          @date = Date.parse("2015-04-03")
          @calculator = MaternityPaternityPayLeaveCalculator.new
          @calculator.due_date = @date
        end

        should "return £111 for lower_earnings_amount" do
          assert_equal 111, @calculator.lower_earnings_amount
        end
      end

      context "due date in 2015-2016 range" do
        setup do
          @date = Date.parse("2016-04-02")
          @calculator = MaternityPaternityPayLeaveCalculator.new
          @calculator.due_date = @date
        end

        should "return £112 for lower_earnings_amount" do
          assert_equal 112, @calculator.lower_earnings_amount
        end
      end

      context "due date in 2016-2017 range" do
        setup do
          @date = Date.parse("2017-03-31")
          @calculator = MaternityPaternityPayLeaveCalculator.new
          @calculator.due_date = @date
        end

        should "return £112 for lower_earnings_amount" do
          assert_equal 112, @calculator.lower_earnings_amount
        end
      end

      context "due date in 2017-2018 range" do
        setup do
          @date = Date.parse("2018-03-30")
          @calculator = MaternityPaternityPayLeaveCalculator.new
          @calculator.due_date = @date
        end

        should "return £113 for lower_earnings_amount" do
          assert_equal 113, @calculator.lower_earnings_amount
        end
      end

      context "due date in 2018-2019 range" do
        setup do
          @date = Date.parse("2019-04-05")
          @calculator = MaternityPaternityPayLeaveCalculator.new
          @calculator.due_date = @date
        end

        should "return £116 for lower_earnings_amount" do
          assert_equal 116, @calculator.lower_earnings_amount
        end
      end

      context "due date in 2019-2020 range" do
        setup do
          @date = Date.parse("2020-04-03")
          @calculator = MaternityPaternityPayLeaveCalculator.new
          @calculator.due_date = @date
        end

        should "return £118 for lower_earnings_amount" do
          assert_equal 118, @calculator.lower_earnings_amount
        end
      end

      context "due date in 2020-2021 range" do
        setup do
          @date = Date.parse("2021-04-01")
          @calculator = MaternityPaternityPayLeaveCalculator.new
          @calculator.due_date = @date
        end

        should "return £120 for lower_earnings_amount" do
          assert_equal 120, @calculator.lower_earnings_amount
        end
      end

      context "due date outside all ranges" do
        setup do
          @date = Date.parse("2022-01-01")
          @calculator = MaternityPaternityPayLeaveCalculator.new
          @calculator.due_date = @date
        end

        should "return the latest known lower_earnings_amount" do
          assert_equal 120, @calculator.lower_earnings_amount
        end
      end

      context "an LEL period which straddles an LEL uprating" do
        setup do
          @date = Date.parse("2018-09-08")
          @calculator = MaternityPaternityPayLeaveCalculator.new
          @calculator.due_date = @date
        end

        should "return the more recent lower_earnings_amount" do
          assert_equal 116, @calculator.lower_earnings_amount
        end
      end
    end
  end
end
