require_relative "../../test_helper"

module SmartAnswer::Calculators
  class StatePensionAmountCalculatorTest < ActiveSupport::TestCase
    context "male, born 5th April 1945, 45 qualifying years" do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "male", dob: "1945-04-05", qualifying_years: "45")
      end

      should "be 109.89 for what_you_get" do
        assert_equal 107.45, @calculator.what_you_get
      end

      should "be 90.39 for you_get_future" do
        assert_equal 90.39, @calculator.you_get_future
      end
    end
  end
end
