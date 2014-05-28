# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'
require 'gds_api/test_helpers/worldwide'


class CheckUkVisaV2Test < ActiveSupport::TestCase
  include FlowTestHelper
  include GdsApi::TestHelpers::Worldwide

  setup do
    @location_slugs = %w(andorra anguilla armenia canada china croatia mexico south-africa turkey yemen oman united-arab-emirates qatar taiwan venezuela)
    worldwide_api_has_locations(@location_slugs)
    setup_for_testing_flow 'check-uk-visa-v2'
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
        add_response 'six_months_or_less'
      end
      should "take you to outcome no visa outcome_no_visa_needed" do
        assert_current_node :outcome_no_visa_needed
      end
    end
    context "coming to the UK to work" do
      setup do
        add_response 'work'
        add_response 'six_months_or_less'
      end
      should "take you to work_n outcome" do
        assert_current_node :outcome_work_n
      end
    end
    context "tourism, visiting friends or family" do
      setup do
        add_response 'tourism'
      end
      should "take you to school_n outcome" do
        assert_current_node :outcome_school_n
      end
    end
    context "visiting child at school" do
      setup do
        add_response 'school'
      end
      should "take you to school_n outcome" do
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
      should "take you to medical_n outcome" do
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
      should "take you to outcome family_m" do
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
    context "tourism, visiting friends or family" do
      setup do
        add_response 'tourism'
      end
      should "take you to school_n outcome" do
        assert_current_node :outcome_school_n
      end
    end
    context "visiting child at school" do
      setup do
        add_response 'school'
      end
      should "take you to school_n outcome" do
        assert_current_node :outcome_school_n
      end
    end
    context "getting married" do
      setup do
        add_response 'marriage'
      end
      should "take you to marriage outcome" do
        assert_current_node :outcome_marriage
      end
    end
    context "get private medical treatment" do
      setup do
        add_response 'medical'
      end
      should "take you to medical_n outcome" do
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
      should "take you to outcome family_y" do
        assert_current_node :outcome_joining_family_nvn
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
    context "tourism, visiting friends or family" do
      setup do
        add_response 'tourism'
      end
      should "take you to general_y outcome" do
        assert_current_node :outcome_general_y
      end
    end
    context "visiting child at school" do
      setup do
        add_response 'school'
      end
      should "take you to school_y outcome" do
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
      should "ask you if you're planning to leave the airport?" do
        assert_current_node :planning_to_leave_airport?
      end
      context "planning to leave airport" do
        setup do
          add_response 'yes'
        end
        should "take you to 'transit_leaving_airport' outcome" do
          assert_current_node :outcome_transit_leaving_airport_datv
        end
      end
      context "not planning to leave airport" do
        setup do
          add_response 'no'
        end
        should "take you to outcome no visa needed" do
          assert_current_node :outcome_transit_not_leaving_airport
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
        add_response 'six_months_or_less'
      end
      should "take you to outcome study_m" do
        assert_current_node :outcome_study_m
      end
    end
    context "coming to the UK to work" do
      setup do
        add_response 'work'
        add_response 'six_months_or_less'
      end
      should "take you to outcome work_m" do
        assert_current_node :outcome_work_m
      end
    end
    context "tourism, visiting friends or family" do
      setup do
        add_response 'tourism'
      end
      should "take you to general_y outcome" do
        assert_current_node :outcome_general_y
      end
      context "Chinese passport" do
        setup do
          setup_for_testing_flow 'check-uk-visa-v2'
          add_response "china"
          add_response "tourism"
        end
        should "take insert an additional phrase" do
          assert_current_node :outcome_general_y
          assert_phrase_list :if_china, [:china_tour_group]
        end
      end
    end
    context "visiting child at school" do
      setup do
        add_response 'school'
      end
      should "take you to school_y outcome" do
        assert_current_node :outcome_school_y
      end
      context "Oman passport" do
        setup do
          setup_for_testing_flow 'check-uk-visa-v2'
          add_response "oman"
          add_response "school"
        end
        should "take you to outcome_visit_waiver outcome" do
          assert_current_node :outcome_visit_waiver
        end
      end
    end
    context "getting married" do
      setup do
        add_response 'marriage'
      end
      should "take you to  marriage outcome" do
        assert_current_node :outcome_marriage
      end
    end
    context "get private medical treatment" do
      setup do
        add_response 'medical'
      end
      should "take you to the medical_y outcome" do
        assert_current_node :outcome_medical_y
      end
    end
    context "coming to the on the way somewhere else" do
      setup do
        add_response 'transit'
      end
      should " ask you if you're planning to leave the airport" do
        assert_current_node :planning_to_leave_airport?
      end
      context "planning to leave airport" do
        setup do
          add_response 'yes'
        end
        should "take you to transit_leaving_airport outcome" do
          assert_current_node :outcome_transit_leaving_airport_datv
        end
      end
      context "not planning to leave airport" do
        setup do
          add_response 'no'
        end
        should "take you to transit_not_leaving_airport outcome" do
          assert_current_node :outcome_transit_not_leaving_airport
        end
      end
      context "Venezuelan passport" do
        setup do
          setup_for_testing_flow 'check-uk-visa-v2'
          add_response "venezuela"
          add_response "transit"
        end
        should "" do
          assert_current_node :planning_to_leave_airport?
        end
        context "leaving airport" do
          setup do
            add_response "yes"
          end
          should "take you to the visit waiver outcome with leaving airport phraselist" do
            assert_current_node :outcome_visit_waiver
            assert_phrase_list :if_exception, [:epassport_crossing_border]
            assert_phrase_list :outcome_title, [:epassport_visa_not_needed_title]
          end
        end
        context "leaving airport" do
          setup do
            add_response "no"
          end
          should "take you to the visit waiver outcome with NOT leaving airport phraselist" do
            assert_current_node :outcome_visit_waiver
            assert_phrase_list :if_exception, [:epassport_not_crossing_border]
            assert_phrase_list :outcome_title, [:epassport_visa_not_needed_title]
          end
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
      add_response 'six_months_or_less'
    end
    should "takes you to outcome_work_m" do
      assert_current_node :outcome_work_m
    end
  end
  context "testing turkey phrase list" do
  setup do
    add_response "turkey"
    add_response "work"
    add_response "longer_than_six_months"
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
        assert_phrase_list :if_exception, [:electronic_visa_waiver]
    end
  end

  context "testing croatia phrase list" do
    setup do
      add_response "croatia"
    end
    should "takes you to outcome_no_visa_needed with croatia phraselist" do
      assert_current_node :outcome_no_visa_needed
      assert_phrase_list :no_visa_additional_sentence, [:croatia_additional_sentence]
    end
  end

  #testing canada - all groupings AND NON visa national outcome - study AND work - less AND more than 6 months
  context "testing canada" do
    setup do
      add_response "canada"
    end
    should "ask reason of staying" do
      assert_current_node :purpose_of_visit?
    end

    context "testing study reason" do
      setup do
        add_response "study"
      end
      should "ask for how long" do
        assert_current_node :staying_for_how_long?
      end

      context "testing canada/all groupings but EEA outcome - study - longer than six months" do
        setup do
          add_response "longer_than_six_months"
        end
        should "take you to outcome 2 study y" do
          assert_current_node :outcome_study_y
        end
      end

      context "testing canada/non visa national outcome- study - less or six months" do
        setup do
          add_response "six_months_or_less"
        end
        should "take you to outcome_no_visa_needed" do
          assert_current_node :outcome_no_visa_needed
          assert_phrase_list :no_visa_additional_sentence, [:study_additional_sentence]
        end
      end
    end #end canada study reason

    context "testing work reason" do
      setup do
        add_response "work"
      end
      should "ask for how long" do
        assert_current_node :staying_for_how_long?
      end

      context "testing canada/all groupings but EEA outcome - work - longer than six months" do
        setup do
          add_response "longer_than_six_months"
        end
        should "take you to outcome 2 study y" do
          assert_current_node :outcome_work_y
          assert_phrase_list :if_youth_mobility_scheme_country, [:youth_mobility_scheme]
        end
      end

      context "testing canada/non visa national outcome - work - less or six months" do
        setup do
          add_response "six_months_or_less"
        end
        should "take you to outcome 5.5 work N visa may be not needed" do
          assert_current_node :outcome_work_n
        end
      end
    end #end canada work reason
  end #end canada - NON visa country


  #testing armenia - visa national outcome - study AND work
  context "testing armenia" do
    setup do
      add_response "armenia"
    end
    should "ask reason of staying" do
      assert_current_node :purpose_of_visit?
    end

    context "testing armenia/non visa national outcome- study - less or six months" do
      setup do
        add_response "study"
        add_response "six_months_or_less"
      end
      should "take you to outcome_study_m" do
        assert_current_node :outcome_study_m
      end
    end

    context "testing armenia/non visa national outcome - work - less or six months" do
      setup do
        add_response "work"
        add_response "six_months_or_less"
      end
      should "take you to outcome outcome_work_m" do
        assert_current_node :outcome_work_m
      end
    end
  end #end armenia -  visa country

  #testing venezuela - oman - qatar - UAE
  context "testing venezuela special outcome - study - less or six months" do
    setup do
      add_response "oman"
      add_response "study"
      add_response "six_months_or_less"
    end
    should "take you to outcome_visit_waiver" do
      assert_current_node :outcome_visit_waiver
    end
  end

  context "choose a Non-visa country and check for outcome_work_m" do
    setup do
      add_response 'mexico'
      add_response 'work'
      add_response 'six_months_or_less'
    end
      should "take you to outcome work_m" do
        assert_current_node :outcome_work_n
    end
  end

  context "outcome taiwan exception study and six_months_or_less" do
    setup do
      add_response 'taiwan'
      add_response 'study'
      add_response 'six_months_or_less'
    end
      should "take you to outcome taiwan exception" do
        assert_current_node :outcome_taiwan_exception
    end
  end

  context "outcome taiwan exception tourism" do
    setup do
      add_response 'taiwan'
      add_response 'tourism'
    end
      should "take you to outcome taiwan exception" do
        assert_current_node :outcome_taiwan_exception
    end
  end

  context "outcome taiwan exception school" do
    setup do
      add_response 'taiwan'
      add_response 'school'
    end
      should "take you to outcome taiwan exception" do
        assert_current_node :outcome_taiwan_exception
    end
  end

  context "outcome taiwan exception medical" do
    setup do
      add_response 'taiwan'
      add_response 'medical'
    end
      should "take you to outcome taiwan exception" do
        assert_current_node :outcome_taiwan_exception
    end
  end
  context "outcome taiwan exception transit" do
    setup do
      add_response 'taiwan'
      add_response 'transit'
    end
    should "take you to outcome taiwan exception" do
      assert_current_node :planning_to_leave_airport?
    end
    context "leaving airport" do
      setup do
        add_response "yes"
      end
      should "take you to the visit waiver outcome with leaving airport phraselist" do
        assert_current_node :outcome_visit_waiver
        assert_phrase_list :if_exception, [:passport_bio_crossing_border]
        assert_phrase_list :outcome_title, [:passport_bio_visa_not_needed_title]
      end
    end
    context "leaving airport" do
      setup do
        add_response "no"
      end
      should "take you to the visit waiver outcome with NOT leaving airport phraselist" do
        assert_current_node :outcome_visit_waiver
        assert_phrase_list :if_exception, [:passport_bio_not_crossing_border]
        assert_phrase_list :outcome_title, [:passport_bio_visa_not_needed_title]
      end
    end
  end
  context "outcome venezuela exception transit" do
    setup do
      add_response 'venezuela'
    end
    context "coming to the UK to visit child at school" do
      setup do
        add_response 'school'
      end
      should "take you to school outcome without personalised phraselist" do
        assert_current_node :outcome_school_y
        assert_state_variable :if_exception, nil
      end
    end
    context "coming to the UK for tourism" do
      setup do
        add_response 'tourism'
      end
      should "take you to tourism outcome without personalised phraselist" do
        assert_current_node :outcome_general_y
        assert_state_variable :if_exception, nil
      end
    end
    context "coming to the UK for study" do
      setup do
        add_response 'study'
        add_response 'six_months_or_less'
      end
      should "take you to study outcome without personalised phraselist" do
        assert_current_node :outcome_study_m
        assert_state_variable :if_exception, nil
      end
    end
    context "coming to the UK for study" do
      setup do
        add_response 'medical'
      end
      should "take you to medical outcome without personalised phraselist" do
        assert_current_node :outcome_medical_y
        assert_state_variable :if_exception, nil
      end
    end
  end
end

