require_relative "../../test_helper"

module SmartAnswer::Calculators
  class MinimumWageCalculatorTest < ActiveSupport::TestCase
    context "Validation" do
      setup do
        @calculator = MinimumWageCalculator.new
      end

      context "for age" do
        should "not accept ages less than or equal to 0" do
          refute @calculator.valid_age?(0)
        end

        should "not accept ages greater than 200" do
          refute @calculator.valid_age?(201)
        end

        should "accept ages between 1 and 200" do
          assert @calculator.valid_age?(1)
          assert @calculator.valid_age?(200)
        end
      end

      context "for pay frequency" do
        should "not accept frequency less than 1" do
          refute @calculator.valid_pay_frequency?(0)
        end

        should "not accept frequency greater than 31" do
          refute @calculator.valid_pay_frequency?(32)
        end

        should "accept frequency between 1 and 31" do
          assert @calculator.valid_pay_frequency?(1)
          assert @calculator.valid_pay_frequency?(31)
        end
      end

      context "for hours worked" do
        setup do
          @calculator.pay_frequency = 1
        end

        should "not accept hours less than 0" do
          refute @calculator.valid_hours_worked?(0)
        end

        should "not accept hours greater than 16 times the pay frequency" do
          invalid_hours = (16 * @calculator.pay_frequency) + 1
          refute @calculator.valid_hours_worked?(invalid_hours)
        end

        should "accept hours greater than or equal to 1" do
          assert @calculator.valid_hours_worked?(1)
        end

        should "accept hours less than or equal to 16 times the pay frequency" do
          valid_hours = 16 * @calculator.pay_frequency
          assert @calculator.valid_hours_worked?(valid_hours)
        end
      end

      context "for accommodation charge" do
        should "not accept amount less than or equal to 0" do
          refute @calculator.valid_accommodation_charge?(0)
        end

        should "accept 1 or more" do
          assert @calculator.valid_accommodation_charge?(1)
        end
      end

      context "for accommodation usage" do
        should "not accept days per week of less than or equal to -1" do
          refute @calculator.valid_accommodation_usage?(-1)
        end

        should "not accept days per week of greater than or equal to 8" do
          refute @calculator.valid_accommodation_usage?(8)
        end

        should "accept days per week greater than or equal to 0" do
          assert @calculator.valid_accommodation_usage?(0)
        end

        should "accept days per week less than or equal to 7" do
          assert @calculator.valid_accommodation_usage?(7)
        end
      end

      context "for age for living wage" do
        should "not accept ages below 25" do
          refute @calculator.valid_age_for_living_wage?(24)
        end

        should "accept ages 25 or above" do
          assert @calculator.valid_age_for_living_wage?(25)
          assert @calculator.valid_age_for_living_wage?(26)
        end
      end
    end

    context "#national_living_wage" do
      setup do
        @calculator = MinimumWageCalculator.new
      end

      should "return the national living wage" do
        @calculator.stubs(:minimum_hourly_rate).returns(99)
        assert_equal 99, @calculator.national_living_wage_rate
      end
    end

    context "#eligible_for_living_wage?" do
      setup do
        @calculator = MinimumWageCalculator.new
      end

      should "return true if the age is 25 or over" do
        %w(25 26).each do |age|
          @calculator.age = age
          assert @calculator.eligible_for_living_wage?
        end
      end

      should "return false if age is lower than 24 or nil" do
        %w(nil 0 24).each do |age|
          @calculator.age = age
          refute @calculator.eligible_for_living_wage?
        end
      end

      should "return false if age is over 25, and date is on or before 2016-04-01" do
        @calculator.date = Date.parse("2016-03-30")
        @calculator.age = 26
        assert !@calculator.eligible_for_living_wage?
      end
    end

    context "#under_school_leaving_age?" do
      setup do
        @calculator = MinimumWageCalculator.new
      end

      should "return true if age is lower than 16" do
        @calculator.age = 15
        assert @calculator.under_school_leaving_age?
      end

      should "return false if age is greater than or equal to 16" do
        @calculator.age = 16
        refute @calculator.under_school_leaving_age?
      end
    end

    context "#historically_receiving_minimum_wage?" do
      setup do
        @calculator = MinimumWageCalculator.new
      end

      should "return true if the historical adjustment is less than or equal to 0" do
        @calculator.stubs(:historical_adjustment).returns(0)
        assert @calculator.historically_receiving_minimum_wage?
      end

      should "return false if the historical adjustment is greater than 0" do
        @calculator.stubs(:historical_adjustment).returns(1)
        refute @calculator.historically_receiving_minimum_wage?
      end
    end

    context "MinimumWageCalculator" do
      setup do
        @age = 19
        @basic_pay = 187.46
        @basic_hours = 39
        @calculator = MinimumWageCalculator.new(
          age: @age,
          date: Date.parse("2010-10-01"),
          basic_pay: @basic_pay,
          basic_hours: @basic_hours,
        )
      end

      context "compare basic_pay_check and @basic_pay" do
        should "be the same " do
          assert_equal @basic_pay, @calculator.basic_total
        end
      end

      context "basic hourly rate" do
        should "be basic pay divided by basic hours" do
          assert_equal 4.81, @calculator.basic_hourly_rate
        end
      end

      context "minimum hourly rate" do
        should "be the minimum wage per hour for the age and year" do
          assert_equal 4.92, @calculator.minimum_hourly_rate
        end
        context "when eligible for living wage?" do
          should "return the national living wage rate" do
            @calculator = MinimumWageCalculator.new(age: 25, date: Date.parse("2016-04-02"))
            assert_equal 7.2, @calculator.minimum_hourly_rate
          end
        end
      end

      context "total hours" do
        should "be basic" do
          assert_equal 39, @calculator.total_hours
        end
      end

      context "total hourly rate" do
        should "calculate the total pay divided by total hours" do
          assert_equal 4.81, @calculator.total_hourly_rate
        end
        should "be zero if 0 or less hours are entered" do
          @calculator = MinimumWageCalculator.new age: @age, date: Date.parse("2010-10-01"), basic_pay: @basic_pay, basic_hours: 0
          assert_equal 0, @calculator.total_hourly_rate
        end
      end

      context "total pay" do
        should "calculate the basic pay plus the accomodation cost" do
          @calculator.accommodation_cost = 100
          assert_equal 287.46, @calculator.total_pay
        end
      end

      context "above minimum wage?" do
        should "indicate if the minimum hourly rate is less than the total hourly rate" do
          assert !@calculator.minimum_wage_or_above?
        end

        should "be above if the average hourly rate is above the minimum hourly rate" do
          @calculator.basic_pay = 400
          @calculator.basic_hours = 39
          assert @calculator.minimum_wage_or_above?
        end
      end

      context "adjust for accommodation" do
        setup do
          @calculator.accommodation_adjustment(7.99, 4)
        end

        should "calculate the accommodation cost" do
          assert_equal(-13.52, @calculator.accommodation_cost)
        end

        should "be included the total pay calculation" do
          assert_equal 173.94, @calculator.total_pay
        end
      end

      context "historical entitlement" do
        setup do
          @historical_entitlement = 191.88
        end
        should "be minimum wage for the year multiplied by total hours" do
          assert_equal @historical_entitlement, @calculator.historical_entitlement
        end

        context "underpayment" do
          setup do
            @underpayment = (191.88 - @calculator.basic_total).round(2)
          end
          should "be the total pay minus the historical entitlement" do
            assert_equal @underpayment, @calculator.underpayment
          end

          context "historical_adjustment" do
            setup do
              @underpayment = (@underpayment * -1) if @underpayment.negative?
              @historical_adjustment = ((@underpayment / 4.92) * @calculator.per_hour_minimum_wage(Date.today)).round(2)
            end

            should "be underpayment divided by the historical minimum hourly rate times the current minimum hourly rate" do
              assert_equal @historical_adjustment, @calculator.historical_adjustment
            end
          end
        end
      end

      # Test cases from the Minimum National Wage docs.
      # for various scenarios.
      #
      # Scenario 1
      context "minimum wage calculator for a 24 yr old low hourly rate" do
        setup do
          # NOTE: test_date included as all minimum wage calculations are date sensitive
          test_date = Date.parse("2012-08-01")
          @calculator = MinimumWageCalculator.new(
            age: 24,
            pay_frequency: 7,
            basic_pay: 168,
            basic_hours: 40,
            date: test_date,
          )
        end

        should "have a total hourly rate of 4.20" do
          assert_equal 6.08, @calculator.minimum_hourly_rate
          assert_equal 4.2, @calculator.basic_hourly_rate
          assert_equal 4.2, @calculator.total_hourly_rate
        end
      end

      # Scenario 2
      context "minimum wage calculator for a 23 yr old working 70 hours over a fortnight after 01/10/2012" do
        setup do
          @calculator = MinimumWageCalculator.new(
            age: 23,
            pay_frequency: 14,
            date: Date.parse("2012-10-01"),
            basic_pay: 420,
            basic_hours: 70,
          )
        end

        should "calculate total hourly rate" do
          assert_equal 6.19, @calculator.minimum_hourly_rate
          assert_equal 6, @calculator.total_hourly_rate
        end
      end

      # Scenario 3
      context "24 y/o with a low hourly rate" do
        setup do
          @calculator = MinimumWageCalculator.new(
            age: 24,
            date: Date.parse("2011-10-01"),
            pay_frequency: 7,
            basic_pay: 100,
            basic_hours: 40,
          )
        end

        should "calculate total hourly rate" do
          assert_equal 6.08, @calculator.minimum_hourly_rate
          assert_equal 2.5, @calculator.basic_hourly_rate
          assert_equal 2.5, @calculator.total_hourly_rate
          assert !@calculator.minimum_wage_or_above?, "should be below the minimum wage"
        end

        should "adjust for free accommodation" do
          @calculator.accommodation_adjustment(0, 5)
          assert_equal 23.65, @calculator.accommodation_cost
          assert_equal 3.09, @calculator.total_hourly_rate
          assert !@calculator.minimum_wage_or_above?, "should be below the minimum wage"
        end

        should "adjust for accommodation charged above the threshold" do
          @calculator.accommodation_adjustment(6, 5)
          assert_equal(-6.35, @calculator.accommodation_cost)
          assert_equal 2.34, @calculator.total_hourly_rate
          assert !@calculator.minimum_wage_or_above?, "should be below the minimum wage"
        end

        should "adjust for accommodation charged below the threshold" do
          @calculator.accommodation_adjustment(4, 5)
          assert_equal 0, @calculator.accommodation_cost
          assert_equal 2.50, @calculator.total_hourly_rate
          assert !@calculator.minimum_wage_or_above?, "should be below the minimum wage"
        end
      end
    end
    # Test URL: /am-i-getting-minimum-wage/y/past_payment/2010-10-01/apprentice_under_19/7/35/78.0/0/no
    context "Historical adjustment for apprentices (hours:35, pay:78)" do
      setup do
        Timecop.travel(Date.parse("30 Sep 2013"))
      end
      should "equal 10.07 historical adjustment" do
        @calculator = MinimumWageCalculator.new(
          age: 0,
          date: Date.parse("1 November 2010"),
          pay_frequency: 7,
          basic_hours: 35,
          basic_pay: 78,
          is_apprentice: true,
        )
        assert_equal 2.50, @calculator.minimum_hourly_rate
        assert_equal 2.23, @calculator.total_hourly_rate
        assert_equal 10.07, @calculator.historical_adjustment
      end
    end

    context "per hour minimum wage" do
      should "give the minimum wage for this year (2011-2012) for a given age" do
        test_date = Date.parse("2012-08-01")
        @calculator = MinimumWageCalculator.new age: 17, date: test_date
        assert_equal 3.68, @calculator.per_hour_minimum_wage
        @calculator = MinimumWageCalculator.new age: 21, date: test_date
        assert_equal 6.08, @calculator.per_hour_minimum_wage
      end
      should "give the historical minimum wage" do
        @calculator = MinimumWageCalculator.new age: 17, date: Date.parse("2010-10-01")
        assert_equal 3.64, @calculator.per_hour_minimum_wage
        @calculator = MinimumWageCalculator.new age: 18, date: Date.parse("2010-10-01")
        assert_equal 4.92, @calculator.per_hour_minimum_wage
      end
      should "account for the 18-22 age range before 2010" do
        @calculator = MinimumWageCalculator.new age: 21, date: Date.parse("2009-10-01")
        assert_equal 4.83, @calculator.per_hour_minimum_wage
        @calculator = MinimumWageCalculator.new age: 22, date: Date.parse("2009-10-01")
        assert_equal 5.8, @calculator.per_hour_minimum_wage
      end

      context "from 1 Oct 2013" do
        setup do
          @calculator = MinimumWageCalculator.new(date: Date.parse("2013-10-01"))
        end

        should "be 3.72 for people aged under 18" do
          [0, 17].each do |age|
            @calculator.age = age
            assert_equal 3.72, @calculator.per_hour_minimum_wage
          end
        end

        should "be 5.03 for people aged between 18 and 20" do
          [18, 20].each do |age|
            @calculator.age = age
            assert_equal 5.03, @calculator.per_hour_minimum_wage
          end
        end

        should "be 6.31 for people aged over 25" do
          [25, 999].each do |age|
            @calculator.age = age
            assert_equal 6.31, @calculator.per_hour_minimum_wage
          end
        end

        should "have an apprentice rate of 2.68" do
          assert_equal 2.68, @calculator.apprentice_rate
        end

        should "have an accommodation rate of 4.91" do
          assert_equal 4.91, @calculator.free_accommodation_rate
        end
      end

      context "from 1 Oct 2014" do
        setup do
          @calculator = MinimumWageCalculator.new(date: Date.parse("2014-10-01"))
        end

        should "be 3.79 for people aged under 18" do
          [0, 17].each do |age|
            @calculator.age = age
            assert_equal 3.79, @calculator.per_hour_minimum_wage
          end
        end

        should "be 5.13 for people aged between 18 and 20" do
          [18, 20].each do |age|
            @calculator.age = age
            assert_equal 5.13, @calculator.per_hour_minimum_wage
          end
        end

        should "be 6.50 for people aged over 25" do
          [25, 999].each do |age|
            @calculator.age = age
            assert_equal 6.50, @calculator.per_hour_minimum_wage
          end
        end

        should "have an apprentice rate of 3.40" do
          assert_equal 2.73, @calculator.apprentice_rate
        end

        should "have an accommodation rate of 5.08" do
          assert_equal 5.08, @calculator.free_accommodation_rate
        end
      end

      context "from 1 Oct 2015" do
        setup do
          @calculator = MinimumWageCalculator.new(date: Date.parse("2015-10-01"))
        end

        should "be 3.87 for people aged under 18" do
          [0, 17].each do |age|
            @calculator.age = age
            assert_equal 3.87, @calculator.per_hour_minimum_wage
          end
        end

        should "be 5.30 for people aged between 18 and 20" do
          [18, 20].each do |age|
            @calculator.age = age
            assert_equal 5.30, @calculator.per_hour_minimum_wage
          end
        end

        should "be 6.70 for people aged over 25" do
          [25, 999].each do |age|
            @calculator.age = age
            assert_equal 6.70, @calculator.per_hour_minimum_wage
          end
        end

        should "have an apprentice rate of 3.30" do
          assert_equal 3.30, @calculator.apprentice_rate
        end

        should "have an accommodation rate of 5.35" do
          assert_equal 5.35, @calculator.free_accommodation_rate
        end
      end

      context "from 1 Apr 2016" do
        setup do
          @calculator = MinimumWageCalculator.new(date: Date.parse("2016-04-01"))
        end

        should "be 3.87 for people aged under 18" do
          [0, 17].each do |age|
            @calculator.age = age
            assert_equal 3.87, @calculator.per_hour_minimum_wage
          end
        end

        should "be 5.30 for people aged between 18 and 20" do
          [18, 20].each do |age|
            @calculator.age = age
            assert_equal 5.30, @calculator.per_hour_minimum_wage
          end
        end

        should "be 6.70 for people aged between 21 and 24" do
          [21, 24].each do |age|
            @calculator.age = age
            assert_equal 6.70, @calculator.per_hour_minimum_wage
          end
        end

        should "be 7.20 for people aged over 25" do
          [25, 999].each do |age|
            @calculator.age = age
            assert_equal 7.20, @calculator.per_hour_minimum_wage
          end
        end

        should "have an apprentice rate of 3.30" do
          assert_equal 3.30, @calculator.apprentice_rate
        end

        should "have an accommodation rate of 5.35" do
          assert_equal 5.35, @calculator.free_accommodation_rate
        end
      end

      context "from 1 Oct 2016" do
        setup do
          @calculator = MinimumWageCalculator.new(date: Date.parse("2016-10-02"))
        end

        should "be 4.00 for people aged under 18" do
          [0, 17].each do |age|
            @calculator.age = age
            assert_equal 4.00, @calculator.per_hour_minimum_wage
          end
        end

        should "be 5.55 for people aged between 18 and 20" do
          [18, 20].each do |age|
            @calculator.age = age
            assert_equal 5.55, @calculator.per_hour_minimum_wage
          end
        end

        should "be 6.95 for people aged between 21 and 24" do
          [21, 24].each do |age|
            @calculator.age = age
            assert_equal 6.95, @calculator.per_hour_minimum_wage
          end
        end

        should "be 7.20 for people aged over 25" do
          [25, 999].each do |age|
            @calculator.age = age
            assert_equal 7.20, @calculator.per_hour_minimum_wage
          end
        end

        should "have an apprentice rate of 3.40" do
          assert_equal 3.40, @calculator.apprentice_rate
        end

        should "have an accommodation rate of 6.0" do
          assert_equal 6.00, @calculator.free_accommodation_rate
        end
      end
    end

    context "accommodation adjustment" do
      setup do
        # NOTE: test_date must be included as results are date sensitive
        test_date = Date.parse("2012-08-01")
        @calculator = MinimumWageCalculator.new age: 22, date: test_date
      end
      should "return 0 for accommodation charged under the threshold" do
        assert_equal 0, @calculator.accommodation_adjustment("3.50", 5)
      end
      should "return the number of nights times the threshold if the accommodation is free" do
        assert_equal((4.73 * 4), @calculator.accommodation_adjustment("0", 4))
      end
      should "subtract the charged fee from the free fee where the accommodation costs more than the threshold" do
        charge = 10.12
        number_of_nights = 5
        free_adjustment = (4.73 * number_of_nights).round(2)
        charged_adjustment = @calculator.accommodation_adjustment(charge, number_of_nights)
        assert_equal((free_adjustment - (charge * number_of_nights)).round(2), charged_adjustment)
        assert charged_adjustment.negative? # this should always be less than zero
      end
    end

    context "total_pay and basic_rate calculations" do
      setup do
        @calculator = MinimumWageCalculator.new(
          age: 25,
          pay_frequency: 5,
          basic_pay: 260,
          basic_hours: 40,
        )
      end

      context "test date sensitive vars" do
        setup do
          test_date = Date.parse("2012-08-01")
          @calculator = MinimumWageCalculator.new(
            age: 25,
            pay_frequency: 5,
            basic_pay: 260,
            basic_hours: 40,
            date: test_date,
          )
        end

        should "[with accommodation_adjustment] return rate total (216.39)" do
          @calculator.accommodation_adjustment(20, 4)
          assert_equal 216.39, @calculator.total_pay
        end
      end
    end

    context "basic_rate tests" do
      setup do
        @calculator = MinimumWageCalculator.new(
          age: 25,
          pay_frequency: 5,
          basic_pay: 312,
          basic_hours: 39,
        )
      end
      should "basic_rate = 8" do
        assert_equal 8, @calculator.basic_hourly_rate
      end
    end

    context "non-historical minimum wage" do
      should "return today's minimum wage rate for 25 year old" do
        @calculator = MinimumWageCalculator.new(
          age: 24,
          pay_frequency: 7,
          basic_pay: 312,
          basic_hours: 39,
          date: Date.parse("5 Aug 2012"),
        )
        assert_equal 6.08, @calculator.minimum_hourly_rate
      end
      should "return today's minimum wage rate for 19 year old" do
        @calculator = MinimumWageCalculator.new(
          age: 19,
          pay_frequency: 7,
          basic_pay: 312,
          basic_hours: 39,
          date: Date.parse("5 Aug 2012"),
        )
        assert_equal 4.98, @calculator.minimum_hourly_rate
      end
      should "return today's minimum wage rate for 17 year old" do
        @calculator = MinimumWageCalculator.new(
          age: 17,
          pay_frequency: 7,
          basic_pay: 312,
          basic_hours: 39,
          date: Date.parse("5 Aug 2012"),
        )
        assert_equal 3.68, @calculator.minimum_hourly_rate
      end
    end

    context "non-historical total entitlement and underpayment test" do
      setup do
        @calculator = MinimumWageCalculator.new(
          age: 24,
          pay_frequency: 7,
          basic_pay: 100,
          basic_hours: 39,
          date: Date.parse("5 Aug 2012"),
        )
      end
      should "return total_entitlement" do
        assert_equal 237.12, @calculator.total_entitlement
      end
      should "return total_underpayment" do
        assert_equal 100.0, @calculator.total_pay
        assert_equal 137.12, @calculator.total_underpayment
      end
      should "return total_underpayment as 0.0" do
        @calculator = MinimumWageCalculator.new(
          age: 25,
          pay_frequency: 7,
          basic_pay: 300,
          basic_hours: 39,
          date: Date.parse("5 Aug 2012"),
        )
        assert_equal 300.0, @calculator.total_pay
        assert_equal 0.0, @calculator.total_underpayment
      end
    end

    context "historical below minimum wage" do
      setup do
        Timecop.travel(Date.parse("2012-10-09"))
      end
      should "return false to minimum_wage_or_above?" do
        @calculator = MinimumWageCalculator.new(
          age: 25,
          pay_frequency: 7,
          basic_pay: 100,
          basic_hours: 39,
          date: Date.parse("5 Aug 2010"),
        )
        assert !@calculator.minimum_wage_or_above?
      end
      should "below minimum_wage_or_above (200)" do
        @calculator = MinimumWageCalculator.new(
          age: 24,
          pay_frequency: 7,
          basic_pay: 200,
          basic_hours: 40,
          date: Date.parse("5 Aug 2010"),
        )
        # underpayment
        assert !@calculator.minimum_wage_or_above?
        assert_equal 32, @calculator.underpayment
        assert_equal 5.52, (@calculator.underpayment / @calculator.per_hour_minimum_wage).round(2)
        assert_equal 6.19, @calculator.per_hour_minimum_wage(Date.today)
        assert_equal 34.15, @calculator.historical_adjustment
        # assert_equal 43.20, @calculator.total_underpayment
      end

      # Test URL: /am-i-getting-minimum-wage/y/past_payment/2007-10-01/no/25/7/40/100.0/0/no
      should "historical_adjustment test: hours: 40; pay: 100; date: 5 Aug 2008" do
        @calculator = MinimumWageCalculator.new(
          age: 24,
          pay_frequency: 7,
          basic_pay: 100,
          basic_hours: 40,
          date: Date.parse("5 Aug 2008"),
        )
        # underpayment
        assert_equal 5.52, @calculator.minimum_hourly_rate
        assert_equal 2.5, @calculator.total_hourly_rate
        assert_equal 135.46, @calculator.historical_adjustment
      end

      # Test URL: /am-i-getting-minimum-wage/y/past_payment/2008-10-01/no/25/7/40/100.0/0/no
      should "historical_adjustment test: hours: 40; pay: 100; date: 5 Aug 2009" do
        @calculator = MinimumWageCalculator.new(
          age: 24,
          pay_frequency: 7,
          basic_pay: 100,
          basic_hours: 40,
          date: Date.parse("5 Aug 2009"),
        )
        # underpayment
        assert_equal 5.73, @calculator.minimum_hourly_rate
        assert_equal 2.5, @calculator.total_hourly_rate
        assert_equal 139.57, @calculator.historical_adjustment
      end

      # Test URL: /am-i-getting-minimum-wage/y/past_payment/2008-10-01/no/25/7/40/40.0/0/no
      should "historical_adjustment test: hours: 40; pay: 40" do
        @calculator = MinimumWageCalculator.new(
          age: 24,
          pay_frequency: 7,
          basic_pay: 40,
          basic_hours: 40,
          date: Date.parse("5 Aug 2009"),
        )
        # underpayment
        assert_equal 5.73, @calculator.minimum_hourly_rate
        assert_equal 1, @calculator.total_hourly_rate
        assert_equal 204.39, @calculator.historical_adjustment
      end

      # Test URL: /am-i-getting-minimum-wage/y/past_payment/2007-10-01/no/25/28/147/741.0/0/no
      should "historical_adjustment test: hours: 147; pay: 741" do
        @calculator = MinimumWageCalculator.new(
          age: 24,
          pay_frequency: 28,
          basic_pay: 741,
          basic_hours: 147,
          date: Date.parse("5 Aug 2007"),
        )
        # underpayment
        assert_equal 5.35, @calculator.minimum_hourly_rate
        assert_equal 5.04, @calculator.total_hourly_rate
        assert_equal 52.59, @calculator.historical_adjustment
      end

      # Test URL: /am-i-getting-minimum-wage/y/past_payment/2007-10-01/no/25/28/147/696.0/0/no
      should "historical_adjustment test: hours: 147; pay: 696" do
        @calculator = MinimumWageCalculator.new(
          age: 24,
          pay_frequency: 28,
          basic_pay: 696,
          basic_hours: 147,
          date: Date.parse("5 Aug 2007"),
        )
        # underpayment
        assert_equal 5.35, @calculator.minimum_hourly_rate
        assert_equal 4.73, @calculator.total_hourly_rate
        assert_equal 104.65, @calculator.historical_adjustment
      end

      # Test URL: /am-i-getting-minimum-wage/y/past_payment/2007-10-01/no/25/28/147/661.0/0/no
      should "historical_adjustment test: hours: 147; pay: 661" do
        @calculator = MinimumWageCalculator.new(
          age: 24,
          pay_frequency: 28,
          basic_pay: 661,
          basic_hours: 147,
          date: Date.parse("5 Aug 2007"),
        )
        # underpayment
        assert_equal 5.35, @calculator.minimum_hourly_rate
        assert_equal 4.5, @calculator.total_hourly_rate
        assert_equal 145.15, @calculator.historical_adjustment
      end
    end
  end
end
