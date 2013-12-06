# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'
require 'gds_api/test_helpers/worldwide'


class WhatVisaToVisitUkTest < ActiveSupport::TestCase
  include FlowTestHelper
  include GdsApi::TestHelpers::Worldwide

  setup do
    @location_slugs = %w(andorra anguilla south-africa yemen)
    worldwide_api_has_locations(@location_slugs)
    setup_for_testing_flow 'what-visa-to-visit-uk'
  end

  should "ask what passport do you have" do
    assert_current_node :what_passport_do_you_have?
  end

  context "choose a UKOT country" do
    setup do
      worldwide_api_has_organisations_for_location('anguilla', read_fixture_file('worldwide/anguilla_organisations.json'))
      add_response 'anguilla'
    end
    should "ask what are you coming to the UK to do" do
      assert_current_node :purpose_of_visit?
    end
    context "coming to the UK to study" do
      setup do
        add_response 'study'
      end
      should "take you to the outcome Study M" do
        assert_current_node :outcome_study_m
      end
    end
    context "coming to the UK to work" do
      setup do
        add_response 'work'
      end
      should "take you to outcome Work M" do
        assert_current_node :outcome_work_m
      end
    end
    context "tourism, visiting friends or family" do
      setup do
        add_response 'tourism'
      end
      should "take you to the 'general y' outcome" do
        assert_current_node :outcome_general_y
      end
    end
    context "getting married" do
      setup do
        add_response 'marriage'
      end
      should "take you to the marriage outcome" do
        assert_current_node :outcome_marriage
      end
    end
    context "coming to the UK on the way somewhere else" do
      setup do
        add_response 'transit'
      end
      should "take you to outcome no visa needed" do
        assert_current_node :outcome_no_visa_needed
      end
    end
    context "coming to join family" do
      setup do
        add_response 'family'
      end
      should "take you to outcome Family M" do
        assert_current_node :outcome_family_m
      end
    end
  end

  context "choose a Non-visa nationals country" do
    setup do
      worldwide_api_has_organisations_for_location('andorra', read_fixture_file('worldwide/andorra_organisations.json'))
      add_response 'andorra'
    end
    should "ask what are you coming to the UK to do" do
      assert_current_node :purpose_of_visit?
    end
    context "coming to the UK to study" do
      setup do
        add_response 'study'
      end
      should "take you to the outcome Study M" do
        assert_current_node :outcome_study_m
      end
    end
    context "coming to the UK to work" do
      setup do
        add_response 'work'
      end
      should "take you to outcome Work M" do
        assert_current_node :outcome_work_m
      end
    end
    context "tourism, visiting friends or family" do
      setup do
        add_response 'tourism'
      end
      should "take you to the 'visit/business' outcome" do
        assert_current_node :outcome_visit_business_n
      end
    end
    context "getting married" do
      setup do
        add_response 'marriage'
      end
      should "take you to the marriage outcome" do
        assert_current_node :outcome_marriage
      end
    end
    context "coming to the on the way somewhere else" do
      setup do
        add_response 'transit'
      end
      should "take you to outcome no visa needed" do
        assert_current_node :outcome_no_visa_needed
      end
    end
    context "coming to join family" do
      setup do
        add_response 'family'
      end
      should "take you to outcome Family Y" do
        assert_current_node :outcome_family_y
      end
    end
  end

  context "choose a Visa nationals country" do
    setup do
      worldwide_api_has_organisations_for_location('yemen', read_fixture_file('worldwide/yemen_organisations.json'))
      add_response 'yemen'
    end
    should "ask what are you coming to the UK to do" do
      assert_current_node :purpose_of_visit?
    end
    context "coming to the UK to study" do
      setup do
        add_response 'study'
      end
      should "take you to the outcome Study Y" do
        assert_current_node :outcome_study_y
      end
    end
    context "coming to the UK to work" do
      setup do
        add_response 'work'
      end
      should "take you to outcome Work Y" do
        assert_current_node :outcome_work_y
      end
    end
    context "tourism, visiting friends or family" do
      setup do
        add_response 'tourism'
      end
      should "take you to the 'general y' outcome" do
        assert_current_node :outcome_general_y
      end
    end
    context "getting married" do
      setup do
        add_response 'marriage'
      end
      should "take you to the marriage outcome" do
        assert_current_node :outcome_marriage
      end
    end
    context "coming to the on the way somewhere else" do
      setup do
        add_response 'transit'
      end
      should "take you to Transit M outcome" do
        assert_current_node :outcome_transit_m
      end
    end
    context "coming to join family" do
      setup do
        add_response 'family'
      end
      should "take you to outcome Family Y" do
        assert_current_node :outcome_family_y
      end
    end
  end

  context "choose a DATV country" do
    setup do
      worldwide_api_has_organisations_for_location('south-africa', read_fixture_file('worldwide/south-africa_organisations.json'))
      add_response 'south-africa'
    end
    should "ask what are you coming to the UK to do" do
      assert_current_node :purpose_of_visit?
    end
    context "coming to the UK to study" do
      setup do
        add_response 'study'
      end
      should "take you to the outcome Study Y" do
        assert_current_node :outcome_study_y
      end
    end
    context "coming to the UK to work" do
      setup do
        add_response 'work'
      end
      should "take you to outcome Work Y" do
        assert_current_node :outcome_work_y
      end
    end
    context "tourism, visiting friends or family" do
      setup do
        add_response 'tourism'
      end
      should "take you to the 'general y' outcome" do
        assert_current_node :outcome_general_y
      end
    end
    context "getting married" do
      setup do
        add_response 'marriage'
      end
      should "take you to the marriage outcome" do
        assert_current_node :outcome_marriage
      end
    end
    context "coming to the on the way somewhere else" do
      setup do
        add_response 'transit'
      end
      should "take you to outcome Transit Y" do
        assert_current_node :outcome_transit_y
      end
    end
    context "coming to join family" do
      setup do
        add_response 'family'
      end
      should "take you to outcome Family Y" do
        assert_current_node :outcome_family_y
      end
    end
  end
end
