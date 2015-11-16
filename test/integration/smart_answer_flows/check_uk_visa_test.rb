require_relative '../../test_helper'
require_relative 'flow_test_helper'
require 'gds_api/test_helpers/worldwide'

require "smart_answer_flows/check-uk-visa"

class CheckUkVisaTest < ActiveSupport::TestCase
  include FlowTestHelper
  include GdsApi::TestHelpers::Worldwide

  setup do
    @location_slugs = %w(andorra anguilla armenia bolivia canada china colombia croatia mexico south-africa stateless-or-refugee syria turkey yemen oman united-arab-emirates qatar taiwan venezuela)
    worldwide_api_has_locations(@location_slugs)
    setup_for_testing_flow SmartAnswer::CheckUkVisaFlow
  end

  should "ask what passport do you have" do
    assert_current_node :what_passport_do_you_have?
  end

  context "choose Stateless or Refugee" do
    setup do
      add_response "stateless-or-refugee"
    end

    should "suggest to apply in country of originallity or residence for outcome_marriage" do
      add_response 'marriage'

      assert_current_node :outcome_marriage
    end

    should "suggest to apply in country of originallity or residence for outcome_study_m" do
      add_response 'study'
      add_response 'six_months_or_less'

      assert_current_node :outcome_study_m
    end

    should "suggest to apply in country of originallity or residence for outcome_study_y" do
      add_response 'study'
      add_response 'longer_than_six_months'

      assert_current_node :outcome_study_y
    end

    should "suggest to apply in country of originallity or residence for outcome_work_m" do
      add_response 'work'
      add_response 'six_months_or_less'
      assert_current_node :outcome_work_m
    end

    should "suggest to apply in country of originallity or residence for outcome_work_y" do
      add_response 'work'
      add_response 'longer_than_six_months'
      assert_current_node :outcome_work_y
    end

    should "suggest to apply in country of originallity or residence for outcome_transit_leaving_airport" do
      add_response 'transit'
      add_response 'yes'

      assert_current_node :outcome_transit_leaving_airport
    end

    should "suggests to get a Direct Airside Transit visa if not leaving the airport" do
      add_response 'transit'
      add_response 'no'

      assert_current_node :outcome_transit_refugee_not_leaving_airport
    end

    should "suggest to apply in country of originallity or residence for outcome_standard_visit" do
      add_response 'tourism'

      assert_current_node :outcome_standard_visit
    end

    should "suggest to apply in country of originallity or residence for outcome_school_y" do
      add_response 'school'
      assert_current_node :outcome_school_y
    end

    should "suggest to apply in country of originallity or residence for outcome_medical_y" do
      add_response 'medical'
      assert_current_node :outcome_medical_y
    end

    should "suggest to apply in country of originallity or residence for outcome_joining_family_y" do
      add_response 'family'
      assert_current_node :outcome_joining_family_y
    end
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

  context "choose a visa national country or refugee" do
    context "when chosen armenia" do
      setup do
        add_response 'armenia'
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

      context "coming to the UK on the way somewhere else" do
        setup do
          add_response 'transit'
        end
        should "ask you if you're planning to leave the airport" do
          assert_current_node :passing_through_uk_border_control?
        end
        context "planning to leave airport" do
          setup do
            add_response 'yes'
          end
          should "take you to transit_leaving_airport outcome" do
            assert_current_node :outcome_transit_leaving_airport
          end
        end
        context "not planning to leave airport" do
          setup do
            add_response 'no'
          end
          should "take you to transit_not_leaving_airport outcome" do
            assert_current_node :outcome_no_visa_needed
          end
        end
      end
    end
  end

  context "choose a DATV country" do
    setup do
      add_response 'yemen'
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
        assert_current_node :outcome_standard_visit
      end
      context "Chinese passport" do
        setup do
          reset_responses
          add_response "china"
          add_response "tourism"
        end
        should "take insert an additional phrase" do
          assert_current_node :outcome_standard_visit
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
          reset_responses
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
    context "coming to the UK on the way somewhere else" do
      setup do
        add_response 'transit'
      end
      should " ask you if you're planning to leave the airport" do
        assert_current_node :passing_through_uk_border_control?
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
      context "Venezuelan in transit" do
        setup do
          reset_responses
          add_response "venezuela"
          add_response "transit"
        end
        should "be asked if they are leaving the airport" do
          assert_current_node :passing_through_uk_border_control?
        end
        context "when leaving airport" do
          setup do
            add_response "yes"
          end
          should "lead to outcome_transit_leaving_airport_datv" do
            assert_current_node :outcome_transit_leaving_airport_datv
          end
        end
        context "not leaving airport" do
          setup do
            add_response "no"
          end
          should "lead to outcome_transit_venezuala" do
            assert_current_node :outcome_transit_venezuala
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
    end
  end
  context "testing outcome visit waiver" do
    setup do
      add_response 'oman'
      add_response 'medical'
    end
      should "take you to outcome visit waiver" do
      assert_current_node :outcome_visit_waiver
    end
  end
  context "testing croatia phrase list" do
    setup do
      add_response "croatia"
    end
    should "takes you to outcome_no_visa_needed with croatia phraselist" do
      assert_current_node :outcome_no_visa_needed
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

  context "choose a Non-visa country and check for outcome_work_n" do
    setup do
      add_response 'mexico'
      add_response 'work'
      add_response 'six_months_or_less'
    end
      should "take you to outcome work_n" do
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
      assert_current_node :passing_through_uk_border_control?
    end
    context "leaving airport" do
      setup do
        add_response "yes"
      end
      should "take you to the transit taiwan outcome" do
        assert_current_node :outcome_transit_taiwan
      end
    end
    context "leaving airport" do
      setup do
        add_response "no"
      end
      should "take you to the transit taiwan outcome" do
        assert_current_node :outcome_transit_taiwan
      end
    end
  end
  context "check taiwan goes to outcome work n" do
    setup do
      add_response 'taiwan'
      add_response 'work'
      add_response 'six_months_or_less'
    end
    should "go to ouctome work n" do
      assert_current_node :outcome_work_n
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
      end
    end
    context "coming to the UK for tourism" do
      setup do
        add_response 'tourism'
      end
      should "take you to tourism outcome without personalised phraselist" do
        assert_current_node :outcome_standard_visit
      end
    end
    context "coming to the UK for study" do
      setup do
        add_response 'study'
        add_response 'six_months_or_less'
      end
      should "take you to study outcome without personalised phraselist" do
        assert_current_node :outcome_study_m
      end
    end
    context "coming to the UK for study" do
      setup do
        add_response 'medical'
      end
      should "take you to medical outcome without personalised phraselist" do
        assert_current_node :outcome_medical_y
      end
    end
  end

  context "Syria transit B1 B2 visa exceptions" do
    setup do
      add_response 'syria'
      add_response 'transit'
    end

    should "mention B1 and B2 visas when leaving the airport" do
      add_response 'yes'
      assert_current_node :outcome_transit_leaving_airport_datv
    end

    should "mention B1 and B2 visas when not leaving the airport" do
      add_response 'no'
      assert_current_node :outcome_transit_not_leaving_airport
    end
  end

  context "check for diplomatic and government business travellers" do
    setup do
      add_response 'bolivia'
      add_response 'diplomatic'
    end
    should "go to diplomatic and government outcome" do
      assert_current_node :outcome_diplomatic_business
    end
  end
end
