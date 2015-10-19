require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class PayLeaveForParentsCalculatorTest < ActiveSupport::TestCase
      setup do
        @due_date = Date.parse('2015-1-1')
        @calculator = SmartAnswer::Calculators::PayLeaveForParentsCalculator.new
      end

      test "continuity_start_date" do
        expected = Date.parse('2014-3-29')
        assert_equal expected, @calculator.continuity_start_date(@due_date)
      end

      test "continuity_end_date" do
        expected = Date.parse('2014-9-14')
        assert_equal expected, @calculator.continuity_end_date(@due_date)
      end
    end
  end
end
