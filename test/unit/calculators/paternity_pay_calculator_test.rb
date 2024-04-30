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

      context "#paternity_pay_week_and_pay" do
        setup do
          due_date = Date.parse("1 May 2014")
          @calculator = PaternityPayCalculator.new(due_date)
          @calculator.leave_start_date = due_date
          @calculator.pay_method = "weekly_starting"
          @calculator.stubs(:average_weekly_earnings).returns("125.00")
        end

        should "produce 2 weeks of pay dates and pay at 90% of wage" do
          assert_equal "Week 1|£112.50\nWeek 2|£112.50", @calculator.paternity_pay_week_and_pay
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
        context "due date is on or before 6 April 2024" do
          setup do
            due_date = Date.parse("6 April 2024")
            @calculator = PaternityPayCalculator.new(due_date)
          end

          context "employee lives in England/Scotland/Wales" do
            setup do
              @calculator.where_does_the_employee_live = "england"
            end

            should "set the paternity deadline to 55 days after the due date when the baby is born prematurely" do
              @calculator.date_of_birth = Date.parse("4 April 2024")

              assert_equal Date.parse("31-05-2024"), @calculator.paternity_deadline
            end

            should "set the paternity deadline to 55 days after the birth date when the baby is born late" do
              @calculator.date_of_birth = Date.parse("8 April 2024")

              assert_equal Date.parse("02-06-2024"), @calculator.paternity_deadline
            end
          end

          context "employee lives in Northern Ireland" do
            setup do
              @calculator.where_does_the_employee_live = "northern_ireland"
            end

            should "set the paternity deadline to 55 days after the due date when the baby is born prematurely" do
              @calculator.date_of_birth = Date.parse("4 April 2024")

              assert_equal Date.parse("31-05-2024"), @calculator.paternity_deadline
            end

            should "set the paternity deadline to 55 days after the birth date when the baby is born late" do
              @calculator.date_of_birth = Date.parse("8 April 2024")

              assert_equal Date.parse("02-06-2024"), @calculator.paternity_deadline
            end
          end
        end

        context "due date is on or after 7 April 2024" do
          setup do
            due_date = Date.parse("7 April 2024")
            @calculator = PaternityPayCalculator.new(due_date)
          end

          context "employee lives in England/Scotland/Wales" do
            setup do
              @calculator.where_does_the_employee_live = "england"
            end

            should "set the paternity deadline to 364 days after the due date when the baby is born prematurely" do
              @calculator.date_of_birth = Date.parse("4 April 2024")

              assert_equal Date.parse("06-04-2025"), @calculator.paternity_deadline
            end

            should "set the paternity to 364 days after the birth date when the baby is born late" do
              @calculator.date_of_birth = Date.parse("8 April 2024")

              assert_equal Date.parse("07-04-2025"), @calculator.paternity_deadline
            end
          end

          context "employee lives in Northern Ireland" do
            setup do
              @calculator.where_does_the_employee_live = "northern_ireland"
            end

            should "set the paternity deadline to 55 days after the due date when the baby is born prematurely" do
              @calculator.date_of_birth = Date.parse("4 April 2024")

              assert_equal Date.parse("01-06-2024"), @calculator.paternity_deadline
            end

            should "set the paternity deadline to 55 days after the birth date when the baby is born late" do
              @calculator.date_of_birth = Date.parse("8 April 2024")

              assert_equal Date.parse("02-06-2024"), @calculator.paternity_deadline
            end
          end
        end
      end

      context "#leave_must_be_taken_consecutively?" do
        context "employee lives in England/Scotland/Wales" do
          setup do
            @employee_location = "england"
          end

          should "be false when due date is after 6 April 2024" do
            calculator = PaternityPayCalculator.new(Date.parse("7 April 2024"))
            calculator.where_does_the_employee_live = @employee_location

            assert_equal false, calculator.leave_must_be_taken_consecutively?
          end

          should "be true when due date is 6 April 2024 (or before)" do
            calculator = PaternityPayCalculator.new(Date.parse("6 April 2024"))
            calculator.where_does_the_employee_live = @employee_location

            assert_equal true, calculator.leave_must_be_taken_consecutively?
          end
        end

        context "employee lives in Northern Ireland" do
          setup do
            @employee_location = "northern_ireland"
          end

          should "be true when due date is after 6 April 2024" do
            calculator = PaternityPayCalculator.new(Date.parse("7 April 2024"))
            calculator.where_does_the_employee_live = @employee_location

            assert_equal true, calculator.leave_must_be_taken_consecutively?
          end

          should "be true when due date is 6 April 2024 (or before)" do
            calculator = PaternityPayCalculator.new(Date.parse("6 April 2024"))
            calculator.where_does_the_employee_live = @employee_location

            assert_equal true, calculator.leave_must_be_taken_consecutively?
          end
        end
      end
    end
  end
end
