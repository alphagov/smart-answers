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

    context "transit_countries=" do
      should "not add a country when 'none'" do
        @calculator.transit_countries = "none"

        assert_equal [], @calculator.transit_countries
      end

      should "add a single country" do
        @calculator.transit_countries = "one"

        assert_equal %w[one], @calculator.transit_countries
      end

      should "add more than one country" do
        @calculator.transit_countries = "one,two"

        assert_equal %w[one two], @calculator.transit_countries
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
  end
end
