require_relative "../../test_helper"

module SmartAnswer::Calculators
  class AgriculturalHolidayEntitlementCalculatorTest < ActiveSupport::TestCase
    context AgriculturalHolidayEntitlementCalculator do
      setup do
        @calc = AgriculturalHolidayEntitlementCalculator.new
      end
      context "holiday_days" do
        should "be different given the days worked per week" do
          assert_equal 38, @calc.holiday_days(7)
          assert_equal 31, @calc.holiday_days(5)
          assert_equal 13, @calc.holiday_days(1.5)
          assert_equal 7.5, @calc.holiday_days(0.5)
        end
      end
      context "start_of_holiday_year" do
        should "divide the year on 1st Oct and return the relevant calculation start date" do
          Timecop.travel(Date.civil(Date.today.year, 6, 1))
          assert_equal Date.civil(Date.today.year - 1, 10, 1), @calc.start_of_holiday_year
          Timecop.travel(Date.civil(Date.today.year, 10, 2))
          assert_equal Date.civil(Date.today.year, 10, 1), @calc.start_of_holiday_year
        end
      end
      context "weeks_worked" do
        should "give the number of weeks between the calculation period and holiday start dates" do
          Timecop.travel(Date.civil(Date.today.year, 10, 2))
          assert_equal 4, @calc.weeks_worked(Date.civil(Date.today.year, 11, 1))
        end
      end
      context "available_days" do
        should "give the number of days since the calculation period started" do
          Timecop.travel(Date.civil(Date.today.year, 12, 25))
          assert_equal 85, @calc.available_days
        end
      end

      context "valid_total_days_worked?" do
        setup do
          @calc.stubs(:available_days).returns(100)
        end

        should "be truthy if total days worked is less than or equal to available days" do
          @calc.total_days_worked = 100
          assert @calc.valid_total_days_worked?
        end

        should "be falsey if total days worked is more than available days" do
          @calc.total_days_worked = 101
          refute @calc.valid_total_days_worked?
        end
      end

      context "valid_weeks_at_current_employer?" do
        should "be truthy if weeks at current employer is less than 52" do
          @calc.weeks_at_current_employer = 51
          assert @calc.valid_weeks_at_current_employer?
        end

        should "be falsey if weeks at current employer is equal to or more than 52" do
          @calc.weeks_at_current_employer = 52
          refute @calc.valid_weeks_at_current_employer?
        end
      end
    end
  end
end
