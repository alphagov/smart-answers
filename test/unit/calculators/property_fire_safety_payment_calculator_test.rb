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

    context "#uprated_value_of_property" do
      setup do
        stubbed_uprating_data = {
          "default" => 10,
          2000 => 5,
        }

        YAML.stubs(:load_file).returns(stubbed_uprating_data)
      end

      should "return the value_of_property multiplied by the uprating value for the year_of_purchase" do
        @calculator.year_of_purchase = 2000
        @calculator.value_of_property = "99999.99"
        assert_equal @calculator.uprated_value_of_property, 500_000
      end

      should "return the value_of_property multiplied by the default uprating value if year_of_purchase is not found" do
        @calculator.year_of_purchase = 2001
        @calculator.value_of_property = "100000.99"
        assert_equal @calculator.uprated_value_of_property, 1_000_010
      end
    end
  end
end
