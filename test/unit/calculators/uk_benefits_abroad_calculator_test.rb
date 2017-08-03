require "test_helper"

module SmartAnswer::Calculators
  class UkBenefitsAbroadCalculatorTest < ActiveSupport::TestCase
    setup do
      @calculator = UkBenefitsAbroadCalculator.new
    end

    context "#benefit?" do
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

    context "#dispute_criteria?" do
      should "returns true if dispute criteria is valid" do
        @calculator.dispute_criteria = %w(trades_dispute appealing_against_decision)

        assert @calculator.dispute_criteria?
      end

      should "returns false if dispute criteria isn't valid" do
        @calculator.dispute_criteria = %w(arbitary_element)

        refute @calculator.dispute_criteria?
      end

      should "returns false if dispute criteria contains at least one invalid element" do
        @calculator.dispute_criteria = %w(invalid_element trades_dispute)

        refute @calculator.dispute_criteria?
      end

      should "returns false if dispute criteria isn't an array" do
        @calculator.dispute_criteria = "invalid"

        refute @calculator.dispute_criteria?
      end

      should "returns false if dispute criteria is empty" do
        @calculator.dispute_criteria = []

        refute @calculator.dispute_criteria?
      end

      should "returns false if dispute criteria is nil" do
        @calculator.dispute_criteria = nil

        refute @calculator.dispute_criteria?
      end
    end
  end
end
