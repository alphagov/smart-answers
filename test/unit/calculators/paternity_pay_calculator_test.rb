require_relative "../../test_helper"

module SmartAnswer::Calculators
  class PaternityPayCalculatorTest < ActiveSupport::TestCase
    context PaternityPayCalculator do
      context "#paydates_and_pay" do
        setup do
          due_date = Date.parse("1 May 2014")
          @calculator = PaternityPayCalculator.new(due_date)
          @calculator.leave_start_date = due_date
          @calculator.pay_method = "weekly_starting"
          @calculator.stubs(:average_weekly_earnings).returns("125.00")
        end

        should "produce 2 weeks of pay dates and pay at 90% of wage" do
          paydates_and_pay = @calculator.paydates_and_pay
          assert_equal "2014-05-07", paydates_and_pay.first[:date].to_s
          assert_equal 112.5, paydates_and_pay.first[:pay]
          assert_equal "2014-05-14", paydates_and_pay.last[:date].to_s
          assert_equal 112.5, paydates_and_pay.last[:pay]
        end
      end

      context "paternity leave duration weekly payment dates" do
        setup do
          due_date = Date.parse("1 October 2015")
          @calculator = PaternityPayCalculator.new(due_date)
          @calculator.leave_start_date = due_date
          @calculator.pay_method = "weekly_starting"
          @calculator.stubs(:average_weekly_earnings).returns("500.00")
        end

        should "suggest a single payment when requesting a one week leave" do
          @calculator.paternity_leave_duration = "one_week"
          actual_pay_dates = @calculator.paydates_and_pay.map { |pay| pay[:date] }

          assert_equal Date.parse("7 October 2015"), @calculator.pay_end_date
          assert_equal [Date.parse("7 October 2015")], actual_pay_dates
        end

        should "suggest two payments when requesting a two week leave" do
          @calculator.paternity_leave_duration = "two_weeks"
          actual_pay_dates = @calculator.paydates_and_pay.map { |pay| pay[:date] }
          assert_equal Date.parse("14 October 2015"), @calculator.pay_end_date
          assert_equal [Date.parse("7 October 2015"), Date.parse("14 October 2015")], actual_pay_dates
        end
      end

      context "for paternity pay monthly dates" do
        should "produce 1 week of pay dates and pay at maximum amount" do
          date = Date.parse("10 April #{Time.zone.now.year}")
          calculator = PaternityPayCalculator.new(date)
          calculator.leave_start_date = date
          calculator.pay_method = "last_day_of_the_month"
          calculator.stubs(:average_weekly_earnings).returns(500.00)

          assert_equal (calculator.statutory_rate(date) * 2), calculator.paydates_and_pay.first[:pay]
        end
      end

      context "#paternity_deadline" do
        context "deadline is 55 days ahead" do
          setup do
            @due_date = Date.parse("6 April 2024")
          end

          should "give paternity deadline based on due date when baby is born prematurely" do
            calculator = PaternityPayCalculator.new(@due_date)
            calculator.date_of_birth = Date.parse("4 April 2024")

            assert_equal "31-05-2024", calculator.paternity_deadline
          end

          should "give paternity deadline based on actual birth date when baby is born late" do
            calculator = PaternityPayCalculator.new(@due_date)
            calculator.date_of_birth = Date.parse("8 April 2024")

            assert_equal "02-06-2024", calculator.paternity_deadline
          end
        end

        context "deadline is 364 days ahead" do
          setup do
            @due_date = Date.parse("7 April 2024")
          end

          should "give paternity deadline based on due date when baby is born prematurely" do
            calculator = PaternityPayCalculator.new(@due_date)
            calculator.date_of_birth = Date.parse("4 April 2024")

            assert_equal "06-04-2025", calculator.paternity_deadline
          end

          should "give paternity deadline based on actual birth date when baby is born late" do
            calculator = PaternityPayCalculator.new(@due_date)
            calculator.date_of_birth = Date.parse("8 April 2024")

            assert_equal "07-04-2025", calculator.paternity_deadline
          end
        end
      end
    end
  end
end
