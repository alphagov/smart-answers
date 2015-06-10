require_relative '../../test_helper'

#TODO Other contexts

module SmartAnswer::Calculators
  class ChildcareCostCalculatorTest < ActiveSupport::TestCase
    context ".weekly_cost" do
      should "return the weekly cost based on the annual cost" do
        assert_equal 12, ChildcareCostCalculator.weekly_cost(600)
      end
    end

    context ".weekly_cost" do
      should "return the weekly cost based on the annual cost - rounding up test" do
        assert_equal 56, ChildcareCostCalculator.weekly_cost(2880)
      end
    end

    context ".weekly_cost_from_monthly" do
      should "return the weekly cost based on the monthly cost" do
        assert_equal 14, ChildcareCostCalculator.weekly_cost_from_monthly(60)
      end
    end

    context ".weekly_cost_from_fortnightly" do
      should "return the weekly cost based on the fortnightly cost" do
        assert_equal 14, ChildcareCostCalculator.weekly_cost_from_fortnightly(27)
      end
    end

    context ".weekly_cost_from_four_weekly" do
      should "return the weekly cost based on the four weekly cost" do
        assert_equal 20, ChildcareCostCalculator.weekly_cost_from_four_weekly(77)
      end
    end

    context ".cost_change" do
      should "return the difference between weekly cost and tax" do
        assert_equal 3, ChildcareCostCalculator.cost_change(10, 7)
      end
    end
  end
end
