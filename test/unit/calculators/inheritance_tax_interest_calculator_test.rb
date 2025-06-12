require_relative "../../test_helper"

module SmartAnswer::Calculators
  class InheritanceTaxInterestCalculatorTest < ActiveSupport::TestCase
    def setup
      @calculator = SmartAnswer::Calculators::InheritanceTaxInterestCalculator.new(
        start_date: Date.parse("2023-01-01"),
        end_date: Date.parse("2023-01-10"),
        inheritance_tax_owed: 10_000,
      )
    end

    context "#calculate_interest" do
      should "calculate correct interest over 10 days at 6% rate (0.06)" do
        @calculator.start_date = Date.parse("2023-01-01")
        @calculator.end_date = Date.parse("2023-01-10")
        @calculator.inheritance_tax_owed = 10_000

        assert_equal SmartAnswer::Money.new(15.7), @calculator.calculate_interest
      end

      should "calculate correct interest across multiple rate periods" do
        @calculator.start_date = Date.parse("2022-12-31")
        @calculator.end_date = Date.parse("2023-01-10")
        @calculator.inheritance_tax_owed = 10_000

        assert_equal SmartAnswer::Money.new(17.2), @calculator.calculate_interest
      end
    end

    context "#calculate_interest_for_date" do
      should "calculate daily interest truncated to 2 decimal places" do
        date = Date.parse("2023-01-07")
        amount = @calculator.send(:calculate_interest_for_date, date)
        assert_equal BigDecimal("1.64"), amount
      end
    end
  end
end
