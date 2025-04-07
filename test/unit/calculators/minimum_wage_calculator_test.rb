require_relative "../../test_helper"

module SmartAnswer::Calculators
  class MinimumWageCalculatorTest < ActiveSupport::TestCase
    context "Initialisation" do
      should "reject invalid 'past_or_current_payment' values" do
        assert_raises(ArgumentError, "Invalid past_or_current_payment value: 'bad value'") do
          MinimumWageCalculator.new(past_or_current_payment: "bad value")
        end
      end
      should "reject missing 'past_or_current_payment' argument" do
        assert_raises(ArgumentError, "Missing past_or_current_payment argument") do
          MinimumWageCalculator.new
        end
      end
    end

    context "Any tax year validation" do
      setup do
        @calculator = MinimumWageCalculator.new(past_or_current_payment: "current_payment")
      end

      context "for age" do
        should "not accept ages less than or equal to 0" do
          assert_not @calculator.valid_age?(0)
        end

        should "not accept ages greater than 200" do
          assert_not @calculator.valid_age?(201)
        end

        should "accept ages between 1 and 200" do
          assert @calculator.valid_age?(1)
          assert @calculator.valid_age?(200)
        end
      end

      context "for pay frequency" do
        should "not accept frequency less than 1" do
          assert_not @calculator.valid_pay_frequency?(0)
        end

        should "not accept frequency greater than 31" do
          assert_not @calculator.valid_pay_frequency?(32)
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
          assert_not @calculator.valid_hours_worked?(0)
        end

        should "not accept hours greater than 16 times the pay frequency" do
          invalid_hours = (16 * @calculator.pay_frequency) + 1
          assert_not @calculator.valid_hours_worked?(invalid_hours)
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
          assert_not @calculator.valid_accommodation_charge?(0)
        end

        should "accept 1 or more" do
          assert @calculator.valid_accommodation_charge?(1)
        end
      end

      context "for accommodation usage" do
        should "not accept days per week of less than or equal to -1" do
          assert_not @calculator.valid_accommodation_usage?(-1)
        end

        should "not accept days per week of greater than or equal to 8" do
          assert_not @calculator.valid_accommodation_usage?(8)
        end

        should "accept days per week greater than or equal to 0" do
          assert @calculator.valid_accommodation_usage?(0)
        end

        should "accept days per week less than or equal to 7" do
          assert @calculator.valid_accommodation_usage?(7)
        end
      end
    end

    context "Past tax year validation" do
      setup do
        @calculator = MinimumWageCalculator.new(past_or_current_payment: "past_payment")
      end

      context "for age for living wage" do
        should "not accept ages below 21" do
          assert_not @calculator.valid_age_for_living_wage?(20)
        end

        should "accept ages 21 or above" do
          assert @calculator.valid_age_for_living_wage?(21)
          assert @calculator.valid_age_for_living_wage?(22)
          assert @calculator.valid_age_for_living_wage?(23)
          assert @calculator.valid_age_for_living_wage?(24)
        end
      end
    end

    context "Current tax year validation" do
      setup do
        @calculator = MinimumWageCalculator.new(past_or_current_payment: "current_payment")
      end

      context "for age for living wage" do
        should "not accept ages below minimum" do
          assert_not @calculator.valid_age_for_living_wage?(20)
        end

        should "accept ages 21 or above" do
          assert @calculator.valid_age_for_living_wage?(21)
          assert @calculator.valid_age_for_living_wage?(22)
          assert @calculator.valid_age_for_living_wage?(23)
          assert @calculator.valid_age_for_living_wage?(24)
        end
      end
    end

    context "#eligible_for_living_wage?" do
      context "in the past tax year" do
        should "return true if the age is the minimum for the living wage or higher" do
          %w[23 24].each do |age|
            @calculator = MinimumWageCalculator.new(past_or_current_payment: "past_payment")
            @calculator.age = age
            assert @calculator.eligible_for_living_wage?
          end
        end

        should "return false if age is lower than the minimum or nil" do
          %w[nil 0 20].each do |age|
            @calculator = MinimumWageCalculator.new(past_or_current_payment: "current_payment")
            @calculator.age = age
            assert_not @calculator.eligible_for_living_wage?
          end
        end
      end

      context "in the current tax year" do
        should "return true if the age is the minimum for the living wage or higher" do
          %w[21 22].each do |age|
            @calculator = MinimumWageCalculator.new(past_or_current_payment: "current_payment")
            @calculator.age = age
            assert @calculator.eligible_for_living_wage?
          end
        end

        should "return false if age is lower than the minimum or nil" do
          %w[nil 0 20].each do |age|
            @calculator = MinimumWageCalculator.new(past_or_current_payment: "current_payment")
            @calculator.age = age
            assert_not @calculator.eligible_for_living_wage?
          end
        end
      end
    end

    context "#under_school_leaving_age?" do
      setup do
        @calculator = MinimumWageCalculator.new(past_or_current_payment: "current_payment")
      end

      should "return true if age is lower than 16" do
        @calculator.age = 15
        assert @calculator.under_school_leaving_age?
      end

      should "return false if age is greater than or equal to 16" do
        @calculator.age = 16
        assert_not @calculator.under_school_leaving_age?
      end
    end

    context "MinimumWageCalculator" do
      setup do
        @age = 19
        @basic_pay = 187.46
        @basic_hours = 39
        @calculator = MinimumWageCalculator.new(
          age: @age,
          basic_pay: @basic_pay,
          basic_hours: @basic_hours,
          past_or_current_payment: "current_payment",
        )
      end

      context "compare basic_pay_check and @basic_pay" do
        should "be the same " do
          assert_equal @basic_pay, @calculator.basic_total
        end
      end

      context "minimum hourly rate" do
        should "be the minimum wage per hour for the age and year" do
          assert_equal 10.00, @calculator.minimum_hourly_rate
        end
        context "when eligible for living wage?" do
          should "return the national living wage rate" do
            @calculator = MinimumWageCalculator.new(age: 25, past_or_current_payment: "past_payment")
            assert_equal 11.44, @calculator.minimum_hourly_rate
          end
        end
      end

      context "total hours" do
        should "be basic" do
          assert_equal 39, @calculator.total_hours
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
          assert_not @calculator.minimum_wage_or_above?
        end

        should "be above if the average hourly rate is above the minimum hourly rate" do
          @calculator.basic_pay = 400
          @calculator.basic_hours = 39
          assert @calculator.minimum_wage_or_above?
        end
      end

      context "adjustment for accommodation" do
        setup do
          @calculator.accommodation_adjustment(12.00, 4)
        end

        should "calculate the accommodation cost" do
          expected = ((10.66 * 4) - (12.00 * 4)).round(2) * 1
          assert_equal(expected, @calculator.accommodation_cost)
        end

        should "be included in the total pay calculation" do
          expected = ((@basic_pay / @basic_hours) * @basic_hours + @calculator.accommodation_cost).round(2)
          assert_equal expected, @calculator.total_pay
        end
      end

      context "historical entitlement" do
        should "be minimum wage for the year multiplied by total hours" do
          assert_equal 390.0, @calculator.historical_entitlement
        end
      end

      # Test cases from the Minimum National Wage docs.
      # for various scenarios.
      #
      # Scenario 1
      context "minimum wage calculator for a 24 yr old low hourly rate" do
        setup do
          @calculator = MinimumWageCalculator.new(
            age: 24,
            pay_frequency: 7,
            basic_pay: 168,
            basic_hours: 40,
            past_or_current_payment: "current_payment",
          )
        end

        should "have a minimum hourly rate of 12.21" do
          assert_equal 12.21, @calculator.minimum_hourly_rate
        end
      end

      # Scenario 2
      context "minimum wage calculator for a 23 yr old working 70 hours over a fortnight" do
        setup do
          @calculator = MinimumWageCalculator.new(
            age: 23,
            pay_frequency: 14,
            basic_pay: 420,
            basic_hours: 70,
            past_or_current_payment: "past_payment",
          )
        end

        should "calculate minimum hourly rate" do
          assert_equal 11.44, @calculator.minimum_hourly_rate
        end
      end

      # Scenario 3
      context "24 y/o with a low hourly rate" do
        setup do
          @calculator = MinimumWageCalculator.new(
            age: 24,
            past_or_current_payment: "current_payment",
            pay_frequency: 7,
            basic_pay: 100,
            basic_hours: 40,
          )
        end

        should "calculate total hourly rate" do
          assert_equal 12.21, @calculator.minimum_hourly_rate
          assert_not @calculator.minimum_wage_or_above?, "should be below the minimum wage"
        end

        should "adjust for free accommodation" do
          @calculator.accommodation_adjustment(0, 5)
          assert_equal 53.30, @calculator.accommodation_cost
          assert_not @calculator.minimum_wage_or_above?, "should be below the minimum wage"
        end

        should "adjust for accommodation charged above the threshold" do
          @calculator.accommodation_adjustment(12, 5)
          assert_equal(-6.70, @calculator.accommodation_cost)
          assert_not @calculator.minimum_wage_or_above?, "should be below the minimum wage"
        end

        should "adjust for accommodation charged below the threshold" do
          @calculator.accommodation_adjustment(8, 5)
          assert_equal 0, @calculator.accommodation_cost
          assert_not @calculator.minimum_wage_or_above?, "should be below the minimum wage"
        end
      end
    end

    context "per hour minimum wage" do
      context "for current tax year" do
        setup do
          @calculator = MinimumWageCalculator.new(past_or_current_payment: "current_payment")
        end

        should "be correct for those under 18" do
          [0, 17].each do |age|
            @calculator.age = age
            assert_equal 7.55, @calculator.per_hour_minimum_wage
          end
        end

        should "be correct for 18 to 20 year olds" do
          [18, 20].each do |age|
            @calculator.age = age
            assert_equal 10.0, @calculator.per_hour_minimum_wage
          end
        end

        should "be correct for 21 to 22 year olds" do
          [21, 22].each do |age|
            @calculator.age = age
            assert_equal 12.21, @calculator.per_hour_minimum_wage
          end
        end

        should "be correct for those aged 23 and over" do
          [23, 100].each do |age|
            @calculator.age = age
            assert_equal 12.21, @calculator.per_hour_minimum_wage
          end
        end

        should "have correct apprentice rate" do
          assert_equal 7.55, @calculator.apprentice_rate
        end

        should "have correct accommodation rate" do
          assert_equal 10.66, @calculator.free_accommodation_rate
        end
      end
    end

    context "accommodation adjustment" do
      setup do
        @calculator = MinimumWageCalculator.new age: 22, past_or_current_payment: "past_payment"
      end
      should "return 0 for accommodation charged under the threshold" do
        assert_equal 0, @calculator.accommodation_adjustment("3.50", 5)
      end
      should "return the number of nights times the threshold if the accommodation is free" do
        assert_equal((9.99 * 4), @calculator.accommodation_adjustment("0", 4))
      end
      should "subtract the charged fee from the free fee where the accommodation costs more than the threshold" do
        charge = 10.90
        number_of_nights = 5
        free_adjustment = (9.99 * number_of_nights).round(2)
        charged_adjustment = @calculator.accommodation_adjustment(charge, number_of_nights)
        assert_equal((free_adjustment - (charge * number_of_nights)).round(2), charged_adjustment)
        assert charged_adjustment.negative? # this should always be less than zero
      end
    end

    context "total_pay and basic_rate calculations" do
      should "[with accommodation_adjustment] return rate total" do
        @calculator = MinimumWageCalculator.new(
          age: 25,
          pay_frequency: 5,
          basic_pay: 260,
          basic_hours: 40,
          past_or_current_payment: "current_payment",
        )
        @calculator.accommodation_adjustment(20, 4)
        assert_equal 233.32, @calculator.total_pay
      end
    end

    context "non-historical minimum wage" do
      should "return today's minimum wage rate for 24 year old" do
        @calculator = MinimumWageCalculator.new(
          age: 24,
          pay_frequency: 7,
          basic_pay: 312,
          basic_hours: 39,
          past_or_current_payment: "current_payment",
        )
        assert_equal 12.21, @calculator.minimum_hourly_rate
      end
      should "return today's minimum wage rate for 19 year old" do
        @calculator = MinimumWageCalculator.new(
          age: 19,
          pay_frequency: 7,
          basic_pay: 312,
          basic_hours: 39,
          past_or_current_payment: "current_payment",
        )
        assert_equal 10.0, @calculator.minimum_hourly_rate
      end
      should "return today's minimum wage rate for 17 year old" do
        @calculator = MinimumWageCalculator.new(
          age: 17,
          pay_frequency: 7,
          basic_pay: 312,
          basic_hours: 39,
          past_or_current_payment: "current_payment",
        )
        assert_equal 7.55, @calculator.minimum_hourly_rate
      end
    end

    context "non-historical total entitlement and underpayment test" do
      setup do
        @calculator = MinimumWageCalculator.new(
          age: 24,
          pay_frequency: 7,
          basic_pay: 100,
          basic_hours: 39,
          past_or_current_payment: "current_payment",
        )
      end
      should "return total_entitlement" do
        assert_equal 476.19, @calculator.total_entitlement
      end
      should "return total_underpayment" do
        assert_equal 100.0, @calculator.total_pay
      end
      should "return total_underpayment as 0.0" do
        @calculator = MinimumWageCalculator.new(
          age: 25,
          pay_frequency: 7,
          basic_pay: 300,
          basic_hours: 39,
          past_or_current_payment: "current_payment",
        )
        assert_equal 300.0, @calculator.total_pay
      end
    end
  end
end
