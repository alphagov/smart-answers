require_relative '../../test_helper'

module SmartAnswer::Calculators
  class HolidayEntitlementTest < ActiveSupport::TestCase

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
        calc.expects(:full_time_part_time_days).returns(18.342452)

        assert_equal '18.3', calc.formatted_full_time_part_time_days
      end
    end

    context "calculating casual or irregular hours entitlement" do
      should "return the hours and minutes of entitlement" do
        calc = HolidayEntitlement.new(:total_hours => 1314.4)
        assert_equal [158, 38], calc.casual_irregular_entitlement
      end
    end # casual or irregular

    context "calculating annualised entitlement" do
      should "return the average hours per woeking week" do
        calc = HolidayEntitlement.new(:total_hours => 1314.4)
        assert_equal '28.33', sprintf('%.2f', calc.annualised_hours_per_week)
      end

      should "return the hours and minutes of entitlement" do
        calc = HolidayEntitlement.new(:total_hours => 1314.4)
        assert_equal [158, 38], calc.annualised_entitlement
      end
    end # annualised

    context "calculating compressed hours entitlement" do
      should "return the hours and minutes of entitlement" do
        calc = HolidayEntitlement.new(:hours_per_week => 20.5, :days_per_week => 3)
        assert_equal [114, 48], calc.compressed_hours_entitlement
      end

      should "return the hours and minutes of daily entitlement" do
        calc = HolidayEntitlement.new(:hours_per_week => 20.5, :days_per_week => 3)
        assert_equal [6, 50], calc.compressed_hours_daily_average
      end
    end

    context "calculating shift worker shifts" do
      context "full year" do
        setup do
          @calc = HolidayEntitlement.new(
            :hours_per_shift => 7.5,
            :shifts_per_shift_pattern => 4,
            :days_per_shift_pattern => 8
          )
        end

        should "return the average shifts per week" do
          assert_equal 3.5, @calc.shifts_per_week
        end

        should "return the holiday entitlement in shifts" do
          assert_equal '19.600', sprintf('%.3f', @calc.shift_entitlement)
        end
      end # full year

      context "starting this year" do
        setup do
          @calc = HolidayEntitlement.new(
            :start_date => '2012-07-01',
            :hours_per_shift => 7.5,
            :shifts_per_shift_pattern => 4,
            :days_per_shift_pattern => 8
          )
        end

        should "return the holiday entitlement in shifts" do
          assert_equal '9.800', sprintf('%.3f', @calc.shift_entitlement)
        end
      end

      context "leaving this year" do
        setup do
          @calc = HolidayEntitlement.new(
            :leaving_date => '2012-09-30',
            :hours_per_shift => 7.5,
            :shifts_per_shift_pattern => 4,
            :days_per_shift_pattern => 8
          )
        end

        should "return the holiday entitlement in shifts" do
          assert_equal '14.620', sprintf('%.3f', @calc.shift_entitlement)
        end
      end
    end

    context "strip_zeros" do
      setup do
        @calc = HolidayEntitlement.new
      end

      should "strip trailing zeroes after the dp from numbers" do
        assert_equal "123", @calc.strip_zeros(123.0)
      end

      should "not strip significant zeroes" do
        assert_equal "120", @calc.strip_zeros(120.0)
      end
    end

    context "formatted version of anything" do
      # implemented with method_missing
      setup do
        @calc = HolidayEntitlement.new
      end

      should "return foo to 1 dp by default" do
        @calc.stubs(:foo).returns(123.6593)
        assert_equal '123.7', @calc.formatted_foo
      end

      should "allow overriding the dp" do
        @calc.stubs(:foo).returns(123.6593)
        assert_equal '123.66', @calc.formatted_foo(2)
      end

      should "strip .0 from foo" do
        @calc.stubs(:foo).returns(23.0493)
        assert_equal '23', @calc.formatted_foo
      end
    end
  end
end
