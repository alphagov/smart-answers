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

    context "#fully_protected_from_costs?" do
      should "be true if uprated value is under outer London limit and not living in London" do
        @calculator.stubs(:uprated_value_of_property).returns(PropertyFireSafetyPaymentCalculator::OUTSIDE_LONDON_VALUATION_LIMIT)
        @calculator.live_in_london = "no"
        assert @calculator.fully_protected_from_costs?
      end

      should "be true if uprated value is under inner London lower limit and living in London" do
        @calculator.stubs(:uprated_value_of_property).returns(PropertyFireSafetyPaymentCalculator::INSIDE_LONDON_VALUATION_LIMIT)
        @calculator.live_in_london = "yes"
        assert @calculator.fully_protected_from_costs?
      end

      should "be false if uprated value is over 175k and not living in London" do
        @calculator.stubs(:uprated_value_of_property).returns(PropertyFireSafetyPaymentCalculator::OUTSIDE_LONDON_VALUATION_LIMIT + 1)
        @calculator.live_in_london = "no"
        assert_not @calculator.fully_protected_from_costs?
      end

      should "be true if uprated value is over 325k and living in London" do
        @calculator.stubs(:uprated_value_of_property).returns(PropertyFireSafetyPaymentCalculator::INSIDE_LONDON_VALUATION_LIMIT + 1)
        @calculator.live_in_london = "yes"
        assert_not @calculator.fully_protected_from_costs?
      end
    end

    context "#leaseholder_costs" do
      context "not living in London with value between outer London limit and one million" do
        setup do
          @calculator.stubs(:uprated_value_of_property).returns(PropertyFireSafetyPaymentCalculator::OUTSIDE_LONDON_VALUATION_LIMIT)
          @calculator.live_in_london = "no"
        end

        should "return ten thousand if not shared ownership" do
          @calculator.shared_ownership = "no"
          assert_equal @calculator.leaseholder_costs, 10_000
        end

        should "return percentage owned multipled by ten thousand if shared ownership" do
          @calculator.shared_ownership = "yes"
          @calculator.percentage_owned = 0.50
          assert_equal @calculator.leaseholder_costs, 5_000
        end
      end
    end
  end
end
