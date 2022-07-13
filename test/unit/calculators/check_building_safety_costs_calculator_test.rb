require_relative "../../test_helper"

module SmartAnswer::Calculators
  class CheckBuildingSafetyCostsCalculatorTest < ActiveSupport::TestCase
    setup do
      @calculator = CheckBuildingSafetyCostsCalculator.new
    end

    context "#valid_percentage_owned?" do
      should "be valid if percentage owned is between minimum and maximum percentage limit" do
        @calculator.percentage_owned = CheckBuildingSafetyCostsCalculator::MIN_PERCENTAGE_LIMIT
        assert @calculator.valid_percentage_owned?
      end

      should "be invalid if percentage owned is over max percentage limit " do
        @calculator.percentage_owned = CheckBuildingSafetyCostsCalculator::MAX_PERCENTAGE_LIMIT + 1
        assert_not @calculator.valid_percentage_owned?
      end

      should "be invalid if year of purchase isless than minimum percentage" do
        @calculator.percentage_owned = CheckBuildingSafetyCostsCalculator::MIN_PERCENTAGE_LIMIT - 1
        assert_not @calculator.valid_percentage_owned?
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
        @calculator.stubs(:uprated_value_of_property).returns(CheckBuildingSafetyCostsCalculator::OUTSIDE_LONDON_VALUATION_LIMIT)
        @calculator.live_in_london = "no"
        assert @calculator.fully_protected_from_costs?
      end

      should "be true if uprated value is under inner London lower limit and living in London" do
        @calculator.stubs(:uprated_value_of_property).returns(CheckBuildingSafetyCostsCalculator::INSIDE_LONDON_VALUATION_LIMIT)
        @calculator.live_in_london = "yes"
        assert @calculator.fully_protected_from_costs?
      end

      should "be false if uprated value is over 175k and not living in London" do
        @calculator.stubs(:uprated_value_of_property).returns(CheckBuildingSafetyCostsCalculator::OUTSIDE_LONDON_VALUATION_LIMIT + 1)
        @calculator.live_in_london = "no"
        assert_not @calculator.fully_protected_from_costs?
      end

      should "be true if uprated value is over 325k and living in London" do
        @calculator.stubs(:uprated_value_of_property).returns(CheckBuildingSafetyCostsCalculator::INSIDE_LONDON_VALUATION_LIMIT + 1)
        @calculator.live_in_london = "yes"
        assert_not @calculator.fully_protected_from_costs?
      end
    end

    context "#presented_annual_price_cap" do
      should "return one tenth of the maximum_cost as a pound value" do
        @calculator.stubs(:maximum_cost).returns(100_000)
        assert_equal @calculator.presented_annual_price_cap, "£10,000"
      end
    end

    context "#presented_remaining_costs" do
      should "return the leaseholder costs minus the amount already paid, rounded up" do
        @calculator.stubs(:maximum_cost).returns(100_000)
        @calculator.amount_already_paid = "50000.01"
        assert_equal @calculator.presented_remaining_costs, "£50,000"
      end
    end

    context "#presented_amount_already_paid" do
      should "return the amount already paid as currency, rounded up" do
        @calculator.amount_already_paid = "50000.01"
        assert_equal @calculator.presented_amount_already_paid, "£50,000"
      end
    end

    context "#presented_valuation_limit" do
      should "return the inside London valuation limit as currency if living in London" do
        @calculator.live_in_london = "yes"
        assert_equal @calculator.presented_valuation_limit, "£325,000"
      end

      should "return the outside London valuation limit as currency if iving outside London" do
        @calculator.live_in_london = "no"
        assert_equal @calculator.presented_valuation_limit, "£175,000"
      end
    end

    context "remaining_costs_more_than_annual_price_cap" do
      should "be true if remaining_costs is more than annual_leaseholder costs" do
        @calculator.stubs(:maximum_cost).returns(15_000)
        @calculator.amount_already_paid = "1"
        assert @calculator.remaining_costs_more_than_annual_price_cap?
      end

      should "be false if remaining_costs is less than annual_leaseholder" do
        @calculator.stubs(:maximum_cost).returns(15_000)
        @calculator.amount_already_paid = "50000"
        assert_not @calculator.remaining_costs_more_than_annual_price_cap?
      end
    end

    context "fully_repaid?" do
      should "be true if remaining_costs is 0" do
        @calculator.stubs(:maximum_cost).returns(15_000)
        @calculator.amount_already_paid = "50000"
        assert @calculator.fully_repaid?
      end

      should "be false if remaining_costs is more than 0" do
        @calculator.stubs(:maximum_cost).returns(15_000)
        @calculator.amount_already_paid = "1"
        assert_not @calculator.fully_repaid?
      end
    end
  end
end
