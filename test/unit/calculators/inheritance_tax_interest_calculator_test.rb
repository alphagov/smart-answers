require_relative "../../test_helper"

module SmartAnswer::Calculators
  class InheritanceTaxInterestCalculatorTest < ActiveSupport::TestCase
    def setup
      @calculator = SmartAnswer::Calculators::InheritanceTaxInterestCalculator.new(
        start_date: nil,
        end_date: nil,
        inheritance_tax_owed: 10_000,
      )
    end

    context "#calculate_interest" do
      should "calculate correct interest over 10 days at 6% rate (0.06)" do
        @calculator.start_date = Date.parse("2023-01-01")
        @calculator.end_date = Date.parse("2023-01-10")

        assert_equal "15.71", @calculator.calculate_interest
      end

      should "calculate correct interest across multiple rate periods" do
        @calculator.start_date = Date.parse("2022-12-31")
        @calculator.end_date = Date.parse("2023-01-10")

        assert_equal "17.21", @calculator.calculate_interest
      end
    end

    context "#calculate interest for specific date" do
      should "calculate daily interest truncated to 2 decimal places" do
        @calculator.start_date = Date.parse("2023-01-07")
        @calculator.end_date = Date.parse("2023-01-07")

        assert_equal "1.64", @calculator.calculate_interest

        @calculator.start_date = Date.parse("2025-08-07")
        @calculator.end_date = Date.parse("2025-08-07")

        assert_equal "2.25", @calculator.calculate_interest

        @calculator.start_date = Date.parse("2025-08-29")
        @calculator.end_date = Date.parse("2025-08-29")

        assert_equal "2.19", @calculator.calculate_interest
      end
    end
  end
end
