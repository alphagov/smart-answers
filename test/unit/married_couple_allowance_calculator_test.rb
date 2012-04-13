require_relative '../test_helper'

module SmartAnswer
  class MarriedCouplesAllowanceCalculatorTest < ActiveSupport::TestCase

    test  "maximum allowance when low annual income" do
      calculator = MarriedCouplesAllowanceCalculator.new()
      result = calculator.calculate_allowance(400)
      assert_equal Money.new("729.5"), result
    end

    test  "minimum allowance when high annual income" do
      calculator = MarriedCouplesAllowanceCalculator.new()
      result = calculator.calculate_allowance(50000)
      assert_equal Money.new("280"), result
    end

    test  "maximum allowance of personal entitlement when medium but not over income limit" do
      calculator = MarriedCouplesAllowanceCalculator.new()
      #to do
      result = calculator.calculate_allowance(40000)
      assert_equal Money.new("729.5"), result
    end


    test  "10% of personal entitlement when medium" do
      calculator = MarriedCouplesAllowanceCalculator.new()
      result = calculator.calculate_allowance(30000)
      assert_equal Money.new("691"), result
    end

  end
end
