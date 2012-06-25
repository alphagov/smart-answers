require_relative '../../test_helper'

module SmartAnswer::Calculators
  class HolidayEntitlementTest < ActiveSupport::TestCase

    def setup
      @calculator = HolidayEntitlement.new()
    end

    test "Hours in a time series" do
      assert_equal @calculator.hours_between_date(Date.today, Date.yesterday), 24
    end

    test "Make a hash into times" do
      seconds = @calculator.hours_as_seconds(@calculator.hours_between_date(Date.today, Date.yesterday))
      hash = @calculator.seconds_to_hash seconds
      assert_equal hash[:dd], 1
      assert_equal hash[:hh], 0
      assert_equal hash[:mm], 0
    end

    test "Fraction of a year" do
      start_of_year = Date.civil(Date.today.year, 1, 1)
      end_of_fraction = Date.civil(Date.today.year, 4, 1)
      fraction = sprintf "%.3f", @calculator.fraction_of_year(end_of_fraction, start_of_year)
      assert_equal fraction, "0.249"
    end

  end
end
