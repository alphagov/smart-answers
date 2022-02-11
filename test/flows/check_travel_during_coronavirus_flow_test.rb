require "test_helper"
require "support/flow_test_helper"

class CheckTravelDuringCoronavirusFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    testing_flow CheckTravelDuringCoronavirusFlow
    stub_worldwide_api_has_locations(%w[spain ireland italy poland])
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
        SmartAnswer::Calculators::CheckTravelDuringCoronavirusCalculator.any_instance.stubs(:red_list_countries).returns(%w[spain])
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
        SmartAnswer::Calculators::CheckTravelDuringCoronavirusCalculator.any_instance.stubs(:red_list_countries).returns(%w[spain])
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
      SmartAnswer::Calculators::CheckTravelDuringCoronavirusCalculator.any_instance.stubs(:red_list_countries).returns(%w[spain])
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
      add_responses which_country: "poland",
                    any_other_countries_1: "no"
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of travelling_with_young_people " \
                "if the user is not travelling to a red list country " do
        assert_next_node :travelling_with_young_people, for_response: "3371ccf8123dfadf"
      end

      should "have a next node of travelling_with_children " \
                "if the user is travelling to a red list country " do
        add_responses which_country: "spain",
                      going_to_countries_within_10_days: "yes"
        SmartAnswer::Calculators::CheckTravelDuringCoronavirusCalculator.any_instance.stubs(:red_list_countries).returns(%w[spain])
        assert_next_node :travelling_with_children, for_response: "3371ccf8123dfadf"
      end
    end
  end

  context "question: travelling_with_children" do
    setup do
      testing_node :travelling_with_children
      add_responses which_country: "spain",
                    any_other_countries_1: "no",
                    going_to_countries_within_10_days: "yes",
                    vaccination_status: "3371ccf8123dfadf"
      SmartAnswer::Calculators::CheckTravelDuringCoronavirusCalculator.any_instance.stubs(:red_list_countries).returns(%w[spain])
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

  context "question: travelling_with_young_people" do
    setup do
      testing_node :travelling_with_young_people
      add_responses which_country: "spain",
                    any_other_countries_1: "no",
                    vaccination_status: "3371ccf8123dfadf"
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of results " \
                "for any response " do
        assert_next_node :results, for_response: "yes"
      end
    end
  end

  context "outcome: results" do
    setup do
      testing_node :results
      add_responses which_country: "poland",
                    any_other_countries_1: "no",
                    vaccination_status: "3371ccf8123dfadf",
                    travelling_with_young_people: "no"
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

    should "render 'exempt vaccination content' if exempt from vaccination" do
      add_responses vaccination_status: "529202127233d442"
      assert_rendered_outcome text: "The country you’re travelling to decides its own rules"
    end

    context "content for countries changing covid status" do
      should "render 'move to the red list' content for countries moving to the red list" do
        travel_to("2022-01-01") do
          WorldLocation.stubs(:travel_rules).returns({
            "results" => [
              {
                "title" => "Poland",
                "details" => {
                  "slug" => "poland",
                },
                "england_coronavirus_travel" => [
                  {
                    "covid_status" => "not_red",
                    "covid_status_applies_at" => "2021-12-20T:02:00.000+00:00",
                  },
                  {
                    "covid_status" => "red",
                    "covid_status_applies_at" => "2022-02-20T:02:00.000+00:00",
                  },
                ],
              },
            ],
          })
          assert_rendered_outcome text: "Poland will move to the red list for travel to England"
        end
      end

      should "render 'removed from the red list' content for countries moving from the red list" do
        travel_to("2022-01-01") do
          WorldLocation.stubs(:travel_rules).returns({
            "results" => [
              {
                "title" => "Poland",
                "details" => {
                  "slug" => "poland",
                },
                "england_coronavirus_travel" => [
                  {
                    "covid_status" => "red",
                    "covid_status_applies_at" => "2021-12-20T:02:00.000+00:00",
                  },
                  {
                    "covid_status" => "not_red",
                    "covid_status_applies_at" => "2022-02-20T:02:00.000+00:00",
                  },
                ],
              },
            ],
          })

          add_responses going_to_countries_within_10_days: "no",
                        travelling_with_children: "zero_to_four"
          assert_rendered_outcome text: "Poland will be removed from the red list for travel to England"
        end
      end

      should "not render changing status content if most recent status is in the past" do
        travel_to("2022-03-01") do
          WorldLocation.stubs(:travel_rules).returns({
            "results" => [
              {
                "title" => "Poland",
                "details" => {
                  "slug" => "poland",
                },
                "england_coronavirus_travel" => [
                  {
                    "covid_status" => "red",
                    "covid_status_applies_at" => "2021-12-20T:02:00.000+00:00",
                  },
                  {
                    "covid_status" => "not_red",
                    "covid_status_applies_at" => "2022-02-20T:02:00.000+00:00",
                  },
                ],
              },
            ],
          })

          assert_no_match "Poland will be removed from the red list for travel to England", @test_flow.outcome_text
        end
      end
    end

    context "country specific content that has had the headers converted" do
      setup do
        SmartAnswer::Calculators::CheckTravelDuringCoronavirusCalculator.any_instance.stubs(:countries_with_content_headers_converted).returns(%w[spain italy])
        add_responses which_country: "italy"
      end

      should "render the specific country guidance" do
        assert_rendered_outcome text: "You should read the Italy entry requirements guidance. Based on your answers, relevant sections are:"
      end

      should "render transiting guidance for transit countries" do
        add_responses any_other_countries_1: "yes",
                      which_1_country: "spain",
                      any_other_countries_2: "no",
                      transit_countries: "spain"
        assert_rendered_outcome text: "travelling through Spain"
      end

      should "render link to fully vaccinated people guidance if fully vaccinated" do
        add_responses vaccination_status: "3371ccf8123dfadf"
        assert_rendered_outcome text: "fully vaccinated people (opens in new tab)"
      end

      should "render link to fully vaccinated people guidance if taking part in vaccine trial" do
        add_responses vaccination_status: "e9e286f8822bc330"
        assert_rendered_outcome text: "fully vaccinated people (opens in new tab)"
      end

      should "render link to people who aren't fully vaccinated guidance if not fully vaccinated" do
        add_responses vaccination_status: "9ddc7655bfd0d477"
        assert_rendered_outcome text: "people who aren't fully vaccinated (opens in new tab)"
      end

      should "not render link to fully vaccinated people guidance if exempt from vaccination" do
        add_responses vaccination_status: "529202127233d442"
        assert_no_match "fully vaccinated people (opens in new tab)", @test_flow.outcome_text
      end

      should "not render link to people who aren't fully vaccinated guidance if exempt from vaccination" do
        add_responses vaccination_status: "529202127233d442"
        assert_no_match "people who aren't fully vaccinated (opens in new tab)", @test_flow.outcome_text
      end

      should "render guidance for people who aren't fully vaccinated" do
        add_responses vaccination_status: "9ddc7655bfd0d477"
        assert_rendered_outcome text: "Returning to England if you’re not fully vaccinated"
      end

      should "render guidance for people who are fully vaccinated" do
        assert_rendered_outcome text: "Returning to England if you’re fully vaccinated"
      end

      should "render guidance for people travelling with children" do
        add_responses travelling_with_young_people: "yes"
        assert_rendered_outcome text: "travelling with children and young people"
      end

      should "not render guidance for travelling with young people if not travelling with children or unders 18s" do
        add_responses travelling_with_young_people: "no"
        assert_no_match "travelling with children and young people", @test_flow.outcome_text
      end

      should "render guidance for people travelling with children when travelling to a red list country" do
        travel_to("2022-02-01") do
          WorldLocation.stubs(:travel_rules).returns({
            "results" => [
              {
                "title" => "Spain",
                "details" => {
                  "slug" => "spain",
                },
                "england_coronavirus_travel" => [
                  {
                    "covid_status" => "red",
                    "covid_status_applies_at" => "2021-12-20T:02:00.000+00:00",
                  },
                ],
              },
            ],
          })
          add_responses which_country: "spain",
                        travelling_with_children: "zero_to_four"
          assert_rendered_outcome text: "travelling with children and young people"
        end
      end

      should "render not guidance for people travelling with children when travelling to a red list country if not travelling with children" do
        travel_to("2022-02-01") do
          WorldLocation.stubs(:travel_rules).returns({
            "results" => [
              {
                "title" => "Spain",
                "details" => {
                  "slug" => "spain",
                },
                "england_coronavirus_travel" => [
                  {
                    "covid_status" => "red",
                    "covid_status_applies_at" => "2021-12-20T:02:00.000+00:00",
                  },
                ],
              },
            ],
          })
          add_responses which_country: "spain",
                        travelling_with_children: "none"
          assert_no_match "travelling with children and young people", @test_flow.outcome_text
        end
      end

      should "render other guidance for entering" do
        assert_rendered_outcome text: "There may also be other requirements for entering"
      end
    end

    context "country specific content that has not had the headers converted" do
      setup do
        add_responses which_country: "poland",
                      any_other_countries_1: "no",
                      transit_countries: "none",
                      going_to_countries_within_10_days: "no",
                      vaccination_status: "3371ccf8123dfadf",
                      travelling_with_young_people: "no"
      end

      should "render the entry requirements" do
        assert_rendered_outcome text: "You should read the Poland entry requirements"
      end
    end

    context "content with a red list country" do
      setup do
        WorldLocation.stubs(:travel_rules).returns({
          "results" => [
            {
              "title" => "Spain",
              "details" => {
                "slug" => "spain",
              },
              "england_coronavirus_travel" => [
                {
                  "covid_status" => "red",
                  "covid_status_applies_at" => "2020-12-20T:02:00.000+00:00",
                },
              ],
            },
          ],
        })
        add_responses which_country: "spain",
                      any_other_countries_1: "no",
                      going_to_countries_within_10_days: "yes",
                      vaccination_status: "3371ccf8123dfadf",
                      travelling_with_children: "none"
      end

      should "render country red list status" do
        assert_rendered_outcome text: "Spain is on the travel red list."
      end

      should "render red list country guidance" do
        assert_rendered_outcome text: "Returning to England after visiting a red list country"
      end

      should "render travelling with children zero to four guidance when user is travelling with children" do
        add_responses travelling_with_children: "zero_to_four"
        assert_rendered_outcome text: "Returning to England with children aged 4 and under"
      end

      should "render travelling with children five to seventeen guidance when user is travelling with children" do
        add_responses travelling_with_children: "five_to_seventeen"
        assert_rendered_outcome text: "Returning to England with young people aged 5 to 17"
      end

      should "render the exempt medical guidance" do
        assert_rendered_outcome text: "Exemptions for medical reasons"
      end

      should "render the exempt compassionate guidance" do
        assert_rendered_outcome text: "Exemptions for compassionate reasons"
      end
    end

    context "content without a red list country" do
      setup do
        add_responses which_country: "spain",
                      any_other_countries_1: "no",
                      transit_countries: "none",
                      going_to_countries_within_10_days: "no",
                      vaccination_status: "3371ccf8123dfadf",
                      travelling_with_young_people: "no"
      end

      should "render vaccinated guidance when user is fully vaccinated" do
        assert_rendered_outcome text: "Returning to England if you’re fully vaccinated"
      end

      should "render unvaccinated guidance when user is not fully vaccinated" do
        add_responses vaccination_status: "9ddc7655bfd0d477"
        assert_rendered_outcome text: "Returning to England if you’re not fully vaccinated"
      end

      should "render travelling with children/young people guidance when user is travelling with children/young people" do
        add_responses travelling_with_young_people: "yes"
        assert_rendered_outcome text: "Returning to England with children and young people"
      end

      should "render the exempt jobs guidance" do
        assert_rendered_outcome text: "Exemptions because of your job"
      end
    end

    context "content for Ireland" do
      setup do
        add_responses which_country: "ireland",
                      any_other_countries_1: "no",
                      transit_countries: "none",
                      going_to_countries_within_10_days: "no",
                      vaccination_status: "3371ccf8123dfadf",
                      travelling_with_children: "none"
      end

      should "render Ireland country guidance but no other country guidance if user only travelling to Ireland" do
        assert_rendered_outcome text: "Returning to England from Ireland"
        assert_no_match "Returning to England if you’re fully vaccinated", @test_flow.outcome_text
      end

      should "render Ireland country guidance and red list guidance if user also travelled to red list country" do
        add_responses any_other_countries_1: "yes",
                      which_1_country: "spain",
                      any_other_countries_2: "no",
                      transit_countries: "none",
                      going_to_countries_within_10_days: "yes"
        SmartAnswer::Calculators::CheckTravelDuringCoronavirusCalculator.any_instance.stubs(:red_list_countries).returns(%w[spain])

        assert_rendered_outcome text: "If you’ve been in Ireland for 10 days or more before travelling to England"
        assert_rendered_outcome text: "Returning to England after visiting a red list country"
      end

      should "render Ireland country guidance and other country guidance if user is vaccinated also travelled to other countries" do
        add_responses any_other_countries_1: "yes",
                      which_1_country: "spain",
                      any_other_countries_2: "no"

        assert_rendered_outcome text: "If you’ve been in Ireland for 10 days or more before travelling to England"
        assert_rendered_outcome text: "Returning to England if you’re fully vaccinated"
      end

      should "render Ireland country guidance and other country guidance if user is not vaccinated also travelled to other countries" do
        add_responses any_other_countries_1: "yes",
                      which_1_country: "spain",
                      any_other_countries_2: "no",
                      vaccination_status: "9ddc7655bfd0d477"

        assert_rendered_outcome text: "If you’ve been in Ireland for 10 days or more before travelling to England"
        assert_rendered_outcome text: "Returning to England if you’re not fully vaccinated"
      end
    end
  end
end
