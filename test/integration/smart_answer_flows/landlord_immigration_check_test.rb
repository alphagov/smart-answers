require_relative "../../test_helper"
require_relative "flow_test_helper"
require 'gds_api/test_helpers/imminence'

require "smart_answer_flows/landlord-immigration-check"

class LandlordImmigrationCheckFlowTest < ActiveSupport::TestCase
  include FlowTestHelper
  include GdsApi::TestHelpers::Imminence

  setup do
    setup_for_testing_flow SmartAnswer::LandlordImmigrationCheckFlow

    imminence_has_areas_for_postcode("PA3%202SW", [{ type: 'EUR', name: 'Scotland', country_name: 'Scotland' }])
    imminence_has_areas_for_postcode("B1%201PW", [{ type: 'EUR', name: 'West Midlands', country_name: 'England' }])
  end

  should "start by asking first question" do
    assert_current_node :property?
  end

  should "lead to outcome_check_not_needed" do
    add_response "PA3 2SW"
    assert_current_node :outcome_check_not_needed
  end

  should "lead to main_home" do
    add_response "B1 1PW" # property
    assert_current_node :main_home?
  end

  should "lead to tenant_over_18" do
    add_response "B1 1PW" # property
    add_response "yes" # main_home
    assert_current_node :tenant_over_18?
  end

  should "lead to what_nationality" do
    add_response "B1 1PW" # property
    add_response "yes" # main_home
    add_response "yes" # tenant_over_18
    assert_current_node :what_nationality?
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
    add_response "eea" # what_nationality
    add_response "yes" # has_uk_passport
    assert_current_node :outcome_can_rent
  end


  context "when tenant is from eea" do
    setup do
      add_response "B1 1PW" # property
      add_response "yes" # main_home
      add_response "yes" # tenant_over_18
    end

    should "go to what_nationality outcome" do
      assert_current_node :what_nationality?
    end

    should "go to has_eu_documents if EEA is selected" do
      add_response "eea" # what_nationality?
      assert_current_node :has_eu_documents?
    end

    should "go to outcome_can_rent if tenant has EEA passport" do
      add_response "eea" # what_nationality?
      add_response "yes" # has_eu_documents?
      assert_current_node :outcome_can_rent
    end

    should "go to has_other_documents if tenant hasn't got EEA passport" do
      add_response "eea" # what_nationality?
      add_response "no" # has_eu_documents?
      assert_current_node :has_other_documents?
    end

    should "go to outcome_can_rent if tenant has got other documents" do
      add_response "eea" # what_nationality?
      add_response "no" # has_eu_documents?
      add_response "yes" # has_other_documents?
      assert_current_node :outcome_can_rent
    end

    should "go to waiting_for_documents if tenant hasn't got other documents" do
      add_response "eea" # what_nationality?
      add_response "no" # has_eu_documents?
      add_response "no" # has_other_documents?
      assert_current_node :outcome_can_not_rent
    end
  end

  should "lead to outcome_can_not_rent" do
    add_response "B1 1PW" # property
    add_response "yes" # main_home
    add_response "yes" # tenant_over_18
    add_response "eea" # what_nationality
    add_response "no" # has_eu_documents?
    add_response "no" # has_other_documents?
    assert_current_node :outcome_can_not_rent
  end
end
