require_relative "../../test_helper"

module SmartAnswer::Calculators
  class CheckFireSafetyCostsCalculatorTest < ActiveSupport::TestCase
    setup do
      @calculator = CheckFireSafetyCostsCalculator.new
    end

    context "#valid_percentage_owned?" do
      should "be valid if percentage owned is between minimum and maximum percentage limit" do
        @calculator.percentage_owned = CheckFireSafetyCostsCalculator::MIN_PERCENTAGE_LIMIT
        assert @calculator.valid_percentage_owned?
      end

      should "be invalid if percentage owned is over max percentage limit " do
        @calculator.percentage_owned = CheckFireSafetyCostsCalculator::MAX_PERCENTAGE_LIMIT + 1
        assert_not @calculator.valid_percentage_owned?
      end

      should "be invalid if year of purchase isless than minimum percentage" do
        @calculator.percentage_owned = CheckFireSafetyCostsCalculator::MIN_PERCENTAGE_LIMIT - 1
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
        @calculator.stubs(:uprated_value_of_property).returns(CheckFireSafetyCostsCalculator::OUTSIDE_LONDON_VALUATION_LIMIT)
        @calculator.live_in_london = "no"
        assert @calculator.fully_protected_from_costs?
      end

      should "be true if uprated value is under inner London lower limit and living in London" do
        @calculator.stubs(:uprated_value_of_property).returns(CheckFireSafetyCostsCalculator::INSIDE_LONDON_VALUATION_LIMIT)
        @calculator.live_in_london = "yes"
        assert @calculator.fully_protected_from_costs?
      end

      should "be false if uprated value is over 175k and not living in London" do
        @calculator.stubs(:uprated_value_of_property).returns(CheckFireSafetyCostsCalculator::OUTSIDE_LONDON_VALUATION_LIMIT + 1)
        @calculator.live_in_london = "no"
        assert_not @calculator.fully_protected_from_costs?
      end

      should "be true if uprated value is over 325k and living in London" do
        @calculator.stubs(:uprated_value_of_property).returns(CheckFireSafetyCostsCalculator::INSIDE_LONDON_VALUATION_LIMIT + 1)
        @calculator.live_in_london = "yes"
        assert_not @calculator.fully_protected_from_costs?
      end
    end

    context "#presented_leaseholder_costs" do
      context "not living in London with value between outer London limit and one million" do
        setup do
          @calculator.stubs(:uprated_value_of_property).returns(CheckFireSafetyCostsCalculator::OUTSIDE_LONDON_VALUATION_LIMIT)
          @calculator.live_in_london = "no"
        end

        should "return £10,000 if not shared ownership" do
          @calculator.shared_ownership = "no"
          assert_equal @calculator.presented_leaseholder_costs, "£10,000"
        end

        should "return percentage owned multipled by ten thousand if shared ownership" do
          @calculator.shared_ownership = "yes"
          @calculator.percentage_owned = 0.50
          assert_equal @calculator.presented_leaseholder_costs, "£5,000"
        end
      end

      context "living in London with value between inner London limit and one million" do
        setup do
          @calculator.stubs(:uprated_value_of_property).returns(CheckFireSafetyCostsCalculator::INSIDE_LONDON_VALUATION_LIMIT)
          @calculator.live_in_london = "yes"
        end

        should "return £15,000 if not shared ownership" do
          @calculator.shared_ownership = "no"
          assert_equal @calculator.presented_leaseholder_costs, "£15,000"
        end

        should "return percentage owned multipled by fifteen thousand if shared ownership" do
          @calculator.shared_ownership = "yes"
          @calculator.percentage_owned = 0.50
          assert_equal @calculator.presented_leaseholder_costs, "£7,500"
        end
      end

      context "uprated value is over one million" do
        setup do
          @calculator.stubs(:uprated_value_of_property).returns(CheckFireSafetyCostsCalculator::ONE_MILLION)
        end

        should "return £50,000 if not shared ownership" do
          @calculator.shared_ownership = "no"
          assert_equal @calculator.presented_leaseholder_costs, "£50,000"
        end

        should "return percentage owned multipled by fifty thousand if shared ownership" do
          @calculator.shared_ownership = "yes"
          @calculator.percentage_owned = 0.50
          assert_equal @calculator.presented_leaseholder_costs, "£25,000"
        end
      end

      context "uprated value is over two million" do
        setup do
          @calculator.stubs(:uprated_value_of_property).returns(CheckFireSafetyCostsCalculator::TWO_MILLION)
        end

        should "return £100,000 if not shared ownership" do
          @calculator.shared_ownership = "no"
          assert_equal @calculator.presented_leaseholder_costs, "£100,000"
        end

        should "return percentage owned multipled by one hunderd thousand if shared ownership" do
          @calculator.shared_ownership = "yes"
          @calculator.percentage_owned = 0.50
          assert_equal @calculator.presented_leaseholder_costs, "£50,000"
        end
      end
    end

    context "#presented_annual_leaseholder_costs" do
      should "return one tenth of the leaseholder_costs as a pound value" do
        @calculator.stubs(:leaseholder_costs).returns(100_000)
        assert_equal @calculator.presented_annual_leaseholder_costs, "£10,000"
      end
    end
  end
end
