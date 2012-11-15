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

    context "use correct weekly pay and number of years limits" do
      
      # Aged 45, 12 years service, 350 per week
      should "be 4900" do
        @calculator = RedundancyCalculator.new("45", 12, 350)
        assert_equal 4900, @calculator.pay
      end

      # Aged 42, 22 years of service, 500 per week
      should "use maximum of 20 years and maximum of 430 per week" do
        @calculator = RedundancyCalculator.new("42", 22, 500)
        assert_equal 8815, @calculator.pay
      end

      should "use the maximum rate of 430 per week" do
        @calculator = RedundancyCalculator.new("41", 4, 1500)
        assert_equal 1720, @calculator.pay
      end

      should "be 1.5 times the weekly maximum for an 18 year old with 3 years service" do
        @calculator = RedundancyCalculator.new("18", 3, 500)
        assert_equal 645, @calculator.pay
        assert_equal 1.5, @calculator.number_of_weeks_entitlement
      end

      should "be 7.5 times the weekly pay for a 26 year old with 11 years service" do
        @calculator = RedundancyCalculator.new("26", 11, 250)
        assert_equal 1875, @calculator.pay
        assert_equal 7.5, @calculator.number_of_weeks_entitlement
      end

      should "be 10.5 times the weekly pay for a 32 year old with 11 years service" do
        @calculator = RedundancyCalculator.new("32", 11, 420)
        assert_equal 4410, @calculator.pay
        assert_equal 10.5, @calculator.number_of_weeks_entitlement
      end

      should "be 13.5 times the weekly pay for a 34 year old with 15 years of service" do
        @calculator = RedundancyCalculator.new("34", 15, 386)
        assert_equal 5211, @calculator.pay
        assert_equal 13.5, @calculator.number_of_weeks_entitlement
      end

      should "be 19 times the weekly pay for a 40 year old with 20 years of service" do
        @calculator = RedundancyCalculator.new("40", 20, 401)
        assert_equal 7619, @calculator.pay
        assert_equal 19, @calculator.number_of_weeks_entitlement
      end

      should "be 17.5 times the weekly pay for a 48 year old with 14 years of service" do
        @calculator = RedundancyCalculator.new("48", 14, 381)
        assert_equal 6667.5, @calculator.pay
        assert_equal 17.5, @calculator.number_of_weeks_entitlement
      end
    end
  end
end
