require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class PayLeaveForParentsCalculatorTest < ActiveSupport::TestCase
      test "continuity_start_date" do
        due_date = Date.parse('2015-1-1')
        expected = Date.parse('2014-3-29')
        calculator = SmartAnswer::Calculators::PayLeaveForParentsCalculator.new
        assert_equal expected, calculator.continuity_start_date(due_date)
      end
    end
  end
end
