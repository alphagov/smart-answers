require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/check-uk-visa"

class CheckUkVisaTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    @location_slugs = %w[andorra anguilla armenia austria bolivia canada china colombia croatia estonia hong-kong ireland latvia macao mexico south-africa stateless-or-refugee syria turkey democratic-republic-of-the-congo oman united-arab-emirates qatar taiwan venezuela afghanistan yemen]
    stub_world_locations(@location_slugs)
    setup_for_testing_flow SmartAnswer::CheckUkVisaFlow
  end

  context "hong-kong" do
    setup do
      add_response "hong-kong"
    end

    should "direct user to what sort of travel document do you have? (Q1e)" do
      assert_current_node :what_sort_of_travel_document?
    end

    should "direct user to purpose_of_visit (Q2) for passport" do
      add_response "passport"
      assert_current_node :purpose_of_visit?
    end

    should "direct user to purpose_of_visit (Q2) for travel document" do
      add_response "travel_document"
      assert_current_node :purpose_of_visit?
    end
  end

  context "macao" do
    setup do
      add_response "macao"
    end

    should "direct user to what sort of travel document do you have? (Q1f)" do
      assert_current_node :what_sort_of_travel_document?
    end

    should "direct user to purpose_of_visit (Q2) for passport" do
      add_response "passport"
      assert_current_node :purpose_of_visit?
    end

    should "direct user to purpose_of_visit (Q2) for travel document" do
      add_response "travel_document"
      assert_current_node :purpose_of_visit?
    end
  end

  context "transit" do
    setup do
      add_response "afghanistan"
      add_response "transit"
    end

    should "direct user to cta question (q2a)" do
      assert_current_node :travelling_to_cta?
    end

    context "travelling to channel islands or isle of man" do
      setup do
        add_response "channel_islands_or_isle_of_man"
      end

      should "go to question channel_islands_or_isle_of_man?" do
        assert_current_node :channel_islands_or_isle_of_man?
      end
    end

    context "travelling to travelling to ireland" do
      setup do
        add_response "republic_of_ireland"
      end

      should "go to outcome_transit_to_the_republic_of_ireland" do
        assert_current_node :outcome_transit_to_the_republic_of_ireland
      end
    end

    context "travelling elsewhere" do
      setup do
        add_response "somewhere_else"
      end

      should "go to question passing_through_uk_border_control?" do
        assert_current_node :passing_through_uk_border_control?
      end
    end
  end

  should "ask what passport do you have" do
    assert_current_node :what_passport_do_you_have?
  end

  context "choose Stateless or Refugee" do
    setup do
      add_response "stateless-or-refugee"
    end

    context "marriage" do
      should "suggest to apply in country of originallity or residence for outcome_marriage" do
        add_response "marriage"

        assert_current_node :outcome_marriage_visa_nat_datv
      end
    end

    context "study" do
      should "suggest to apply in country of originallity or residence for outcome_study_m" do
        add_response "study"
        add_response "six_months_or_less"

        assert_current_node :outcome_study_m
      end

      should "suggest to apply in country of originallity or residence for outcome_study_y" do
        add_response "study"
        add_response "longer_than_six_months"

        assert_current_node :outcome_study_y
      end
    end

    context "work" do
      should "suggest to apply in country of originallity or residence for outcome_work_m" do
        add_response "work"
        add_response "six_months_or_less"
        assert_current_node :outcome_work_m
      end

      should "suggest to apply in country of originallity or residence for outcome_work_y" do
        add_response "work"
        add_response "longer_than_six_months"
        assert_current_node :outcome_work_y
      end
    end

    context "transit" do
      should "suggest to apply in country of originallity or residence for outcome_transit_leaving_airport" do
        add_response "transit"
        add_response "somewhere_else"
        add_response "yes"

        assert_current_node :outcome_transit_leaving_airport
      end

      should "suggests to get a Direct Airside Transit visa if not leaving the airport" do
        add_response "transit"
        add_response "somewhere_else"
        add_response "no"

        assert_current_node :outcome_transit_refugee_not_leaving_airport
      end
    end

    should "check whether they are going to be visiting a family member/partner" do
      add_response "tourism"

      assert_current_node :travelling_visiting_partner_family_member?
    end

    should "suggest to apply in country of originallity or residence for outcome_school_y" do
      add_response "school"
      assert_current_node :outcome_school_y
    end

    should "suggest to apply in country of originallity or residence for outcome_medical_y" do
      add_response "medical"
      assert_current_node :outcome_medical_y
    end

    context "choose to visit partner or family who have an article 10 card" do
      setup do
        add_response "family"
        add_response "yes"
      end

      should "show outcome no visa needed" do
        assert_current_node :outcome_no_visa_needed
      end
    end
  end

  context "choose Ireland" do
    setup do
      add_response "ireland"
    end

    should "go to outcome no visa needed" do
      assert_current_node :outcome_no_visa_needed
    end
  end

  context "choose an EEA country" do
    setup do
      add_response "austria"
    end

    should "go ask what when are you coming to the UK" do
      assert_current_node :when_are_you_coming_to_the_uk?
    end

    context "before 2021" do
      setup { add_response "before_2021" }

      should "take you to outcome no visa outcome_no_visa_needed" do
        assert_current_node :outcome_no_visa_needed
      end
    end

    context "after 2021" do
      setup { add_response "from_2021" }

      should "ask what are you coming to the UK to do" do
        assert_current_node :purpose_of_visit?
      end

      context "coming to the UK for tourism" do
        setup do
          add_response "tourism"
        end

        should "take you to outcome no visa outcome_school_n" do
          assert_current_node :outcome_school_n
        end
      end

      context "coming to the UK to study" do
        setup do
          add_response "study"
        end

        should "take you to outcome no visa outcome_no_visa_needed if six months or less" do
          add_response "six_months_or_less"
          assert_current_node :outcome_no_visa_needed
        end

        should "take you to outcome no visa outcome_study_y if longer than six months" do
          add_response "longer_than_six_months"
          assert_current_node :outcome_study_y
        end
      end

      context "coming to the UK to work" do
        setup do
          add_response "work"
        end

        should "take you to outcome outcome_work_n if six months or less" do
          add_response "six_months_or_less"
          assert_current_node :outcome_work_n
        end

        should "take you to outcome outcome_work_y if longer than six months" do
          add_response "longer_than_six_months"
          assert_current_node :outcome_work_y
        end
      end

      context "coming to the UK for marriage" do
        setup do
          add_response "marriage"
        end

        should "take you to outcome outcome_marriage_nvn_ukot" do
          assert_current_node :outcome_marriage_nvn_ukot
        end
      end

      context "coming to the UK for a long stay with family" do
        setup do
          add_response "family"
        end

        should "take you to outcome outcome_joining_family_nvn" do
          assert_current_node :outcome_joining_family_nvn
        end
      end

      context "coming to the UK on transit" do
        setup do
          add_response "transit"
        end

        should "take you to outcome 'Where are you travelling to?'" do
          assert_current_node :travelling_to_cta?
        end

        context "to the Channel Islands or Isle of Man" do
          setup do
            add_response "channel_islands_or_isle_of_man"
          end

          should "ask you what you will be doing in Channel Islands or Isle of Man" do
            assert_current_node :channel_islands_or_isle_of_man?
          end
        end

        context "to the Republic of Ireland" do
          setup do
            add_response "republic_of_ireland"
          end

          should "take you to outcome no visa needed" do
            assert_current_node :outcome_no_visa_needed
          end
        end

        context "to somewhere else" do
          setup do
            add_response "somewhere_else"
          end

          should "take you to outcome no visa needed" do
            assert_current_node :outcome_no_visa_needed
          end
        end
      end
    end
  end

  context "choose a UKOT country" do
    setup do
      add_response "anguilla"
    end
    should "ask what are you coming to the UK to do" do
      assert_current_node :purpose_of_visit?
    end
    context "coming to the UK to study" do
      setup do
        add_response "study"
        add_response "six_months_or_less"
      end
      should "take you to outcome no visa outcome_no_visa_needed" do
        assert_current_node :outcome_no_visa_needed
      end
    end
    context "coming to the UK to work" do
      setup do
        add_response "work"
        add_response "six_months_or_less"
      end
      should "take you to work_n outcome" do
        assert_current_node :outcome_work_n
      end
    end
    context "tourism, visiting friends or family" do
      setup do
        add_response "tourism"
      end
      should "take you to school_n outcome" do
        assert_current_node :outcome_school_n
      end
    end
    context "visiting child at school" do
      setup do
        add_response "school"
      end
      should "take you to school_n outcome" do
        assert_current_node :outcome_school_n
      end
    end
    context "getting married" do
      setup do
        add_response "marriage"
      end
      should "take you to the marriage outcome" do
        assert_current_node :outcome_marriage_nvn_ukot
      end
    end
    context "get private medical treatment" do
      setup do
        add_response "medical"
      end
      should "take you to medical_n outcome" do
        assert_current_node :outcome_medical_n
      end
    end
    context "coming to the UK on transit" do
      setup do
        add_response "transit"
      end
      should "take you to outcome no visa needed" do
        assert_current_node :travelling_to_cta?
      end
      context "to the Repulic of Ireland" do
        setup do
          add_response "republic_of_ireland"
        end

        should "take you to outcome no visa needed" do
          assert_current_node :outcome_no_visa_needed
        end
      end
      context "to somewhere else" do
        setup do
          add_response "somewhere_else"
        end

        should "take you to outcome no visa needed" do
          assert_current_node :outcome_no_visa_needed
        end
      end
    end
    context "coming to join family" do
      setup do
        add_response "family"
      end
      should "take you to outcome family_m" do
        assert_current_node :outcome_joining_family_m
      end
    end
  end

  context "choose a Non-visa nationals country" do
    setup do
      add_response "andorra"
    end
    should "ask what are you coming to the UK to do" do
      assert_current_node :purpose_of_visit?
    end
    context "tourism, visiting friends or family" do
      setup do
        add_response "tourism"
      end
      should "take you to school_n outcome" do
        assert_current_node :outcome_school_n
      end
    end
    context "visiting child at school" do
      setup do
        add_response "school"
      end
      should "take you to school_n outcome" do
        assert_current_node :outcome_school_n
      end
    end
    context "getting married" do
      setup do
        add_response "marriage"
      end
      should "take you to marriage outcome" do
        assert_current_node :outcome_marriage_nvn_ukot
      end
    end
    context "get private medical treatment" do
      setup do
        add_response "medical"
      end
      should "take you to medical_n outcome" do
        assert_current_node :outcome_medical_n
      end
    end
    context "on transit" do
      setup do
        add_response "transit"
      end

      should "take you to common travel area (cta) question" do
        assert_current_node :travelling_to_cta?
      end

      context "to the channel islands" do
        setup do
          add_response "channel_islands_or_isle_of_man"
        end

        should "take you to purpose of visit question" do
          assert_current_node :channel_islands_or_isle_of_man?
        end
      end
      context "to the Republis of Ireland" do
        setup do
          add_response "republic_of_ireland"
        end

        should "take you to outcome no visa needed" do
          assert_current_node :outcome_no_visa_needed
        end
      end
      context "heading somewhere else" do
        setup do
          add_response "somewhere_else"
        end

        should "take you to outcome no visa needed" do
          assert_current_node :outcome_no_visa_needed
        end
      end
    end
    context "coming to join family" do
      setup do
        add_response "family"
      end
      should "take you to outcome family_y" do
        assert_current_node :outcome_joining_family_nvn
      end
    end
  end

  context "choose a visa national country or refugee" do
    context "when chosen armenia" do
      setup do
        add_response "armenia"
      end
      should "ask what are you coming to the UK to do" do
        assert_current_node :purpose_of_visit?
      end

      context "coming to the UK to study" do
        setup do
          add_response "study"
          add_response "six_months_or_less"
        end
        should "take you to outcome study_m" do
          assert_current_node :outcome_study_m
        end
      end

      context "coming to the UK to work" do
        setup do
          add_response "work"
          add_response "six_months_or_less"
        end
        should "take you to outcome work_m" do
          assert_current_node :outcome_work_m
        end
      end

      context "coming to the UK on the way somewhere else" do
        setup do
          add_response "transit"
          add_response "somewhere_else"
        end
        should "ask you if you're planning to leave the airport" do
          assert_current_node :passing_through_uk_border_control?
        end
        context "planning to leave airport" do
          setup do
            add_response "yes"
          end
          should "take you to transit_leaving_airport outcome" do
            assert_current_node :outcome_transit_leaving_airport
          end
        end
        context "not planning to leave airport" do
          setup do
            add_response "no"
          end
          should "take you to transit_not_leaving_airport outcome" do
            assert_current_node :outcome_no_visa_needed
          end
        end
      end
    end
  end

  context "choose an EVW country" do
    setup do
      add_response "oman"
    end

    should "ask what are you comming to the UK to do" do
      assert_current_node :purpose_of_visit?
    end

    context "coming to the UK to work" do
      setup do
        add_response "work"
      end

      should "ask how long you intend to stay" do
        assert_current_node :staying_for_how_long?
      end

      context "6 months or less" do
        setup do
          add_response "six_months_or_less"
        end

        should "take you to the outcome work_waiver" do
          assert_current_node :outcome_work_waiver
        end
      end

      context "longer than 6 months" do
        setup do
          add_response "longer_than_six_months"
        end

        should "take you to the outcome work_y" do
          assert_current_node :outcome_work_y
        end
      end
    end

    context "coming to the UK to study" do
      setup do
        add_response "study"
      end

      should "ask how long you intend to stay" do
        assert_current_node :staying_for_how_long?
      end

      context "6 months or less" do
        setup do
          add_response "six_months_or_less"
        end

        should "take you to the outcome work_waiver" do
          assert_current_node :outcome_study_waiver
        end
      end

      context "longer than 6 months" do
        setup do
          add_response "longer_than_six_months"
        end

        should "take you to the outcome study_y" do
          assert_current_node :outcome_study_y
        end
      end
    end

    context "coming to the UK to visit a child in school" do
      setup do
        add_response "school"
      end

      should "take you to the outcome school_waiver" do
        assert_current_node :outcome_school_waiver
      end
    end

    context "coming to the UK to get married" do
      setup do
        add_response "marriage"
      end

      should "take you to the marriage outcome" do
        assert_current_node :outcome_marriage_electronic_visa_waiver
      end
    end
  end

  context "choose a DATV country" do
    setup do
      add_response "democratic-republic-of-the-congo"
    end
    should "ask what are you coming to the UK to do" do
      assert_current_node :purpose_of_visit?
    end
    context "coming to the UK to study" do
      setup do
        add_response "study"
        add_response "six_months_or_less"
      end
      should "take you to outcome study_m" do
        assert_current_node :outcome_study_m
      end
    end
    context "coming to the UK to work" do
      setup do
        add_response "work"
        add_response "six_months_or_less"
      end
      should "take you to outcome work_m" do
        assert_current_node :outcome_work_m
      end
    end
    context "tourism, visiting friends or family" do
      setup do
        add_response "tourism"
      end
      context "travelling/visting with partner/family member" do
        setup do
          add_response "no"
        end

        should "take you to outcome standard visitor visa" do
          assert_current_node :outcome_standard_visitor_visa
        end
      end
    end
    context "visiting child at school" do
      setup do
        add_response "school"
      end
      should "take you to school_y outcome" do
        assert_current_node :outcome_school_y
      end
    end
    context "getting married" do
      setup do
        add_response "marriage"
      end
      should "take you to  marriage outcome" do
        assert_current_node :outcome_marriage_visa_nat_datv
      end
    end
    context "get private medical treatment" do
      setup do
        add_response "medical"
      end
      should "take you to the medical_y outcome" do
        assert_current_node :outcome_medical_y
      end
    end
    context "coming to the UK on the way somewhere else" do
      setup do
        add_response "transit"
        add_response "somewhere_else"
      end
      should "ask you if you're planning to leave the airport" do
        assert_current_node :passing_through_uk_border_control?
      end
      context "planning to leave airport" do
        setup do
          add_response "yes"
        end
        should "take you to transit_leaving_airport outcome" do
          assert_current_node :outcome_transit_leaving_airport_datv
        end
      end
      context "not planning to leave airport" do
        setup do
          add_response "no"
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
          add_response "somewhere_else"
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
          should "lead to outcome_transit_venezuela" do
            assert_current_node :outcome_transit_venezuela
          end
        end
      end
    end
    context "coming to join family member, without an article 10 card, and they're a British citizen" do
      setup do
        add_response "family"
        add_response "no"
        add_response "yes"
      end

      should "take to partner_family_british_citizen_y outcome" do
        assert_current_node :outcome_partner_family_british_citizen_y
      end
    end
  end

  context "choose Hong Kong" do
    setup do
      add_response "hong-kong"
    end

    context "with travel document" do
      setup do
        add_response "travel_document"
      end

      context "get private medical treatment" do
        should "take you to the medical_y outcome" do
          add_response "medical"
          assert_current_node :outcome_medical_y
        end
      end

      context "tourism" do
        setup do
          add_response "tourism"
        end

        context "travelling with a a UK family member with an article 10 card" do
          setup do
            add_response "yes"
            add_response "yes"
          end

          should "take you to no visa needed outcome" do
            assert_current_node :outcome_no_visa_needed
          end
        end
      end

      context "in transit" do
        setup do
          add_response "transit"
        end

        context "travelling to the Republic of Ireland" do
          should "take you to the outcome 14a" do
            add_response "republic_of_ireland"
            assert_current_node :outcome_transit_to_the_republic_of_ireland
          end
        end

        context "travelling elsewhere" do
          setup do
            add_response "somewhere_else"
          end

          should "not require a visa if not passing through border control" do
            add_response "no"

            assert_current_node :outcome_no_visa_needed
          end

          should "take you to outcome_transit_leaving_airport if passing through border control" do
            add_response "yes"
            assert_current_node :outcome_transit_leaving_airport
          end
        end
      end

      context "studying in the UK" do
        setup do
          add_response "study"
        end
        context "6 months or less" do
          should "takes you to outcome_study_m" do
            add_response "six_months_or_less"
            assert_current_node :outcome_study_m
          end
        end
        context "more than 6 months" do
          should "takes you to outcome_study_y" do
            add_response "longer_than_six_months"
            assert_current_node :outcome_study_y
          end
        end
      end

      context "working in the UK" do
        setup do
          add_response "work"
        end
        context "6 months or less" do
          should "takes you to outcome_work_m" do
            add_response "six_months_or_less"
            assert_current_node :outcome_work_m
          end
        end
        context "more than 6 months" do
          should "takes you to outcome_work_y" do
            add_response "longer_than_six_months"
            assert_current_node :outcome_work_y
          end
        end
      end
    end

    context "with passport" do
      setup do
        add_response "passport"
      end

      context "get private medical treatment" do
        should "take you to the medical_n outcome" do
          add_response "medical"
          assert_current_node :outcome_medical_n
        end
      end

      context "tourism, visiting friends or family" do
        should "take you to the school_n" do
          add_response "tourism"
          # The school outcome does not contain school-specific content
          assert_current_node :outcome_school_n
        end
      end

      context "in transit" do
        setup do
          add_response "transit"
        end

        context "travelling to the Republic of Ireland" do
          should "not require a visa" do
            add_response "somewhere_else"
            assert_current_node :outcome_no_visa_needed
          end
        end

        context "travelling elsewhere" do
          should "not require a visa" do
            add_response "republic_of_ireland"
            assert_current_node :outcome_no_visa_needed
          end
        end
      end

      context "studying in the UK" do
        setup do
          add_response "study"
        end
        context "6 months or less" do
          should "take you to no visa needed outcome" do
            add_response "six_months_or_less"
            assert_current_node :outcome_no_visa_needed
          end
        end
        context "more than 6 months" do
          should "takes you to outcome_study_y" do
            add_response "longer_than_six_months"
            assert_current_node :outcome_study_y
          end
        end
      end

      context "working in the UK" do
        setup do
          add_response "work"
        end
        context "6 months or less" do
          should "take you to no outcome_work_n" do
            add_response "six_months_or_less"
            assert_current_node :outcome_work_n
          end
        end
        context "more than 6 months" do
          should "takes you to outcome_work_y" do
            add_response "longer_than_six_months"
            assert_current_node :outcome_work_y
          end
        end
      end
    end
  end

  context "choose Macao (travel document)" do
    setup do
      add_response "macao"
    end

    context "with travel document" do
      setup do
        add_response "travel_document"
      end

      context "get private medical treatment" do
        should "take you to the medical_y outcome" do
          add_response "medical"
          assert_current_node :outcome_medical_y
        end
      end

      context "tourism, visiting friends or family" do
        setup do
          add_response "tourism"
        end

        context "travelling with a a UK family member" do
          should "take you to standard visitor visa" do
            add_response "no"
            assert_current_node :outcome_standard_visitor_visa
          end
        end
      end

      context "in transit" do
        setup do
          add_response "transit"
        end

        context "travelling to the Republic of Ireland" do
          should "take you to the outcome 14a" do
            add_response "republic_of_ireland"
            assert_current_node :outcome_transit_to_the_republic_of_ireland
          end
        end

        context "travelling elsewhere" do
          setup do
            add_response "somewhere_else"
          end

          should "not require a visa if not passing through border control" do
            add_response "no"
            assert_current_node :outcome_no_visa_needed
          end

          should "take you to outcome_transit_leaving_airport if passing through border control" do
            add_response "yes"
            assert_current_node :outcome_transit_leaving_airport
          end
        end
      end

      context "studying in the UK" do
        setup do
          add_response "study"
        end
        context "6 months or less" do
          should "takes you to outcome_study_m" do
            add_response "six_months_or_less"
            assert_current_node :outcome_study_m
          end
        end
        context "more than 6 months" do
          should "takes you to outcome_study_y" do
            add_response "longer_than_six_months"
            assert_current_node :outcome_study_y
          end
        end
      end

      context "working in the UK" do
        setup do
          add_response "work"
        end
        context "6 months or less" do
          should "takes you to outcome_work_m" do
            add_response "six_months_or_less"
            assert_current_node :outcome_work_m
          end
        end
        context "more than 6 months" do
          should "takes you to outcome_work_y" do
            add_response "longer_than_six_months"
            assert_current_node :outcome_work_y
          end
        end
      end
    end

    context "with passport" do
      setup do
        add_response "passport"
      end

      context "get private medical treatment" do
        should "take you to the medical_n outcome" do
          add_response "medical"
          assert_current_node :outcome_medical_n
        end
      end

      context "tourism, visiting friends or family" do
        should "take you to the school_n" do
          add_response "tourism"
          # The school outcome does not contain school-specific content
          assert_current_node :outcome_school_n
        end
      end

      context "in transit" do
        setup do
          add_response "transit"
        end

        context "travelling to the Republic of Ireland" do
          should "not require a visa" do
            add_response "somewhere_else"
            assert_current_node :outcome_no_visa_needed
          end
        end

        context "travelling elsewhere" do
          should "not require a visa" do
            add_response "republic_of_ireland"
            assert_current_node :outcome_no_visa_needed
          end
        end
      end

      context "studying in the UK" do
        setup do
          add_response "study"
        end
        context "6 months or less" do
          should "take you to no visa needed outcome" do
            add_response "six_months_or_less"
            assert_current_node :outcome_no_visa_needed
          end
        end
        context "more than 6 months" do
          should "takes you to outcome_study_y" do
            add_response "longer_than_six_months"
            assert_current_node :outcome_study_y
          end
        end
      end

      context "working in the UK" do
        setup do
          add_response "work"
        end
        context "6 months or less" do
          should "take you to outcome_work_n outcome" do
            add_response "six_months_or_less"
            assert_current_node :outcome_work_n
          end
        end
        context "more than 6 months" do
          should "takes you to outcome_work_y" do
            add_response "longer_than_six_months"
            assert_current_node :outcome_work_y
          end
        end
      end
    end
  end

  context "testing turkey phrase list" do
    setup do
      add_response "turkey"
      add_response "work"
      add_response "six_months_or_less"
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
      add_response "oman"
      add_response "medical"
    end
    should "take you to outcome visit waiver" do
      assert_current_node :outcome_visit_waiver
    end
  end

  # testing canada - all groupings AND NON visa national outcome - study AND work - less AND more than 6 months
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
    end # end canada study reason

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
    end # end canada work reason
  end # end canada - NON visa country

  # testing armenia - visa national outcome - study AND work
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
  end # end armenia -  visa country

  context "choose a Non-visa country and check for outcome_work_n" do
    setup do
      add_response "mexico"
      add_response "work"
      add_response "six_months_or_less"
    end
    should "take you to outcome work_n" do
      assert_current_node :outcome_work_n
    end
  end

  context "taiwan" do
    setup do
      add_response "taiwan"
    end

    context "outcome taiwan exception study and six_months_or_less" do
      setup do
        add_response "study"
        add_response "six_months_or_less"
      end
      should "take you to outcome taiwan exception" do
        assert_current_node :outcome_study_waiver_taiwan
      end
    end

    context "outcome taiwan exception tourism" do
      setup do
        add_response "tourism"
      end
      should "take you to outcome taiwan exception" do
        assert_current_node :outcome_visit_waiver_taiwan
      end
    end

    context "outcome taiwan exception school" do
      setup do
        add_response "school"
      end

      should "take you to outcome taiwan exception" do
        assert_current_node :outcome_study_waiver_taiwan
      end
    end

    context "outcome taiwan exception medical" do
      setup do
        add_response "medical"
      end

      should "take you to outcome taiwan exception" do
        assert_current_node :outcome_visit_waiver_taiwan
      end
    end

    context "getting married" do
      setup do
        add_response "marriage"
      end

      should "take you to the marriage outcome" do
        assert_current_node :outcome_marriage_taiwan
      end
    end

    context "outcome taiwan exception transit" do
      setup do
        add_response "transit"
        add_response "somewhere_else"
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
        add_response "work"
        add_response "six_months_or_less"
      end

      should "go to ouctome work n" do
        assert_current_node :outcome_work_n
      end
    end
  end

  context "outcome venezuela exception transit" do
    setup do
      add_response "venezuela"
    end
    context "coming to the UK to visit child at school" do
      setup do
        add_response "school"
      end
      should "take you to :outcome_school_y outcome" do
        assert_current_node :outcome_school_y
      end
    end
    context "coming to the UK for tourism" do
      setup do
        add_response "tourism"
      end
      should "take you to :travelling_visiting_partner_family_member?" do
        assert_current_node :travelling_visiting_partner_family_member?
      end
    end
    context "coming to the UK for study" do
      setup do
        add_response "study"
        add_response "six_months_or_less"
      end
      should "take you to :outcome_study_m outcome" do
        assert_current_node :outcome_study_m
      end
    end
    context "coming to the UK for study" do
      setup do
        add_response "medical"
      end
      should "take you to :outcome_medical_y outcome" do
        assert_current_node :outcome_medical_y
      end
    end
  end

  context "Syria transit B1 B2 visa exceptions" do
    setup do
      add_response "syria"
      add_response "transit"
      add_response "somewhere_else"
    end

    should "mention B1 and B2 visas when leaving the airport" do
      add_response "yes"
      assert_current_node :outcome_transit_leaving_airport_datv
    end

    should "mention B1 and B2 visas when not leaving the airport" do
      add_response "no"
      assert_current_node :outcome_transit_not_leaving_airport
    end
  end

  context "check for diplomatic and government business travellers" do
    setup do
      add_response "bolivia"
      add_response "diplomatic"
    end
    should "go to diplomatic and government outcome" do
      assert_current_node :outcome_diplomatic_business
    end
  end

  context "Estonia" do
    setup do
      add_response "estonia"
    end

    should "go ask what sort of passport" do
      assert_current_node :what_sort_of_passport?
    end

    should "go to outcome_no_visa_needed if user has an Estonian passport" do
      add_response "citizen" # Q1c
      assert_current_node :outcome_no_visa_needed
    end

    should "go to question 2 if user has an Alien passport" do
      add_response "alien" # Q1c
      assert_current_node :purpose_of_visit?
    end

    context "purpose of visit is transit" do
      setup do
        add_response "alien" # Q1c
        add_response "transit"
      end

      should "go to outcome no visa needed" do
        assert_current_node :outcome_no_visa_needed
      end
    end
  end

  context "Latvia" do
    setup do
      add_response "latvia"
    end

    should "ask what sort of passport" do
      assert_current_node :what_sort_of_passport?
    end

    should "go to outcome_no_visa_needed if user has an Latvian passport" do
      add_response "citizen" # Q1d
      assert_current_node :outcome_no_visa_needed
    end

    should "go to question 2 if user has an Alien passport" do
      add_response "alien" # Q1d
      assert_current_node :purpose_of_visit?
    end

    context "purpose of visit is transit" do
      setup do
        add_response "alien" # Q1d
        add_response "transit"
      end

      should "go to outcome no visa needed" do
        assert_current_node :outcome_no_visa_needed
      end
    end
  end
end
