require_relative "../../test_helper"

module SmartAnswer::Calculators
  class CovidTravelAbroadCalculatorTest < ActiveSupport::TestCase
    setup do
      @calculator = CovidTravelAbroadCalculator.new

      stub_worldwide_api_has_locations(%w[spain italy poland])
    end

    context "location" do
      should "find a country if it exists" do
        country = @calculator.location("spain")

        assert_equal "spain", country.slug
      end
    end

    context "travel_rules" do
      should "find a country if it exists" do
        @calculator.countries << "spain"
        country = @calculator.location("spain")

        assert_equal [country], @calculator.travel_rules
      end
    end

    context "travelling_with_children=" do
      should "add a single response" do
        @calculator.travelling_with_children = "spain"

        assert_equal %w[spain], @calculator.travelling_with_children
      end

      should "add more than one response" do
        @calculator.travelling_with_children = "spain,italy"

        assert_equal %w[spain italy], @calculator.travelling_with_children
      end
    end

    context "transit_countries=" do
      should "add a single country" do
        @calculator.transit_countries = "spain"

        assert_equal %w[spain], @calculator.transit_countries
      end

      should "add more than one country" do
        @calculator.transit_countries = "spain,italy"

        assert_equal %w[spain italy], @calculator.transit_countries
      end
    end

    context "transit_country_options" do
      should "add a single country" do
        @calculator.countries << "spain"
        expected = { spain: "Spain" }

        assert_equal expected.with_indifferent_access, @calculator.transit_country_options
      end

      should "add more than one country" do
        @calculator.countries << "spain"
        @calculator.countries << "italy"
        expected = { spain: "Spain", italy: "Italy" }

        assert_equal expected.with_indifferent_access, @calculator.transit_country_options
      end
    end

    context "travelling_to_red_list_country?" do
      # should "return true if going to any country on the red list" do
      #   @calculator.countries << "poland"
      #   @calculator.countries << "spain"

      #   assert_equal true, @calculator.travelling_to_red_list_country?
      # end

      should "return false if not going to a country on the red list" do
        @calculator.countries << "spain"
        @calculator.countries << "italy"

        assert_equal false, @calculator.travelling_to_red_list_country?
      end
    end
  end
end
