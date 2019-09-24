require_relative "../../test_helper"

module SmartAnswer::Calculators
  class RedundancyCalculatorTest < ActiveSupport::TestCase
    context "Money formatting conforms to styleguide" do
      should "lop off trailing 00s" do
        assert_equal RedundancyCalculator.format_money(12.00), "12"
      end

      should "leave trailing other numbers alone" do
        assert_equal RedundancyCalculator.format_money(12.50), "12.50"
        assert_equal RedundancyCalculator.format_money(99.09), "99.09"
      end

      should "use commas to separate thousands" do
        assert_equal RedundancyCalculator.format_money(1200.50), "1,200.50"
        assert_equal RedundancyCalculator.format_money(4500.00), "4,500"
      end
    end

    context "amounts for the redundancy date" do
      should "vary the rate per year" do
        assert_equal 430, RedundancyCalculator.redundancy_rates(Date.new(2013, 1, 1)).rate
        assert_equal 430, RedundancyCalculator.redundancy_rates(Date.new(2013, 1, 31)).rate
        assert_equal 450, RedundancyCalculator.redundancy_rates(Date.new(2013, 2, 1)).rate
        assert_equal 450, RedundancyCalculator.redundancy_rates(Date.new(2014, 4, 5)).rate
        assert_equal 464, RedundancyCalculator.redundancy_rates(Date.new(2014, 4, 6)).rate
        assert_equal 475, RedundancyCalculator.redundancy_rates(Date.new(2015, 4, 6)).rate
        assert_equal 479, RedundancyCalculator.redundancy_rates(Date.new(2016, 4, 6)).rate
        assert_equal 489, RedundancyCalculator.redundancy_rates(Date.new(2017, 4, 6)).rate
        assert_equal 508, RedundancyCalculator.redundancy_rates(Date.new(2018, 4, 6)).rate
        assert_equal 525, RedundancyCalculator.redundancy_rates(Date.new(2019, 4, 6)).rate
      end

      should "vary the max amount per year" do
        assert_equal "12,900", RedundancyCalculator.redundancy_rates(Date.new(2013, 1, 1)).max
        assert_equal "12,900", RedundancyCalculator.redundancy_rates(Date.new(2013, 1, 31)).max
        assert_equal "13,500", RedundancyCalculator.redundancy_rates(Date.new(2013, 2, 1)).max
        assert_equal "13,500", RedundancyCalculator.redundancy_rates(Date.new(2014, 4, 5)).max
        assert_equal "13,920", RedundancyCalculator.redundancy_rates(Date.new(2014, 4, 6)).max
        assert_equal "13,920", RedundancyCalculator.redundancy_rates(Date.new(2015, 4, 5)).max
        assert_equal "14,250", RedundancyCalculator.redundancy_rates(Date.new(2015, 4, 6)).max
        assert_equal "14,370", RedundancyCalculator.redundancy_rates(Date.new(2016, 4, 6)).max
        assert_equal "14,670", RedundancyCalculator.redundancy_rates(Date.new(2017, 4, 6)).max
        assert_equal "15,240", RedundancyCalculator.redundancy_rates(Date.new(2018, 4, 6)).max
        assert_equal "15,750", RedundancyCalculator.redundancy_rates(Date.new(Date.today.year, 12, 31)).max
      end

      should "use the most recent rate for far future dates" do
        future_calculator = RedundancyCalculator.redundancy_rates(5.years.from_now.to_date)
        assert future_calculator.rate.is_a?(Numeric)
        assert future_calculator.max.present?
      end
    end

    context "use correct weekly pay and number of years limits" do
      # Aged 45, 12 years service, 350 per week
      should "be 4900" do
        @calculator = RedundancyCalculator.new(430, "45", 12, 350)
        assert_equal 4900, @calculator.pay
      end

      # Aged 42, 22 years of service, 500 per week
      should "use maximum of 20 years and maximum of 430 per week" do
        @calculator = RedundancyCalculator.new(430, "42", 22, 500)
        assert_equal 8815, @calculator.pay
      end

      # Aged 42, 22 years of service, 500 per week, after 01/02/2013
      should "use maximum of 20 years and maximum of 450 per week" do
        @calculator = RedundancyCalculator.new(450, "42", 22, 500)
        assert_equal 9225, @calculator.pay
      end

      should "use the maximum rate of 430 per week" do
        @calculator = RedundancyCalculator.new(430, "41", 4, 1500)
        assert_equal 1720, @calculator.pay
      end

      should "be 1.5 times the weekly maximum for an 18 year old with 3 years service" do
        @calculator = RedundancyCalculator.new(430, "18", 3, 500)
        assert_equal 645, @calculator.pay
        assert_equal 1.5, @calculator.number_of_weeks_entitlement
      end

      should "be 1.5 times the weekly maximum for an 18 year old with 3 years service made redundant after 01/01/2013" do
        @calculator = RedundancyCalculator.new(450, "18", 3, 500)
        assert_equal 675, @calculator.pay
        assert_equal 1.5, @calculator.number_of_weeks_entitlement
      end

      should "be 7.5 times the weekly pay for a 26 year old with 11 years service" do
        @calculator = RedundancyCalculator.new(430, "26", 11, 250)
        assert_equal 1875, @calculator.pay
        assert_equal 7.5, @calculator.number_of_weeks_entitlement
      end

      should "be 10.5 times the weekly pay for a 32 year old with 11 years service" do
        @calculator = RedundancyCalculator.new(430, "32", 11, 420)
        assert_equal 4410, @calculator.pay
        assert_equal 10.5, @calculator.number_of_weeks_entitlement
      end

      should "be 10.5 times the weekly pay for a 32 year old with 11 years service made redundant after 01/01/2013" do
        @calculator = RedundancyCalculator.new(450, "32", 11, 460)
        assert_equal 4725, @calculator.pay
        assert_equal 10.5, @calculator.number_of_weeks_entitlement
      end

      should "be 13.5 times the weekly pay for a 34 year old with 15 years of service" do
        @calculator = RedundancyCalculator.new(430, "34", 15, 386)
        assert_equal 5211, @calculator.pay
        assert_equal 13.5, @calculator.number_of_weeks_entitlement
      end

      should "be 19 times the weekly pay for a 40 year old with 20 years of service" do
        @calculator = RedundancyCalculator.new(430, "40", 20, 401)
        assert_equal 7619, @calculator.pay
        assert_equal 19, @calculator.number_of_weeks_entitlement
      end

      should "be 17.5 times the weekly pay for a 48 year old with 14 years of service" do
        @calculator = RedundancyCalculator.new(430, "48", 14, 381)
        assert_equal 6667.5, @calculator.pay
        assert_equal 17.5, @calculator.number_of_weeks_entitlement
      end
    end

    context "Redundancy date selector" do
      context "Earliest selectable date" do
        context "Months January to August" do
          should "return the start of the year, four years ago if date is January 1st" do
            Timecop.freeze("2016-01-01")
            assert_equal Date.parse("2012-01-01"), RedundancyCalculator.first_selectable_date
          end

          should "return the start of the year, four years ago if date is August 31st" do
            Timecop.freeze("2016-08-31")
            assert_equal Date.parse("2012-01-01"), RedundancyCalculator.first_selectable_date
          end
        end

        context "Months September to December" do
          should "return the start of the year, three years ago if date is September 1st" do
            Timecop.freeze("2016-09-01")
            assert_equal Date.parse("2013-01-01"), RedundancyCalculator.first_selectable_date
          end

          should "return the start of the year, three years ago if date is December 31st" do
            Timecop.freeze("2016-12-31")
            assert_equal Date.parse("2013-01-01"), RedundancyCalculator.first_selectable_date
          end
        end
      end

      context "Last selectable date" do
        context "Months January to August" do
          should "return the end of the current year if the date is January 1st" do
            Timecop.freeze("2016-01-01")
            assert_equal Date.parse("2016-12-31"), RedundancyCalculator.last_selectable_date
          end

          should "return the end of the current year if the date is August 31st" do
            Timecop.freeze("2016-08-31")
            assert_equal Date.parse("2016-12-31"), RedundancyCalculator.last_selectable_date
          end
        end

        context "Months September to December" do
          should "return end of the next year if the date is September 1st" do
            Timecop.freeze("2016-09-01")
            assert_equal Date.parse("2017-12-31"), RedundancyCalculator.last_selectable_date
          end

          should "return end of the next year if the date is December 31st" do
            Timecop.freeze("2016-12-31")
            assert_equal Date.parse("2017-12-31"), RedundancyCalculator.last_selectable_date
          end
        end
      end
    end
  end
end
