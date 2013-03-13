# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class RegisterADeathV2Test < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
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
        end
      end # Answer embassy
      context "answer fco office in the uk" do
        setup do
          add_response 'back_in_the_uk'
        end
        should "give the fco result and be done" do
          assert_current_node :fco_result
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
        assert_state_variable :embassy_high_commission_or_consulate, "British embassy"
        assert_state_variable :clickbook, %Q([Book an appointment online](http://www.britishembassyinbsas.clickbook.net/ "Book an appointment at the British Embassy"){:rel="external"}\n)
      end
    end # Answer Argentina
    context "answer China" do
      setup do
        add_response 'china'
        add_response 'same_country'
      end
      should "give the embassy result and be done" do
        assert_current_node :embassy_result
        assert_state_variable :embassy_high_commission_or_consulate, "British embassy or consulate"
        assert_state_variable :clickbook, %Q(You can book an appointment at the British embassy or consulate in:

- [Beijing](https://www.clickbook.net/dev/bc.nsf/sub/BritEmBeijing \"Book an appointment at the British Embassy\"){:rel=\"external\"}
- [Shanghai](https://www.clickbook.net/dev/bc.nsf/sub/BritconShanghai \"Book an appointment at the British Embassy\"){:rel=\"external\"}
- [Chongqing](https://www.clickbook.net/dev/bc.nsf/sub/BritConChongqing \"Book an appointment at the British Embassy\"){:rel=\"external\"}
- [Guangzhou](https://www.clickbook.net/dev/bc.nsf/sub/BritConGuangzhou \"Book an appointment at the British Embassy\"){:rel=\"external\"}
)
      end
    end # Answer China
    context "answer Austria" do
      setup do
        add_response 'austria'
        add_response 'same_country'
      end
      should "give the embassy result and be done" do
        assert_current_node :embassy_result
        assert_state_variable :embassy_high_commission_or_consulate, "British embassy"
        assert_state_variable :clickbook, '' 
        assert_state_variable :postal_form_url, "http://ukinaustria.fco.gov.uk/resources/en/pdf/pdf1/credit-card-form"
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
        assert_state_variable :embassy_high_commission_or_consulate, "British embassy"
        assert_state_variable :clickbook, %Q([Book an appointment online](http://britishconsulate-gen.clickbook.net/ "Book an appointment at the British Embassy"){:rel="external"}\n)
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
        assert_state_variable :embassy_high_commission_or_consulate, "British embassy"
        assert_state_variable :clickbook, %Q(You can book an appointment at the British embassy or consulate in:

- [Rome](https://www.clickbook.net/dev/bc.nsf/sub/britishconsrome \"Book an appointment at the British Embassy\"){:rel=\"external\"}
- [Milan](https://www.clickbook.net/dev/bc.nsf/sub/britishconsmilan \"Book an appointment at the British Embassy\"){:rel=\"external\"}
)
        assert_state_variable :postal_form_url, "http://ukinitaly.fco.gov.uk/resources/en/word/3121380/credit-card-authorisation-slip"
        assert_state_variable :postal_return_form_url, "http://ukinitaly.fco.gov.uk/resources/en/word/3121380/Return-delivery-form"
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
        assert_state_variable :embassy_high_commission_or_consulate, "British embassy"
        assert_state_variable :clickbook, '' 
        assert_state_variable :postal_form_url, "http://ukinspain.fco.gov.uk/resources/en/pdf/4758385/20090413_credit_card_form.pdf" 
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
        assert_state_variable :embassy_high_commission_or_consulate, "British embassy"
        assert_state_variable :clickbook, %Q([Book an appointment online](http://ukinparis.clickbook.net/ "Book an appointment at the British Embassy"){:rel="external"}\n)
        assert_state_variable :postal_form_url, "http://ukinfrance.fco.gov.uk/resources/en/word/consular/2012/death-registration-form" 
        assert_phrase_list :postal, [:postal_intro, :postal_registration_by_form]
        assert_state_variable :country_name, "Andorra"
        assert_state_variable :current_location_name, "France"
      end
    end # Answer Andorra, now in France 
  end # Overseas
end
