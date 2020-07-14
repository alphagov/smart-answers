require_relative "../../test_helper"

module SmartAnswer::Calculators
  class PlanAdoptionLeaveTest < ActiveSupport::TestCase
    context PlanAdoptionLeave do
      setup do
        @calculator = PlanAdoptionLeave.new
        @calculator.match_date = Date.parse("2012-06-25")
      end

      context "formatted dates (start date 5 days)" do
        setup do
          @calculator.arrival_date = Date.parse("2012-12-25")
          @calculator.start_date = Date.parse("2012-12-20")
        end

        should "show formatted arrival date" do
          assert_equal "25 December 2012", @calculator.arrival_date_formatted
        end

        should "distance from start (days 05)" do
          assert_equal "5 days", @calculator.distance_start
        end
      end

      context "formatted dates (start_date 2 weeks)" do
        setup do
          @calculator.arrival_date = Date.parse("2012-12-25")
          @calculator.start_date = Date.parse("2012-12-11")
        end

        should "distance from start " do
          assert_equal "14 days", @calculator.distance_start
        end

        context "test date range methods" do
          # /plan-adoption-leave/y/2012-06-25/2012-12-25/weeks_2
          should "qualifying_week give last date of 23 June 2012" do
            assert_equal Date.parse("23 June 2012"), @calculator.qualifying_week.ends_on
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
            assert_equal "11 December 2012 to 11 June 2013", @calculator.period_of_ordinary_leave.to_s
          end

          should "period_of_additional_leave give range of 10 December 2012 - 10 June 2013" do
            assert_equal "11 June 2013 to 10 December 2013", @calculator.period_of_additional_leave.to_s
          end
        end
      end

      context "test validators" do
        should "arrival date before match date should be invalid" do
          @calculator.arrival_date = Date.parse("2012-05-25")
          assert_not @calculator.valid_arrival_date?
        end

        should "arrival date after match date should be valid" do
          @calculator.arrival_date = Date.parse("2012-07-25")
          assert @calculator.valid_arrival_date?
        end

        should "start date can be less than 14 days before arrival date" do
          @calculator.arrival_date = Date.parse("2012-07-25")
          @calculator.start_date = Date.parse("2012-07-15")
          assert @calculator.valid_start_date?
        end

        should "start date cannot be longer than 14 days before arrival date" do
          @calculator.arrival_date = Date.parse("2012-07-25")
          @calculator.start_date = Date.parse("2012-07-10")
          assert_not @calculator.valid_start_date?
        end
      end
    end
  end
end
