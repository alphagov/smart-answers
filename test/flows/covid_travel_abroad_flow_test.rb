require "test_helper"
require "support/flow_test_helper"

class CovidTravelAbroadFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  countries = %w[argentina belize canada]

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
        assert_next_node :any_other_countries_1, for_response: "canada"
      end
    end
  end

  context "question: any_other_countries_1" do
    setup do
      testing_node :any_other_countries_1
      add_responses which_country: "canada"
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of vaccination_status " \
                "for a 'no' response " \
                "when which country is 'canada' " do
        assert_next_node :transit_countries, for_response: "no"
      end

      should "have a next node of which_1_country " \
                "for a 'yes' response " \
                "when which country is 'canada' " do
        assert_next_node :which_1_country, for_response: "yes"
      end
    end
  end

  context "question: transit_countries" do
    setup do
      testing_node :transit_countries
      add_responses which_country: "canada",
                    any_other_countries_1: "no"
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of vaccination_status " \
                "for any response " \
                "when which country is 'canada' " \
                "and any other countries is 'no' " do
        assert_next_node :vaccination_status, for_response: "none"
      end
    end
  end

  context "question: which_1_country" do
    setup do
      testing_node :which_1_country
      add_responses which_country: "canada",
                    any_other_countries_1: "yes"
    end

    should "render question" do
      assert_rendered_question
    end

    context "validations" do
      should "be invalid for a country that has already been chosen" do
        assert_invalid_response "canada"
      end

      should "be valid for a country that has not already been chosen" do
        assert_valid_response "argentina"
      end
    end

    context "next_node" do
      should "have a next node of any_other_countries_2 " \
                "for any response " \
                "when which country is 'canada' " \
                "and any other countries is 'yes' " do
        assert_next_node :any_other_countries_2, for_response: "argentina"
      end
    end
  end

  context "question: vaccination_status" do
    setup do
      testing_node :vaccination_status
      add_responses which_country: "canada",
                    any_other_countries_1: "no",
                    transit_countries: "none"
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of travelling_with_children " \
                "for any response " \
                "when which country is 'canada' " \
                "and any other countries is 'no' " \
                "and transit countries is 'none' " do
        assert_next_node :travelling_with_children, for_response: "fully_vaccinated"
      end
    end
  end

  context "question: travelling_with_children" do
    setup do
      testing_node :travelling_with_children
      add_responses which_country: "canada",
                    any_other_countries_1: "no",
                    transit_countries: "none",
                    vaccination_status: "fully_vaccinated"
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of results " \
                "for any response " \
                "when which country is 'canada' " \
                "and any other countries is 'no' " \
                "and transit countries is 'none' " \
                "and vaccination status is 'fully_vaccinated' " do
        assert_next_node :results, for_response: "yes"
      end
    end
  end

  context "outcome: results" do
    setup do
      testing_node :results
      add_responses which_country: "canada",
                    any_other_countries_1: "no",
                    transit_countries: "none",
                    vaccination_status: "fully_vaccinated",
                    travelling_with_children: "no"
    end

    should "render the appropriate country name" do
      assert_rendered_outcome text: "Canada"
    end

    should "render transit guidance when transit countries includes a selected country" do
      add_responses which_country: "canada",
                    any_other_countries_1: "no",
                    transit_countries: "canada"
      assert_rendered_outcome text: "Transit guidance"
    end

    should "render vaccinated guidance when user is fully vaccinated" do
      assert_rendered_outcome text: "Guidance for vaccinated people"
      assert_rendered_outcome text: "UK guidance for vaccinated people"
    end

    should "render unvaccinated guidance when user is not fully vaccinated" do
      add_responses vaccination_status: "unvaccinated"
      assert_rendered_outcome text: "Guidance for unvaccinated people"
      assert_rendered_outcome text: "UK guidance for unvaccinated people"
    end

    should "render travelling with children guidance when user is travelling with children" do
      add_responses travelling_with_children: "yes"
      assert_rendered_outcome text: "Guidance for travelling with children"
      assert_rendered_outcome text: "UK guidance for travelling with children"
    end

    should "render the exempt jobs guidance" do
      assert_rendered_outcome text: "UK exempt jobs guidance"
    end

    should "render the arriving for urgent medical treatment guidance" do
      assert_rendered_outcome text: "UK guidance on arriving for urgent medical treatment"
    end
  end
end
