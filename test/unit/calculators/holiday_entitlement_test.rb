require_relative "../../test_helper"

module SmartAnswer::Calculators
  class HolidayEntitlementTest < ActiveSupport::TestCase
    context "calculate entitlement on days worked per week" do
      # /days-worked-per-week/full-year/5.0
      context "for a full leave year" do
        should "for 5 days a week" do
          calc = HolidayEntitlement.new(days_per_week: 5)
          assert_equal "28", calc.formatted_full_time_part_time_days
        end

        # /days-worked-per-week/full-year/5.0
        should "for more than 5 days a week" do
          calc = HolidayEntitlement.new(days_per_week: 7)
          assert_equal "28", calc.formatted_full_time_part_time_days
        end

        # /days-worked-per-week/full-year/3.5
        should "for less than 5 days a week" do
          calc = HolidayEntitlement.new(days_per_week: 3)
          assert_equal "17", calc.formatted_full_time_part_time_days
        end
      end

      context "starting part way through a leave year" do
        context "for a standard year" do
          # /days-worked-per-week/starting/2019-06-01/2019-01-01/5.0
          should "for 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-06-01"),
              leave_year_start_date: Date.parse("2019-01-01"),
              days_per_week: 5,
            )

            assert_equal BigDecimal(0.5833333333, 10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal(16.3333333333, 12), calc.full_time_part_time_days.round(10)
            assert_equal "16.5", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2019-11-21/2019-04-01/3.0
          should "for less than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-11-23"),
              leave_year_start_date: Date.parse("2019-04-01"),
              days_per_week: 3,
            )

            assert_equal BigDecimal(0.4166666667, 10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal(7.0, 10), calc.full_time_part_time_days.round(10)
            assert_equal "7", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2019-11-14/2019-01-01/6.0
          should "for more than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-11-14"),
              leave_year_start_date: Date.parse("2019-01-01"),
              days_per_week: 6,
            )

            assert_equal BigDecimal(0.1666666667, 10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal(4.6666666667, 11), calc.full_time_part_time_days.round(10)
            assert_equal "5", calc.formatted_full_time_part_time_days
          end
        end

        context "for a leap year" do
          # /days-worked-per-week/starting/2020-06-01/2020-01-01/5.0
          should "for 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-06-01"),
              leave_year_start_date: Date.parse("2020-01-01"),
              days_per_week: 5,
            )

            assert_equal BigDecimal(0.5833333333, 10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal(16.3333333333, 12), calc.full_time_part_time_days.round(10)
            assert_equal "16.5", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2020-11-21/2020-04-01/3.0
          should "for less than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-11-23"),
              leave_year_start_date: Date.parse("2020-04-01"),
              days_per_week: 3,
            )

            assert_equal BigDecimal(0.4166666667, 10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal(7.0, 10), calc.full_time_part_time_days.round(10)
            assert_equal "7", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2020-11-14/2020-01-01/6.0
          should "for more than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-11-14"),
              leave_year_start_date: Date.parse("2020-01-01"),
              days_per_week: 6,
            )

            assert_equal BigDecimal(0.1666666667, 10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal(4.6666666667, 11), calc.full_time_part_time_days.round(10)
            assert_equal "5", calc.formatted_full_time_part_time_days
          end
        end
      end

      context "leaving part way through a leave year" do
        context "for a standard year" do
          # /days-worked-per-week/starting/2019-06-01/2019-01-01/5.0
          should "for 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-06-01"),
              leave_year_start_date: Date.parse("2019-01-01"),
              days_per_week: 5,
            )

            assert_equal BigDecimal(0.4164383562, 10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal(11.6602739726, 12), calc.full_time_part_time_days.round(10)
            assert_equal "11.7", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2019-11-21/2019-04-01/3.0
          should "for less than 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2018-11-23"),
              leave_year_start_date: Date.parse("2018-04-01"),
              days_per_week: 3,
            )
            assert_equal BigDecimal(0.6493150685, 10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal(10.9084931507, 12), calc.full_time_part_time_days.round(10)
            assert_equal "11", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2019-08-22/2019-01-01/6.0
          should "for more than 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-08-22"),
              leave_year_start_date: Date.parse("2019-01-01"),
              days_per_week: 6,
            )
            assert_equal BigDecimal(0.6410958904, 10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal(21.5408219178, 12), calc.full_time_part_time_days.round(10)
            assert_equal "21.6", calc.formatted_full_time_part_time_days
          end
        end

        context "for a leap year" do
          # /days-worked-per-week/starting/2020-06-01/2020-01-01/5.0
          should "for 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-06-01"),
              leave_year_start_date: Date.parse("2020-01-01"),
              days_per_week: 5,
            )

            assert_equal BigDecimal(0.4180327869, 10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal(11.7049180328, 12), calc.full_time_part_time_days.round(10)
            assert_equal "11.8", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2020-11-21/2020-04-01/3.0
          should "for less than 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-11-23"),
              leave_year_start_date: Date.parse("2019-04-01"),
              days_per_week: 3,
            )

            assert_equal BigDecimal(0.6475409836, 10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal(10.8786885246, 12), calc.full_time_part_time_days.round(10)
            assert_equal "10.9", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2020-08-22/2020-01-01/6.0
          should "for more than 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-08-22"),
              leave_year_start_date: Date.parse("2020-01-01"),
              days_per_week: 6,
            )

            assert_equal BigDecimal(0.6420765027, 10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal(21.5737704918, 12), calc.full_time_part_time_days.round(10)
            assert_equal "21.6", calc.formatted_full_time_part_time_days
          end
        end
      end
    end
  end
end
