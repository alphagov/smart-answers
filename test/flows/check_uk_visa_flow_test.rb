require "test_helper"
require "support/flow_test_helper"
require "support/flows/check_uk_visa_flow_test_helper"

class CheckUkVisaFlowTest < ActiveSupport::TestCase
  include FlowTestHelper
  extend CheckUkVisaFlowTestHelper

  setup do
    testing_flow CheckUkVisaFlow
    @electronic_travel_authorisation_country = "qatar"
    @direct_airside_transit_visa_country = "afghanistan"
    @visa_national_country = "armenia"
    @british_overseas_territory_country = "anguilla"
    @non_visa_national_country = "pitcairn-island"
    @eea_country = "austria"
    @travel_document_country = "hong-kong"
    @b1_b2_country = "syria"
    @youth_mobility_scheme_country = "canada"

    @non_visa_national_eta_text = "You currently do not need an electronic travel authorisation (ETA)"
    @eea_eta_text = "You currently do not need an electronic travel authorisation (ETA)"

    # stub only the countries used in this test for less of a performance impact
    stub_worldwide_api_has_locations(["china",
                                      "india",
                                      "israel",
                                      "ireland",
                                      "estonia",
                                      "georgia",
                                      "latvia",
                                      "hong-kong",
                                      "jordan",
                                      "macao",
                                      "russia",
                                      "taiwan",
                                      "venezuela",
                                      @electronic_travel_authorisation_country,
                                      @direct_airside_transit_visa_country,
                                      @visa_national_country,
                                      @british_overseas_territory_country,
                                      @non_visa_national_country,
                                      @eea_country,
                                      @travel_document_country,
                                      @b1_b2_country,
                                      @youth_mobility_scheme_country].uniq)
  end

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: what_passport_do_you_have?" do
    setup do
      testing_node :what_passport_do_you_have?
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of dual_british_or_irish_citizenship?" do
        assert_next_node :dual_british_or_irish_citizenship?, for_response: "ireland"
      end
    end
  end

  context "question: dual_british_or_irish_citizenship?" do
    setup do
      testing_node :dual_british_or_irish_citizenship?
    end

    should "render the question" do
      add_responses what_passport_do_you_have?: "estonia"
      assert_rendered_question
    end

    context "next_node for a 'no' response" do
      setup do
        add_responses dual_british_or_irish_citizenship?: "no"
      end

      should "have a next node of israeli_document_type? with an 'israel' passport" do
        add_responses what_passport_do_you_have?: "israel"
        assert_next_node :israeli_document_type?
      end

      %w[estonia latvia].each do |country|
        should "have a next node of what_sort_of_passport? with a '#{country}' passport" do
          add_responses what_passport_do_you_have?: country
          assert_next_node :what_sort_of_passport?
        end
      end

      %w[hong-kong macao].each do |country|
        should "have a next node of what_sort_of_travel_document? with a '#{country}' passport" do
          add_responses what_passport_do_you_have?: country
          assert_next_node :what_sort_of_travel_document?
        end
      end

      should "have a next node of outcome_no_visa_needed_ireland with a 'ireland' passport" do
        add_responses what_passport_do_you_have?: "ireland"
        assert_next_node :outcome_no_visa_needed_ireland
      end

      should "have a next node of purpose_of_visit? with a different country passport" do
        add_responses what_passport_do_you_have?: @eea_country
        assert_next_node :purpose_of_visit?
      end
    end

    context "next_node for a 'yes' response" do
      setup do
        add_responses what_passport_do_you_have?: "estonia",
                      dual_british_or_irish_citizenship?: "yes"
      end

      should "have a next node of outcome_no_visa_or_eta_for_british_or_irish_dual_citizens" do
        assert_next_node :outcome_no_visa_or_eta_for_british_or_irish_dual_citizens
      end
    end

    context "next_node for a 'dont_know' response" do
      setup do
        add_responses what_passport_do_you_have?: "estonia",
                      dual_british_or_irish_citizenship?: "dont_know"
      end

      should "have a next node of outcome_no_visa_or_eta_for_british_or_irish_dual_citizens" do
        assert_next_node :outcome_no_visa_or_eta_for_british_or_irish_dual_citizens
      end
    end
  end

  context "question: israeli_document_type?" do
    setup do
      testing_node :israeli_document_type?
      add_responses what_passport_do_you_have?: "israel",
                    dual_british_or_irish_citizenship?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of purpose_of_visit?" do
        assert_next_node :purpose_of_visit?, for_response: "provisional-passport"
      end
    end
  end

  context "question: what_sort_of_passport?" do
    setup do
      testing_node :what_sort_of_passport?
      add_responses what_passport_do_you_have?: "estonia",
                    dual_british_or_irish_citizenship?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of purpose_of_visit?" do
        assert_next_node :purpose_of_visit?, for_response: "alien"
      end
    end
  end

  context "question: what_sort_of_travel_document?" do
    setup do
      testing_node :what_sort_of_travel_document?
      add_responses what_passport_do_you_have?: "hong-kong",
                    dual_british_or_irish_citizenship?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of purpose_of_visit?" do
        assert_next_node :purpose_of_visit?, for_response: "passport"
      end
    end
  end

  context "question: purpose_of_visit?" do
    setup do
      testing_node :purpose_of_visit?
      add_responses what_passport_do_you_have?: @eea_country,
                    dual_british_or_irish_citizenship?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      test_shared_purpose_of_visit_next_nodes

      should "have a next node of travelling_to_cta? for a 'transit' response" do
        assert_next_node :travelling_to_cta?, for_response: "transit"
      end
    end
  end

  context "question: what_type_of_work?" do
    setup do
      testing_node :what_type_of_work?
      add_responses what_passport_do_you_have?: @eea_country,
                    dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "work",
                    staying_for_how_long?: "longer_than_six_months"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of outcome_work_y if working in academia" do
        assert_next_node :outcome_work_y, for_response: "academic"
      end

      should "have a next node of outcome_work_y if working in arts" do
        assert_next_node :outcome_work_y, for_response: "arts"
      end

      should "have a next node of outcome_work_y if working in business" do
        assert_next_node :outcome_work_y, for_response: "business"
      end

      should "have a next node of outcome_work_y if working in digital" do
        assert_next_node :outcome_work_y, for_response: "digital"
      end

      should "have a next node of outcome_work_y if working in health" do
        assert_next_node :outcome_work_y, for_response: "health"
      end

      should "have a next node of outcome_work_y if working in a sector thats not listed" do
        assert_next_node :outcome_work_y, for_response: "other"
      end

      should "have a next node of outcome_work_y if working in religion" do
        assert_next_node :outcome_work_y, for_response: "religious"
      end

      should "have a next node of outcome_work_y if working in sports" do
        assert_next_node :outcome_work_y, for_response: "sports"
      end
    end
  end

  context "question: travelling_to_cta?" do
    setup do
      testing_node :travelling_to_cta?
      add_responses what_passport_do_you_have?: @eea_country,
                    dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "transit"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of channel_islands_or_isle_of_man? for a 'channel_islands_or_isle_of_man' response" do
        assert_next_node :channel_islands_or_isle_of_man?, for_response: "channel_islands_or_isle_of_man"
      end

      should "have a next node of outcome_transit_to_the_republic_of_ireland_electronic_travel_authorisation for an EEA passport and a 'republic_of_ireland' response" do
        add_responses what_passport_do_you_have?: @eea_country
        assert_next_node :outcome_transit_to_the_republic_of_ireland_electronic_travel_authorisation, for_response: "republic_of_ireland"
      end

      should "have a next node of outcome_no_visa_needed for an EEA passport and a 'somewhere_else' response" do
        add_responses what_passport_do_you_have?: @eea_country
        assert_next_node :outcome_no_visa_needed, for_response: "somewhere_else"
      end

      %w[republic_of_ireland somewhere_else].each do |response|
        should "have a next node of outcome_no_visa_needed for a non-visa national passport and a " \
               "'#{response}' response" do
          add_responses what_passport_do_you_have?: @non_visa_national_country
          assert_next_node :outcome_no_visa_needed, for_response: response
        end

        should "have a next node of outcome_no_visa_needed for a British overseas territory passport and a " \
               "'#{response}' response" do
          add_responses what_passport_do_you_have?: @british_overseas_territory_country
          assert_next_node :outcome_no_visa_needed, for_response: response
        end
      end

      should "have a next node of outcome_transit_to_the_republic_of_ireland_electronic_travel_authorisation for a travel document country with a passport " \
             "and a 'republic_of_ireland' response" do
        add_responses what_passport_do_you_have?: @travel_document_country,
                      what_sort_of_travel_document?: "passport"
        assert_next_node :outcome_transit_to_the_republic_of_ireland_electronic_travel_authorisation, for_response: "republic_of_ireland"
      end

      should "have a next node of outcome_no_visa_needed for a travel document country with a passport " \
             "and a 'somewhere_else' response" do
        add_responses what_passport_do_you_have?: @travel_document_country,
                      what_sort_of_travel_document?: "passport"
        assert_next_node :outcome_no_visa_needed, for_response: "somewhere_else"
      end

      should "have a next node of outcome_transit_to_the_republic_of_ireland for a different country and a " \
             "'republic_of_ireland' response" do
        add_responses what_passport_do_you_have?: @visa_national_country
        assert_next_node :outcome_transit_to_the_republic_of_ireland, for_response: "republic_of_ireland"
      end

      should "have a next node of outcome_transit_to_the_republic_of_ireland_electronic_travel_authorisation for a different country and a " \
             "'republic_of_ireland' response" do
        add_responses what_passport_do_you_have?: @electronic_travel_authorisation_country
        assert_next_node :outcome_transit_to_the_republic_of_ireland_electronic_travel_authorisation, for_response: "republic_of_ireland"
      end

      should "have a next node of passing_through_uk_border_control? for a travel document country with " \
             "a travel document and a 'somewhere_else' response" do
        add_responses what_passport_do_you_have?: @travel_document_country,
                      what_sort_of_travel_document?: "travel_document"
        assert_next_node :passing_through_uk_border_control?, for_response: "somewhere_else"
      end

      should "have a next node of passing_through_uk_border_control? for a different country and a " \
             "'somewhere_else' response" do
        add_responses what_passport_do_you_have?: @visa_national_country
        assert_next_node :passing_through_uk_border_control?, for_response: "somewhere_else"
      end
    end
  end

  context "question: channel_islands_or_isle_of_man?" do
    setup do
      testing_node :channel_islands_or_isle_of_man?
      add_responses dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "transit",
                    travelling_to_cta?: "channel_islands_or_isle_of_man"
    end

    should "render the question" do
      add_responses what_passport_do_you_have?: @eea_country
      assert_rendered_question
    end

    context "next_node" do
      setup do
        add_responses what_passport_do_you_have?: @eea_country
      end

      test_shared_purpose_of_visit_next_nodes
    end
  end

  context "question: passing_through_uk_border_control?" do
    setup do
      testing_node :passing_through_uk_border_control?
      add_responses what_passport_do_you_have?: @visa_national_country,
                    dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "transit",
                    travelling_to_cta?: "somewhere_else"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      context "for a 'yes' response" do
        should "have a next node of outcome_transit_taiwan_through_border_control for a Taiwan passport" do
          add_responses what_passport_do_you_have?: "taiwan"
          assert_next_node :outcome_transit_taiwan_through_border_control, for_response: "yes"
        end

        should "have a next node of outcome_transit_leaving_airport for a visa national passport" do
          add_responses what_passport_do_you_have?: @visa_national_country
          assert_next_node :outcome_transit_leaving_airport, for_response: "yes"
        end

        should "have a next node of outcome_transit_leaving_airport for a travel_document" do
          add_responses what_passport_do_you_have?: @travel_document_country,
                        what_sort_of_travel_document?: "travel_document"
          assert_next_node :outcome_transit_leaving_airport, for_response: "yes"
        end

        should "have a next node of outcome_transit_leaving_airport for a direct airside transit visa passport" do
          add_responses what_passport_do_you_have?: @direct_airside_transit_visa_country
          assert_next_node :outcome_transit_leaving_airport_direct_airside_transit_visa, for_response: "yes"
        end
      end

      context "for a 'no' response" do
        should "have a next node of outcome_transit_taiwan for a Taiwan passport" do
          add_responses what_passport_do_you_have?: "taiwan"
          assert_next_node :outcome_transit_taiwan, for_response: "no"
        end

        should "have a next node of outcome_no_visa_needed for a Venezuela passport" do
          add_responses what_passport_do_you_have?: "venezuela"
          assert_next_node :outcome_no_visa_needed, for_response: "no"
        end

        should "have a next node of outcome_transit_refugee_not_leaving_airport for a stateless-or-refugee passport" do
          add_responses what_passport_do_you_have?: "stateless-or-refugee"
          assert_next_node :outcome_transit_refugee_not_leaving_airport, for_response: "no"
        end

        should "have a next node of outcome_transit_not_leaving_airport for a direct airside transit visa" do
          add_responses what_passport_do_you_have?: @direct_airside_transit_visa_country
          assert_next_node :outcome_transit_not_leaving_airport, for_response: "no"
        end

        should "have a next node of outcome_no_visa_needed for a visa national passport" do
          add_responses what_passport_do_you_have?: @visa_national_country
          assert_next_node :outcome_no_visa_needed, for_response: "no"
        end

        should "have a next node of outcome_no_visa_needed for a travel document" do
          add_responses what_passport_do_you_have?: @travel_document_country,
                        what_sort_of_travel_document?: "travel_document"
          assert_next_node :outcome_no_visa_needed, for_response: "no"
        end
      end
    end
  end

  context "question: staying_for_how_long?" do
    setup do
      testing_node :staying_for_how_long?
      add_responses what_passport_do_you_have?: @eea_country,
                    dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "study"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      context "for a 'longer_than_six_months' response" do
        should "have a next node of outcome_study_y for a study visit purpose" do
          add_responses purpose_of_visit?: "study"
          assert_next_node :outcome_study_y, for_response: "longer_than_six_months"
        end

        should "have a next node of what_type_of_work? for a work visit purpose" do
          add_responses purpose_of_visit?: "work"
          assert_next_node :what_type_of_work?, for_response: "longer_than_six_months"
        end
      end

      context "for a 'six_months_or_less' response" do
        should "have a next node of outcome_study_electronic_travel_authorisation for a study visit with electronic travel authorisation passport" do
          add_responses what_passport_do_you_have?: @electronic_travel_authorisation_country,
                        purpose_of_visit?: "study"
          assert_next_node :outcome_study_electronic_travel_authorisation, for_response: "six_months_or_less"
        end

        should "have a next node of outcome_study_electronic_travel_authorisation for a study visit with a Taiwan passport" do
          add_responses what_passport_do_you_have?: "taiwan", purpose_of_visit?: "study"
          assert_next_node :outcome_study_electronic_travel_authorisation, for_response: "six_months_or_less"
        end

        should "have a next node of outcome_study_m for a study visit with a direct airside transit visa" do
          add_responses what_passport_do_you_have?: @direct_airside_transit_visa_country,
                        purpose_of_visit?: "study"
          assert_next_node :outcome_study_m, for_response: "six_months_or_less"
        end

        should "have a next node of outcome_study_m for a study visit with a visa national passport" do
          add_responses what_passport_do_you_have?: @visa_national_country,
                        purpose_of_visit?: "study"
          assert_next_node :outcome_study_m, for_response: "six_months_or_less"
        end

        should "have a next node of outcome_study_no_visa_needed for a study visit with a British overseas " \
               "territory passport" do
          add_responses what_passport_do_you_have?: @british_overseas_territory_country,
                        purpose_of_visit?: "study"
          assert_next_node :outcome_study_no_visa_needed, for_response: "six_months_or_less"
        end

        should "have a next node of outcome_study_no_visa_needed for a study visit with a non-visa national passport" do
          add_responses what_passport_do_you_have?: @non_visa_national_country,
                        purpose_of_visit?: "study"
          assert_next_node :outcome_study_no_visa_needed, for_response: "six_months_or_less"
        end

        should "have a next node of outcome_study_electronic_travel_authorisation for a study visit with an EEA passport" do
          add_responses what_passport_do_you_have?: @eea_country,
                        purpose_of_visit?: "study"
          assert_next_node :outcome_study_electronic_travel_authorisation, for_response: "six_months_or_less"
        end

        should "have a next node of outcome_work_electronic_travel_authorisation for a work visit with a electronic travel authorisation passport" do
          add_responses what_passport_do_you_have?: @electronic_travel_authorisation_country,
                        purpose_of_visit?: "work"
          assert_next_node :outcome_work_electronic_travel_authorisation, for_response: "six_months_or_less"
        end

        should "have a next node of outcome_work_n for a work visit with a British overseas territory passport" do
          add_responses what_passport_do_you_have?: @british_overseas_territory_country,
                        purpose_of_visit?: "work"
          assert_next_node :outcome_work_n, for_response: "six_months_or_less"
        end

        should "have a next node of outcome_work_electronic_travel_authorisation for a work visit with a Taiwan passport" do
          add_responses what_passport_do_you_have?: "taiwan", purpose_of_visit?: "work"
          assert_next_node :outcome_work_electronic_travel_authorisation, for_response: "six_months_or_less"
        end

        should "have a next node of outcome_work_n for a work visit with a non-visa national passport" do
          add_responses what_passport_do_you_have?: @non_visa_national_country,
                        purpose_of_visit?: "work"
          assert_next_node :outcome_work_n, for_response: "six_months_or_less"
        end

        should "have a next node of outcome_work_electronic_travel_authorisation for a work visit with an EEA passport" do
          add_responses what_passport_do_you_have?: @eea_country,
                        purpose_of_visit?: "work"
          assert_next_node :outcome_work_electronic_travel_authorisation, for_response: "six_months_or_less"
        end

        should "have a next node of outcome_work_m for a work visit for other countries" do
          add_responses what_passport_do_you_have?: @direct_airside_transit_visa_country,
                        purpose_of_visit?: "work"
          assert_next_node :outcome_work_m, for_response: "six_months_or_less"
        end
      end
    end
  end

  context "question: travelling_visiting_partner_family_member?" do
    setup do
      testing_node :travelling_visiting_partner_family_member?
      add_responses what_passport_do_you_have?: @visa_national_country,
                    dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "tourism"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of outcome_tourism_visa_partner for a 'yes' response" do
        assert_next_node :outcome_tourism_visa_partner, for_response: "yes"
      end

      should "have a next node of outcome_standard_visitor_visa for a 'no' response and a non family visit" do
        assert_next_node :outcome_standard_visitor_visa, for_response: "no"
      end
    end
  end

  context "question: partner_family_british_citizen?" do
    setup do
      testing_node :partner_family_british_citizen?
      add_responses what_passport_do_you_have?: @visa_national_country,
                    dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "family"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of outcome_partner_family_british_citizen_y for a 'yes' response" do
        assert_next_node :outcome_partner_family_british_citizen_y, for_response: "yes"
      end

      should "have a next node of partner_family_eea? for a 'no' response" do
        assert_next_node :partner_family_eea?, for_response: "no"
      end
    end
  end

  context "question: partner_family_eea?" do
    setup do
      testing_node :partner_family_eea?
      add_responses what_passport_do_you_have?: @visa_national_country,
                    dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "family",
                    partner_family_british_citizen?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of outcome_partner_family_eea_y for a 'yes' response" do
        assert_next_node :outcome_partner_family_eea_y, for_response: "yes"
      end

      should "have a next node of outcome_partner_family_eea_n for a 'no' response" do
        assert_next_node :outcome_partner_family_eea_n, for_response: "no"
      end
    end
  end

  context "outcome: outcome_marriage_visa_nat_direct_airside_transit_visa" do
    setup do
      testing_node :outcome_marriage_visa_nat_direct_airside_transit_visa
      add_responses purpose_of_visit?: "marriage",
                    dual_british_or_irish_citizenship?: "no"
    end

    %w[estonia latvia].each do |country|
      should "render visa country guidance when an alien #{country} passport is held" do
        add_responses what_passport_do_you_have?: country,
                      what_sort_of_passport?: "alien"
        assert_rendered_outcome text: "You must apply for your visa from the country you’re currently living in."
      end
    end

    should "render visa country guidance when passport country is stateless-or-refugee" do
      add_responses what_passport_do_you_have?: "stateless-or-refugee"
      assert_rendered_outcome text: "You must apply for your visa from the country you’re originally from or currently living in."
    end
  end

  context "outcome: outcome_medical_y" do
    setup do
      testing_node :outcome_medical_y
      add_responses dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "medical"
    end

    %w[estonia latvia].each do |country|
      should "render visa country guidance when an alien #{country} passport is held" do
        add_responses what_passport_do_you_have?: country,
                      what_sort_of_passport?: "alien"
        assert_rendered_outcome text: "You must apply for your visa from the country you’re currently living in."
      end
    end

    should "render visa country guidance when passport country is stateless-or-refugee" do
      add_responses what_passport_do_you_have?: "stateless-or-refugee"
      assert_rendered_outcome text: "You must apply for your visa from the country you’re originally from or currently living in."
    end
  end

  context "outcome: outcome_marriage_nvn" do
    setup do
      testing_node :outcome_marriage_nvn
      add_responses dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "marriage"
    end

    should "render specific guidance to British nationals overseas" do
      add_responses what_passport_do_you_have?: "british-national-overseas"
      assert_rendered_outcome text: "you can apply for a British National Overseas (BNO) visa."
      assert_rendered_outcome text: "You will not need a visa but"
    end

    should "render different guidance to non-British nationals overseas" do
      add_responses what_passport_do_you_have?: @eea_country
      assert_rendered_outcome text: "you must apply for a family visa"
      assert_rendered_outcome text: "electronic travel authorisation (ETA)"
      assert_no_rendered_outcome text: "You will not need a visa but"
    end

    should "render specific guidance related to converting a civil partnership into a marriage for ETA
        country passport holders, instead of standard nvn guidance" do
      add_responses what_passport_do_you_have?: @electronic_travel_authorisation_country
      assert_rendered_outcome text: "electronic travel authorisation (ETA)"
      assert_no_rendered_outcome text: "You will not need a visa but"
    end
  end

  context "outcome: outcome_no_visa_needed" do
    setup do
      testing_node :outcome_no_visa_needed
      add_responses dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "transit"
    end

    should "not render a suggestion of evidence for a further journey for EEA countries as they are now ETA countries" do
      add_responses what_passport_do_you_have?: @eea_country,
                    travelling_to_cta?: "somewhere_else"
      assert_no_rendered_outcome text: "you should bring evidence of your onward journey"
    end

    should "not render a suggestion of evidence for a further journey for ETA countries" do
      add_responses what_passport_do_you_have?: @electronic_travel_authorisation_country,
                    travelling_to_cta?: "somewhere_else"
      assert_no_rendered_outcome text: "you should bring evidence of your onward journey"
    end

    should "render a suggestion of applying for a transit visa for ETA countries when transiting to somewhere else" do
      add_responses what_passport_do_you_have?: @electronic_travel_authorisation_country,
                    travelling_to_cta?: "somewhere_else"
      assert_rendered_outcome text: "You may want to apply for a transit visa"
    end

    should "render a suggestion of applying for a transit visa for EU/EEA ETA countries" do
      add_responses what_passport_do_you_have?: @eea_country,
                    travelling_to_cta?: "somewhere_else"
      assert_rendered_outcome text: "You may want to apply for a transit visa"
    end
  end

  context "outcome: outcome_transit_to_the_republic_of_ireland_electronic_travel_authorisation" do
    setup do
      testing_node :outcome_transit_to_the_republic_of_ireland_electronic_travel_authorisation
      add_responses dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "transit"
    end

    should "render a suggestion of a transit visa for a further journey to Ireland" do
      add_responses what_passport_do_you_have?: @eea_country,
                    travelling_to_cta?: "republic_of_ireland"
      assert_rendered_outcome text: "You may want to apply for a transit visa"
    end

    should "render specific guidance for a Taiwan passport" do
      add_responses what_passport_do_you_have?: "taiwan",
                    travelling_to_cta?: "republic_of_ireland"
      assert_rendered_outcome text: "personal ID number on the bio data page"
    end
  end

  context "medical ETA for Taiwan" do
    setup do
      testing_node :outcome_medical_electronic_travel_authorisation
      add_responses what_passport_do_you_have?: "taiwan",
                    dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "medical"
    end

    should "render specific guidance for a Taiwan passport" do
      assert_rendered_outcome text: "personal ID number on the bio data page"
    end
  end

  context "tourism ETA for Taiwan" do
    setup do
      testing_node :outcome_tourism_electronic_travel_authorisation
      add_responses what_passport_do_you_have?: "taiwan",
                    dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "tourism"
    end

    should "render specific guidance for a Taiwan passport" do
      assert_rendered_outcome text: "personal ID number on the bio data page"
    end
  end

  context "work ETA for Taiwan" do
    setup do
      testing_node :outcome_work_electronic_travel_authorisation
      add_responses what_passport_do_you_have?: "taiwan",
                    dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "work",
                    staying_for_how_long?: "six_months_or_less"
    end

    should "render specific guidance for a Taiwan passport" do
      assert_rendered_outcome text: "personal ID number on the bio data page"
    end
  end

  context "school ETA for Taiwan" do
    setup do
      testing_node :outcome_school_electronic_travel_authorisation
      add_responses what_passport_do_you_have?: "taiwan",
                    dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "school"
    end

    should "render specific guidance for a Taiwan passport" do
      assert_rendered_outcome text: "personal ID number on the bio data page"
    end
  end

  context "study ETA for Taiwan" do
    setup do
      testing_node :outcome_study_electronic_travel_authorisation
      add_responses what_passport_do_you_have?: "taiwan",
                    dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "study",
                    staying_for_how_long?: "six_months_or_less"
    end

    should "render specific guidance for a Taiwan passport" do
      assert_rendered_outcome text: "personal ID number on the bio data page"
    end
  end

  context "outcome: outcome_school_y" do
    setup do
      testing_node :outcome_school_y
      add_responses dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "school"
    end

    test_estonia_latvia_alien_outcome_guidance
    test_stateless_or_refugee_outcome_guidance
  end

  context "outcome: outcome_standard_visitor_visa" do
    setup do
      testing_node :outcome_standard_visitor_visa
      add_responses dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "tourism",
                    travelling_visiting_partner_family_member?: "no"
    end

    should "render China specific guidance" do
      add_responses what_passport_do_you_have?: "china"
      assert_rendered_outcome text: "You can apply for an ‘ADS visa’"
    end

    test_stateless_or_refugee_outcome_guidance
  end

  context "outcome: outcome_study_m" do
    setup do
      testing_node :outcome_study_m
      add_responses dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "study",
                    staying_for_how_long?: "six_months_or_less"
    end

    test_stateless_or_refugee_outcome_guidance
  end

  context "outcome: outcome_study_y" do
    setup do
      testing_node :outcome_study_y
      add_responses dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "study",
                    staying_for_how_long?: "longer_than_six_months"
    end

    should "render extra guidance to British nationals overseas" do
      add_responses what_passport_do_you_have?: "british-national-overseas"
      assert_rendered_outcome text: "You can also study with a British National Overseas (BNO) visa"
    end

    test_stateless_or_refugee_outcome_guidance
  end

  context "outcome: outcome_transit_to_the_republic_of_ireland" do
    setup do
      testing_node :outcome_transit_to_the_republic_of_ireland
      add_responses dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "transit",
                    travelling_to_cta?: "republic_of_ireland"
    end

    should "render different guidance for passports from outher countries" do
      add_responses what_passport_do_you_have?: @visa_national_country
      assert_rendered_outcome text: "You’ll need a visa to pass through the UK (unless you’re exempt)"
    end
  end

  context "outcome: outcome_transit_leaving_airport" do
    setup do
      testing_node :outcome_transit_leaving_airport
      add_responses dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "transit",
                    travelling_to_cta?: "somewhere_else",
                    passing_through_uk_border_control?: "yes"
    end

    should "render different guidance for passports from outher countries" do
      add_responses what_passport_do_you_have?: @visa_national_country
      assert_rendered_outcome text: "You’ll need a visa to pass through the UK in transit"
    end
  end

  context "outcome: outcome_transit_leaving_airport_direct_airside_transit_visa" do
    setup do
      testing_node :outcome_transit_leaving_airport_direct_airside_transit_visa
      add_responses dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "transit",
                    travelling_to_cta?: "somewhere_else",
                    passing_through_uk_border_control?: "yes"
    end

    should "render extra guidance for a B1/B2 visa exception" do
      add_responses what_passport_do_you_have?: @b1_b2_country
      assert_rendered_outcome text: "except if you have a B1 or B2 visit visa from the USA"
    end
  end

  context "outcome: outcome_work_n" do
    setup do
      testing_node :outcome_work_n
      add_responses dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "work",
                    staying_for_how_long?: "six_months_or_less"
    end
  end

  context "outcome: outcome_work_m" do
    setup do
      testing_node :outcome_work_m
      add_responses dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "work",
                    staying_for_how_long?: "six_months_or_less"
    end

    test_estonia_latvia_alien_outcome_guidance
    test_stateless_or_refugee_outcome_guidance
  end

  context "outcome: outcome_work_y" do
    context "what_type_of_work: academic" do
      setup do
        testing_node :outcome_work_y
        add_responses dual_british_or_irish_citizenship?: "no",
                      purpose_of_visit?: "work",
                      staying_for_how_long?: "longer_than_six_months",
                      what_type_of_work?: "academic"
      end

      test_stateless_or_refugee_outcome_guidance
      test_bno_outcome_guidance
      test_country_in_youth_mobility_outcome_guidance
      test_country_in_uk_ancestry_visa
      test_india_young_professionals_visa_guidance
      test_visa_count("canada", 9)
      test_visa_count("china", 7)
      test_visa_count("british-national-overseas", 10)
      test_visa_count("stateless-or-refugee", 7)
    end

    context "what_type_of_work: arts" do
      setup do
        testing_node :outcome_work_y
        add_responses purpose_of_visit?: "work",
                      staying_for_how_long?: "longer_than_six_months",
                      what_type_of_work?: "arts"
      end

      test_stateless_or_refugee_outcome_guidance
      test_bno_outcome_guidance
      test_country_in_youth_mobility_outcome_guidance
      test_india_young_professionals_visa_guidance
      test_visa_count("canada", 11)
      test_visa_count("china", 9)
      test_visa_count("british-national-overseas", 12)
      test_visa_count("stateless-or-refugee", 9)
    end

    context "what_type_of_work: business" do
      setup do
        testing_node :outcome_work_y
        add_responses purpose_of_visit?: "work",
                      staying_for_how_long?: "longer_than_six_months",
                      what_type_of_work?: "business"
      end

      test_stateless_or_refugee_outcome_guidance
      test_bno_outcome_guidance
      test_country_in_youth_mobility_outcome_guidance
      test_country_in_uk_ancestry_visa_with_business_information
      test_india_young_professionals_visa_guidance
      test_visa_count("canada", 6)
      test_visa_count("china", 4)
      test_visa_count("british-national-overseas", 7)
      test_visa_count("stateless-or-refugee", 4)
    end

    context "what_type_of_work: digital" do
      setup do
        testing_node :outcome_work_y
        add_responses purpose_of_visit?: "work",
                      staying_for_how_long?: "longer_than_six_months",
                      what_type_of_work?: "digital"
      end

      test_stateless_or_refugee_outcome_guidance
      test_bno_outcome_guidance
      test_country_in_youth_mobility_outcome_guidance
      test_country_in_uk_ancestry_visa
      test_india_young_professionals_visa_guidance
      test_visa_count("canada", 8)
      test_visa_count("china", 6)
      test_visa_count("british-national-overseas", 9)
      test_visa_count("stateless-or-refugee", 6)
    end

    context "what_type_of_work: health" do
      setup do
        testing_node :outcome_work_y
        add_responses purpose_of_visit?: "work",
                      staying_for_how_long?: "longer_than_six_months",
                      what_type_of_work?: "health"
      end

      test_stateless_or_refugee_outcome_guidance
      test_bno_outcome_guidance
      test_country_in_youth_mobility_outcome_guidance
      test_country_in_uk_ancestry_visa
      test_india_young_professionals_visa_guidance
      test_visa_count("canada", 10)
      test_visa_count("china", 8)
      test_visa_count("british-national-overseas", 11)
      test_visa_count("stateless-or-refugee", 8)
    end

    context "what_type_of_work: other" do
      setup do
        testing_node :outcome_work_y
        add_responses purpose_of_visit?: "work",
                      staying_for_how_long?: "longer_than_six_months",
                      what_type_of_work?: "other"
      end

      test_stateless_or_refugee_outcome_guidance
      test_bno_outcome_guidance
      test_country_in_youth_mobility_outcome_guidance
      test_country_in_uk_ancestry_visa
      test_india_young_professionals_visa_guidance
      test_visa_count("canada", 12)
      test_visa_count("china", 10)
      test_visa_count("british-national-overseas", 13)
      test_visa_count("stateless-or-refugee", 10)
    end

    context "what_type_of_work: religious" do
      setup do
        testing_node :outcome_work_y
        add_responses purpose_of_visit?: "work",
                      staying_for_how_long?: "longer_than_six_months",
                      what_type_of_work?: "religious"
      end

      test_stateless_or_refugee_outcome_guidance
      test_bno_outcome_guidance
      test_country_in_youth_mobility_outcome_guidance
      test_country_in_uk_ancestry_visa
      test_india_young_professionals_visa_guidance
      test_visa_count("canada", 4)
      test_visa_count("china", 2)
      test_visa_count("british-national-overseas", 5)
      test_visa_count("stateless-or-refugee", 2)
    end
  end

  context "outcome: outcome_joining_family_nvn" do
    setup do
      testing_node :outcome_joining_family_nvn
      add_responses dual_british_or_irish_citizenship?: "no",
                    purpose_of_visit?: "family"
    end

    should "render correct text for non-visa-national country passport" do
      add_responses what_passport_do_you_have?: @non_visa_national_country
      assert_rendered_outcome text: "You may need a visa"
      assert_rendered_outcome text: "Whether you need a visa depends"
    end

    should "not render ETA text for non-visa-national country passport" do
      add_responses what_passport_do_you_have?: @non_visa_national_country
      assert_no_rendered_outcome text: "You'll need a visa or electronic travel authorisation (ETA)"
      assert_no_rendered_outcome text: "Whether you need a visa or ETA depends"
    end

    should "render correct text for ETA country passport" do
      add_responses what_passport_do_you_have?: @electronic_travel_authorisation_country
      assert_rendered_outcome text: "You’ll need an electronic travel authorisation (ETA) or a visa"
      assert_rendered_outcome text: "Whether you need a visa or an ETA depends"
    end

    should "not render non-visa-national text for ETA country passport" do
      add_responses what_passport_do_you_have?: @electronic_travel_authorisation_country
      assert_no_rendered_outcome text: "You may need a visa"
      assert_no_rendered_outcome text: "Whether you need a visa depends"
    end
  end

  context "ETA callout box on" do
    context "outcome: outcome_tourism_n" do
      setup do
        testing_node :outcome_tourism_n
        add_responses dual_british_or_irish_citizenship?: "no",
                      purpose_of_visit?: "tourism"
      end

      should "not render callout box for countries that do not require it" do
        add_responses what_passport_do_you_have?: @british_overseas_territory_country
        assert_no_rendered_outcome text: @non_visa_national_eta_text
        assert_no_rendered_outcome text: @eea_eta_text
      end
    end

    context "outcome: outcome_work_n" do
      setup do
        testing_node :outcome_work_n
        add_responses dual_british_or_irish_citizenship?: "no",
                      purpose_of_visit?: "work",
                      staying_for_how_long?: "six_months_or_less"
      end

      should "not render ETA callout box for countries that do not require it" do
        add_responses what_passport_do_you_have?: @british_overseas_territory_country
        assert_no_rendered_outcome text: @non_visa_national_eta_text
        assert_no_rendered_outcome text: @eea_eta_text
      end
    end

    context "outcome: outcome_study_no_visa_needed" do
      setup do
        testing_node :outcome_study_no_visa_needed
        add_responses dual_british_or_irish_citizenship?: "no",
                      purpose_of_visit?: "study",
                      staying_for_how_long?: "six_months_or_less"
      end

      should "not render ETA callout box for countries that do not require it" do
        add_responses what_passport_do_you_have?: @british_overseas_territory_country
        assert_no_rendered_outcome text: @non_visa_national_eta_text
        assert_no_rendered_outcome text: @eea_eta_text
      end
    end

    context "outcome: outcome_marriage_nvn" do
      setup do
        testing_node :outcome_marriage_nvn
        add_responses dual_british_or_irish_citizenship?: "no",
                      purpose_of_visit?: "marriage"
      end

      should "not render ETA callout box for countries that do not require it" do
        add_responses what_passport_do_you_have?: @british_overseas_territory_country
        assert_no_rendered_outcome text: @non_visa_national_eta_text
        assert_no_rendered_outcome text: @eea_eta_text
      end
    end

    context "outcome: outcome_school_n" do
      setup do
        testing_node :outcome_school_n
        add_responses dual_british_or_irish_citizenship?: "no",
                      purpose_of_visit?: "school"
      end

      should "not render ETA callout box for countries that do not require it" do
        add_responses what_passport_do_you_have?: @british_overseas_territory_country
        assert_no_rendered_outcome text: @non_visa_national_eta_text
        assert_no_rendered_outcome text: @eea_eta_text
      end
    end

    context "outcome: outcome_medical_n" do
      setup do
        testing_node :outcome_medical_n
        add_responses dual_british_or_irish_citizenship?: "no",
                      purpose_of_visit?: "medical"
      end

      should "not render ETA callout box for countries that do not require it" do
        add_responses what_passport_do_you_have?: @british_overseas_territory_country
        assert_no_rendered_outcome text: @non_visa_national_eta_text
        assert_no_rendered_outcome text: @eea_eta_text
      end
    end

    context "outcome: outcome_no_visa_needed" do
      setup do
        testing_node :outcome_no_visa_needed
        add_responses dual_british_or_irish_citizenship?: "no",
                      purpose_of_visit?: "transit",
                      travelling_to_cta?: "somewhere_else"
      end

      should "not render ETA callout box for countries that do not require it" do
        add_responses what_passport_do_you_have?: @british_overseas_territory_country
        assert_no_rendered_outcome text: @non_visa_national_eta_text
        assert_no_rendered_outcome text: @eea_eta_text
      end
    end
  end
end
