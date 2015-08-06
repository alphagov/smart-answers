require_relative "../../test_helper"

module SmartAnswer::Calculators
  class PlanMaternityLeaveTest < ActiveSupport::TestCase
    context PlanMaternityLeave do
      setup do
        @due_date = "2013-01-02"
        @start_date = "2012-12-19" # 2 weeks
        @calculator = PlanMaternityLeave.new(due_date: @due_date)
      end

      context "formatted dates" do
        should "show formatted due date" do
          assert_equal "Wednesday, 02 January 2013", @calculator.formatted_due_date
        end

        should "show formatted start_date (2 weeks)" do
          @calculator.enter_start_date("2012-12-19")
          assert_equal "19 December 2012", @calculator.formatted_start_date
        end

        should "format start date (5 days)" do
          @calculator.enter_start_date("2012-12-29")
          assert_equal "29 December 2012", @calculator.formatted_start_date
        end
      end

      context "distance from start dates" do
        should "distance from start (days 05)" do
          @calculator.enter_start_date("2012-12-28")
          assert_equal "5 days", @calculator.distance_start
        end

        should "distance from start (weeks 02)" do
          @calculator.enter_start_date("2012-12-19")
          assert_equal "14 days", @calculator.distance_start
        end
      end

      context "test date range methods" do
        setup do
          # /plan-maternity-leave/y/2012-12-09/weeks_2
          @calculator = PlanMaternityLeave.new(due_date: "2012-12-09")
          @calculator.enter_start_date("2012-11-25")
        end

        should "qualifying_week give last date of 1 September 2012" do
          assert_equal Date.parse("1 September 2012"), @calculator.qualifying_week.last
        end

        should "earliest_start give date of 23 September 2012" do
          assert_equal Date.parse("23 September 2012"), @calculator.earliest_start
        end

        should "period_of_ordinary_leave give range of 25 November 2012 to 25 May 2013" do
          assert_equal "25 November 2012 to 25 May 2013", @calculator.format_date_range(@calculator.period_of_ordinary_leave)
        end

        should "period_of_additional_leave give range of 26 May 2013 to 23 November 2013" do
          assert_equal "26 May 2013 to 23 November 2013", @calculator.format_date_range(@calculator.period_of_additional_leave)
        end
      end
    end
  end
end
