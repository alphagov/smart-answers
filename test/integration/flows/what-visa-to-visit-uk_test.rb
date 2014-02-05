# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'
require 'gds_api/test_helpers/worldwide'


class WhatVisaToVisitUkTest < ActiveSupport::TestCase
  include FlowTestHelper
  include GdsApi::TestHelpers::Worldwide

  setup do
    @location_slugs = %w(andorra china croatia anguilla south-africa turkey venezuela yemen oman united-arab-emirates qatar)
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
        assert_current_node :outcome_joining_family_m
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
        assert_current_node :outcome_joining_family_y
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
        assert_current_node :outcome_joining_family_y
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
      context "Chinese passport" do
        setup do
          setup_for_testing_flow 'what-visa-to-visit-uk'
          add_response "china"
          add_response "tourism"
        end
        should "take insert an additional phrase" do
          assert_current_node :outcome_general_y
          assert_phrase_list :if_china, [:china_tour_group]
        end
      end
      context "Venezuelan passport" do
        setup do
          setup_for_testing_flow 'what-visa-to-visit-uk'
          add_response "venezuela"
          add_response "tourism"
        end
        should "take you to the 'outcome_venezuela_transit' outcome" do
          assert_current_node :outcome_visit_waiver
        end
      end
    end
    context "visiting child at school" do
      setup do
        add_response 'school'
      end
      should "take you to the 'school Y' outcome" do
        assert_current_node :outcome_school_y
      end
      context "Venezuelan passport" do
        setup do
          setup_for_testing_flow 'what-visa-to-visit-uk'
          add_response "venezuela"
          add_response "school"
        end
        should "take you to the 'outcome_venezuela_transit' outcome" do
          assert_current_node :outcome_visit_waiver
        end
      end
      context "Oman passport" do
        setup do
          setup_for_testing_flow 'what-visa-to-visit-uk'
          add_response "oman"
          add_response "school"
        end
        should "take you to the 'outcome_venezuela_transit' outcome" do
          assert_current_node :outcome_visit_waiver
        end
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
          assert_current_node :outcome_visit_waiver
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
      context "Venezuelan passport" do
        setup do
          setup_for_testing_flow 'what-visa-to-visit-uk'
          add_response "venezuela"
          add_response "transit"
        end
        should "take you to the 'outcome_venezuela_transit' outcome" do
          assert_current_node :outcome_visit_waiver
        end
      end
    end
    context "coming to join family" do
      setup do
        add_response 'family'
      end
      should "take you to outcome Family Y" do
        assert_current_node :outcome_joining_family_y
      end
    end
  end
  context "testing turkey phrase list" do
    setup do
      add_response "turkey"
      add_response "work"
    end
    should "takes you to outcome_work_y" do
      assert_current_node :outcome_work_y
      assert_phrase_list :if_turkey, [:turkey_business_person_visa]
    end
  end
    context "testing outcome visit waiver" do
      setup do
        add_response 'oman'
        add_response 'medical'
      end
      should "take you to outcome visit waiver" do
        assert_current_node :outcome_visit_waiver
        assert_phrase_list :if_oman_qatar_uae, [:electronic_visa_waiver]
    end
  end
  

      
  context "testing croatia phrase list" do
    setup do
      add_response "croatia"
    end
    should "takes you to outcome_no_visa_needed with croatia phraselist" do
      assert_current_node :outcome_no_visa_needed
      assert_phrase_list :if_croatia, [:croatia_work_permit]
    end
  end
end
