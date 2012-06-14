require_relative "../../test_helper"
require "smart_answer/calculators/minimum_wage_calculator"

module SmartAnswer
  class MinimumWageCalculatorTest < ActiveSupport::TestCase
    def setup
      @calculator = MinimumWageCalculator.new
    end

    test "should per hour calculate minimum wage for those aged 21 or over" do
      assert_equal @calculator.calculate("per_hour", "21_or_over", "120"), "729.60"
      assert_equal @calculator.calculate("per_hour", "21_or_over", "20"), "121.60"
    end

    test "should per hour calculate minimum wage for those aged 18 to 20" do
      assert_equal @calculator.calculate("per_hour", "18_to_20", "120"), "597.60"
      assert_equal @calculator.calculate("per_hour", "18_to_20", "20"), "99.60"
    end

    test "should calculate per hour minimum wage for those aged under 18" do
      assert_equal @calculator.calculate("per_hour", "under_18", "120"), "441.60"
      assert_equal @calculator.calculate("per_hour", "under_18", "20"), "73.60"
    end

    test "should calculate per hour minimum wage for apprentices aged under 19" do
      assert_equal @calculator.calculate("per_hour", "under_19", "120"), "312.00"
      assert_equal @calculator.calculate("per_hour", "under_19", "20"), "52.00"
    end
  end
end