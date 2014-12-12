# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'
require 'gds_api/test_helpers/worldwide'

class RegisterABirthV2Test < ActiveSupport::TestCase
  include FlowTestHelper
  include GdsApi::TestHelpers::Worldwide

  setup do
    @location_slugs = %w(afghanistan andorra australia bangladesh barbados belize el-salvador estonia germany guatemala grenada iran laos libya maldives netherlands pakistan serbia spain sri-lanka st-kitts-and-nevis thailand turkey united-arab-emirates)
    worldwide_api_has_locations(@location_slugs)
    setup_for_testing_flow 'register-a-birth-v2'
  end

  should "ask which country the child was born in" do
    assert_current_node :country_of_birth?
  end

  context "answer Turkey" do
    setup do
      worldwide_api_has_organisations_for_location('turkey', read_fixture_file('worldwide/turkey_organisations.json'))
      add_response 'turkey'
    end
    should "ask which parent has british nationality" do
      assert_current_node :who_has_british_nationality?
    end
    context "answer mother" do
      setup do
        add_response 'mother'
      end
      should "ask if you are married or civil partnered" do
        assert_current_node :married_couple_or_civil_partnership?
      end
      context "answer no" do
        setup do
          add_response 'no'
        end
        should "ask where you are now and go to embassy result" do
          add_response "same_country"
          assert_current_node :embassy_result
        end
      end # not married/cp
    end # mother
  end # Turkey

  context "answer with a commonwealth country" do
    should "give the commonwealth result" do
      add_response 'australia'
      assert_current_node :commonwealth_result
    end
  end # commonweath result

  context "answer Andorra" do
    should "store the correct registration country" do
      worldwide_api_has_organisations_for_location('spain', read_fixture_file('worldwide/spain_organisations.json'))
      add_response 'andorra'
      add_response 'father'
      add_response 'yes'
      add_response 'same_country'
      assert_state_variable :registration_country, 'spain'
      assert_phrase_list :oru_documents_variant, [:oru_documents_variant_andorra]
    end
  end # Andorra

  context "answer Iran" do
    should "give the no embassy outcome and be done" do
      worldwide_api_has_organisations_for_location('iran', read_fixture_file('worldwide/iran_organisations.json'))
      add_response 'iran'
      assert_current_node :no_embassy_result
    end
  end # Iran

  context "answer Spain" do
    setup do
      worldwide_api_has_organisations_for_location('spain', read_fixture_file('worldwide/spain_organisations.json'))
      add_response 'spain'
    end
    should "store this as the registration country" do
      assert_state_variable :registration_country, 'spain'
    end
    should "ask which parent has british nationality" do
      assert_current_node :who_has_british_nationality?
    end
    context "answer father" do
      setup do
        add_response 'father'
      end
      should "ask if you are married or civil partnered" do
        assert_current_node :married_couple_or_civil_partnership?
      end
      context "answer no" do
        setup do
          add_response 'no'
        end
        should "ask when the child was born" do
          assert_current_node :childs_date_of_birth?
        end
        context "answer pre 1st July 2006" do
          should "give the homeoffice result" do
            add_response '2006-06-30'
            assert_current_node :homeoffice_result
          end
        end
        context "answer on or after 1st July 2006" do
          setup do
            add_response '2006-07-01'
          end
          should "ask where you are now" do
            assert_current_node :where_are_you_now?
          end
        end
      end # not married/cp
    end # father is british citizen
    context "answer mother and father" do
      setup do
        add_response 'mother_and_father'
      end
      should "ask if you are married or civil partnered" do
        assert_current_node :married_couple_or_civil_partnership?
      end
      context "answer yes" do
        setup do
          add_response 'yes'
        end
        should "ask where you are now" do
          assert_current_node :where_are_you_now?
        end
        context "answer back in the UK" do
          should "give the oru result" do
            add_response 'in_the_uk'
            assert_state_variable :registration_country, 'spain'
            assert_state_variable :button_data, {text: "Pay now", url: "https://pay-register-birth-abroad.service.gov.uk/start"}
            assert_current_node :oru_result
            assert_phrase_list :oru_documents_variant, [:oru_documents_variant_spain]
            assert_phrase_list :oru_address, [:oru_address_uk]
            assert_phrase_list :translator_link, [:approved_translator_link]
            assert_state_variable :translator_link_url, "/government/publications/spain-list-of-lawyers"
            assert_phrase_list :waiting_time, [:registration_takes_5_days]
          end
        end
      end # married
    end # Spain
  end
  context "answer Afghanistan" do
    should "give the embassy result" do
      worldwide_api_has_organisations_for_location('afghanistan', read_fixture_file('worldwide/afghanistan_organisations.json'))
      add_response "afghanistan"
      add_response "mother_and_father"
      add_response "yes"
      add_response "same_country"
      assert_current_node :embassy_result
      assert_state_variable :embassy_high_commission_or_consulate, "British embassy"
      assert_state_variable :registration_country_name_lowercase_prefix, "Afghanistan"
      assert_state_variable :british_national_parent, 'mother_and_father'
      assert_phrase_list :documents_you_must_provide, [:documents_you_must_provide_all]
      assert_phrase_list :fees_for_consular_services, [:consular_service_fees]
      assert_phrase_list :go_to_the_embassy, [:registering_all, :registering_either_parent]
      assert_state_variable :postal_form_url, nil
      assert_state_variable :postal, ""
      assert_phrase_list :footnote, [:footnote_exceptions]
    end
  end
  context "born in Bangladesh but currently in Pakistan" do
    should "give the embassy result" do
      worldwide_api_has_organisations_for_location('bangladesh', read_fixture_file('worldwide/bangladesh_organisations.json'))
      worldwide_api_has_organisations_for_location('pakistan', read_fixture_file('worldwide/pakistan_organisations.json'))
      add_response "bangladesh"
      add_response "mother_and_father"
      add_response "yes"
      add_response "another_country"
      add_response "pakistan"
      assert_current_node :embassy_result
      assert_state_variable :embassy_high_commission_or_consulate, "British high commission"
      assert_state_variable :registration_country_name_lowercase_prefix, "Pakistan"
      assert_state_variable :british_national_parent, 'mother_and_father'
      assert_phrase_list :documents_you_must_provide, [:documents_you_must_provide_bangladesh]
      assert_phrase_list :fees_for_consular_services, [:consular_service_fees]
      assert_phrase_list :go_to_the_embassy, [:registering_all, :registering_either_parent]
      assert_state_variable :postal_form_url, nil
      assert_state_variable :postal, ""
      assert_phrase_list :footnote, [:footnote_another_country]
    end
  end # Afghanistan
  context "answer Pakistan" do
    should "give the oru result" do
      worldwide_api_has_organisations_for_location('pakistan', read_fixture_file('worldwide/pakistan_organisations.json'))
      add_response "pakistan"
      add_response "father"
      add_response "yes"
      add_response "in_the_uk"
      assert_current_node :oru_result
      assert_phrase_list :waiting_time, [:registration_can_take_3_months]
    end
  end # Pakistan and in UK
  context "answer Pakistan" do
    should "give the oru result" do
      worldwide_api_has_organisations_for_location('pakistan', read_fixture_file('worldwide/pakistan_organisations.json'))
      add_response "pakistan"
      add_response "father"
      add_response "yes"
      add_response "same_country"
      assert_current_node :embassy_result
    end
  end # Pakistan

  context "answer Belize" do
    should "give the embassy result" do
      worldwide_api_has_organisations_for_location('belize', read_fixture_file('worldwide/belize_organisations.json'))
      add_response "belize"
      add_response "father"
      add_response "no"
      add_response "2006-07-01"
      add_response "same_country"
      assert_current_node :oru_result
      assert_phrase_list :oru_documents_variant, [:oru_documents]
      assert_phrase_list :oru_address, [:oru_address_abroad]
      assert_phrase_list :translator_link, [:no_translator_link]
      assert_phrase_list :waiting_time, [:registration_takes_5_days]
    end # Not married or CP
  end # Belize
  context "answer Libya" do
    should "give the embassy result" do
      worldwide_api_has_organisations_for_location('libya', read_fixture_file('worldwide/libya_organisations.json'))
      add_response "libya"
      add_response "father"
      add_response "yes"
      add_response "same_country"
      assert_current_node :embassy_result
      assert_state_variable :british_national_parent, 'father'
      assert_phrase_list :fees_for_consular_services, [:consular_service_fees_libya]
      assert_phrase_list :documents_you_must_provide, [:documents_you_must_provide_libya]
      assert_phrase_list :go_to_the_embassy, [:registering_all, :registering_either_parent]
    end # Not married or CP
  end # Libya
  context "answer barbados" do
    should "give the embassy result" do
      worldwide_api_has_organisations_for_location('barbados', read_fixture_file('worldwide/barbados_organisations.json'))
      add_response "barbados"
      add_response "father"
      add_response "yes"
      add_response "same_country"
      assert_current_node :embassy_result
      assert_state_variable :british_national_parent, 'father'
      assert_phrase_list :fees_for_consular_services, [:consular_service_fees]
      assert_phrase_list :documents_you_must_provide, [:documents_you_must_provide_all]
      assert_phrase_list :go_to_the_embassy, [:registering_all, :registering_either_parent]
      assert_state_variable :cash_only, ''
      assert_phrase_list :footnote, [:footnote]
    end # Not married or CP
  end # Barbados
  context "answer united arab emirates" do
    should "give the oru result and not married phrase" do
      worldwide_api_has_organisations_for_location('united-arab-emirates', read_fixture_file('worldwide/united-arab-emirates_organisations.json'))
      add_response "united-arab-emirates"
      add_response "mother_and_father"
      add_response "no"
      add_response "same_country"
      assert_current_node :oru_result
      assert_state_variable :british_national_parent, 'mother_and_father'
      assert_phrase_list :oru_documents_variant, [:oru_documents_variant_uae_not_married]
      assert_phrase_list :translator_link, [:approved_translator_link]
      assert_state_variable :translator_link_url, "/government/publications/united-arab-emirates-list-of-lawyers"
      assert_state_variable :country_of_birth, "united-arab-emirates"
      assert_state_variable :paternity_declaration, true
    end # Not married or CP
    should "give the oru result" do
      worldwide_api_has_organisations_for_location('united-arab-emirates', read_fixture_file('worldwide/united-arab-emirates_organisations.json'))
      add_response "united-arab-emirates"
      add_response "father"
      add_response "yes"
      add_response "same_country"
      assert_current_node :oru_result
      assert_state_variable :british_national_parent, 'father'
      assert_phrase_list :oru_documents_variant, [:"oru_documents_variant_united-arab-emirates"]
      assert_phrase_list :translator_link, [:approved_translator_link]
      assert_state_variable :translator_link_url, "/government/publications/united-arab-emirates-list-of-lawyers"
    end
  end # UAE

  context "el-salvador, where you have to register in guatemala" do
    setup do
      worldwide_api_has_organisations_for_location('guatemala', read_fixture_file('worldwide/guatemala_organisations.json'))
      add_response "el-salvador"
    end

    should "calculate the registration country as Guatemala" do
      add_response 'father'
      add_response 'yes'
      add_response 'same_country'
      assert_state_variable :registration_country, "guatemala"
      assert_state_variable :registration_country_name_lowercase_prefix, "Guatemala"
    end
  end

  context "laos, no longer have to register in thailand" do
    setup do
      worldwide_api_has_organisations_for_location('laos', read_fixture_file('worldwide/laos_organisations.json'))
      add_response "laos"
    end
    should "calculate the registration country as Laos" do
      add_response 'father'
      add_response 'yes'
      add_response 'same_country'
      assert_state_variable :registration_country, "laos"
      assert_state_variable :registration_country_name_lowercase_prefix, "Laos"
    end
  end
  context "maldives, where you have to register in sri lanka" do
    setup do
      worldwide_api_has_organisations_for_location('sri-lanka', read_fixture_file('worldwide/sri-lanka_organisations.json'))
      add_response "maldives"
    end
    should "calculate the registration country as Sri Lanka" do
      add_response 'father'
      add_response 'yes'
      add_response 'same_country'
      assert_state_variable :registration_country, "sri-lanka"
      assert_state_variable :registration_country_name_lowercase_prefix, "Sri Lanka"
    end
  end
  context "child born in grenada, parent in St kitts" do
    should "calculate the registration country as barbados" do
      worldwide_api_has_organisations_for_location('barbados', read_fixture_file('worldwide/barbados_organisations.json'))
      add_response 'grenada'
      add_response 'mother'
      add_response 'yes'
      add_response 'another_country'
      add_response 'st-kitts-and-nevis'
      assert_current_node :oru_result
      assert_phrase_list :birth_registration_form, [:birth_registration_form]
    end
  end

  context "answer Netherlands" do
    should "go to oru result" do
      worldwide_api_has_organisations_for_location('netherlands', read_fixture_file('worldwide/netherlands_organisations.json'))
      add_response 'netherlands'
      add_response 'father'
      add_response 'yes'
      add_response 'same_country'
      assert_current_node :oru_result
      assert_phrase_list :oru_documents_variant, [:oru_documents_variant_netherlands]
      assert_phrase_list :oru_address, [:oru_address_abroad]
      assert_phrase_list :translator_link, [:approved_translator_link]
      assert_state_variable :translator_link_url, "/government/publications/netherlands-list-of-lawyers"
    end
  end # Netherlands
  context "answer serbia" do
    should "check for clickbook and give embassy result" do
      worldwide_api_has_organisations_for_location('serbia', read_fixture_file('worldwide/serbia_organisations.json'))
      add_response "serbia"
      add_response "father"
      add_response "yes"
      add_response "same_country"
      assert_current_node :oru_result
      assert_phrase_list :oru_documents_variant, [:oru_documents]
      assert_phrase_list :oru_address, [:oru_address_abroad]
      assert_phrase_list :translator_link, [:approved_translator_link]
      assert_state_variable :translator_link_url, "/government/publications/list-of-translators-and-interpreters-in-serbia"
    end
  end # Serbia
  context "answer estonia" do
    should "show cash, credit card or cheque condition and give embassy result" do
      worldwide_api_has_organisations_for_location('estonia', read_fixture_file('worldwide/estonia_organisations.json'))
      add_response "estonia"
      add_response "mother_and_father"
      add_response "yes"
      add_response "same_country"
      assert_current_node :oru_result
      assert_phrase_list :oru_documents_variant, [:oru_documents]
      assert_phrase_list :oru_address, [:oru_address_abroad]
      assert_phrase_list :translator_link, [:no_translator_link]
    end
  end # Estonia

  context "answer united-arab-emirates" do
    should "go to oru result" do
      worldwide_api_has_organisations_for_location('united-arab-emirates', read_fixture_file('worldwide/united-arab-emirates_organisations.json'))
      add_response "united-arab-emirates"
      add_response "mother_and_father"
      add_response "yes"
      add_response "same_country"
      assert_current_node :oru_result
      assert_phrase_list :oru_documents_variant, [:"oru_documents_variant_united-arab-emirates"]
      assert_phrase_list :oru_address, [:oru_address_abroad]
      assert_phrase_list :translator_link, [:approved_translator_link]
      assert_state_variable :translator_link_url, "/government/publications/united-arab-emirates-list-of-lawyers"
    end
  end # UAE

  context "answer oru country and in another country" do
    should "ask which country the user is in now" do
      worldwide_api_has_organisations_for_location('united-arab-emirates', read_fixture_file('worldwide/united-arab-emirates_organisations.json'))
      add_response "united-arab-emirates"
      add_response "mother_and_father"
      add_response "yes"
      add_response "another_country"
      add_response "germany"
      assert_current_node :oru_result
      assert_phrase_list :oru_courier_text, [:oru_courier_text_default]
      assert_phrase_list :waiting_time, [:registration_takes_5_days]
    end
  end
end
