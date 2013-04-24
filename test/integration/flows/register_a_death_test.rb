# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class RegisterADeathTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'register-a-death'
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
        assert_phrase_list :content_sections, [:intro_ew,
          :who_can_register, :who_can_register_home_hospital,
          :what_you_need_to_do_expected, :need_to_tell_registrar,
          :documents_youll_get_ew_expected]
      end
      should "be outcome3 if death not expected" do
        add_response 'no'
        assert_current_node :uk_result
        assert_phrase_list :content_sections, [:intro_ew,
          :who_can_register, :who_can_register_home_hospital,
          :what_you_need_to_do_unexpected, :need_to_tell_registrar,
          :documents_youll_get_ew_unexpected]
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
        assert_phrase_list :content_sections, [:intro_ew,
          :who_can_register, :who_can_register_elsewhere,
          :what_you_need_to_do_expected, :need_to_tell_registrar,
          :documents_youll_get_ew_expected]
      end

      should "be outcome4 if death not expected" do
        add_response :no
        assert_current_node :uk_result
        assert_phrase_list :content_sections, [:intro_ew,
          :who_can_register, :who_can_register_elsewhere,
          :what_you_need_to_do_unexpected, :need_to_tell_registrar,
          :documents_youll_get_ew_unexpected]
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
        assert_state_variable :country_name, "Australia"
        assert_current_node :commonwealth_result
      end
    end # Australia (commonwealth country)
    context "answer Spain" do
      setup do
        add_response 'spain'
      end
      should "ask where you are now" do
        assert_state_variable :country_name, "Spain"
        assert_state_variable :current_location_name, "Spain"
        assert_current_node :where_are_you_now?
      end
      context "answer same country" do
        setup do
          add_response 'same_country'
        end
        should "give the embassy result and be done" do
          assert_current_node :embassy_result
          assert_phrase_list :footnote, [:footnote]
        end
      end # Answer embassy
      context "answer fco office in the uk" do
        setup do
          add_response 'back_in_the_uk'
        end
        should "give the fco result and be done" do
          assert_current_node :fco_result
          assert_state_variable :embassy_high_commission_or_consulate, "British embassy"
          assert_phrase_list :registration_footnote, [:reg_footnote]
        end
      end # Answer fco 
    end # Answer Spain

    context "answer Morocco" do
      setup do
        add_response 'morocco'
      end
      should "ask where you want to register the death" do
        assert_state_variable :country_name, "Morocco"
        assert_current_node :where_are_you_now?
      end
      context "answer fco office in the uk" do
        setup do
          add_response 'back_in_the_uk'
        end
        should "give the fco result and be done" do
          assert_current_node :fco_result
        end
      end # Answer fco 
    end # Morocco

    context "answer Argentina" do
      setup do
        add_response 'argentina'
        add_response 'same_country'
      end
      should "give the embassy result and be done" do
        assert_current_node :embassy_result
        assert_phrase_list :documents_required_embassy_result, [:documents_list_embassy]
        assert_state_variable :embassy_high_commission_or_consulate, "British embassy"
        assert_phrase_list :booking_text_embassy_result, [:booking_text_embassy]
        assert_state_variable :clickbook, %Q([Book an appointment online](http://www.britishembassyinbsas.clickbook.net/ "Book an appointment at the British embassy"){:rel="external"}\n)
      end
    end # Answer Argentina
    context "answer China" do
      setup do
        add_response 'china'
        add_response 'same_country'
      end
      should "give the embassy result and be done" do
        assert_current_node :embassy_result
        assert_phrase_list :documents_required_embassy_result, [:documents_list_embassy]
        assert_state_variable :embassy_high_commission_or_consulate, "British embassy or consulate"
        assert_phrase_list :booking_text_embassy_result, [:booking_text_embassy]
        assert_state_variable :clickbook, %Q(You can book an appointment at the British embassy or consulate in:

- [Beijing](https://www.clickbook.net/dev/bc.nsf/sub/BritEmBeijing \"Book an appointment at the British embassy or consulate in Beijing\"){:rel=\"external\"}
- [Shanghai](https://www.clickbook.net/dev/bc.nsf/sub/BritconShanghai \"Book an appointment at the British embassy or consulate in Shanghai\"){:rel=\"external\"}
- [Chongqing](https://www.clickbook.net/dev/bc.nsf/sub/BritConChongqing \"Book an appointment at the British embassy or consulate in Chongqing\"){:rel=\"external\"}
- [Guangzhou](https://www.clickbook.net/dev/bc.nsf/sub/BritConGuangzhou \"Book an appointment at the British embassy or consulate in Guangzhou\"){:rel=\"external\"}
)
        assert_phrase_list :fees_for_consular_services, [:consular_service_fees]
      end
    end # Answer China
    context "answer Austria" do
      setup do
        add_response 'austria'
        add_response 'same_country'
      end
      should "give the embassy result and be done" do
        assert_current_node :embassy_result
        assert_phrase_list :documents_required_embassy_result, [:documents_list_embassy]
        assert_state_variable :embassy_high_commission_or_consulate, "British embassy"
        assert_state_variable :clickbook, '' 
        assert_phrase_list :booking_text_embassy_result, [:booking_text_embassy]
        assert_phrase_list :fees_for_consular_services, [:consular_service_fees]
        assert_state_variable :postal_form_url, "/government/uploads/system/uploads/attachment_data/file/136797/credit-card-form.pdf"
        assert_phrase_list :postal, [:postal_intro, :postal_registration_by_form]
      end
    end # Answer Austria
    context "answer Belgium" do
      setup do
        add_response 'belgium'
        add_response 'same_country'
      end
      should "give the embassy result and be done" do
        assert_current_node :embassy_result
        assert_phrase_list :documents_required_embassy_result, [:documents_list_embassy]
        assert_state_variable :embassy_high_commission_or_consulate, "British consulate-general"
        assert_phrase_list :booking_text_embassy_result, [:booking_text_embassy]
        assert_state_variable :clickbook, %Q([Book an appointment online](http://britishconsulate-gen.clickbook.net/ "Book an appointment at the British consulate-general"){:rel="external"}\n)
        assert_phrase_list :fees_for_consular_services, [:consular_service_fees]
        assert_state_variable :postal_form_url, nil
        assert_phrase_list :postal, [:postal_intro, :postal_registration_belgium]
      end
    end # Answer Belgium
    context "answer Italy" do
      setup do
        add_response 'italy'
        add_response 'same_country'
      end
      should "give the embassy result and be done" do
        assert_current_node :embassy_result
        assert_phrase_list :documents_required_embassy_result, [:documents_list_embassy]
        assert_state_variable :embassy_high_commission_or_consulate, "British embassy"
        assert_phrase_list :booking_text_embassy_result, [:booking_text_embassy]
        assert_phrase_list :fees_for_consular_services, [:consular_service_fees]
        assert_state_variable :clickbook, %Q(You can book an appointment at the British embassy or consulate in:

- [Rome](https://www.clickbook.net/dev/bc.nsf/sub/britishconsrome \"Book an appointment at the British embassy in Rome\"){:rel=\"external\"}
- [Milan](https://www.clickbook.net/dev/bc.nsf/sub/britishconsmilan \"Book an appointment at the British embassy in Milan\"){:rel=\"external\"}
)
        assert_state_variable :postal_form_url, "/government/uploads/system/uploads/attachment_data/file/136810/credit-card-authorisation-slip.doc"
        assert_state_variable :postal_return_form_url, "/government/uploads/system/uploads/attachment_data/file/136822/return-delivery-form.doc"
        assert_phrase_list :postal, [:postal_intro, :postal_registration_by_form, :postal_delivery_form]
      end
    end # Answer Italy
    context "death occurred in Andorra" do
      setup do
        add_response 'andorra'
        add_response 'same_country'
      end
      should "give the embassy result and be done" do
        assert_current_node :embassy_result
        assert_phrase_list :documents_required_embassy_result, [:documents_list_embassy]
        assert_state_variable :embassy_high_commission_or_consulate, "British embassy"
        assert_phrase_list :booking_text_embassy_result, [:booking_text_embassy]
        assert_state_variable :clickbook, '' 
        assert_phrase_list :fees_for_consular_services, [:consular_service_fees]
        assert_state_variable :postal_form_url, "/government/uploads/system/uploads/attachment_data/file/136819/20090413_credit_card_form.pdf.pdf" 
        assert_phrase_list :postal, [:postal_intro, :postal_registration_by_form, :postal_delivery_form]
        assert_state_variable :country_name, "Andorra"
        assert_state_variable :current_location, "spain"
      end
    end # Answer Andorra
    context "death occurred in Andorra, but they are now in France" do
      setup do
        add_response 'andorra'
        add_response 'another_country'
        add_response 'france'
      end
      should "give the embassy result and be done" do
        assert_current_node :embassy_result
        assert_phrase_list :documents_required_embassy_result, [:documents_list_embassy]
        assert_state_variable :embassy_high_commission_or_consulate, "British embassy"
        assert_phrase_list :booking_text_embassy_result, [:booking_text_embassy]
        assert_state_variable :clickbook, %Q([Book an appointment online](http://ukinparis.clickbook.net/ "Book an appointment at the British embassy"){:rel="external"}\n)
        assert_phrase_list :fees_for_consular_services, [:consular_service_fees]
        assert_state_variable :postal_form_url, "/government/uploads/system/uploads/attachment_data/file/136805/death-registration-form.doc" 
        assert_phrase_list :postal, [:postal_intro, :postal_registration_by_form]
        assert_state_variable :country_name, "Andorra"
        assert_state_variable :current_location_name, "France"
        assert_phrase_list :footnote, [:footnote_another_country]
      end
    end # Answer Andorra, now in France 
    context "answer Afghanistan" do
      setup do
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
        end
      end
      context "now back in the UK" do
        should "give the FCO result and be done" do
          add_response 'back_in_the_uk'
          assert_current_node :fco_result
          assert_state_variable :embassy_high_commission_or_consulate, "British embassy"
          assert_state_variable :registration_footnote, ''      
        end
      end
    end # Answer Afghanistan
    context "answer Iran" do
      should "give the no embassy result" do
        add_response :no_embassy_result
      end
    end # Iran
    context "answer Libya" do
      setup do
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
      end
    end # Answer Libya
    context "answer Sweden" do
      setup do
        add_response 'sweden'
        add_response 'same_country'
      end
      should "give the embassy result and be done" do
        assert_current_node :embassy_result
        assert_phrase_list :documents_required_embassy_result, [:documents_list_embassy_sweden]
        assert_state_variable :embassy_high_commission_or_consulate, "British embassy"
        assert_phrase_list :booking_text_embassy_result, [:booking_text_embassy]
        assert_state_variable :clickbook, %Q([Book an appointment online](http://www.ukinsweden.clickbook.net/ "Book an appointment at the British embassy"){:rel="external"}\n)
        assert_phrase_list :fees_for_consular_services, [:consular_service_fees]
        assert_state_variable :postal_form_url, nil
        assert_phrase_list :postal, [:postal_intro, :postal_registration_sweden]
      end
    end # Answer Sweden
    context "answer Hong Kong" do
      setup do
        add_response 'hong-kong-(sar-of-china)'
        add_response 'same_country'
      end
      should "give the embassy result and be done" do
        assert_current_node :embassy_result
        assert_phrase_list :documents_required_embassy_result, [:documents_list_embassy]
        assert_state_variable :embassy_high_commission_or_consulate, "British consulate-general"
        assert_phrase_list :booking_text_embassy_result, [:booking_text_embassy_hong_kong]
        assert_state_variable :clickbook, ''
        assert_phrase_list :fees_for_consular_services, [:consular_service_fees]
        assert_state_variable :postal_form_url, nil
      end
    end # Answer Hong Kong
    context "answer Brazil" do
      setup do
        add_response 'brazil'
        add_response 'same_country'
      end
      should "give the embassy result and be done" do
        assert_current_node :embassy_result
        assert_phrase_list :documents_required_embassy_result, [:documents_list_embassy]
        assert_state_variable :embassy_high_commission_or_consulate, "British consulate-general"
        assert_phrase_list :booking_text_embassy_result, [:booking_text_embassy]
        assert_state_variable :clickbook, %Q([Book an appointment online](http://www.britishconsulaterj.clickbook.net/ "Book an appointment at the British consulate-general"){:rel="external"}\n)
        assert_phrase_list :fees_for_consular_services, [:consular_service_fees]
        assert_state_variable :postal_form_url, "/government/uploads/system/uploads/attachment_data/file/136799/postbr_birthregform.pdf"
        assert_phrase_list :postal, [:postal_intro, :postal_registration_by_form]
      end
    end # Answer Brazil
    context "answer Germany" do
      setup do
        add_response 'germany'
        add_response 'same_country'
      end
      should "give the embassy result and be done" do
        assert_current_node :embassy_result
        assert_phrase_list :documents_required_embassy_result, [:documents_list_embassy]
        assert_state_variable :embassy_high_commission_or_consulate, "British consulate-general"
        assert_phrase_list :booking_text_embassy_result, [:booking_text_embassy]
        assert_state_variable :clickbook, ''
        assert_phrase_list :fees_for_consular_services, [:consular_service_fees]
        assert_state_variable :postal_form_url, "/government/uploads/system/uploads/attachment_data/file/136806/payment_authorisation_slip.pdf"
        assert_phrase_list :postal, [:postal_intro, :postal_registration_by_form]
        assert_match /40476 Düsseldorf/, current_state.embassy_details
      end
    end # Answer Germany
    context "answer USA" do
      setup do
        add_response 'united-states'
        add_response 'same_country'
      end
      should "give the embassy result and be done" do
        assert_current_node :embassy_result
        assert_phrase_list :documents_required_embassy_result, [:documents_list_embassy]
        assert_state_variable :embassy_high_commission_or_consulate, "British embassy"
        assert_phrase_list :booking_text_embassy_result, [:booking_text_embassy]
        assert_state_variable :clickbook, %Q([Book an appointment online](http://www.britishembassydc.clickbook.net/ "Book an appointment at the British embassy"){:rel="external"}\n)
        assert_phrase_list :fees_for_consular_services, [:consular_service_fees]
        assert_state_variable :postal_form_url, nil
        assert_phrase_list :postal, [:postal_intro, :"postal_registration_united-states"]
        assert_match /3100 Massachusetts Ave, NW/, current_state.embassy_details
      end
    end # Answer USA




  end # Overseas
end
