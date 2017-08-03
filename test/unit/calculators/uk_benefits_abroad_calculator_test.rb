require "test_helper"

module SmartAnswer::Calculators
  class UkBenefitsAbroadCalculatorTest < ActiveSupport::TestCase
    context "#benefit?" do
      setup do
        @calculator = UkBenefitsAbroadCalculator.new
      end

      should "returns true if benefit list is valid" do
        @calculator.benefits = %w(incapacity_benefit state_pension)

        assert @calculator.benefits?
      end

      should "returns false if benefit list isn't valid" do
        @calculator.benefits = %w(arbitary_element)

        refute @calculator.benefits?
      end

      should "returns false if benefit list contains at least one invalid element" do
        @calculator.benefits = %w(invalid_element state_pension)

        refute @calculator.benefits?
      end

      should "returns false if benefit list isn't an array" do
        @calculator.benefits = "invalid"

        refute @calculator.benefits?
      end

      should "returns false if benefit list is empty" do
        @calculator.benefits = []

        refute @calculator.benefits?
      end

      should "returns false if benefit list is nil" do
        @calculator.benefits = nil

        refute @calculator.benefits?
      end
    end
  end
end
