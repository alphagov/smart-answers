# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'
require 'gds_api/test_helpers/worldwide'


class WhatVisaToVisitUkTest < ActiveSupport::TestCase
  include FlowTestHelper
  include GdsApi::TestHelpers::Worldwide

  setup do
    @location_slugs = %w(andorra anguilla south-africa venezuela yemen)
    worldwide_api_has_locations(@location_slugs)
    setup_for_testing_flow 'what-visa-to-visit-uk'
  end

  should "ask what passport do you have" do
    assert_current_node :what_passport_do_you_have?
  end

  context "choose a UKOT country" do
    setup do
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
      should "take you to the 'school N' outcome" do
        assert_current_node :outcome_school_n
      end
    end
    context "visiting child at school" do
      setup do
        add_response 'school'
      end
      should "take you to the 'school N' outcome" do
        assert_current_node :outcome_school_n
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
    context "get private medical treatment" do
      setup do
        add_response 'medical'
      end
      should "take you to the 'medical_n' outcome" do
        assert_current_node :outcome_medical_n
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
      should "take you to the 'school N' outcome" do
        assert_current_node :outcome_school_n
      end
    end
    context "visiting child at school" do
      setup do
        add_response 'school'
      end
      should "take you to the 'school N' outcome" do
        assert_current_node :outcome_school_n
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
    context "get private medical treatment" do
      setup do
        add_response 'medical'
      end
      should "take you to the 'medical_n' outcome" do
        assert_current_node :outcome_medical_n
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
    context "visiting child at school" do
      setup do
        add_response 'school'
      end
      should "take you to the 'school Y' outcome" do
        assert_current_node :outcome_school_y
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
    context "get private medical treatment" do
      setup do
        add_response 'medical'
      end
      should "take you to the 'medical_y' outcome" do
        assert_current_node :outcome_medical_y
      end
    end
    context "coming to the UK on the way somewhere else" do
      setup do
        add_response 'transit'
      end
      should "take ask you if you're planning to leave the airport?" do
        assert_current_node :planning_to_leave_airport?
      end
      context "planning to leave airport" do
        setup do
          add_response 'yes'
        end
        should "take you to the 'transit_leaving_airport' outcome" do
          assert_current_node :outcome_transit_leaving_airport
        end
      end
      context "not planning to leave airport" do
        setup do
          add_response 'no'
        end
        should "take you to outcome no visa needed" do
          assert_current_node :outcome_no_visa_needed
        end
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
    context "visiting child at school" do
      setup do
        add_response 'school'
      end
      should "take you to the 'school Y' outcome" do
        assert_current_node :outcome_school_y
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
    context "get private medical treatment" do
      setup do
        add_response 'medical'
      end
      should "take you to the 'medical_y' outcome" do
        assert_current_node :outcome_medical_y
      end
      context "Venezuelan passport" do
        setup do
          setup_for_testing_flow 'what-visa-to-visit-uk'
          add_response "venezuela"
          add_response "medical"
        end
        should "take you to the 'outcome_venezuela_transit' outcome" do
          assert_current_node :outcome_visit_venezuela
        end
      end
    end
    context "coming to the on the way somewhere else" do
      setup do
        add_response 'transit'
      end
      should "take ask you if you're planning to leave the airport?" do
        assert_current_node :planning_to_leave_airport?
      end
      context "planning to leave airport" do
        setup do
          add_response 'yes'
        end
        should "take you to the 'transit_leaving_airport' outcome" do
          assert_current_node :outcome_transit_leaving_airport
        end
      end
      context "not planning to leave airport" do
        setup do
          add_response 'no'
        end
        should "take you to the 'transit_not_leaving_airport' outcome" do
          assert_current_node :outcome_transit_not_leaving_airport
        end
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
