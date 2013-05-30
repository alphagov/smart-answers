# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'
require 'gds_api/test_helpers/worldwide'

class FindABritishEmbassyTest < ActiveSupport::TestCase
  include FlowTestHelper
  include GdsApi::TestHelpers::Worldwide
  
  setup do
    worldwide_api_has_selection_of_locations
    setup_for_testing_flow 'find-a-british-embassy'
  end

  should "ask which country you want details for" do
    assert_current_node :choose_embassy_country
  end

  should "error for a country that doesn't exist" do
    add_response 'non-existent'
    assert_current_node :choose_embassy_country, :error => true
  end

  should "display the embassy details for a country with embassy details available" do
    worldwide_api_has_organisations_for_location('australia', read_fixture_file('worldwide/australia_organisations.json'))
    add_response 'australia'
    assert_current_node :embassy_outcome
    expected_location = WorldLocation.find('australia')
    assert_state_variable :location, expected_location
    assert_state_variable :country_name, "Australia"
    assert_state_variable :organisation, expected_location.fco_organisation

    expected_titles = [
      "British High Commission Canberra",
      "British Consulate-General Sydney",
      "British Consulate-General Melbourne",
      "British Consulate Perth",
      "British Consulate Brisbane",
    ]
    assert_equal expected_titles, outcome_body.css('h3').map(&:text)
  end

  should "display the outcome with no embassies available" do
    worldwide_api_has_no_organisations_for_location('nicaragua')
    add_response 'nicaragua'
    assert_current_node :embassy_outcome
    expected_location = WorldLocation.find('nicaragua')
    assert_state_variable :location, expected_location
    assert_state_variable :country_name, "Nicaragua"
    assert_state_variable :organisation, nil

    assert_equal "No embassy details found", outcome_body.at_css('p').text
  end

  should "prefix 'the' on appropriate country names" do
    worldwide_api_has_no_organisations_for_location('bahamas')
    add_response 'bahamas'

    assert_current_node :embassy_outcome
    expected_location = WorldLocation.find('bahamas')
    assert_state_variable :location, expected_location
    assert_state_variable :country_name, "the Bahamas"
  end
end
