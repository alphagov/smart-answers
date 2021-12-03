require "test_helper"
require "support/flow_test_helper"

class CovidTravelAbroadFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  countries = %w[argentina belize spain]

  setup do
    testing_flow CovidTravelAbroadFlow
    stub_worldwide_api_has_locations(countries)
  end

  should "render start page" do
    assert_rendered_start_page
  end

  context "question: which_country" do
    setup do
      testing_node :which_country
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of any_other_countries_1 " \
                "for any response " do
        assert_next_node :any_other_countries_1, for_response: "spain"
      end
    end
  end

  context "question: any_other_countries_1" do
    setup do
      testing_node :any_other_countries_1
      add_responses which_country: "spain"
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of vaccination_status " \
                "for a 'no' response " \
                "when which country is 'spain' " do
        assert_next_node :vaccination_status, for_response: "no"
      end

      should "have a next node of transit_countries " \
               "for a 'no' response " \
               "when which country is 'spain' " \
               "and any other countries is 'yes' " \
               "and which 1 country is 'argentina' " do
        add_responses which_country: "spain",
                      any_other_countries_1: "yes",
                      which_1_country: "argentina"
        assert_next_node :transit_countries, for_response: "no"
      end

      should "have a next node of which_1_country " \
                "for a 'yes' response " \
                "when which country is 'spain' " do
        assert_next_node :which_1_country, for_response: "yes"
      end
    end
  end

  context "question: transit_countries" do
    setup do
      testing_node :transit_countries
      add_responses which_country: "spain",
                    any_other_countries_1: "yes",
                    which_1_country: "argentina",
                    any_other_countries_2: "no"
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of vaccination_status " \
                "for any response " \
                "when which country is 'spain' " \
                "and any other countries is 'no' " do
        assert_next_node :vaccination_status, for_response: "none"
      end
    end
  end

  context "question: which_1_country" do
    setup do
      testing_node :which_1_country
      add_responses which_country: "spain",
                    any_other_countries_1: "yes"
    end

    should "render question" do
      assert_rendered_question
    end

    context "validations" do
      should "be invalid for a country that has already been chosen" do
        assert_invalid_response "spain"
      end

      should "be valid for a country that has not already been chosen" do
        assert_valid_response "argentina"
      end
    end

    context "next_node" do
      should "have a next node of any_other_countries_2 " \
                "for any response " \
                "when which country is 'spain' " \
                "and any other countries is 'yes' " do
        assert_next_node :any_other_countries_2, for_response: "argentina"
      end
    end
  end

  context "question: vaccination_status" do
    setup do
      testing_node :vaccination_status
      add_responses which_country: "spain",
                    any_other_countries_1: "no",
                    transit_countries: "none"
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of travelling_with_children " \
                "for any response " \
                "when which country is 'spain' " \
                "and any other countries is 'no' " \
                "and transit countries is 'none' " do
        assert_next_node :travelling_with_children, for_response: "vaccinated"
      end
    end
  end

  context "question: travelling_with_children" do
    setup do
      testing_node :travelling_with_children
      add_responses which_country: "spain",
                    any_other_countries_1: "no",
                    transit_countries: "none",
                    vaccination_status: "vaccinated"
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of results " \
                "for any response " \
                "when which country is 'spain' " \
                "and any other countries is 'no' " \
                "and transit countries is 'no' " \
                "and vaccination status is 'vaccinated' " do
        assert_next_node :results, for_response: "zero_to_four"
      end
    end
  end

  context "outcome: results" do
    setup do
      testing_node :results
    end

    context "country content that has not had the headers converted" do
      setup do
        add_responses which_country: "belize",
                      any_other_countries_1: "no",
                      transit_countries: "none",
                      vaccination_status: "vaccinated",
                      travelling_with_children: "none"
      end

      should "render the entry requirements" do
        assert_rendered_outcome text: "You should read the Belize entry requirements"
      end
    end

    context "country content that has had the headers converted" do
      setup do
        add_responses which_country: "spain",
                      any_other_countries_1: "no",
                      transit_countries: "none",
                      vaccination_status: "vaccinated",
                      travelling_with_children: "none"
      end

      should "render the appropriate country name" do
        assert_rendered_outcome text: "Spain"
      end

      should "render transit guidance when transit countries includes a selected country" do
        add_responses which_country: "spain",
                      any_other_countries_1: "yes",
                      which_1_country: "argentina",
                      any_other_countries_2: "no",
                      transit_countries: "spain"
        assert_rendered_outcome text: "travelling through Spain"
      end

      should "render vaccinated guidance when user is fully vaccinated" do
        assert_rendered_outcome text: "Travelling to England if you're fully vaccinated"
      end

      should "render unvaccinated guidance when user is not fully vaccinated" do
        add_responses vaccination_status: "none"
        assert_rendered_outcome text: "Returning to England if you're not fully vaccinated"
      end

      should "render travelling with children zero to four guidance when user is travelling with children" do
        add_responses travelling_with_children: "zero_to_four"
        assert_rendered_outcome text: "travelling with children and young people"
        assert_rendered_outcome text: "Returning to England with children aged 4 and under"
      end

      should "render travelling with children five to seventeen guidance when user is travelling with children" do
        add_responses travelling_with_children: "five_to_seventeen"
        assert_rendered_outcome text: "travelling with children and young people"
        assert_rendered_outcome text: "Returning to England with young people aged 5 to 17"
      end

      should "render the exempt jobs guidance" do
        assert_rendered_outcome text: "Exemptions because of your job"
      end

      should "render the arriving for urgent medical treatment guidance" do
        assert_rendered_outcome text: "Returning to England to receive urgent medical treatment"
      end
    end
  end
end
