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
      context "calculation_period" do
        should "divide the year on 1st Oct and return the relevant calculation start date" do
          Timecop.travel(Date.civil(Date.today.year, 6, 1))
          assert_equal Date.civil(Date.today.year - 1, 10, 1), @calc.calculation_period
          Timecop.travel(Date.civil(Date.today.year, 10, 2))
          assert_equal Date.civil(Date.today.year, 10, 1), @calc.calculation_period
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
    end
  end
end
