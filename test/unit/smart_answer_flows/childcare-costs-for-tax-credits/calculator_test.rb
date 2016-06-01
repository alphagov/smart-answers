require_relative '../../../test_helper'

require "smart_answer_flows/childcare-costs-for-tax-credits/calculator"

#TODO Other contexts

module SmartAnswer
  class ChildcareCostsForTaxCreditsFlow < Flow
    class CalculatorTest < ActiveSupport::TestCase
      context ".weekly_cost" do
        should "return the weekly cost based on the annual cost" do
          assert_equal 12, Calculator.weekly_cost(600)
        end
      end

      context ".weekly_cost" do
        should "return the weekly cost based on the annual cost - rounding up test" do
          assert_equal 56, Calculator.weekly_cost(2880)
        end
      end

      context ".weekly_cost_from_monthly" do
        should "return the weekly cost based on the monthly cost" do
          assert_equal 14, Calculator.weekly_cost_from_monthly(60)
        end
      end

      context ".weekly_cost_from_fortnightly" do
        should "return the weekly cost based on the fortnightly cost" do
          assert_equal 14, Calculator.weekly_cost_from_fortnightly(27)
        end
      end

      context ".weekly_cost_from_four_weekly" do
        should "return the weekly cost based on the four weekly cost" do
          assert_equal 20, Calculator.weekly_cost_from_four_weekly(77)
        end
      end

      context ".cost_change" do
        should "return the difference between weekly cost and tax" do
          assert_equal 3, Calculator.cost_change(10, 7)
        end
      end
    end
  end
end
