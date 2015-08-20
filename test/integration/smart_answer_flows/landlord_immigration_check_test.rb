require_relative "../../test_helper"
require_relative "flow_test_helper"
require 'gds_api/test_helpers/imminence'

require "smart_answer_flows/landlord-immigration-check"

class LandlordImmigrationCheckFlowTest < ActiveSupport::TestCase
  include FlowTestHelper
  include GdsApi::TestHelpers::Imminence

  setup do
    setup_for_testing_flow SmartAnswer::LandlordImmigrationCheckFlow
    imminence_has_areas_for_postcode("WC2B%206SE", [])
    imminence_has_areas_for_postcode("B1%201PW", [{ slug: "birmingham-city-council" }])
  end

  should "start by asking first question" do
    assert_current_node :property
  end

  should "lead to outcome_check_not_needed" do
    add_response "WC2B 6SE"
    assert_current_node :outcome_check_not_needed
  end

  should "lead to outcome_can_not_rent" do
    add_response "B1 1PW" # property
    add_response "yes" # main_home
    add_response "yes" # tenant_over_18
    add_response "no" # has_uk_passport
    add_response "no" # right_to_abode
    add_response "no" # has_certificate
    add_response "eu_eea_switzerland" # tenant_country
    add_response "no" # has_documents
    add_response "no" # has_other_documents
    add_response "no" # time_limited_to_remain
    add_response "no" # has_residence_card_or_eu_eea_swiss_family_member
    add_response "no" # has_asylum_card
    add_response "no" # immigration_application
    assert_current_node :outcome_can_not_rent
  end

  should "lead to outcome_can_not_rent" do
    add_response "B1 1PW" # property
    add_response "yes" # main_home
    add_response "yes" # tenant_over_18
    add_response "no" # has_uk_passport
    add_response "no" # right_to_abode
    add_response "no" # has_certificate
    add_response "non_eea_but_with_eu_eea_switzerland_family_member" # tenant_country
    add_response "no" # has_residence_card_or_eu_eea_swiss_family_member
    add_response "no" # has_asylum_card
    add_response "no" # immigration_application
    assert_current_node :outcome_can_not_rent
  end

  should "lead to outcome_check_not_needed_if_holiday_or_under_3_months" do
    add_response "B1 1PW" # property
    add_response "no" # main_home
    add_response "holiday_accommodation" # property_type
    assert_current_node :outcome_check_not_needed_if_holiday_or_under_3_months
  end

  should "lead to outcome_check_needed_if_break_clause" do
    add_response "B1 1PW" # property
    add_response "no" # main_home
    add_response "7_year_lease_property" # property_type
    assert_current_node :outcome_check_needed_if_break_clause
  end

  should "lead to outcome_check_not_needed_when_mobile_home" do
    add_response "B1 1PW" # property
    add_response "no" # main_home
    add_response "mobile_home" # property_type
    assert_current_node :outcome_check_not_needed_when_mobile_home
  end

  should "lead to outcome_check_may_be_needed_when_student" do
    add_response "B1 1PW" # property
    add_response "no" # main_home
    add_response "student_accommodation" # property_type
    assert_current_node :outcome_check_may_be_needed_when_student
  end

  should "lead to outcome_check_not_needed_when_under_18" do
    add_response "B1 1PW" # property
    add_response "yes" # main_home
    add_response "no" # tenant_over_18
    assert_current_node :outcome_check_not_needed_when_under_18
  end

  should "lead to outcome_can_rent" do
    add_response "B1 1PW" # property
    add_response "yes" # main_home
    add_response "yes" # tenant_over_18
    add_response "yes" # has_uk_passport
    assert_current_node :outcome_can_rent
  end
end
