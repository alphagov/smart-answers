require_relative "../../test_helper"

module SmartAnswer::Calculators
  class CheckBenefitsSupportCalculatorTest < ActiveSupport::TestCase
    context CheckBenefitsSupportCalculator do
      context "#eligible_for_employment_and_support_allowance?" do
        should "return true if eligible for Employment and Support Allowance" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.over_state_pension_age = "no"
          calculator.disability_or_health_condition = "yes"
          calculator.disability_affecting_work = "yes_unable_to_work"

          assert calculator.eligible_for_employment_and_support_allowance?

          calculator.disability_affecting_work = "yes_limits_work"
          assert calculator.eligible_for_employment_and_support_allowance?
        end

        should "return false if not eligible for Employment and Support Allowance" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.over_state_pension_age = "no"
          calculator.disability_or_health_condition = "no"
          assert_not calculator.eligible_for_employment_and_support_allowance?
        end
      end
    end
  end
end
