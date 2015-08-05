require_relative "../../test_helper"

module SmartAnswer::Calculators
  class PlanAdoptionLeaveTest < ActiveSupport::TestCase
    context PlanAdoptionLeave do
      setup do
        @match_date = Date.parse("2012-06-25")
      end

      context "formatted dates (start date 5 days)" do
        setup do
          @calculator = PlanAdoptionLeave.new(
            match_date: @match_date, arrival_date: Date.parse("2012-12-25"), start_date: Date.parse("2012-12-20"))
        end

        should "show formatted due date" do
          assert_equal "25 June 2012", @calculator.formatted_match_date
          assert_equal "25 December 2012", @calculator.formatted_arrival_date
        end

        should "format start date " do
          assert_equal "20 December 2012", @calculator.formatted_start_date
        end

        should "distance from start (days 05)" do
          assert_equal "5 days", @calculator.distance_start
        end
      end
      context "formatted dates (start_date 2 weeks)" do
        setup do
          @calculator = PlanAdoptionLeave.new(
            match_date: @match_date, arrival_date: Date.parse("2012-12-25"), start_date: Date.parse("2012-12-11"))
        end

        should "format start date" do
          assert_equal "11 December 2012", @calculator.formatted_start_date
        end

        should "distance from start " do
          assert_equal "14 days", @calculator.distance_start
        end

        context "test date range methods" do
          # /plan-adoption-leave/y/2012-06-25/2012-12-25/weeks_2
          should "qualifying_week give last date of 23 June 2012" do
            assert_equal Date.parse("23 June 2012"), @calculator.qualifying_week.last
          end

          should "last_qualifying_week_formatted give 23 June 2012" do
            assert_equal "23 June 2012", @calculator.last_qualifying_week_formatted
          end

          should "earliest_start give date of 11 December 2012" do
            assert_equal Date.parse("11 December 2012"), @calculator.earliest_start
          end

          should "earliest_start_formatted give 11 December 2012" do
            assert_equal "11 December 2012", @calculator.earliest_start_formatted
          end

          should "period_of_ordinary_leave give range of 11 December 2012 - 11 June 2013" do
            assert_equal "11 December 2012 to 11 June 2013", @calculator.format_date_range(@calculator.period_of_ordinary_leave)
          end

          should "period_of_additional_leave give range of 10 December 2012 - 10 June 2013" do
            assert_equal "11 June 2013 to 10 December 2013", @calculator.format_date_range(@calculator.period_of_additional_leave)
          end
        end
      end
    end
  end
end
