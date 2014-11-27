# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'
require 'gds_api/test_helpers/worldwide'

class RegisterADeathTestV2 < ActiveSupport::TestCase
  include FlowTestHelper
  include GdsApi::TestHelpers::Worldwide

  setup do
    @location_slugs = %w(afghanistan andorra argentina australia austria barbados belgium brazil dominica egypt france germany iran italy libya morocco north-korea pakistan serbia slovakia spain st-kitts-and-nevis)
    worldwide_api_has_locations(@location_slugs)
    setup_for_testing_flow 'register-a-death-v2'
  end

  should "ask where the death happened" do
    assert_current_node :where_did_the_death_happen?
  end

  context "answer England or Wales" do
    setup do
      add_response 'england_wales'
    end
    should "ask whether the death occurred at home or in hospital or elsewhere" do
      assert_current_node :did_the_person_die_at_home_hospital?
    end
    context "answer home or in hospital" do
      setup do
        add_response 'at_home_hospital'
      end
      should "ask if the death was expected" do
        assert_current_node :was_death_expected?
      end
      should "be outcome1 if death was expected" do
        add_response 'yes'
        assert_current_node :uk_result
        assert_phrase_list :content_sections, [:intro_ew, :who_can_register, :who_can_register_home_hospital, :what_you_need_to_do_expected, :need_to_tell_registrar, :documents_youll_get_ew_expected]
      end
      should "be outcome3 if death not expected" do
        add_response 'no'
        assert_current_node :uk_result
        assert_phrase_list :content_sections, [:intro_ew, :who_can_register, :who_can_register_home_hospital, :what_you_need_to_do_unexpected, :need_to_tell_registrar, :documents_youll_get_ew_unexpected]
      end
    end
    context "answer elsewhere" do
      setup do
        add_response 'elsewhere'
      end
      should "ask if the death was expected" do
        assert_current_node :was_death_expected?
      end
      should "be outcome2 if death was expected" do
        add_response :yes
        assert_current_node :uk_result
        assert_phrase_list :content_sections, [:intro_ew, :who_can_register, :who_can_register_elsewhere, :what_you_need_to_do_expected, :need_to_tell_registrar, :documents_youll_get_ew_expected]
      end

      should "be outcome4 if death not expected" do
        add_response :no
        assert_current_node :uk_result
        assert_phrase_list :content_sections, [:intro_ew, :who_can_register, :who_can_register_elsewhere, :what_you_need_to_do_unexpected, :need_to_tell_registrar, :documents_youll_get_ew_unexpected]
      end
    end
  end # England, Wales

  context "answer Scotland" do
    setup do
      add_response 'scotland'
    end
    should "ask whether the death occurred at home, in hospital or elsewhere" do
      assert_current_node :did_the_person_die_at_home_hospital?
    end
    context "answer home or in hospital" do
      setup do
        add_response 'at_home_hospital'
      end
      should "ask if the death was expected" do
        assert_current_node :was_death_expected?
      end
      should "be outcome5 if death was expected" do
        add_response :yes
        assert_current_node :uk_result
        assert_phrase_list :content_sections, [:intro_scotland]
      end
      should "be outcome7 if death not expected" do
        add_response :no
        assert_current_node :uk_result
        assert_phrase_list :content_sections, [:intro_scotland]
      end
    end
    context "answer elsewhere" do
      setup do
        add_response 'elsewhere'
      end
      should "ask if the death was expected" do
        assert_current_node :was_death_expected?
      end
      should "be outcome6 if death was expected" do
        add_response :yes
        assert_current_node :uk_result
        assert_phrase_list :content_sections, [:intro_scotland]
      end

      should "be outcome8 if death not expected" do
        add_response :no
        assert_current_node :uk_result
        assert_phrase_list :content_sections, [:intro_scotland]
      end
    end
  end # Scotland

  context "answer Northern Ireland" do
    setup do
      add_response 'northern_ireland'
    end
    should "ask whether the death occurred at home, in hospital or elsewhere" do
      assert_current_node :did_the_person_die_at_home_hospital?
    end
    context "answer home or in hospital" do
      setup do
        add_response 'at_home_hospital'
      end
      should "ask if the death was expected" do
        assert_current_node :was_death_expected?
      end
      should "be outcome5 if death was expected" do
        add_response :yes
        assert_current_node :uk_result
        assert_phrase_list :content_sections, [:intro_northern_ireland]
      end
      should "be outcome7 if death not expected" do
        add_response :no
        assert_current_node :uk_result
        assert_phrase_list :content_sections, [:intro_northern_ireland]
      end
    end
    context "answer elsewhere" do
      setup do
        add_response 'elsewhere'
      end
      should "ask if the death was expected" do
        assert_current_node :was_death_expected?
      end
      should "be outcome6 if death was expected" do
        add_response :yes
        assert_current_node :uk_result
        assert_phrase_list :content_sections, [:intro_northern_ireland]
      end

      should "be outcome8 if death not expected" do
        add_response :no
        assert_current_node :uk_result
        assert_phrase_list :content_sections, [:intro_northern_ireland]
      end
    end
  end # Northern Ireland

  context "answer overseas" do
    setup do
      add_response 'overseas'
    end

    should "ask which country" do
      assert_current_node :which_country?
    end
    context "answer Australia" do
      setup do
        add_response 'australia'
      end
      should "give the commonwealth result" do
        assert_state_variable :current_location_name_lowercase_prefix, "Australia"
        assert_current_node :commonwealth_result
      end
    end # Australia (commonwealth country)
    context "answer Spain" do
      setup do
        worldwide_api_has_organisations_for_location('spain', read_fixture_file('worldwide/spain_organisations.json'))
        add_response 'spain'
      end
      should "ask where you are now" do
        assert_state_variable :current_location_name_lowercase_prefix, "Spain"
        assert_current_node :where_are_you_now?
      end
      context "answer same country" do
        setup do
          add_response 'same_country'
        end
        should "give the embassy result and be done" do
          assert_current_node :oru_result
          assert_phrase_list :oru_address, [:oru_address_abroad]
          assert_phrase_list :translator_link, [:approved_translator_link]
          assert_state_variable :translator_link_url, "/government/publications/spain-list-of-lawyers"
          assert_phrase_list :waiting_time, [:registration_takes_3_days]
        end
      end # Answer embassy
      context "answer ORU office in the uk" do
        setup do
          add_response 'in_the_uk'
        end
        should "give the ORU result and be done" do
          assert_current_node :oru_result
          assert_phrase_list :oru_address, [:oru_address_uk]
          assert_phrase_list :translator_link, [:approved_translator_link]
          assert_state_variable :translator_link_url, "/government/publications/spain-list-of-lawyers"
          assert_phrase_list :waiting_time, [:registration_takes_3_days]
        end
      end # Answer ORU
    end # Answer Spain

    context "answer Morocco - currently in the UK" do
      setup do
        worldwide_api_has_organisations_for_location('morocco', read_fixture_file('worldwide/morocco_organisations.json'))
        add_response 'morocco'
      end
      should "ask where are you now" do
        assert_state_variable :current_location_name_lowercase_prefix, "Morocco"
        assert_current_node :where_are_you_now?
      end
      context "answer ORU office in the uk" do
        setup do
          add_response 'in_the_uk'
        end
        should "give the ORU result and be done" do
          assert_current_node :oru_result
          assert_phrase_list :translator_link, [:no_translator_link]
          assert_state_variable :translator_link_url, nil
        end
      end # Answer ORU
    end # Morocco

    context "answer Argentina - currently in Argentina" do
      setup do
        worldwide_api_has_organisations_for_location('argentina', read_fixture_file('worldwide/argentina_organisations.json'))
        add_response 'argentina'
        add_response 'same_country'
      end
      should "give the embassy result and be done" do
        assert_current_node :embassy_result
        assert_phrase_list :documents_required_embassy_result, [:documents_list_embassy]
        assert_state_variable :embassy_high_commission_or_consulate, "British embassy"
        assert_phrase_list :booking_text_embassy_result, [:booking_text_embassy]
        expected_location = WorldLocation.find('argentina')
        assert_state_variable :location, expected_location
        assert_state_variable :organisation, expected_location.fco_organisation
      end
    end # Answer Argentina
    context "answer Austria" do
      setup do
        worldwide_api_has_organisations_for_location('austria', read_fixture_file('worldwide/austria_organisations.json'))
        add_response 'austria'
        add_response 'same_country'
      end
      should "give the embassy result and be done" do
        assert_current_node :embassy_result
        assert_phrase_list :documents_required_embassy_result, [:documents_list_embassy]
        assert_state_variable :embassy_high_commission_or_consulate, "British embassy"
        assert_phrase_list :booking_text_embassy_result, [:booking_text_embassy]
        assert_phrase_list :fees_for_consular_services, [:consular_service_fees]
        assert_state_variable :postal_form_url, "/government/publications/passport-credit-debit-card-payment-authorisation-slip-austria"
        assert_phrase_list :postal, [:postal_intro, :postal_registration_by_form]
        expected_location = WorldLocation.find('austria')
        assert_state_variable :location, expected_location
        assert_state_variable :organisation, expected_location.fco_organisation
      end
    end # Answer Austria
    context "answer Slovakia" do
      setup do
        worldwide_api_has_organisations_for_location('slovakia', read_fixture_file('worldwide/slovakia_organisations.json'))
        add_response 'slovakia'
        add_response 'same_country'
      end
      should "give the embassy result and be done" do
        assert_current_node :embassy_result
        assert_phrase_list :documents_required_embassy_result, [:documents_list_embassy]
        assert_state_variable :embassy_high_commission_or_consulate, "British embassy"
        assert_phrase_list :fees_for_consular_services, [:consular_service_fees]
        assert_state_variable :postal_form_url, "/government/publications/credit-card-authorisation-form--2"
        assert_phrase_list :postal, [:post_only_pay_by_card_countries]
      end
    end # Answer Slovakia
    context "answer Italy" do
      setup do
        worldwide_api_has_organisations_for_location('italy', read_fixture_file('worldwide/italy_organisations.json'))
        add_response 'italy'
        add_response 'same_country'
      end
      should "give the ORU result and be done" do
        assert_current_node :oru_result
        assert_phrase_list :oru_address, [:oru_address_abroad]
        assert_state_variable :button_data, {text: "Pay now", url: "https://pay-register-death-abroad.service.gov.uk/start"}
        assert_phrase_list :translator_link, [:approved_translator_link]
        assert_state_variable :translator_link_url, "/government/publications/italy-list-of-lawyers"
      end
    end # Answer Italy

    context "death occurred in Andorra, but they are now in France" do
      setup do
        worldwide_api_has_organisations_for_location('france', read_fixture_file('worldwide/france_organisations.json'))
        add_response 'andorra'
        add_response 'another_country'
        add_response 'france'
      end
      should "give the oru result and be done" do
        assert_current_node :oru_result
        assert_phrase_list :oru_address, [:oru_address_abroad]
        assert_state_variable :button_data, {text: "Pay now", url: "https://pay-register-death-abroad.service.gov.uk/start"}
        assert_phrase_list :translator_link, [:approved_translator_link]
        assert_state_variable :translator_link_url, "/government/publications/spain-list-of-lawyers"
      end
    end # Answer Andorra, now in France

    context "answer Afghanistan" do
      setup do
        worldwide_api_has_organisations_for_location('afghanistan', read_fixture_file('worldwide/afghanistan_organisations.json'))
        add_response 'afghanistan'
      end
      context "currently still in the country" do
        should "give the embassy result and be done" do
          add_response 'same_country'
          assert_current_node :embassy_result
          assert_phrase_list :documents_required_embassy_result, [:documents_list_embassy]
          assert_state_variable :embassy_high_commission_or_consulate, "British embassy"
          assert_phrase_list :booking_text_embassy_result, [:booking_text_embassy]
          assert_phrase_list :fees_for_consular_services, [:consular_service_fees]
          assert_phrase_list :footnote, [:footnote_exceptions]
          expected_location = WorldLocation.find('afghanistan')
          assert_state_variable :location, expected_location
          assert_state_variable :organisation, expected_location.fco_organisation
        end
      end
      context "now back in the UK" do
        should "give the ORU result and be done" do
          add_response 'in_the_uk'
          assert_current_node :oru_result
          assert_state_variable :button_data, {text: "Pay now", url: "https://pay-register-death-abroad.service.gov.uk/start"}
          assert_phrase_list :oru_address, [:oru_address_uk]
          assert_phrase_list :translator_link, [:no_translator_link]
          assert_state_variable :translator_link_url, nil
        end
      end
    end # Answer Afghanistan
    context "answer Iran" do
      setup do
        worldwide_api_has_organisations_for_location('iran', read_fixture_file('worldwide/iran_organisations.json'))
        add_response 'iran'
      end
      should "give the no embassy result" do
        add_response :no_embassy_result
        expected_location = WorldLocation.find('iran')
      end
    end # Iran
    context "answer Libya" do
      setup do
        worldwide_api_has_organisations_for_location('libya', read_fixture_file('worldwide/libya_organisations.json'))
        add_response 'libya'
        add_response 'same_country'
      end
      should "give the embassy result and be done" do
        assert_current_node :embassy_result
        assert_phrase_list :documents_required_embassy_result, [:documents_list_embassy_libya]
        assert_state_variable :embassy_high_commission_or_consulate, "British embassy"
        assert_phrase_list :booking_text_embassy_result, [:booking_text_embassy]
        assert_phrase_list :fees_for_consular_services, [:consular_service_fees_libya]
        assert_state_variable :postal_form_url, nil
        expected_location = WorldLocation.find('libya')
        assert_state_variable :location, expected_location
        assert_state_variable :organisation, expected_location.fco_organisation
      end
    end # Answer Libya
    context "answer Brazil, registered in north-korea" do
      setup do
        worldwide_api_has_organisations_for_location('brazil', read_fixture_file('worldwide/brazil_organisations.json'))
        worldwide_api_has_organisations_for_location('north-korea', read_fixture_file('worldwide/north-korea_organisations.json'))
        add_response 'brazil'
        add_response 'another_country'
        add_response 'north-korea'
      end
      should "give the embassy result and be done" do
        assert_current_node :embassy_result
        assert_phrase_list :documents_required_embassy_result, [:documents_list_embassy]
        assert_state_variable :embassy_high_commission_or_consulate, "British embassy"
        assert_phrase_list :booking_text_embassy_result, [:booking_text_embassy]
        assert_phrase_list :fees_for_consular_services, [:consular_service_fees]
        expected_location = WorldLocation.find('north-korea')
        assert_state_variable :location, expected_location
        assert_state_variable :organisation, expected_location.fco_organisation
      end
    end # Answer Brazil

    context "answer death in Serbia, user in the UK" do
      setup do
        worldwide_api_has_organisations_for_location('serbia', read_fixture_file('worldwide/serbia_organisations.json'))
        add_response 'serbia'
        add_response 'in_the_uk'
      end
      should "give the embassy result and be done" do
        assert_phrase_list :oru_address, [:oru_address_uk]
        assert_phrase_list :translator_link, [:approved_translator_link]
        assert_state_variable :translator_link_url, "/government/publications/list-of-translators-and-interpreters-in-serbia"
      end
    end # Answer Serbia
    context "answer Pakistan, user in the UK" do
      should "give the oru result" do
        worldwide_api_has_organisations_for_location('pakistan', read_fixture_file('worldwide/pakistan_organisations.json'))
        add_response "pakistan"
        add_response "in_the_uk"
        assert_current_node :oru_result
        assert_phrase_list :waiting_time, [:registration_can_take_3_months]
      end
    end # Pakistan and in UK
    context "answer death in dominica, user in st kitts" do
      setup do
        worldwide_api_has_organisations_for_location('barbados', read_fixture_file('worldwide/barbados_organisations.json'))
        add_response 'dominica'
        add_response 'another_country'
        add_response 'st-kitts-and-nevis'
      end
      should "give the embassy result and be done" do
        assert_phrase_list :oru_address, [:oru_address_abroad]
        assert_phrase_list :translator_link, [:no_translator_link]
        assert_state_variable :translator_link_url, nil
      end
    end # Answer Dominica
    context "answer death in Egypt, user in Belgium" do
      setup do
        worldwide_api_has_organisations_for_location('belgium', read_fixture_file('worldwide/belgium_organisations.json'))
        add_response 'egypt'
        add_response 'another_country'
        add_response 'belgium'
      end
      should "give embassy_result" do
        assert_current_node :embassy_result
        assert_state_variable :death_country_name_lowercase_prefix, 'Egypt'
        assert_state_variable :current_location_name_lowercase_prefix, 'Belgium'
        assert_state_variable :current_location, 'belgium'
      end
    end # Death in Egypt user in Belgium

    context "answer North Korea" do
      setup do
        worldwide_api_has_organisations_for_location('north-korea', read_fixture_file('worldwide/north-korea_organisations.json'))
        add_response 'north-korea'
      end
      context "still in North Korea" do
        should "give the embassy result (this is an exception to ORU transition)" do
          add_response 'same_country'
          assert_current_node :embassy_result
          assert_phrase_list :documents_required_embassy_result, [:"documents_list_embassy_north-korea"]
        end
      end
      context "in another country" do
        should "give the ORU result" do
          add_response 'another_country'
          add_response 'italy'
          assert_current_node :oru_result
          assert_phrase_list :oru_courier_text, [:oru_courier_text_default]
          assert_phrase_list :waiting_time, [:registration_takes_3_days]
        end
      end
    end # Answer North Korea

    context "died in austria, user in north-korea" do
      setup do
        worldwide_api_has_organisations_for_location('austria', read_fixture_file('worldwide/austria_organisations.json'))
        add_response 'austria'
        add_response 'another_country'
        worldwide_api_has_organisations_for_location('north-korea', read_fixture_file('worldwide/north-korea_organisations.json'))
        add_response 'north-korea'
      end
      should "take you to the embassy outcome with specific phrasing" do
        assert_current_node :embassy_result
        assert_phrase_list :footnote, [:footnote_oru_variants_intro, :"footnote_oru_variants_north-korea", :footnote_oru_variants_out]
      end
    end

  end # Overseas
end
