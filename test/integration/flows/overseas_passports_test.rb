# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class OverseasPassportsTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'overseas-passports'
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
          assert_current_node :which_best_describes_you_adult?
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
          assert_current_node :which_best_describes_you_child?
        end
        should "proceed to the aus nz result" do
          add_response 'registered-uk-citizen'
          assert_current_node :aus_nz_result
        end
      end # Child
    end # Applying
    context "answer renewing adult passport" do
      setup do
        add_response 'renewing_new'
        add_response 'adult'
      end
      should "ask which best describes you" do
        assert_current_node :which_best_describes_you_adult?
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
          assert_match /15th Street, Roundabout Wazir Akbar Khan/, current_state.embassy_address
          assert_match /0830-1630 \(Sunday to Thursday\)/, current_state.embassy_address
          assert_current_node :result
        end
      end
    end
  end # Afghanistan

  # Iraq (An example of bespoke application process with non-standard embassies). 
  context "answer Iraq" do
    setup do
      add_response 'iraq'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
      assert_state_variable :current_location, 'iraq'
      assert_state_variable :application_type, 'iraq'
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
          assert_phrase_list :how_long_it_takes, [:how_long_iraq]
          assert_phrase_list :cost, [:cost_iraq]
          assert_phrase_list :how_to_apply, [:how_to_apply_iraq]
          assert_phrase_list :making_application, [:making_application_iraq]
          assert_phrase_list :getting_your_passport, [:getting_your_passport_iraq]
          assert_match /British Embassy, Baghdad/, current_state.embassy_address
          assert_match /Passport opening times: Sun - Wed: 08.30-1200/, current_state.embassy_details
          assert_current_node :result
        end
      end
    end
  end # Iraq 

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
      assert_match /11 Walter Carrington Crescent/, current_state.embassy_address
      assert_match /GMT: Mon-Thurs: 0630-1430 and Fri 0630-1130/, current_state.embassy_details
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
        should "ask which country you were born in" do
          assert_current_node :country_of_birth?
        end
        context "answer Spain" do
          should "give the application result" do
            add_response "spain"
            assert_current_node :ips_application_result
            assert_phrase_list :how_long_it_takes, [:how_long_applying_ips1, :how_long_it_takes_ips1]
            assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :ips_documents_group_1]
            assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
            assert_phrase_list :send_your_application, [:send_application_ips1]
            assert_phrase_list :tracking_and_receiving, [:tracking_and_receiving_ips1]
            assert_state_variable :embassy_address, nil
            assert_state_variable :supporting_documents, 'ips_documents_group_1'
          end
        end
        context "answer UK" do
          should "give the application result with the UK documents" do
            add_response "united-kingdom"
            assert_current_node :ips_application_result
            assert_phrase_list :how_long_it_takes, [:how_long_applying_ips1, :how_long_it_takes_ips1]
            assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :ips_documents_group_3]
            assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
            assert_phrase_list :send_your_application, [:send_application_ips1]
            assert_phrase_list :tracking_and_receiving, [:tracking_and_receiving_ips1]
            assert_state_variable :embassy_address, nil 
            assert_state_variable :supporting_documents, 'ips_documents_group_3'
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
        assert_match "45 Khagani Street", current_state.send(:embassy_address)
        assert_match "Mon-Fri: 09:00 - 17:00 Local Time", current_state.embassy_address
        assert_match "+ 994 (12) 4377878", current_state.embassy_details
        assert_match "generalenquiries.baku@fco.gov.uk", current_state.embassy_details
      end
    end # Applying
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
          assert_state_variable :how_to_apply_supplement, ''
          assert_phrase_list :fco_forms, [:child_fco_forms]
          assert_phrase_list :cost, [:passport_courier_costs_fco_europe, :child_passport_costs_fco_europe, :passport_costs_madrid_spain]
          assert_phrase_list :send_your_application, [:send_application_fco_preamble, :send_application_madrid_spain]
          assert_phrase_list :helpline, [:helpline_madrid_spain]
          assert_match "Edificio Torre de Barcelona", current_state.embassy_address
          assert_match "(34) 93 366 6200", current_state.embassy_details
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
          assert_state_variable :how_to_apply_supplement, ''
          assert_phrase_list :fco_forms, [:adult_fco_forms]
          assert_phrase_list :cost, [:passport_courier_costs_fco_europe, :adult_passport_costs_fco_europe, :passport_costs_madrid_spain]
          assert_phrase_list :send_your_application, [:send_application_fco_preamble, :send_application_madrid_spain]
          assert_phrase_list :getting_your_passport, [:getting_your_passport_fco]
          assert_phrase_list :helpline, [:helpline_madrid_spain]
          assert_match "08036 Barcelona,", current_state.embassy_address
          assert_match "Avienda Diagonal 477-13", current_state.embassy_details
        end
      end
    end # Andorra (FCO result cases)
  end
  context "answer Ireland, replacement, adult passport" do
    should "give the fco result with custom phrases" do
      add_response 'ireland'
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :fco_result
      assert_phrase_list :how_to_apply_supplement, [:how_to_apply_dublin_ireland]
    end
  end # Ireland (FCO with custom phrases)
  context "answer India, replacement, adult passport" do
    should "give the fco result with custom phrases" do
      add_response 'india'
      add_response 'applying'
      add_response 'adult'
      assert_current_node :fco_result
      assert_phrase_list :how_long_it_takes, [:how_long_applying_india]
      assert_phrase_list :how_to_apply_supplement, [:how_to_apply_india]
    end
  end # India (FCO with custom phrases)
  context "answer Indonesia, replacement, adult passport" do
    should "give the fco result with custom phrases" do
      add_response 'indonesia'
      add_response 'applying'
      add_response 'adult'
      assert_current_node :fco_result
      assert_phrase_list :cost, [:passport_courier_costs_indonesia, :adult_passport_costs_indonesia, :passport_costs_hong_kong]
      assert_phrase_list :how_to_apply_supplement, [:how_to_apply_retain_passport]
    end
  end # Indonesia (FCO with custom phrases)
  context "answer Jamaica, replacement, adult passport" do
    should "give the fco result with custom phrases" do
      add_response 'jamaica'
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :fco_result
      assert_phrase_list :cost, [:passport_courier_costs_jamaica, :adult_passport_costs_jamaica, :passport_costs_washington_usa]
    end
  end # Jamaica (Custom courier costs affecting all costs) 
  context "answer Malta, replacement, adult passport" do
    should "give the fco result with custom phrases" do
      add_response 'malta'
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :fco_result
      assert_phrase_list :cost, [:passport_courier_costs_fco_europe, :adult_passport_costs_fco_europe, :passport_costs_malta_netherlands]
    end
  end # Malta (FCO with custom phrases)
  context "answer Egypt, replacement, adult passport" do
    should "give the fco result with custom phrases" do
      add_response 'egypt'
      add_response 'replacing'
      add_response 'adult'
      assert_phrase_list :getting_your_passport, [:getting_your_passport_egypt]
      assert_current_node :fco_result
    end
  end # Egypt (FCO with custom phrases)
  context "answer Iran" do
    should "give a bespoke outcome stating an application is not possible in Iran" do
      add_response 'iran'
      assert_current_node :cannot_apply
      assert_phrase_list :body_text, [:body_iran]
    end
  end # Iran - no application outcome
  context "answer Syria" do
    should "give a bespoke outcome stating an application is not possible in Syria" do
      add_response 'syria'
      assert_current_node :cannot_apply
      assert_phrase_list :body_text, [:body_syria]
    end
  end
  context "answer Cameroon, renewing, adult passport" do
    should "give the generic result with custom phrases" do
      add_response 'cameroon'
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :result
      assert_phrase_list :cost, [:cost_cameroon_renewing]
      assert_phrase_list :making_application, [:making_application_cameroon_renewing]
    end
  end # Cameroon (custom phrases)
  context "answer Kenya, applying, adult passport" do
    should "give the generic result with custom phrases" do
      add_response 'kenya'
      add_response 'applying'
      add_response 'adult'
      assert_current_node :result
      assert_phrase_list :how_long_it_takes, [:how_long_nairobi_kenya_applying]
      assert_phrase_list :cost, [:cost_nairobi_kenya_applying]
      assert_phrase_list :supporting_documents, [:supporting_documents_nairobi_kenya_applying]
      assert_phrase_list :making_application, [:making_application_nairobi_kenya]
    end
  end # Kenya (custom phrases)
end
