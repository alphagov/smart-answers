require "test_helper"
require "support/flow_test_helper"

class CovidTravelAbroadFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    testing_flow CovidTravelAbroadFlow
    stub_worldwide_api_has_locations(%w[spain italy poland])
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

      should "have a next node of which_1_country " \
                "for a 'yes' response " \
                "when which country is 'spain' " do
        assert_next_node :which_1_country, for_response: "yes"
      end

      should "have a next node of transit_countries " \
               "for a 'no' response " \
               "when more than one country has been selected " do
        add_responses which_country: "spain",
                      any_other_countries_1: "yes",
                      which_1_country: "italy"
        assert_next_node :transit_countries, for_response: "no"
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
        assert_valid_response "italy"
      end
    end

    context "next_node" do
      should "have a next node of any_other_countries_2 " \
                "for any response " do
        assert_next_node :any_other_countries_2, for_response: "italy"
      end
    end
  end

  context "question: transit_countries" do
    setup do
      testing_node :transit_countries
      add_responses which_country: "spain",
                    any_other_countries_1: "yes",
                    which_1_country: "italy",
                    any_other_countries_2: "no"
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of vaccination_status " \
                "for a 'none' response " \
                "if not travelling to a red list country" do
        assert_next_node :vaccination_status, for_response: "none"
      end

      should "have a next node of going_to_countries_within_10_days " \
                "for a 'none' response " \
                "if travelling to a red list country" do
        SmartAnswer::Calculators::CovidTravelAbroadCalculator.any_instance.stubs(:red_list_countries).returns(%w[spain])
        assert_next_node :going_to_countries_within_10_days, for_response: "none"
      end

      should "have a next node of vaccination_status " \
                "for a country response " \
                "if not travelling to a red list country" do
        assert_next_node :vaccination_status, for_response: "spain"
      end

      should "have a next node of going_to_countries_within_10_days " \
                "for a country response " \
                "if travelling to a red list country" do
        SmartAnswer::Calculators::CovidTravelAbroadCalculator.any_instance.stubs(:red_list_countries).returns(%w[spain])
        assert_next_node :going_to_countries_within_10_days, for_response: "spain"
      end
    end
  end

  context "question: going_to_countries_within_10_days" do
    setup do
      testing_node :going_to_countries_within_10_days
      add_responses which_country: "spain",
                    any_other_countries_1: "yes",
                    which_1_country: "poland",
                    any_other_countries_2: "no",
                    transit_countries: "none"
      SmartAnswer::Calculators::CovidTravelAbroadCalculator.any_instance.stubs(:red_list_countries).returns(%w[spain])
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of vaccination_status " \
                "for any response " do
        assert_next_node :vaccination_status, for_response: "no"
      end
    end
  end

  context "question: vaccination_status" do
    setup do
      testing_node :vaccination_status
      add_responses which_country: "spain",
                    any_other_countries_1: "no"
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of travelling_with_children " \
                "for any response " do
        assert_next_node :travelling_with_children, for_response: "vaccinated"
      end
    end
  end

  context "question: travelling_with_children" do
    setup do
      testing_node :travelling_with_children
      add_responses which_country: "spain",
                    any_other_countries_1: "no",
                    vaccination_status: "vaccinated"
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of results " \
                "for any response " do
        assert_next_node :results, for_response: "zero_to_four"
      end
    end
  end

  context "outcome: results" do
    setup do
      testing_node :results
      add_responses which_country: "poland",
                    any_other_countries_1: "no",
                    vaccination_status: "vaccinated",
                    travelling_with_children: "none"
    end

    should "render 'travelling to' content" do
      assert_rendered_outcome text: "You are travelling to"
    end

    should "render 'travelling through' content if at least one transit stop" do
      add_responses any_other_countries_1: "yes",
                    which_1_country: "spain",
                    any_other_countries_2: "no",
                    transit_countries: "spain"
      assert_rendered_outcome text: "You are travelling through"
    end

    context "country specific content that has had the headers converted" do
      setup do
        SmartAnswer::Calculators::CovidTravelAbroadCalculator.any_instance.stubs(:countries_with_content_headers_converted).returns(%w[spain italy])
        add_responses which_country: "italy"
      end

      should "render the specific country guidance" do
        assert_rendered_outcome text: "You should read the following sections of the Italy entry requirements guidance"
      end

      should "render transiting guidance for transit countries" do
        add_responses any_other_countries_1: "yes",
                      which_1_country: "spain",
                      any_other_countries_2: "no",
                      transit_countries: "spain"
        assert_rendered_outcome text: "travelling through Spain"
      end

      should "render guidance for people who aren't fully vaccinated" do
        add_responses vaccination_status: "none"
        assert_rendered_outcome text: "people who aren't fully vaccinated"
      end

      should "render guidance for people who are fully vaccinated" do
        assert_rendered_outcome text: "fully vaccinated people"
      end

      should "render guidance for people travelling with children" do
        add_responses travelling_with_children: "zero_to_four"
        assert_rendered_outcome text: "travelling with children and young people"
      end

      should "render other guidance for entering" do
        assert_rendered_outcome text: "There may be other requirements for entering"
      end
    end

    context "country specific content that has not had the headers converted" do
      setup do
        add_responses which_country: "poland",
                      any_other_countries_1: "no",
                      transit_countries: "none",
                      going_to_countries_within_10_days: "no",
                      vaccination_status: "vaccinated",
                      travelling_with_children: "none"
      end

      should "render the entry requirements" do
        assert_rendered_outcome text: "You should read the Poland entry requirements"
      end
    end
    end
  end
end
