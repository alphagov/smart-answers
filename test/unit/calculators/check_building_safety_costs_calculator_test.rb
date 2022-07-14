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
      should "be true if uprated value is under outer London valuation limit and not living in London" do
        @calculator.stubs(:uprated_value_of_property).returns(CheckBuildingSafetyCostsCalculator::OUTSIDE_LONDON_VALUATION_LIMIT - 1)
        @calculator.live_in_london = "no"
        assert @calculator.fully_protected_from_costs?
      end

      should "be true if uprated value is under inner London valuation limit and living in London" do
        @calculator.stubs(:uprated_value_of_property).returns(CheckBuildingSafetyCostsCalculator::INSIDE_LONDON_VALUATION_LIMIT - 1)
        @calculator.live_in_london = "yes"
        assert @calculator.fully_protected_from_costs?
      end

      should "be false if uprated value is at least outer London valuation limit and not living in London" do
        @calculator.stubs(:uprated_value_of_property).returns(CheckBuildingSafetyCostsCalculator::OUTSIDE_LONDON_VALUATION_LIMIT)
        @calculator.live_in_london = "no"
        assert_not @calculator.fully_protected_from_costs?
      end

      should "be true if uprated value is at least inner London valuation limit and living in London" do
        @calculator.stubs(:uprated_value_of_property).returns(CheckBuildingSafetyCostsCalculator::INSIDE_LONDON_VALUATION_LIMIT)
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

    context "DLUHC scenarios" do
      should "1991 purchase, 50,000 value, in London" do
        @calculator.year_of_purchase = 1991
        @calculator.value_of_property = 50_000
        @calculator.live_in_london = "yes"
        @calculator.shared_ownership = "no"

        assert_equal @calculator.uprated_value_of_property, 250_000
      end

      should "1992 purchase, 172,500 value, in London" do
        @calculator.year_of_purchase = 1992
        @calculator.value_of_property = 172_500
        @calculator.live_in_london = "yes"
        @calculator.shared_ownership = "no"

        assert_equal @calculator.uprated_value_of_property, 905_625
      end

      should "2003 purchase, 119950 value, outside London, 30% ownership" do
        @calculator.year_of_purchase = 2003
        @calculator.value_of_property = 119_950
        @calculator.live_in_london = "no"
        @calculator.shared_ownership = "yes"
        @calculator.percentage_owned = 0.3

        assert_equal @calculator.uprated_value_of_property, 230_304
      end

      should "1995 purchase, 150k value, outside London" do
        @calculator.year_of_purchase = 1995
        @calculator.value_of_property = 150_000
        @calculator.live_in_london = "no"
        @calculator.shared_ownership = "no"
        @calculator.amount_already_paid = 0

        assert_equal @calculator.uprated_value_of_property, 781_500
        assert_equal @calculator.presented_remaining_costs, "£10,000"
        assert_equal @calculator.presented_annual_price_cap, "£1,000"
      end

      should "2010 purchase, 950k value, outside London" do
        @calculator.year_of_purchase = 2010
        @calculator.value_of_property = 950_000
        @calculator.live_in_london = "no"
        @calculator.shared_ownership = "yes"
        @calculator.percentage_owned = 0.85

        assert_equal @calculator.uprated_value_of_property, 1_434_500
        assert_equal @calculator.presented_remaining_costs, "£42,500"
        assert_equal @calculator.presented_annual_price_cap, "£4,250"
      end

      should "2012 purchase, 325k value, in London, 25% ownership" do
        @calculator.year_of_purchase = 2012
        @calculator.value_of_property = 325_000
        @calculator.live_in_london = "yes"
        @calculator.shared_ownership = "yes"
        @calculator.percentage_owned = 0.25
        @calculator.amount_already_paid = 0

        assert_equal @calculator.uprated_value_of_property, 484_250
        assert_equal @calculator.presented_remaining_costs, "£3,750"
        assert_equal @calculator.presented_annual_price_cap, "£375"
      end

      should "1997 purchase, 90k value, in London, 25% ownership" do
        @calculator.year_of_purchase = 1997
        @calculator.value_of_property = 90_000
        @calculator.live_in_london = "yes"
        @calculator.shared_ownership = "yes"
        @calculator.percentage_owned = 0.25
        @calculator.amount_already_paid = 0

        assert_equal @calculator.uprated_value_of_property, 416_700
        assert_equal @calculator.presented_remaining_costs, "£3,750"
        assert_equal @calculator.presented_annual_price_cap, "£375"
      end

      should "2006 purchase, 1.2m value, outside London, 75% ownership" do
        @calculator.year_of_purchase = 2006
        @calculator.value_of_property = 1_200_000
        @calculator.live_in_london = "no"
        @calculator.shared_ownership = "yes"
        @calculator.percentage_owned = 0.75
        @calculator.amount_already_paid = 0

        assert_equal @calculator.uprated_value_of_property, 1_812_000
        assert_equal @calculator.presented_remaining_costs, "£37,500"
        assert_equal @calculator.presented_annual_price_cap, "£3,750"
      end

      should "2006 purchase, 1.25m value, in London, 75% ownership" do
        @calculator.year_of_purchase = 2006
        @calculator.value_of_property = 1_250_000
        @calculator.live_in_london = "no"
        @calculator.shared_ownership = "yes"
        @calculator.percentage_owned = 0.75
        @calculator.amount_already_paid = 0

        assert_equal @calculator.uprated_value_of_property, 1_887_500
        assert_equal @calculator.presented_remaining_costs, "£37,500"
        assert_equal @calculator.presented_annual_price_cap, "£3,750"
      end

      should "2009 purchase, 2.5m value, outside London" do
        @calculator.year_of_purchase = 2009
        @calculator.value_of_property = 2_500_000
        @calculator.live_in_london = "no"
        @calculator.shared_ownership = "no"
        @calculator.amount_already_paid = 0

        assert_equal @calculator.uprated_value_of_property, 3_975_000
        assert_equal @calculator.presented_remaining_costs, "£100,000"
        assert_equal @calculator.presented_annual_price_cap, "£10,000"
      end

      should "2010 purchase, 2.5m value, inside London" do
        @calculator.year_of_purchase = 2010
        @calculator.value_of_property = 2_500_000
        @calculator.live_in_london = "yes"
        @calculator.shared_ownership = "no"
        @calculator.amount_already_paid = 0

        assert_equal @calculator.uprated_value_of_property, 3_775_000
        assert_equal @calculator.presented_remaining_costs, "£100,000"
        assert_equal @calculator.presented_annual_price_cap, "£10,000"
      end

      should "2015 purchase, 1m value, inside London" do
        @calculator.year_of_purchase = 2015
        @calculator.value_of_property = 1_000_000
        @calculator.live_in_london = "yes"
        @calculator.shared_ownership = "no"
        @calculator.amount_already_paid = 0

        assert_equal @calculator.uprated_value_of_property, 1_190_000
        assert_equal @calculator.presented_remaining_costs, "£50,000"
        assert_equal @calculator.presented_annual_price_cap, "£5,000"
      end

      should "2014 purchase, 1m value, outside London" do
        @calculator.year_of_purchase = 2014
        @calculator.value_of_property = 1_000_000
        @calculator.live_in_london = "no"
        @calculator.shared_ownership = "no"
        @calculator.amount_already_paid = 0

        assert_equal @calculator.uprated_value_of_property, 1_280_000
        assert_equal @calculator.presented_remaining_costs, "£50,000"
        assert_equal @calculator.presented_annual_price_cap, "£5,000"
      end

      should "2019 purchase, 100k value, outside London" do
        @calculator.year_of_purchase = 2019
        @calculator.value_of_property = 100_000
        @calculator.live_in_london = "no"
        @calculator.shared_ownership = "no"
        @calculator.amount_already_paid = 0

        assert_equal @calculator.uprated_value_of_property, 105_000
        assert @calculator.fully_protected_from_costs?
      end

      should "2018 purchase, 295k value, in London" do
        @calculator.year_of_purchase = 2018
        @calculator.value_of_property = 295_000
        @calculator.live_in_london = "yes"
        @calculator.shared_ownership = "no"
        @calculator.amount_already_paid = 0

        assert_equal @calculator.uprated_value_of_property, 306_800
        assert @calculator.fully_protected_from_costs?
      end

      should "2017 purchase, 400k value, in London, 5k paid " do
        @calculator.year_of_purchase = 2017
        @calculator.value_of_property = 400_000
        @calculator.live_in_london = "yes"
        @calculator.shared_ownership = "no"
        @calculator.amount_already_paid = 5000

        assert_equal @calculator.uprated_value_of_property, 416_000
        assert_equal @calculator.presented_remaining_costs, "£10,000"
        assert_equal @calculator.presented_annual_price_cap, "£1,500"
      end

      should "2012 purchase, 150k value, in London, 12k paid " do
        @calculator.year_of_purchase = 2012
        @calculator.value_of_property = 150_000
        @calculator.live_in_london = "yes"
        @calculator.shared_ownership = "no"
        @calculator.amount_already_paid = 12_000

        assert_equal @calculator.uprated_value_of_property, 223_500
        assert @calculator.fully_protected_from_costs?
      end
    end
  end
end
