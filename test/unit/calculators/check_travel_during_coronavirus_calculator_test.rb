require_relative "../../test_helper"

module SmartAnswer::Calculators
  class CheckTravelDuringCoronavirusCalculatorTest < ActiveSupport::TestCase
    setup do
      @calculator = CheckTravelDuringCoronavirusCalculator.new

      stub_worldwide_api_has_locations(%w[spain italy poland])
    end

    context "location" do
      should "find a country if it exists" do
        country = @calculator.location("spain")

        assert_equal "spain", country.slug
      end
    end

    context "country_locations" do
      should "find a country if it exists" do
        @calculator.countries << "spain"
        country = @calculator.location("spain")

        assert_equal [country], @calculator.country_locations
      end
    end

    context "travelling_with_children=" do
      should "add a single response" do
        @calculator.travelling_with_children = "zero_to_four"

        assert_equal %w[zero_to_four], @calculator.travelling_with_children
      end

      should "add more than one response" do
        @calculator.travelling_with_children = "zero_to_four,five_to_seventeen"

        assert_equal %w[zero_to_four five_to_seventeen], @calculator.travelling_with_children
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
        @calculator.countries = %w[spain]
        expected = { spain: "Spain" }

        assert_equal expected.with_indifferent_access, @calculator.transit_country_options
      end

      should "add more than one country" do
        @calculator.countries = %w[spain italy]
        expected = { spain: "Spain", italy: "Italy" }

        assert_equal expected.with_indifferent_access, @calculator.transit_country_options
      end
    end

    context "red_list_country_titles" do
      should "add a single country" do
        @calculator.countries = %w[spain]
        @calculator.stubs(:red_list_countries).returns(%w[spain])

        assert_equal %w[Spain], @calculator.red_list_country_titles
      end

      should "add more than one country" do
        @calculator.countries = %w[spain italy poland]
        @calculator.stubs(:red_list_countries).returns(%w[spain italy])

        assert_equal %w[Spain Italy], @calculator.red_list_country_titles
      end
    end

    context "travelling_to_red_list_country?" do
      should "return true if going to any country on the red list" do
        @calculator.going_to_countries_within_10_days = "yes"

        assert @calculator.travelling_to_red_list_country?
      end

      should "return false if not going to any country on the red list" do
        @calculator.going_to_countries_within_10_days = "no"

        assert_not @calculator.travelling_to_red_list_country?
      end
    end

    should "return true for travelling_to_ireland? if ireland has been selected" do
      @calculator.countries = %w[spain ireland poland]
      assert @calculator.travelling_to_ireland?
    end

    should "return true for single_journey? if only travelling to one country" do
      @calculator.countries = %w[spain]
      assert @calculator.single_journey?
    end
  end
end
