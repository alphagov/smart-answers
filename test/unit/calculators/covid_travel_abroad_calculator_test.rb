require_relative "../../test_helper"

module SmartAnswer::Calculators
  class CovidTravelAbroadCalculatorTest < ActiveSupport::TestCase
    setup do
      @calculator = CovidTravelAbroadCalculator.new
      stub_worldwide_api_has_locations(%w[canada])
    end

    context "location" do
      should "find a country if it exists" do
        country = @calculator.location("canada")

        assert_equal "canada", country.slug
      end
    end

    context "travel_rules" do
      should "find a country if it exists" do
        @calculator.countries << "canada"
        country = @calculator.location("canada")

        assert_equal [country], @calculator.travel_rules
      end
    end

    context "travelling_with_children=" do
      should "add a single response" do
        @calculator.travelling_with_children = "one"

        assert_equal %w[one], @calculator.travelling_with_children
      end

      should "add more than one response" do
        @calculator.travelling_with_children = "one,two"

        assert_equal %w[one two], @calculator.travelling_with_children
      end
    end

    context "transit_countries=" do
      should "add a single country" do
        @calculator.transit_countries = "one"

        assert_equal %w[one], @calculator.transit_countries
      end

      should "add more than one country" do
        @calculator.transit_countries = "one,two"

        assert_equal %w[one two], @calculator.transit_countries
      end
    end

    context "countries_within_10_days=" do
      should "add a single country" do
        @calculator.countries_within_10_days = "one"

        assert_equal %w[one], @calculator.countries_within_10_days
      end

      should "add more than one country" do
        @calculator.countries_within_10_days = "one,two"

        assert_equal %w[one two], @calculator.countries_within_10_days
      end
    end

    context "transit_country_options" do
      should "add a single country" do
        @calculator.countries << "one"
        expected = { one: "One" }

        assert_equal expected.with_indifferent_access, @calculator.transit_country_options
      end

      should "add more than one country" do
        @calculator.countries << "one"
        @calculator.countries << "two"
        expected = { one: "One", two: "Two" }

        assert_equal expected.with_indifferent_access, @calculator.transit_country_options
      end
    end

    context "travelling_to_red_list_country?" do
      should "return true if going to any country on the red list" do
        @calculator.countries << "one"
        @calculator.countries << "two"
        @calculator.countries_within_10_days = "one"

        assert_equal true, @calculator.travelling_to_red_list_country?
      end

      should "return false if not going to a country on the red list" do
        @calculator.countries << "one"
        @calculator.countries << "two"

        assert_equal false, @calculator.travelling_to_red_list_country?
      end
    end
  end
end
