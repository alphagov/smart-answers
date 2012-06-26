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
      fraction = sprintf "%.3f", @calculator.old_fraction_of_year(end_of_fraction, start_of_year)
      assert_equal fraction, "0.249"
    end

    context "rounding and formatting days" do
      should "round to 1 dp" do
        assert_equal '123.7', @calculator.format_days(123.6593)
      end

      should "strip .0" do
        assert_equal '23', @calculator.format_days(23.0450)
      end
    end

    context "calculating fraction of year" do
      should "return 1 with no start date or leaving date" do
        calc = HolidayEntitlement.new
        assert_equal 1, calc.fraction_of_year
      end

      context "with a start_date" do
        should "return the fraction of a year" do
          calc = HolidayEntitlement.new(:start_date => '2011-02-21')
          assert_equal '0.8575', sprintf('%.4f', calc.fraction_of_year)
        end

        should "account for a leap year" do
          calc = HolidayEntitlement.new(:start_date => '2012-02-21')
          assert_equal '0.8579', sprintf('%.4f', calc.fraction_of_year)
        end
      end

      context "with a leaving_date" do
        should "return the fraction of a year" do
          calc = HolidayEntitlement.new(:leaving_date => '2011-06-21')
          assert_equal '0.4685', sprintf('%.4f', calc.fraction_of_year)
        end

        should "account for a leap year" do
          calc = HolidayEntitlement.new(:leaving_date => '2012-06-21')
          assert_equal '0.4699', sprintf('%.4f', calc.fraction_of_year)
        end
      end

      should "format the result" do
        calc = HolidayEntitlement.new(:start_date => '2011-02-21')
        assert_equal '0.86', calc.formatted_fraction_of_year
      end
    end

    context "calculating full-time or part-time holiday entitlement" do
      context "working for a full year" do

        should "calculate entitlement for 5 days a week" do
          calc = HolidayEntitlement.new(
            :days_per_week => 5
          )

          assert_equal 28, calc.full_time_part_time_days
        end

        should "calculate entitlement for more than 5 days a week" do
          calc = HolidayEntitlement.new(
            :days_per_week => 6
          )

          # 28 is the max
          assert_equal 28, calc.full_time_part_time_days
        end

        should "calculate entitlement for less than 5 days a week" do
          calc = HolidayEntitlement.new(
            :days_per_week => 3
          )

          assert_equal '16.80', sprintf('%.2f', calc.full_time_part_time_days)
        end
      end # full year

      context "starting this year" do
        should "calculate entitlement for 5 days a week" do
          calc = HolidayEntitlement.new(
            :start_date => "2012-03-12",
            :days_per_week => 5
          )
          assert_equal '22.49', sprintf('%.2f', calc.full_time_part_time_days)
        end

        should "calculate entitlement for more than 5 days a week" do
          calc = HolidayEntitlement.new(
            :start_date => "2012-03-12",
            :days_per_week => 6
          )
          # TODO: is this correct, or should the 28 day cap be pro-rated
          assert_equal '26.99', sprintf('%.2f', calc.full_time_part_time_days)
        end

        should "cap entitlement at 28 days" do
          calc = HolidayEntitlement.new(
            :start_date => "2012-01-10",
            :days_per_week => 7
          )
          assert_equal 28, calc.full_time_part_time_days
        end

        should "calculate entitlement for less than 5 days per week" do
          calc = HolidayEntitlement.new(
            :start_date => "2012-03-12",
            :days_per_week => 3
          )
          assert_equal '13.50', sprintf('%.2f', calc.full_time_part_time_days)
        end
      end # starting this year

      context "leaving this year" do
        should "calculate entitlement for 5 days a week" do
          calc = HolidayEntitlement.new(
            :leaving_date => '2012-07-24',
            :days_per_week => 5
          )
          assert_equal '15.68', sprintf('%.2f', calc.full_time_part_time_days)
        end

        should "calculate entitlement for more than 5 days a week" do
          calc = HolidayEntitlement.new(
            :leaving_date => '2012-07-24',
            :days_per_week => 6
          )
          assert_equal '18.82', sprintf('%.2f', calc.full_time_part_time_days)
        end

        should "cap entitlement at 28 days" do
          calc = HolidayEntitlement.new(
            :leaving_date => "2012-12-10",
            :days_per_week => 7
          )
          assert_equal 28, calc.full_time_part_time_days
        end

        should "calculate entitlement for less than 5 days a week" do
          calc = HolidayEntitlement.new(
            :leaving_date => '2012-07-24',
            :days_per_week => 3
          )
          assert_equal '9.41', sprintf('%.2f', calc.full_time_part_time_days)
        end
      end # leaving this year

      should "format the result using format_days" do
        calc = HolidayEntitlement.new
        calc.expects(:full_time_part_time_days).returns(:raw_days)
        calc.expects(:format_days).with(:raw_days).returns(:formatted_days)

        assert_equal :formatted_days, calc.formatted_full_time_part_time_days
      end
    end
  end
end
