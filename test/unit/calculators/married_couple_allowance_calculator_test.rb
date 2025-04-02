require_relative "../../test_helper"

module SmartAnswer::Calculators
  class MarriedCouplesAllowanceCalculatorTest < ActiveSupport::TestCase
    setup do
      @income_limit = 27_000
      @personal_allowance = 9000
    end

    def calculator(stubbed_values = {})
      calculator = MarriedCouplesAllowanceCalculator.new
      stubbed_values.each do |key, value|
        calculator.stubs(key).returns(value)
      end
      calculator
    end

    def default_calculator
      return @default_calculator if @default_calculator

      @default_calculator = calculator(
        maximum_mca: 8020,
        minimum_mca: 3010,
        income_limit_for_personal_allowances: @income_limit,
        personal_allowance: @personal_allowance,
      )
    end

    test "worked example on directgov for 2011-12" do
      hmrc_example_calculator = calculator(
        maximum_mca: 7295,
        minimum_mca: 2800,
        income_limit_for_personal_allowances: 24_000,
        personal_allowance: 7475,
        calculate_adjusted_net_income: 29_600,
      )

      result = hmrc_example_calculator.calculate_allowance
      assert_equal SmartAnswer::Money.new("449.50"), result
    end

    # add one for 2013-14 when the worked example is released
    test "worked example on HMRC site for 2012-13" do
      hmrc_example_calculator = calculator(
        maximum_mca: 7705,
        minimum_mca: 2960,
        income_limit_for_personal_allowances: 25_400,
        personal_allowance: 8105,
        calculate_adjusted_net_income: 31_500,
      )

      result = hmrc_example_calculator.calculate_allowance
      assert_equal SmartAnswer::Money.new("465.50"), result
    end

    test "allow an income less than 1" do
      calculator = default_calculator
      calculator.stubs(:calculate_adjusted_net_income).returns(0)
      result = calculator.calculate_allowance
      assert_equal SmartAnswer::Money.new("802"), result
    end

    test "minimum allowance when annual income over income limit" do
      calculator = default_calculator
      calculator.stubs(:calculate_adjusted_net_income).returns(90_000)
      result = calculator.calculate_allowance
      assert_equal SmartAnswer::Money.new("301"), result
    end

    test "maximum allowance when low annual income" do
      calculator = default_calculator
      calculator.stubs(:calculate_adjusted_net_income).returns(100)
      result = calculator.calculate_allowance
      assert_equal SmartAnswer::Money.new("802"), result
    end

    test "maximum allowance when income is greater than income limit but not enough to reduce personal allowance" do
      test_income = @income_limit - 100
      calculator = default_calculator
      calculator.stubs(:calculate_adjusted_net_income).returns(test_income)
      result = calculator.calculate_allowance
      assert_equal SmartAnswer::Money.new("802"), result
    end

    test "maximum allowance when income is same as income limit" do
      calculator = default_calculator
      calculator.stubs(:calculate_adjusted_net_income).returns(@income_limit)
      result = calculator.calculate_allowance
      assert_equal SmartAnswer::Money.new("802"), result
    end

    test "maximum allowance when just over income limit" do
      test_income = @income_limit + 1
      calculator = default_calculator
      calculator.stubs(:calculate_adjusted_net_income).returns(test_income)
      result = calculator.calculate_allowance
      assert_equal SmartAnswer::Money.new("802"), result
    end

    test "adjusted net income calculation" do
      calculator = default_calculator
      calculator.income = 35_000
      calculator.gross_pension_contributions = 3000
      calculator.net_pension_contributions = 2000
      calculator.gift_aided_donations = 1000

      result = calculator.calculate_adjusted_net_income
      assert_equal SmartAnswer::Money.new("28250"), result
    end

    test "rate values for 2024/25" do
      travel_to("2024-06-01") do
        calculator = MarriedCouplesAllowanceCalculator.new

        assert_equal 12_570, calculator.personal_allowance
        assert_equal 37_700.0, calculator.income_limit_for_personal_allowances
        assert_equal 11_080, calculator.maximum_mca
        assert_equal 4270, calculator.minimum_mca
      end
    end

    test "rate values for 2025/26" do
      travel_to("2025-06-01") do
        calculator = MarriedCouplesAllowanceCalculator.new

        assert_equal 12_570, calculator.personal_allowance
        assert_equal 37_700.0, calculator.income_limit_for_personal_allowances
        assert_equal 11_270, calculator.maximum_mca
        assert_equal 4360, calculator.minimum_mca
      end
    end
  end
end
