require_relative '../test_helper'

module SmartAnswer
  class MarriedCouplesAllowanceCalculatorTest < ActiveSupport::TestCase

    test  "maximum allowance when low annual income" do
      calculator = MarriedCouplesAllowanceCalculator.new()
      result = calculator.calculate_allowance(400)
      assert_equal Money.new("770.5"), result
    end

    test  "minimum allowance when high annual income" do
      calculator = MarriedCouplesAllowanceCalculator.new()
      result = calculator.calculate_allowance(50000)
      assert_equal Money.new("296"), result
    end

    test  "worked example on HMRC site" do
      calculator = MarriedCouplesAllowanceCalculator.new()
      result = calculator.calculate_allowance(31500)
      assert_equal Money.new("721"), result
    end

  end
end
