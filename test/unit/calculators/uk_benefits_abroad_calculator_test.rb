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

    context "#partner_premiums?" do
      should "returns true if partner premiums is valid" do
        @calculator.partner_premiums = %w(pension_premium higher_pensioner)

        assert @calculator.partner_premiums?
      end

      should "returns false if partner premiums isn't valid" do
        @calculator.partner_premiums = %w(arbitary_premium)

        refute @calculator.partner_premiums?
      end

      should "returns false if partner premiums contains at least one invalid premium" do
        @calculator.partner_premiums = %w(invalid_premium higher_pensioner)

        refute @calculator.partner_premiums?
      end

      should "returns false if partner premiums isn't an array" do
        @calculator.partner_premiums = "invalid"

        refute @calculator.partner_premiums?
      end

      should "returns false if partner premiums is empty" do
        @calculator.partner_premiums = []

        refute @calculator.partner_premiums?
      end

      should "returns false if partner premiums is nil" do
        @calculator.partner_premiums = nil

        refute @calculator.partner_premiums?
      end
    end

    context "#getting_income_support?" do
      should "returns true if possible impairments is valid" do
        @calculator.possible_impairments = %w(too_ill_to_work temporarily_incapable_of_work)

        assert @calculator.getting_income_support?
      end

      should "returns false if possible impairments isn't valid" do
        @calculator.possible_impairments = %w(arbitary_impairment)

        refute @calculator.getting_income_support?
      end

      should "returns false if possible impairments contains at least one invalid impairment" do
        @calculator.possible_impairments = %w(invalid_impairment too_ill_to_work)

        refute @calculator.getting_income_support?
      end

      should "returns false if possible impairments isn't an array" do
        @calculator.possible_impairments = "invalid"

        refute @calculator.getting_income_support?
      end

      should "returns false if possible impairments is empty" do
        @calculator.possible_impairments = []

        refute @calculator.getting_income_support?
      end

      should "returns false if possible impairments is nil" do
        @calculator.possible_impairments = nil

        refute @calculator.getting_income_support?
      end
    end

    context "#not_getting_sick_pay?" do
      should "returns true if impairment periods is valid" do
        @calculator.impairment_periods = %w(364_days 196_days)

        assert @calculator.not_getting_sick_pay?
      end

      should "returns false if impairment periods isn't valid" do
        @calculator.impairment_periods = %w(arbitary_impairment_period)

        refute @calculator.not_getting_sick_pay?
      end

      should "returns false if impairment periods contains at least one invalid element" do
        @calculator.impairment_periods = %w(invalid_impairment_period 364_days)

        refute @calculator.not_getting_sick_pay?
      end

      should "returns false if impairment periods isn't an array" do
        @calculator.impairment_periods = "invalid"

        refute @calculator.not_getting_sick_pay?
      end

      should "returns false if impairment periods is empty" do
        @calculator.impairment_periods = []

        refute @calculator.not_getting_sick_pay?
      end

      should "returns false if impairment periods is nil" do
        @calculator.impairment_periods = nil

        refute @calculator.not_getting_sick_pay?
      end
    end
  end
end
