require_relative '../test_helper'

module SmartAnswer
  class MarriedCouplesAllowanceCalculatorTest < ActiveSupport::TestCase

    def setup
      @maximum_mca = 8020
      @minimum_mca = 3010

      @income_limit = 27000
      @age_related_allowance = 12000
      @personal_allowance = 9000

      @calculator = MarriedCouplesAllowanceCalculator.new(
        maximum_mca: @maximum_mca,
        minimum_mca: @minimum_mca,
        income_limit: @income_limit,
        personal_allowance: @personal_allowance)
      @calculator_without_income_validation = MarriedCouplesAllowanceCalculator.new(
        maximum_mca: @maximum_mca,
        minimum_mca: @minimum_mca,
        income_limit: @income_limit,
        personal_allowance: @personal_allowance,
        validate_income: false)
    end

    test  "worked example on directgov for 2011-12" do
      hmrc_example_calculator = MarriedCouplesAllowanceCalculator.new(
          maximum_mca: 7295,
          minimum_mca: 2800,
          income_limit: 24000,
          personal_allowance: 7475)

      age_related_allowance_2011_12 =10090
      result = hmrc_example_calculator.calculate_allowance(age_related_allowance_2011_12, 29600)
      assert_equal Money.new("711"), result
    end

    #add one for 2013-14 when the worked example is released
    test  "worked example on HMRC site for 2012-13" do
      hmrc_example_calculator = MarriedCouplesAllowanceCalculator.new(
          maximum_mca: 7705,
          minimum_mca: 2960,
          income_limit: 25400,
          personal_allowance: 8105)
      age_related_allowance_2012_13 = 10660
      result = hmrc_example_calculator.calculate_allowance(age_related_allowance_2012_13, 31500)
      assert_equal Money.new("721"), result
    end

    # backwards compatibility with version 1
    test "don't allow an income less than 1 by default" do
      assert_raises InvalidResponse do
        @calculator.calculate_allowance(@age_related_allowance, 0)
      end
    end

    test "allow an income less than 1 when income validation is false" do
      result = @calculator_without_income_validation.calculate_allowance(@age_related_allowance, 0)
      assert_equal Money.new("802"), result
    end

    test  "minimum allowance when annual income over income limit" do
      result = @calculator.calculate_allowance(@age_related_allowance, 90000)
      assert_equal Money.new("301"), result
    end

    test  "maximum allowance when low annual income" do
      result = @calculator.calculate_allowance(@age_related_allowance, 100)
      assert_equal Money.new("802"), result
    end

    test "maximum allowance when income is greater than income limit but not enough to reduce personal allowance" do
      maximum_reduction = @age_related_allowance - @personal_allowance
      test_income = @income_limit + (maximum_reduction - 100)
      result = @calculator.calculate_allowance(@age_related_allowance, test_income)
      assert_equal Money.new("802"), result
    end

    test "maximum allowance when income is same as income limit" do
      result = @calculator.calculate_allowance(@age_related_allowance, @income_limit)
      assert_equal Money.new("802"), result
    end

    test "maximum allowance when just over income limit" do
      test_income = @income_limit + 1
      result = @calculator.calculate_allowance(@age_related_allowance, test_income)
      assert_equal Money.new("802"), result
    end

    test "adjusted net income calculation" do
      income = 35000
      gross_pension_contributions = 3000
      net_pension_contributions = 2000
      gift_aided_donations = 1000

      result = @calculator.calculate_adjusted_net_income(income, gross_pension_contributions, net_pension_contributions, gift_aided_donations)
      assert_equal Money.new("28250"), result
    end

  end
end
