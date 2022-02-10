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

    context "travelling_with_children?" do
      should "be false when not travelling with children" do
        @calculator.travelling_with_children = "none"
        assert_not @calculator.travelling_with_children?
      end

      should "be true when travelling with children" do
        @calculator.travelling_with_children = "zero_to_four"
        assert @calculator.travelling_with_children?
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

    context "summary_text_fields" do
      should "return an empty array if only travelling to ireland, even with other fields" do
        @calculator.countries = %w[ireland]
        @calculator.travelling_with_young_people = "yes"

        assert_equal [], @calculator.summary_text_fields
      end

      should "not include young person if not travelling_with_young_people?" do
        @calculator.travelling_with_young_people = "no"

        assert_not @calculator.summary_text_fields.include?("young_person")
      end

      should "include young person if travelling_with_young_people?" do
        @calculator.travelling_with_young_people = "yes"

        assert @calculator.summary_text_fields.include?("young_person")
      end

      should "include responses to the travelling_with_children question" do
        @calculator.travelling_with_children = "zero_to_four,five_to_seventeen"

        %w[zero_to_four five_to_seventeen].each do |age|
          assert @calculator.summary_text_fields.include?(age)
        end
      end

      should "include the correct vaccination status for unvaccinated users" do
        @calculator.vaccination_status = "9ddc7655bfd0d477"

        assert @calculator.summary_text_fields.include?("not_vaxed")
      end

      should "include the correct vaccination status for vaccinated users" do
        @calculator.vaccination_status = "529202127233d442"

        assert @calculator.summary_text_fields.include?("fully_vaxed")
      end

      should "include red_list if travelling to a red list country" do
        @calculator.going_to_countries_within_10_days = "yes"

        assert @calculator.summary_text_fields.include?("red_list")
      end
    end

    context "vaccination_options" do
      should "return a hash of options" do
        assert @calculator.vaccination_options.is_a?(Hash)
      end
    end

    context "vaccination_option_keys" do
      should "return an array of option keys" do
        assert @calculator.vaccination_option_keys.is_a?(Array)
      end
    end

    context "vaccination_status_by_name" do
      should "return vaccination status code" do
        assert_equal "e9e286f8822bc330", @calculator.vaccination_status_by_name("vaccine_trial")
      end
    end
  end
end
