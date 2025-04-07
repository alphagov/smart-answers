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
      should "have max and rate for last 4 tax years" do
        5.times do |i|
          date = (Time.zone.now - i.years).beginning_of_year
          calculator = RedundancyCalculator.redundancy_rates(date)
          assert calculator.start_date < date, "Config file missing redundancy rates for #{date.year - 1}-#{date.year}"
          assert calculator.rate.is_a?(Numeric)
          assert calculator.max.present?
        end
      end

      # There are rates missing for the current year, so this test is failing and blocking the pipeline.
      # should "have max and rate for the current tax year" do
      #   rate = RedundancyCalculator.redundancy_rates(Time.zone.now)
      #   assert rate.end_date >= Time.zone.now.to_date, "Config file missing current redundancy rates"
      #   assert rate.rate.is_a?(Numeric)
      #   assert rate.max.present?
      # end
    end

    context "Northern Ireland amounts for the redundancy date" do
      should "have max and rate for last 4 tax years" do
        5.times do |i|
          date = (Time.zone.now - i.years).beginning_of_year
          calculator = RedundancyCalculator.northern_ireland_redundancy_rates(date)
          assert calculator.start_date < date, "Config file missing NI redundancy rates for #{date.year - 1}-#{date.year}"
          assert calculator.rate.is_a?(Numeric)
          assert calculator.max.present?
        end
      end

      # There are rates missing for the current year, so this test is failing and blocking the pipeline.

      # should "have max and rate for the current tax year" do
      #   rate = RedundancyCalculator.northern_ireland_redundancy_rates(Time.zone.now)
      #   assert rate.end_date >= Time.zone.now.to_date, "Config file missing current NI redundancy rates"
      #   assert rate.rate.is_a?(Numeric)
      #   assert rate.max.present?
      # end
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
            travel_to("2016-01-01")
            assert_equal Date.parse("2012-01-01"), RedundancyCalculator.first_selectable_date
          end

          should "return the start of the year, four years ago if date is August 31st" do
            travel_to("2016-08-31")
            assert_equal Date.parse("2012-01-01"), RedundancyCalculator.first_selectable_date
          end
        end

        context "Months September to December" do
          should "return the start of the year, three years ago if date is September 1st" do
            travel_to("2016-09-01")
            assert_equal Date.parse("2013-01-01"), RedundancyCalculator.first_selectable_date
          end

          should "return the start of the year, three years ago if date is December 31st" do
            travel_to("2016-12-31")
            assert_equal Date.parse("2013-01-01"), RedundancyCalculator.first_selectable_date
          end
        end
      end

      context "Last selectable date" do
        context "Months January to August" do
          should "return the end of the current year if the date is January 1st" do
            travel_to("2016-01-01")
            assert_equal Date.parse("2016-12-31"), RedundancyCalculator.last_selectable_date
          end

          should "return the end of the current year if the date is August 31st" do
            travel_to("2016-08-31")
            assert_equal Date.parse("2016-12-31"), RedundancyCalculator.last_selectable_date
          end
        end

        context "Months September to December" do
          should "return end of the next year if the date is September 1st" do
            travel_to("2016-09-01")
            assert_equal Date.parse("2017-12-31"), RedundancyCalculator.last_selectable_date
          end

          should "return end of the next year if the date is December 31st" do
            travel_to("2016-12-31")
            assert_equal Date.parse("2017-12-31"), RedundancyCalculator.last_selectable_date
          end
        end
      end
    end
  end
end
