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

  context "answer Scotland or NI" do
    setup do
      add_response 'scotland_northern_ireland'
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
        assert_phrase_list :content_sections, [:intro_other,
          :documents_youll_get_other_expected]
      end
      should "be outcome7 if death not expected" do
        add_response :no
        assert_current_node :uk_result
        assert_phrase_list :content_sections, [:intro_other, :intro_other_unexpected,
          :documents_youll_get_other_unexpected]
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
        assert_phrase_list :content_sections, [:intro_other,
          :documents_youll_get_other_expected]
      end

      should "be outcome8 if death not expected" do
        add_response :no
        assert_current_node :uk_result
        assert_phrase_list :content_sections, [:intro_other, :intro_other_unexpected,
          :documents_youll_get_other_unexpected]
      end
    end
  end # Scotland, NI

  context "answer overseas" do
    setup do
      add_response 'overseas'
    end

    should "ask whether the death was expected" do
      assert_current_node :was_death_expected?
    end

    context "answer yes" do
      setup do
        add_response 'yes'
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
        should "ask where you want to register the death" do
          assert_state_variable :country_name, "Spain"
          assert_current_node :where_do_you_want_to_register_the_death?
        end
        context "answer embassy" do
          setup do
            add_response 'embassy'
          end
          should "give the embassy result and be done" do
            assert_state_variable :registration_form_url, 
              "http://ukinspain.fco.gov.uk/resources/en/pdf/help-for-BNs/DeathRegForm"
            assert_phrase_list :registration_form, [:country_registration_form_download]
            assert_current_node :embassy_result
          end
        end # Answer embassy
        context "answer fco office in the uk" do
          setup do
            add_response 'fco_uk'
          end
          should "give the fco result and be done" do
            assert_current_node :fco_result
            assert_state_variable :unexpected_death_section, ''
          end
        end # Answer fco 
      end # Answer Spain
    end # Answer yes

    context "answer no" do
      setup do
        add_response 'no'
      end
      should "ask which country" do
        assert_current_node :which_country?
      end
      context "answer Morocco" do
        setup do
          add_response 'morocco'
        end
        should "ask where you want to register the death" do
          assert_state_variable :country_name, "Morocco"
          assert_current_node :where_do_you_want_to_register_the_death?
        end
        context "answer fco office in the uk" do
          setup do
            add_response 'fco_uk'
          end
          should "give the fco result and be done" do
            assert_current_node :fco_result
            assert_phrase_list :unexpected_death_section, [:unexpected_death]
          end
        end # Answer fco 
      end # Morocco
    end
  end # Overseas
end
