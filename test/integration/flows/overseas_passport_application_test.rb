# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class OverseasPassportApplicationTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'overseas-passport-application'
  end
  ## Q1
  should "ask which country you are in" do
    assert_current_node :which_country_are_you_in?
  end
  context "answer Australia" do
    setup do
      add_response 'australia'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
      assert_state_variable :current_location, 'australia'
    end
    context "answer applying" do
      setup do
        add_response 'applying'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
      end
      context "answer adult" do
        setup do
          add_response 'adult'
        end
        should "ask which best describes your situation" do
          assert_current_node :which_best_describes_you?
        end
        context "answer born in the uk before 1 Jan 1983" do
          should "give the australian result" do
            add_response 'born-in-uk-pre-1983'
            assert_state_variable :aus_nz_checklist_variant, 'born-in-uk-pre-1983'
            assert_current_node :aus_nz_result
            assert_phrase_list :how_long_it_takes, [:how_long_australia_post]
            assert_phrase_list :cost, [:cost_australia_post]
            assert_phrase_list :how_to_apply, [:how_to_apply_australia_post]
            assert_phrase_list :how_to_apply_documents, [:how_to_apply_adult_australia_post, "aus_nz_born-in-uk-pre-1983".to_sym]
          end
        end
        context "answer born in the uk after 31 Dec 1982 with father born in UK" do
          should "give the australian result" do
            add_response 'born-in-uk-post-1982-uk-father'
            assert_state_variable :aus_nz_checklist_variant, 'born-in-uk-post-1982-uk-father' 
            assert_current_node :aus_nz_result 
          end
        end
        context "answer born in the uk before 1 Jan 1983 with mother born in UK" do
          should "give the australian result" do
            add_response 'born-in-uk-post-1982-uk-mother'
            assert_state_variable :aus_nz_checklist_variant, 'born-in-uk-post-1982-uk-mother'
            assert_current_node :aus_nz_result 
          end
        end
        context "answer born outside the uk with british father married to mother" do
          should "give the australian result" do
            add_response 'born-outside-uk-parents-married'
            assert_state_variable :aus_nz_checklist_variant, 'born-outside-uk-parents-married'
            assert_current_node :aus_nz_result 
          end
        end
        context "answer born outside the uk with british mother" do
          should "give the australian result" do
            add_response 'born-outside-uk-mother-born-in-uk'
            assert_state_variable :aus_nz_checklist_variant, 'born-outside-uk-mother-born-in-uk'
            assert_current_node :aus_nz_result
          end
        end
        context "answer born in UK after 31 Dec 1983 with british citizen father" do
          should "give the australian result" do
            add_response 'born-in-uk-post-1982-father-uk-citizen'
            assert_state_variable :aus_nz_checklist_variant, 'born-in-uk-post-1982-father-uk-citizen'
            assert_current_node :aus_nz_result
          end
        end
        context "answer born in UK after 31 Dec 1983 with british citizen mother" do
          should "give the australian result" do
            add_response 'born-in-uk-post-1982-mother-uk-citizen'
            assert_state_variable :aus_nz_checklist_variant, 'born-in-uk-post-1982-mother-uk-citizen'
            assert_current_node :aus_nz_result
          end
        end
        context "answer born in UK after 31 Dec 1982 with father in UK service" do
          should "give the australian result" do
            add_response 'born-in-uk-post-1982-father-uk-service'
            assert_state_variable :aus_nz_checklist_variant, 'born-in-uk-post-1982-father-uk-service'
            assert_current_node :aus_nz_result
          end
        end
        context "answer born in UK after 31 Dec 1982 with mother in UK service" do
          should "give the australian result" do
            add_response 'born-in-uk-post-1982-mother-uk-service'
            assert_state_variable :aus_nz_checklist_variant, 'born-in-uk-post-1982-mother-uk-service'
            assert_current_node :aus_nz_result
          end
        end
        context "answer married to british citizen 1983 and registered before 1988" do
          should "give the australian result" do
            add_response 'married-to-uk-citizen-pre-1983-reg-pre-1988'
            assert_state_variable :aus_nz_checklist_variant, 'married-to-uk-citizen-pre-1983-reg-pre-1988'
            assert_current_node :aus_nz_result
          end
        end
        context "answer registered as a british citizen" do
          should "give the australian result" do
            add_response 'registered-uk-citizen'
            assert_state_variable :aus_nz_checklist_variant, 'registered-uk-citizen'
            assert_current_node :aus_nz_result
          end
        end
        context "answer child born outside UK after 1 July 2006 with UK father" do
          should "give the australian result" do
            add_response 'child-born-outside-uk-father-citizen'
            assert_state_variable :aus_nz_checklist_variant, 'child-born-outside-uk-father-citizen'
            assert_current_node :aus_nz_result
          end
        end
        context "answer woman married to a UK citizen before 1949" do
          should "give the australian result" do
            add_response 'woman-married-to-uk-citizen-pre-1949'
            assert_state_variable :aus_nz_checklist_variant, 'woman-married-to-uk-citizen-pre-1949'
            assert_current_node :aus_nz_result
          end
        end
      end # Adult
      context "answer child" do
        setup do
          add_response "child"
        end
        should "ask which best describes you" do
          assert_current_node :which_best_describes_you?
        end
      end # Child
    end # Applying
    context "answer renewing adult passport" do
      setup do
        add_response 'renewing_new'
        add_response 'adult'
      end
      should "ask which best describes you" do
        assert_current_node :which_best_describes_you?
      end
      context "answer born in the UK before 1 Dec 1983" do
        should "should give the australian results and be done" do
          add_response 'born-in-uk-pre-1983'
          assert_current_node :aus_nz_result
        end
      end
    end # Renewing
  end # Australia

  # Afghanistan (An example of bespoke application process). 
  context "answer Afghanistan" do
    setup do
      add_response 'afghanistan'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
      assert_state_variable :current_location, 'afghanistan'
      assert_state_variable :application_type, 'afghanistan'
    end
    context "answer applying" do
      setup do
        add_response 'applying'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
      end
      context "answer adult" do
        should "give the result and be done" do
          add_response 'adult'
          assert_phrase_list :fco_forms, [:adult_fco_forms]
          assert_phrase_list :how_long_it_takes, [:how_long_afghanistan]
          assert_phrase_list :cost, [:cost_afghanistan]
          assert_phrase_list :how_to_apply, [:how_to_apply_afghanistan]
          assert_phrase_list :making_application, [:making_application_afghanistan]
          assert_phrase_list :getting_your_passport, [:getting_your_passport_afghanistan]
          assert_current_node :result
        end
      end
    end
  end # Afghanistan

  context "answer Benin, renewing old passport" do
    setup do
      add_response 'benin'
      add_response 'renewing_old'
      add_response 'adult'
    end
    should "give the result with alternative embassy details" do
      assert_phrase_list :fco_forms, [:adult_fco_forms]
      assert_phrase_list :how_long_it_takes, [:how_long_lagos_nigeria]
      assert_phrase_list :cost, [:cost_lagos_nigeria]
      assert_phrase_list :how_to_apply, [:how_to_apply_lagos_nigeria]
      assert_phrase_list :making_application, [:making_application_lagos_nigeria]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_lagos_nigeria]
      assert_state_variable :embassy_address, "British High Commission\n\nNo. 19, Torrens Close,\nMaitama,\nPMB 4808 (Garki),\nAbuja"
      assert_current_node :result
    end
  end

  # Austria (An example of IPS application 1).
  context "answer Austria" do
    setup do
      add_response 'austria'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
      assert_state_variable :current_location, 'austria'
      assert_state_variable :application_type, 'ips_application_1'
      assert_state_variable :ips_number, "1"
    end
    context "answer applying" do
      setup do
        add_response 'applying'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
      end
      context "answer adult" do
        setup do
          add_response 'adult'
        end
        should "give the result and be done" do
          assert_phrase_list :fco_forms, [:adult_fco_forms]
          assert_current_node :country_of_birth?
        end
        context "answer Greece" do
          should "use the greek document group in the results" do
            add_response 'greece'
            assert_state_variable :supporting_documents, 'ips_documents_group_2'
          end
        end
      end
    end # Applying
    context "answer renewing old blue or black passport" do
      setup do
        add_response 'renewing_old'
        add_response 'adult'
      end
      should "ask which country you were born in" do
        assert_current_node :country_of_birth?
      end
    end # Renewing old style passport
    context "answer replacing" do
      setup do
        add_response 'replacing'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
      end
      context "answer adult" do
        should "give the result and be done" do
          add_response 'adult'
          assert_state_variable :supporting_documents, 'ips_documents_group_1'
          assert_current_node :ips_application_result
          assert_phrase_list :fco_forms, [:adult_fco_forms]
          assert_phrase_list :how_long_it_takes, [:how_long_replacing_ips1, :how_long_it_takes_ips1]
          assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :ips_documents_group_1]
          assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
          assert_phrase_list :send_your_application, [:send_application_ips1]
          assert_phrase_list :tracking_and_receiving, [:tracking_and_receiving_ips1]
          assert_state_variable :embassy_address, nil
        end
      end
    end # Replacing
  end # Austria - IPS_application_1

  # Albania (an example of IPS application 2).
  context "answer Albania" do
    setup do
      add_response 'albania'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
      assert_state_variable :current_location, 'albania'
      assert_state_variable :application_type, 'ips_application_2'
      assert_state_variable :ips_number, "2"
    end
    context "answer applying" do
      setup do
        add_response 'applying'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
      end
      context "answer adult" do
        setup do
          add_response 'adult'
        end
        should "ask which country you were born in" do
          assert_current_node :country_of_birth?
        end
        context "answer Spain" do
          should "give the application result" do
            add_response "spain"
            assert_current_node :ips_application_result
            assert_phrase_list :how_long_it_takes, [:how_long_applying_ips2, :how_long_it_takes_ips2]
            assert_phrase_list :how_to_apply, [:how_to_apply_ips2, :ips_documents_group_1]
            assert_phrase_list :cost, [:passport_courier_costs_ips2, :adult_passport_costs_ips2, :passport_costs_ips2]
            assert_phrase_list :send_your_application, [:send_application_ips2]
            assert_phrase_list :tracking_and_receiving, [:tracking_and_receiving_ips2]
            assert_state_variable :embassy_address, "British Embassy\nRruga Skenderbeg 12\nTirana"
          end
        end
      end
    end # Applying
  end # Albania - IPS_application_2

  # Ajerbaijan (an example of IPS application 3).
  context "answer Azerbaijan" do
    setup do
      add_response 'azerbaijan'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
      assert_state_variable :current_location, 'azerbaijan'
      assert_state_variable :application_type, 'ips_application_3'
      assert_state_variable :ips_number, "3"
    end
    context "answer replacing adult passport" do
      setup do
        add_response 'replacing'
        add_response 'adult'
      end
      should "give the IPS application result" do
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_replacing_ips3, :how_long_it_takes_ips3]
        assert_phrase_list :how_to_apply, [:how_to_apply_ips3, :ips_documents_group_3]
        assert_phrase_list :cost, [:passport_courier_costs_ips3, :adult_passport_costs_ips3, :passport_costs_ips3]
        assert_phrase_list :send_your_application, [:send_application_ips3]
        assert_phrase_list :tracking_and_receiving, [:tracking_and_receiving_ips3]
        assert_state_variable :embassy_address, "British Embassy\n45 Khagani Street\nAZ1010"
      end
    end # Applying
    context "renewing old" do
      # TODO 
    end
  end # Azerbaijan - IPS_application_3

  # Andorra (an example of FCO application via Madrid)
  context "answer Andorra" do
    setup do
      add_response 'andorra'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
      assert_state_variable :current_location, 'andorra'
    end
    context "answer applying" do
      setup do
        add_response 'applying'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
      end
      context "answer child" do
        should "give the FCO result and be done" do
          add_response 'child'
          assert_current_node :fco_result
          assert_phrase_list :fco_forms, [:child_fco_forms]
          assert_phrase_list :how_long_it_takes, [:how_long_applying_fco]
          assert_phrase_list :fco_forms, [:child_fco_forms]
          assert_phrase_list :cost, [:passport_courier_costs_madrid_spain, :child_passport_costs_madrid_spain, :passport_costs_madrid_spain]
          assert_phrase_list :send_your_application, [:send_application_madrid_spain]
          assert_phrase_list :helpline, [:helpline_madrid_spain]
          assert_state_variable :embassy_address, "Edificio Torre de Barcelona\nAvienda Diagonal 477-13\n08036 Barcelona,"
        end
      end
    end
    context "answer renewing old type" do
      setup do
        add_response 'renewing_old'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
      end
      context "answer adult" do
        should "give the FCO result and be done" do
          add_response 'adult'
          assert_current_node :fco_result
          assert_phrase_list :how_long_it_takes, [:how_long_renewing_old_fco]
          assert_phrase_list :fco_forms, [:adult_fco_forms]
          assert_phrase_list :cost, [:passport_courier_costs_madrid_spain, :adult_passport_costs_madrid_spain, :passport_costs_madrid_spain]
          assert_phrase_list :send_your_application, [:send_application_madrid_spain]
          assert_phrase_list :helpline, [:helpline_madrid_spain]
          assert_state_variable :embassy_address, "Edificio Torre de Barcelona\nAvienda Diagonal 477-13\n08036 Barcelona,"
        end
      end
    end # Andorra (FCO result cases)
  end
end
