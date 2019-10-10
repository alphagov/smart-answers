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

            assert_equal BigDecimal("0.5833333333").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("16.3333333333").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "16.5", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2019-11-21/2019-04-01/3.0
          should "for less than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-11-23"),
              leave_year_start_date: Date.parse("2019-04-01"),
              days_per_week: 3,
            )

            assert_equal BigDecimal("0.4166666667").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("7.0").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "7", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2019-11-14/2019-01-01/6.0
          should "for more than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-11-14"),
              leave_year_start_date: Date.parse("2019-01-01"),
              days_per_week: 6,
            )

            assert_equal BigDecimal("0.1666666667").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("4.6666666667").round(10), calc.full_time_part_time_days.round(10)
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

            assert_equal BigDecimal("0.5833333333").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("16.3333333333").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "16.5", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2020-11-21/2020-04-01/3.0
          should "for less than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-11-23"),
              leave_year_start_date: Date.parse("2020-04-01"),
              days_per_week: 3,
            )

            assert_equal BigDecimal("0.4166666667").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("7.0").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "7", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2020-11-14/2020-01-01/6.0
          should "for more than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-11-14"),
              leave_year_start_date: Date.parse("2020-01-01"),
              days_per_week: 6,
            )

            assert_equal BigDecimal("0.1666666667").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("4.6666666667").round(10), calc.full_time_part_time_days.round(10)
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

            assert_equal BigDecimal("0.4164383562").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("11.6602739726").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "11.7", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2019-11-21/2019-04-01/3.0
          should "for less than 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2018-11-23"),
              leave_year_start_date: Date.parse("2018-04-01"),
              days_per_week: 3,
            )
            assert_equal BigDecimal("0.6493150685").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("10.9084931507").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "11", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2019-08-22/2019-01-01/6.0
          should "for more than 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-08-22"),
              leave_year_start_date: Date.parse("2019-01-01"),
              days_per_week: 6,
            )
            assert_equal BigDecimal("0.6410958904").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("21.5408219178").round(10), calc.full_time_part_time_days.round(10)
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

            assert_equal BigDecimal("0.4180327869").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("11.7049180328").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "11.8", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2020-11-21/2020-04-01/3.0
          should "for less than 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-11-23"),
              leave_year_start_date: Date.parse("2019-04-01"),
              days_per_week: 3,
            )

            assert_equal BigDecimal("0.6475409836").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("10.8786885246").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "10.9", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2020-08-22/2020-01-01/6.0
          should "for more than 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-08-22"),
              leave_year_start_date: Date.parse("2020-01-01"),
              days_per_week: 6,
            )

            assert_equal BigDecimal("0.6420765027").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("21.5737704918").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "21.6", calc.formatted_full_time_part_time_days
          end
        end
      end

      context "starting and leaving part way through a leave year" do
        context "for a standard year" do
          # /days-worked-per-week/starting/2020-01-20/2020-08-07/5.0
          should "for 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-01-20"),
              leaving_date: Date.parse("2019-07-18"),
              days_per_week: 5,
            )

            assert_equal BigDecimal("0.4931506849").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("13.8082191780822").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "13.9", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2019-11-23/2020-04-07/3.0
          should "for less than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2018-11-23"),
              leaving_date: Date.parse("2019-04-07"),
              days_per_week: 3,
            )

            assert_equal BigDecimal("0.3726027397").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("6.2597260274").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "6.3", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2019-08-22/2020-07-31/6.0
          should "for more than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2018-08-22"),
              leaving_date: Date.parse("2019-07-31"),
              days_per_week: 6,
            )

            assert_equal BigDecimal("0.9424657534").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("26.3890410959").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "26.4", calc.formatted_full_time_part_time_days
          end
        end

        context "for a leap year" do
          # /days-worked-per-week/starting/2020-01-20/2020-08-07/5.0
          should "for 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-01-20"),
              leaving_date: Date.parse("2020-07-18"),
              days_per_week: 5,
            )

            assert_equal BigDecimal("0.4945355191").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("13.8469945355").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "13.9", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2019-11-23/2020-04-07/3.0
          should "for less than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-11-23"),
              leaving_date: Date.parse("2020-04-07"),
              days_per_week: 3,
            )

            assert_equal BigDecimal("0.3743169399").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("6.2885245902").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "6.3", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2019-08-22/2020-07-31/6.0
          should "for more than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-08-22"),
              leaving_date: Date.parse("2020-07-31"),
              days_per_week: 6,
            )

            assert_equal BigDecimal("0.9426229508").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("26.3934426229508").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "26.4", calc.formatted_full_time_part_time_days
          end
        end
      end
    end

    context "calculate entitlement on hours worked per week and compressed hours" do
      context "for a full leave year" do
        should "for 40 hours over 5 days per week" do
          calc = HolidayEntitlement.new(days_per_week: 5, hours_per_week: 40)
          assert_equal "224", calc.formatted_full_time_part_time_compressed_hours
          assert_equal [224, 0], calc.full_time_part_time_hours_and_minutes
        end

        should "for 25 hours over less than 5 days a week" do
          calc = HolidayEntitlement.new(days_per_week: 3, hours_per_week: 25)
          assert_equal "140", calc.formatted_full_time_part_time_compressed_hours
          assert_equal [140, 0], calc.full_time_part_time_hours_and_minutes
        end

        should "for 36 hours over more than 5 days a week" do
          calc = HolidayEntitlement.new(days_per_week: 6, hours_per_week: 36)
          assert_equal "168", calc.formatted_full_time_part_time_compressed_hours
          assert_equal [168, 0], calc.full_time_part_time_hours_and_minutes
        end
      end

      context "starting part way through a leave year" do
        context "for a standard year" do
          should "for 40 hours over 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-06-01"),
              leave_year_start_date: Date.parse("2019-01-01"),
              days_per_week: 5,
              hours_per_week: 40,
            )

            assert_equal BigDecimal("16.3333333333").round(10), calc.full_time_part_time_days.round(10)
            assert_equal BigDecimal("16.5").round(10), calc.rounded_full_time_part_time_days.round(10)
            assert_equal "132", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [132, 0], calc.full_time_part_time_hours_and_minutes
          end

          should "for 25 hours less than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-11-23"),
              leave_year_start_date: Date.parse("2020-04-01"),
              days_per_week: 3,
              hours_per_week: 25,
            )

            assert_equal BigDecimal("7").round(10), calc.full_time_part_time_days.round(10)
            assert_equal BigDecimal("7").round(10), calc.rounded_full_time_part_time_days.round(10)
            assert_equal "58.34", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [58, 20], calc.full_time_part_time_hours_and_minutes
          end

          should "for 36 hours more than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-11-14"),
              leave_year_start_date: Date.parse("2019-01-01"),
              days_per_week: 6,
              hours_per_week: 36,
            )

            assert_equal BigDecimal("4.6666666667").round(10), calc.full_time_part_time_days.round(10)
            assert_equal BigDecimal("5").round(10), calc.rounded_full_time_part_time_days.round(10)
            assert_equal "30", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [30, 0], calc.full_time_part_time_hours_and_minutes
          end
        end

        context "for a leap year" do
          should "for 40 hours over 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-06-01"),
              leave_year_start_date: Date.parse("2020-01-01"),
              days_per_week: 5,
              hours_per_week: 40,
            )

            assert_equal "132", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [132, 0], calc.full_time_part_time_hours_and_minutes
          end

          should "for 25 hours less than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-11-23"),
              leave_year_start_date: Date.parse("2019-04-01"),
              days_per_week: 3,
              hours_per_week: 25,
            )

            assert_equal "58.34", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [58, 20], calc.full_time_part_time_hours_and_minutes
          end

          should "for 36 hours more than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-11-14"),
              leave_year_start_date: Date.parse("2020-01-01"),
              days_per_week: 6,
              hours_per_week: 36,
            )

            assert_equal "30", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [30, 0], calc.full_time_part_time_hours_and_minutes
          end
        end
      end

      context "leaving part way through a leave year" do
        context "for a standard year" do
          should "for 40 hours over 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-06-01"),
              leave_year_start_date: Date.parse("2019-01-01"),
              days_per_week: 5,
              hours_per_week: 40,
            )

            assert_equal BigDecimal("224").round(10), calc.full_time_part_time_hours.round(10)
            assert_equal BigDecimal("93.2821917808").round(10), calc.pro_rated_hours.round(10)
            assert_equal "93.29", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [93, 17], calc.full_time_part_time_hours_and_minutes
          end

          should "for 25 hours less than 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-11-23"),
              leave_year_start_date: Date.parse("2020-04-01"),
              days_per_week: 3,
              hours_per_week: 25,
            )

            assert_equal BigDecimal("140").round(10), calc.full_time_part_time_hours.round(10)
            assert_equal BigDecimal("90.9041095890").round(10), calc.pro_rated_hours.round(10)
            assert_equal "90.91", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [90, 55], calc.full_time_part_time_hours_and_minutes
          end

          should "for 36 hours more than 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-08-22"),
              leave_year_start_date: Date.parse("2019-01-01"),
              days_per_week: 6,
              hours_per_week: 36,
            )

            assert_equal BigDecimal("168").round(10), calc.full_time_part_time_hours.round(10)
            assert_equal BigDecimal("107.7041095890").round(10), calc.pro_rated_hours.round(10)
            assert_equal "107.71", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [107, 43], calc.full_time_part_time_hours_and_minutes
          end
        end
        context "for a leap year" do
          should "for 40 hours over 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-06-01"),
              leave_year_start_date: Date.parse("2020-01-01"),
              days_per_week: 5,
              hours_per_week: 40,
            )

            assert_equal BigDecimal("224").round(10), calc.full_time_part_time_hours.round(10)
            assert_equal BigDecimal("93.6393442623").round(10), calc.pro_rated_hours.round(10)
            assert_equal "93.64", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [93, 38], calc.full_time_part_time_hours_and_minutes
          end
          should "for 25 hours less than 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-11-23"),
              leave_year_start_date: Date.parse("2019-04-01"),
              days_per_week: 3,
              hours_per_week: 25,
            )

            assert_equal BigDecimal("140").round(10), calc.full_time_part_time_hours.round(10)
            assert_equal BigDecimal("90.6557377049").round(10), calc.pro_rated_hours.round(10)
            assert_equal "90.66", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [90, 40], calc.full_time_part_time_hours_and_minutes
          end

          should "for 36 hours more than 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-08-22"),
              leave_year_start_date: Date.parse("2020-01-01"),
              days_per_week: 6,
              hours_per_week: 36,
            )

            assert_equal BigDecimal("168").round(10), calc.full_time_part_time_hours.round(10)
            assert_equal BigDecimal("107.8688524590").round(10), calc.pro_rated_hours.round(10)
            assert_equal "107.87", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [107, 52], calc.full_time_part_time_hours_and_minutes
          end
        end
      end

      context "starting and leaving part way through a leave year" do
        context "for a standard year" do
          should "for 40 hours over 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-01-20"),
              leaving_date: Date.parse("2019-07-18"),
              days_per_week: 5,
              hours_per_week: 40,
            )

            assert_equal BigDecimal("224").round(10), calc.full_time_part_time_hours.round(10)
            assert_equal BigDecimal("110.4657534247").round(10), calc.pro_rated_hours.round(10)
            assert_equal "110.47", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [110, 28], calc.full_time_part_time_hours_and_minutes
          end

          should "for 25 hours less than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2018-11-23"),
              leaving_date: Date.parse("2019-04-07"),
              days_per_week: 3,
              hours_per_week: 25,
            )

            assert_equal BigDecimal("140").round(10), calc.full_time_part_time_hours.round(10)
            assert_equal BigDecimal("52.1643835616").round(10), calc.pro_rated_hours.round(10)
            assert_equal "52.17", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [52, 10], calc.full_time_part_time_hours_and_minutes
          end

          should "for 36 hours more than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2018-08-22"),
              leaving_date: Date.parse("2019-07-31"),
              days_per_week: 6,
              hours_per_week: 36,
            )

            assert_equal BigDecimal("168").round(10), calc.full_time_part_time_hours.round(10)
            assert_equal BigDecimal("158.3342465753").round(10), calc.pro_rated_hours.round(10)
            assert_equal "158.34", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [158, 20], calc.full_time_part_time_hours_and_minutes
          end
        end
        context "for a leap year" do
          should "for 40 hours over 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-01-20"),
              leaving_date: Date.parse("2020-07-18"),
              days_per_week: 5,
              hours_per_week: 40,
            )

            assert_equal BigDecimal("224").round(10), calc.full_time_part_time_hours.round(10)
            assert_equal BigDecimal("110.7759562842").round(10), calc.pro_rated_hours.round(10)
            assert_equal "110.78", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [110, 47], calc.full_time_part_time_hours_and_minutes
          end
          should "for 25 hours less than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-11-23"),
              leaving_date: Date.parse("2020-04-07"),
              days_per_week: 3,
              hours_per_week: 25,
            )

            assert_equal BigDecimal("140").round(10), calc.full_time_part_time_hours.round(10)
            assert_equal BigDecimal("52.4043715847").round(10), calc.pro_rated_hours.round(10)
            assert_equal "52.41", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [52, 25], calc.full_time_part_time_hours_and_minutes
          end

          should "for 36 hours more than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-08-22"),
              leaving_date: Date.parse("2020-07-31"),
              days_per_week: 6,
              hours_per_week: 36,
            )

            assert_equal BigDecimal("168").round(10), calc.full_time_part_time_hours.round(10)
            assert_equal BigDecimal("158.3606557377").round(10), calc.pro_rated_hours.round(10)
            assert_equal "158.37", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [158, 22], calc.full_time_part_time_hours_and_minutes
          end
        end
      end
    end
  end
end
