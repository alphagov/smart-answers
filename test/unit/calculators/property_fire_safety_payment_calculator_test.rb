require_relative "../../test_helper"

module SmartAnswer::Calculators
  class PropertyFireSafetyPaymentCalculatorTest < ActiveSupport::TestCase
    setup do
      @calculator = PropertyFireSafetyPaymentCalculator.new
    end

    context "#valid_year_of_purchase?" do
      should "be valid if year of purchase is between first valid year and last valid year" do
        @calculator.year_of_purchase = PropertyFireSafetyPaymentCalculator::LAST_VALID_YEAR - 1
        assert @calculator.valid_year_of_purchase?
      end

      should "be invalid if year of purchase is later than last valid " do
        @calculator.year_of_purchase = PropertyFireSafetyPaymentCalculator::LAST_VALID_YEAR + 1
        assert_not @calculator.valid_year_of_purchase?
      end

      should "be invalid if year of purchase is earlier than first valid year " do
        @calculator.year_of_purchase = PropertyFireSafetyPaymentCalculator::FIRST_VALID_YEAR - 1
        assert_not @calculator.valid_year_of_purchase?
      end
    end
  end
end
