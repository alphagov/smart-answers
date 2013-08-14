# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'
require 'gds_api/test_helpers/worldwide'


class OverseasPassportsV2Test < ActiveSupport::TestCase
  include FlowTestHelper
  include GdsApi::TestHelpers::Worldwide

  setup do
    @location_slugs = %w(australia afghanistan iraq benin austria albania morocco azerbaijan ireland india tanzania indonesia jamaica malta italy jordan iran syria cameroon kenya andorra tunisia yemen haiti south-africa united-kingdom greece spain the-occupied-palestinian-territories st-helena-ascension-and-tristan-da-cunha kazakhstan kyrgyzstan egypt nigeria russia congo djibouti)
    worldwide_api_has_locations(@location_slugs)
    setup_for_testing_flow 'overseas-passports-v2'
  end

  ## Q1
  should "ask which country you are in" do
    assert_current_node :which_country_are_you_in?
  end
  context "answer Australia" do
    setup do
      worldwide_api_has_organisations_for_location('australia', read_fixture_file('worldwide/australia_organisations.json'))
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
            assert_phrase_list :instructions, [:instructions_australia_post]
            assert_phrase_list :helpline, [:helpline_fco_webchat]
            expected_location = WorldLocation.find('australia')
            assert_state_variable :location, expected_location
            assert_state_variable :organisation, expected_location.fco_organisation
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
      worldwide_api_has_organisations_for_location('afghanistan', read_fixture_file('worldwide/afghanistan_organisations.json'))
      add_response 'afghanistan'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
      assert_state_variable :current_location, 'afghanistan'
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
          assert_state_variable :application_type, 'afghanistan'
          assert_phrase_list :fco_forms, [:adult_fco_forms]
          assert_phrase_list :how_long_it_takes, [:how_long_afghanistan]
          assert_phrase_list :cost, [:cost_afghanistan]
          assert_phrase_list :how_to_apply, [:how_to_apply_afghanistan]
          assert_phrase_list :making_application, [:making_application_afghanistan]
          assert_phrase_list :getting_your_passport, [:getting_your_passport_afghanistan]
          assert_phrase_list :helpline, [:helpline_intro, :helpline_afghanistan, :helpline_fco_webchat]
          assert_current_node :result
          expected_location = WorldLocation.find('afghanistan')
          assert_state_variable :location, expected_location
          assert_state_variable :organisation, expected_location.fco_organisation
          assert_match /15th Street, Roundabout Wazir Akbar Khan/, outcome_body
        end
      end
    end
  end # Afghanistan

  # Iraq (An example of ips 1 application with some conditional phrases). 
  context "answer Iraq" do
    setup do
      worldwide_api_has_organisations_for_location('iraq', read_fixture_file('worldwide/iraq_organisations.json'))
      add_response 'iraq'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
      assert_state_variable :current_location, 'iraq'
    end
    context "answer applying" do
      setup do
        add_response 'applying'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
        assert_state_variable :application_type, 'ips_application_1'
      end
      context "answer adult" do
        setup do
          add_response 'adult'
        end
        should "ask the country of birth" do
          assert_current_node :country_of_birth?
        end
        context "answer UK" do
          setup do
            add_response 'united-kingdom'
          end
          should "give the result and be done" do
            assert_current_node :ips_application_result
            assert_phrase_list :fco_forms, [:adult_fco_forms]
            assert_phrase_list :how_long_it_takes, [:how_long_applying_ips1, :how_long_it_takes_ips1]
            assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
            assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :hmpo_1_application_form, :ips_documents_group_3]
            assert_phrase_list :send_your_application, [:send_application_ips1_durham]
            assert_phrase_list :getting_your_passport, [:getting_your_passport_iraq]
            assert_phrase_list :tracking_and_receiving, [:tracking_and_receiving_ips1]
            expected_location = WorldLocation.find('iraq')
            assert_state_variable :location, expected_location
            assert_state_variable :organisation, expected_location.fco_organisation
            assert_match /Millburngate House/, outcome_body
          end
        end
      end
    end
  end # Iraq 

  context "answer Benin, renewing old passport" do
    setup do
      worldwide_api_has_organisations_for_location('nigeria', read_fixture_file('worldwide/nigeria_organisations.json'))
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
      assert_phrase_list :helpline, [:helpline_intro, :helpline_pretoria_south_africa, :helpline_fco_webchat]
      assert_current_node :result
      expected_location = WorldLocation.find('nigeria')
      assert_state_variable :location, expected_location
      assert_state_variable :organisation, expected_location.fco_organisation
      assert_match /British Deputy High Commission Lagos/, outcome_body
    end
  end

  # Austria (An example of IPS application 1).
  context "answer Austria" do
    setup do
      worldwide_api_has_organisations_for_location('austria', read_fixture_file('worldwide/austria_organisations.json'))
      add_response 'austria'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
      assert_state_variable :current_location, 'austria'
    end
    context "answer applying" do
      setup do
        add_response 'applying'
      end
      should "ask if the passport is for an adult or a child" do
        assert_state_variable :application_type, 'ips_application_1'
        assert_state_variable :ips_number, "1"
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
          setup do
            add_response 'greece'
          end

          should "use the greek document group in the results" do
            assert_state_variable :supporting_documents, 'ips_documents_group_2'
          end

          should "give the result" do
            assert_current_node :ips_application_result
            assert_phrase_list :fco_forms, [:adult_fco_forms]
            assert_phrase_list :how_long_it_takes, [:how_long_applying_ips1, :how_long_it_takes_ips1]
            assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :hmpo_1_application_form, :ips_documents_group_2]
            assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
            assert_phrase_list :send_your_application, [:send_application_ips1, :send_application_embassy_address]
            assert_phrase_list :getting_your_passport, [:getting_your_passport_ips1]
            assert_phrase_list :tracking_and_receiving, [:tracking_and_receiving_ips1]
            expected_location = WorldLocation.find('austria')
            assert_state_variable :location, expected_location
            assert_state_variable :organisation, expected_location.fco_organisation
            assert_match /101 Old Hall Street/, outcome_body
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
          assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :hmpo_1_application_form, :ips_documents_group_1]
          assert_phrase_list :cost, [:passport_courier_costs_replacing_ips1, :adult_passport_costs_replacing_ips1, :passport_costs_ips1]
          assert_phrase_list :send_your_application, [:send_application_ips1, :send_application_embassy_address]
          assert_phrase_list :tracking_and_receiving, [:tracking_and_receiving_ips1]
          assert_state_variable :embassy_address, nil
          assert_match /101 Old Hall Street/, outcome_body
        end
      end
    end # Replacing
  end # Austria - IPS_application_1

  # Albania (an example of IPS application 2).
  context "answer Albania" do
    setup do
      worldwide_api_has_organisations_for_location('albania', read_fixture_file('worldwide/albania_organisations.json'))
      add_response 'albania'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
      assert_state_variable :current_location, 'albania'
    end
    context "answer applying" do
      setup do
        add_response 'applying'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
        assert_state_variable :application_type, 'ips_application_1'
        assert_state_variable :ips_number, "1"
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
            assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :hmpo_1_application_form, :ips_documents_group_1]
            assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
            assert_phrase_list :send_your_application, [:send_application_ips1, :send_application_embassy_address]
            assert_phrase_list :getting_your_passport, [:getting_your_passport_ips1]
            assert_phrase_list :tracking_and_receiving, [:tracking_and_receiving_ips1]
            assert_state_variable :embassy_address, nil
            assert_state_variable :supporting_documents, 'ips_documents_group_1'
            expected_location = WorldLocation.find('albania')
            assert_state_variable :location, expected_location
            assert_state_variable :organisation, expected_location.fco_organisation
            assert_match /101 Old Hall Street/, outcome_body
          end
        end
        context "answer UK" do
          should "give the application result with the UK documents" do
            add_response "united-kingdom"
            assert_current_node :ips_application_result
            assert_phrase_list :how_long_it_takes, [:how_long_applying_ips1, :how_long_it_takes_ips1]
            assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :hmpo_1_application_form, :ips_documents_group_3]
            assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
            assert_phrase_list :send_your_application, [:send_application_ips1, :send_application_embassy_address]
            assert_phrase_list :tracking_and_receiving, [:tracking_and_receiving_ips1]
            assert_state_variable :embassy_address, nil 
            assert_state_variable :supporting_documents, 'ips_documents_group_3'
            expected_location = WorldLocation.find('albania')
            assert_state_variable :location, expected_location
            assert_state_variable :organisation, expected_location.fco_organisation
            assert_match /101 Old Hall Street/, outcome_body
          end
        end
      end
    end # Applying
  end # Albania - IPS_application_2

  # Morocco (an example of IPS application 2 with custom phrases).
  context "answer Morocco" do
    setup do
      worldwide_api_has_organisations_for_location('morocco', read_fixture_file('worldwide/morocco_organisations.json'))
      add_response 'morocco'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
      assert_state_variable :current_location, 'morocco'
    end
    context "answer replacing" do
      setup do
        add_response 'replacing'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
        assert_state_variable :application_type, 'ips_application_2'
        assert_state_variable :ips_number, "2"
      end
      should "return morocco specific phrases given an adult" do
        add_response 'adult'
        assert_state_variable :supporting_documents, 'ips_documents_group_3'
        assert_current_node :ips_application_result
        assert_phrase_list :fco_forms, [:adult_fco_forms]
        assert_phrase_list :how_long_it_takes, [:how_long_replacing_ips2_morocco, :how_long_it_takes_ips2]
        assert_phrase_list :how_to_apply, [:how_to_apply_ips2, :hmpo_1_application_form, :ips_documents_group_3]
        assert_phrase_list :cost, [:passport_courier_costs_ips2, :adult_passport_costs_ips2, :passport_costs_ips_cash]
        assert_phrase_list :send_your_application, [:send_application_ips2, :send_application_embassy_address]
        assert_phrase_list :getting_your_passport, [:getting_your_passport_ips2]
        assert_phrase_list :tracking_and_receiving, [:tracking_and_receiving_ips2]
        expected_location = WorldLocation.find('morocco')
        assert_state_variable :location, expected_location
        assert_state_variable :organisation, expected_location.fco_organisation
        assert_match /28 Avenue S.A.R. Sidi Mohammed/, outcome_body
      end
    end # Applying
  end # Morocco - IPS_application_2

  # Ajerbaijan (an example of IPS application 3).
  context "answer Azerbaijan" do
    setup do
      worldwide_api_has_organisations_for_location('azerbaijan', read_fixture_file('worldwide/azerbaijan_organisations.json'))
      add_response 'azerbaijan'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
      assert_state_variable :current_location, 'azerbaijan'
    end
    context "answer replacing adult passport" do
      setup do
        add_response 'replacing'
        add_response 'adult'
        assert_state_variable :application_type, 'ips_application_3'
        assert_state_variable :ips_number, "3"
      end
      should "give the IPS application result" do
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_replacing_ips3, :how_long_it_takes_ips3]
        assert_phrase_list :how_to_apply, [:how_to_apply_ips3, :hmpo_1_application_form, :ips_documents_group_3]
        assert_phrase_list :cost, [:passport_courier_costs_ips3, :adult_passport_costs_ips3, :passport_costs_ips3]
        assert_phrase_list :send_your_application, [:send_application_ips3, :send_application_embassy_address]
        assert_phrase_list :getting_your_passport, [:getting_your_passport_ips3]
        assert_phrase_list :tracking_and_receiving, [:tracking_and_receiving_ips3]
        expected_location = WorldLocation.find('azerbaijan')
        assert_state_variable :location, expected_location
        assert_state_variable :organisation, expected_location.fco_organisation
        assert_match /45 Khagani Street/, outcome_body
      end
    end # Applying
  end # Azerbaijan - IPS_application_3

  context "answer Ireland, replacement, adult passport" do
    should "give the fco result with custom phrases" do
      worldwide_api_has_organisations_for_location('ireland', read_fixture_file('worldwide/ireland_organisations.json'))
      add_response 'ireland'
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :fco_result
      assert_phrase_list :how_to_apply_supplement, [:how_to_apply_dublin_ireland]
      assert_phrase_list :helpline, [:helpline_dublin_ireland, :helpline_fco_webchat]
      assert_match /^[\d,]+ Euros \| [\d,]+ Euros$/, current_state.costs_euros_adult_32
      expected_location = WorldLocation.find('ireland')
      assert_state_variable :location, expected_location
      assert_state_variable :organisation, expected_location.fco_organisation
      assert_match /29 Merrion Road/, outcome_body
    end
  end # Ireland (FCO with custom phrases)

  context "answer India" do
    context "applying, adult passport" do
      should "give the fco result with custom phrases" do
        worldwide_api_has_organisations_for_location('india', read_fixture_file('worldwide/india_organisations.json'))
        add_response 'india'
        add_response 'applying'
        add_response 'adult'
        assert_current_node :fco_result
        assert_phrase_list :how_long_it_takes, [:how_long_applying_india]
        assert_phrase_list :cost, [:passport_courier_costs_applying_india, :adult_passport_costs_applying_india, :passport_costs_india]
        assert_phrase_list :supporting_documents, [:supporting_documents_india_applying_renewing]
        assert_match /^[\d,]+ Indian Rupees \| [\d,]+ Indian Rupees$/, current_state.costs_indian_rupees_adult_32
        expected_location = WorldLocation.find('india')
        assert_state_variable :location, expected_location
        assert_state_variable :organisation, expected_location.fco_organisation
        assert_match /New Delhi, 110021/, outcome_body
      end
    end
    context "replacing, adult passport" do
      should "give the fco result with custom phrases" do
        worldwide_api_has_organisations_for_location('india', read_fixture_file('worldwide/india_organisations.json'))
        add_response 'india'
        add_response 'replacing'
        add_response 'adult'
        assert_current_node :fco_result
        assert_phrase_list :how_long_it_takes, [:how_long_replacing_fco]
        assert_phrase_list :cost, [:passport_courier_costs_applying_india, :adult_passport_costs_applying_india, :passport_costs_india]
        assert_state_variable :supporting_documents, ''
      end
    end
  end # India (FCO with custom phrases)

  context "answer Tanzania, replacement, adult passport" do
    should "give the fco result with custom phrases" do
      worldwide_api_has_organisations_for_location('tanzania', read_fixture_file('worldwide/tanzania_organisations.json'))
      add_response 'tanzania'
      add_response 'applying'
      add_response 'adult'
      assert_current_node :fco_result
      assert_phrase_list :how_long_it_takes, [:how_long_applying_tanzania]
      expected_location = WorldLocation.find('tanzania')
      assert_state_variable :location, expected_location
      assert_state_variable :organisation, expected_location.fco_organisation
      assert_match /South Africa/, outcome_body
    end
  end # Tanzania (FCO with custom phrases)

  context "answer Congo, replacement, adult passport" do
    should "give the fco result with custom phrases" do
      worldwide_api_has_organisations_for_location('congo', read_fixture_file('worldwide/congo_organisations.json'))
      add_response 'congo'
      add_response 'applying'
      add_response 'adult'
      assert_current_node :fco_result
      assert_phrase_list :how_long_it_takes, [:how_long_applying_fco]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_congo]
      expected_location = WorldLocation.find('congo')
      assert_state_variable :location, expected_location
      assert_state_variable :organisation, expected_location.fco_organisation
      assert_match /South Africa/, outcome_body
    end
  end # Tanzania (FCO with custom phrases)

  context "answer Indonesia, replacement, adult passport" do
    should "give the fco result with custom phrases" do
      worldwide_api_has_organisations_for_location('indonesia', read_fixture_file('worldwide/indonesia_organisations.json'))
      add_response 'indonesia'
      add_response 'applying'
      add_response 'adult'
      assert_current_node :fco_result
      assert_phrase_list :cost, [:passport_courier_costs_indonesia, :adult_passport_costs_indonesia, :passport_costs_indonesia]
      expected_location = WorldLocation.find('indonesia')
      assert_state_variable :location, expected_location
      assert_state_variable :organisation, expected_location.fco_organisation
      assert_match /British Embassy Jakarta/, outcome_body
    end
  end # Indonesia (FCO with custom phrases)

  context "answer Malta, replacement, adult passport" do
    should "give the fco result with custom phrases" do
      worldwide_api_has_organisations_for_location('malta', read_fixture_file('worldwide/malta_organisations.json'))
      add_response 'malta'
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_phrase_list :cost, [:passport_courier_costs_replacing_ips1, :adult_passport_costs_replacing_ips1, :passport_costs_ips1]
      expected_location = WorldLocation.find('malta')
      assert_state_variable :location, expected_location
      assert_state_variable :organisation, expected_location.fco_organisation
      assert_match /Millburngate House/, outcome_body
    end
  end # Malta (IPS1 with custom phrases)

  context "answer Italy, replacement, adult passport" do
    should "give the fco result with custom phrases" do
      worldwide_api_has_organisations_for_location('italy', read_fixture_file('worldwide/italy_organisations.json'))
      add_response 'italy'
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_phrase_list :cost, [:passport_courier_costs_replacing_ips1, :adult_passport_costs_replacing_ips1, :passport_costs_ips1]
      expected_location = WorldLocation.find('italy')
      assert_state_variable :location, expected_location
      assert_state_variable :organisation, expected_location.fco_organisation
      assert_match /Millburngate House/, outcome_body
    end
  end # Italy (IPS1 with custom phrases)

  context "answer Jordan, replacement, adult passport" do
    should "give the ips1 result with custom phrases" do
      worldwide_api_has_organisations_for_location('jordan', read_fixture_file('worldwide/jordan_organisations.json'))
      add_response 'jordan'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_phrase_list :getting_your_passport, [:getting_your_passport_jordan]
      assert_current_node :ips_application_result
      assert_match /^[\d,]+ Jordanian Dinars \| [\d,]+ Jordanian Dinars$/, current_state.costs_jordanian_dinars_adult_32
      expected_location = WorldLocation.find('jordan')
      assert_state_variable :location, expected_location
      assert_state_variable :organisation, expected_location.fco_organisation
      assert_match /Millburngate House/, outcome_body
    end
  end # Jordan (IPS1 with custom phrases)

  context "answer Iran" do
    should "give a bespoke outcome stating an application is not possible in Iran" do
      worldwide_api_has_organisations_for_location('iran', read_fixture_file('worldwide/iran_organisations.json'))
      add_response 'iran'
      assert_current_node :cannot_apply
      assert_phrase_list :body_text, [:body_iran]
      expected_location = WorldLocation.find('iran')
      assert_state_variable :location, expected_location
    end
  end # Iran - no application outcome
  
  context "answer Syria" do
    should "give a bespoke outcome stating an application is not possible in Syria" do
      worldwide_api_has_organisations_for_location('syria', read_fixture_file('worldwide/syria_organisations.json'))
      add_response 'syria'
      assert_current_node :cannot_apply
      assert_phrase_list :body_text, [:body_syria]
      expected_location = WorldLocation.find('syria')
      assert_state_variable :location, expected_location
    end
  end # Syria - no application outcome

  context "answer Cameroon, renewing, adult passport" do
    should "give the generic result with custom phrases" do
      worldwide_api_has_organisations_for_location('cameroon', read_fixture_file('worldwide/cameroon_organisations.json'))
      add_response 'cameroon'
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :result
      assert_phrase_list :cost, [:cost_cameroon_renewing]
      assert_phrase_list :making_application, [:making_application_cameroon_renewing]
      expected_location = WorldLocation.find('cameroon')
      assert_state_variable :location, expected_location
      assert_state_variable :organisation, expected_location.fco_organisation
      assert_match /Avenue Winston Churchill/, outcome_body
    end
  end # Cameroon (custom phrases)

  context "answer Kenya, applying, adult passport" do
    should "give the generic result with custom phrases" do
      worldwide_api_has_organisations_for_location('kenya', read_fixture_file('worldwide/kenya_organisations.json'))
      add_response 'kenya'
      add_response 'applying'
      add_response 'adult'
      assert_current_node :result
      assert_phrase_list :how_long_it_takes, [:how_long_nairobi_kenya_applying]
      assert_phrase_list :cost, [:cost_nairobi_kenya_applying]
      assert_phrase_list :supporting_documents, [:supporting_documents_nairobi_kenya_applying]
      assert_phrase_list :making_application, [:making_application_nairobi_kenya]
      assert_phrase_list :helpline, [:helpline_intro, :helpline_pretoria_south_africa, :helpline_fco_webchat]
      expected_location = WorldLocation.find('kenya')
      assert_state_variable :location, expected_location
      assert_state_variable :organisation, expected_location.fco_organisation
      assert_match /Upper Hill Road/, outcome_body
    end
  end # Kenya (custom phrases)

  context "answer Egypt, renewing, adult passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('egypt', read_fixture_file('worldwide/egypt_organisations.json'))
      add_response 'egypt'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_applying_ips1, :how_long_it_takes_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :hmpo_1_application_form, :ips_documents_group_3]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :send_your_application, [:send_application_ips1_durham]
      assert_phrase_list :tracking_and_receiving, [:tracking_and_receiving_ips1]
      assert_state_variable :embassy_address, nil
      assert_state_variable :supporting_documents, 'ips_documents_group_3'
      expected_location = WorldLocation.find('egypt')
      assert_state_variable :location, expected_location
      assert_state_variable :organisation, expected_location.fco_organisation
      assert_match /Millburngate House/, outcome_body
    end
  end # Egypt

  context "answer Andorra, renewing, adult passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('andorra', read_fixture_file('worldwide/andorra_organisations.json'))
      add_response 'andorra'
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_renewing_new_ips1, :how_long_it_takes_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :hmpo_1_application_form, :ips_documents_group_1]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :send_your_application, [:send_application_ips1_belfast]
      assert_phrase_list :tracking_and_receiving, [:tracking_and_receiving_ips1]
      assert_state_variable :embassy_address, nil
      assert_state_variable :supporting_documents, 'ips_documents_group_1'
      expected_location = WorldLocation.find('andorra')
      assert_state_variable :location, expected_location
      assert_state_variable :organisation, expected_location.fco_organisation
      assert_match /90-106 Victoria Street/, outcome_body
    end
  end # Andorra

  context "answer Tunisia, applying, adult passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('tunisia', read_fixture_file('worldwide/tunisia_organisations.json'))
      add_response 'tunisia'
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_replacing_ips2_morocco, :how_long_it_takes_ips2]
      assert_phrase_list :how_to_apply, [:how_to_apply_ips2, :hmpo_1_application_form, :ips_documents_group_2]
      assert_phrase_list :cost, [:passport_courier_costs_ips2, :adult_passport_costs_ips2, :passport_costs_ips_cash]
      assert_phrase_list :send_your_application, [:send_application_ips2, :send_application_embassy_address]
      assert_phrase_list :tracking_and_receiving, [:tracking_and_receiving_ips2]
      assert_state_variable :supporting_documents, 'ips_documents_group_2'
      expected_location = WorldLocation.find('tunisia')
      assert_state_variable :location, expected_location
      assert_state_variable :organisation, expected_location.fco_organisation
      assert_match /Rue du Lac Windermere/, outcome_body
    end
  end # Tunisia

  context "answer Yemen, applying, adult passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('yemen', read_fixture_file('worldwide/yemen_organisations.json'))
      add_response 'yemen'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_applying_ips1, :how_long_it_takes_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :hmpo_1_application_form, :ips_documents_group_3]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :send_your_application, [:send_application_ips1_durham]
      assert_phrase_list :tracking_and_receiving, [:tracking_and_receiving_ips1]
      expected_location = WorldLocation.find('yemen')
      assert_state_variable :location, expected_location
      assert_state_variable :organisation, expected_location.fco_organisation
      assert_match /Millburngate House/, outcome_body
    end
  end # Yemen

  context "answer Haiti, renewing-new, adult passport" do
    should "give the ips result" do
      worldwide_api_has_organisations_for_location('haiti', read_fixture_file('worldwide/haiti_organisations.json'))
      add_response 'haiti'
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_renewing_new_ips1, :how_long_it_takes_ips1]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :send_your_application, [:send_application_ips1_durham]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_ips1]
      expected_location = WorldLocation.find('haiti')
      assert_state_variable :location, expected_location
      assert_state_variable :organisation, expected_location.fco_organisation
      assert_match /Millburngate House/, outcome_body
    end
  end # Haiti

  context "answer South Africa" do
    context "applying, adult passport" do
      should "give the fco result with custom phrases" do
        worldwide_api_has_organisations_for_location('south-africa', read_fixture_file('worldwide/south-africa_organisations.json'))
        add_response 'south-africa'
        add_response 'applying'
        add_response 'adult'
        assert_current_node :fco_result
        assert_phrase_list :how_long_it_takes, [:how_long_applying_fco]
        assert_phrase_list :cost, [:passport_courier_costs_pretoria_south_africa, :adult_passport_costs_pretoria_south_africa, :passport_costs_pretoria_south_africa]
        assert_phrase_list :supporting_documents, [:supporting_documents_south_africa_applying]
        expected_location = WorldLocation.find('south-africa')
        assert_state_variable :location, expected_location
        assert_state_variable :organisation, expected_location.fco_organisation
        assert_match /Pretoria 0028/, outcome_body
        assert_match /Pretoria 0083/, outcome_body
      end
    end
    context "renewing, adult passport" do
      should "give the fco result with custom phrases" do
        worldwide_api_has_organisations_for_location('south-africa', read_fixture_file('worldwide/south-africa_organisations.json'))
        add_response 'south-africa'
        add_response 'renewing_old'
        add_response 'adult'
        assert_current_node :fco_result
        assert_phrase_list :how_long_it_takes, [:how_long_renewing_old_fco]
        assert_phrase_list :cost, [:passport_courier_costs_pretoria_south_africa, :adult_passport_costs_pretoria_south_africa, :passport_costs_pretoria_south_africa]
        assert_match /^[\d,]+ South African Rand \| [\d,]+ South African Rand$/, current_state.costs_south_african_rand_adult_32
        assert_state_variable :supporting_documents, ''
      end
    end
  end # South Africa (FCO with custom phrases)

  context "answer Gaza, applying, adult passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('the-occupied-palestinian-territories', read_fixture_file('worldwide/the-occupied-palestinian-territories_organisations.json'))
      add_response 'the-occupied-palestinian-territories'
      add_response 'gaza'
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_replacing_ips3, :how_long_it_takes_ips3]
      assert_phrase_list :how_to_apply, [:how_to_apply_ips3, :hmpo_1_application_form, :ips_documents_group_1]
      assert_phrase_list :cost, [:passport_courier_costs_ips3, :adult_passport_costs_ips3, :passport_costs_ips_cash]
      assert_phrase_list :send_your_application, [:send_application_ips3_gaza]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_ips3]
      assert_phrase_list :tracking_and_receiving, [:tracking_and_receiving_ips3]
      expected_location = WorldLocation.find('the-occupied-palestinian-territories')
      assert_state_variable :location, expected_location
      assert_state_variable :organisation, expected_location.fco_organisation
    end
  end # Tunisia

  context "answer St Helena, renewing old, adult passport" do
    should "give the fco result with custom phrases" do
      worldwide_api_has_no_organisations_for_location('st-helena-ascension-and-tristan-da-cunha')
      add_response 'st-helena-ascension-and-tristan-da-cunha'
      add_response "st-helena"
      add_response 'renewing_old'
      add_response 'adult'
      assert_current_node :fco_result
      assert_phrase_list :how_long_it_takes, [:how_long_renewing_old_fco]
      assert_phrase_list :cost, [:passport_courier_costs_washington_usa, :adult_passport_costs_washington_usa, :passport_costs_washington_usa]
      assert_match /^[\d,]+ South African Rand \| [\d,]+ South African Rand$/, current_state.costs_south_african_rand_adult_32
      assert_state_variable :supporting_documents, ''
      expected_location = WorldLocation.find('st-helena-ascension-and-tristan-da-cunha')
      assert_state_variable :location, expected_location
      assert_state_variable :organisation, expected_location.fco_organisation
    end
  end # St Helena (FCO with custom phrases)

  context "answer Kazakhstan, applying, child passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('kazakhstan', read_fixture_file('worldwide/kazakhstan_organisations.json'))
      add_response 'kazakhstan'
      add_response 'applying'
      add_response 'child'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_kazakhstan, :how_long_it_takes_ips3]
      assert_phrase_list :cost, [:passport_courier_costs_ips3, :child_passport_costs_ips3, :passport_costs_ips3]
      assert_phrase_list :send_your_application, [:send_application_ips3, :send_application_embassy_address]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_ips3]
      expected_location = WorldLocation.find('kazakhstan')
      assert_state_variable :location, expected_location
      assert_state_variable :organisation, expected_location.fco_organisation
      assert_match /Astana 010000/, outcome_body
    end
  end # Kazakhstan

  context "answer Kyrgyzstan, renewing_old, adult passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('kazakhstan', read_fixture_file('worldwide/kazakhstan_organisations.json'))
      add_response 'kyrgyzstan'
      add_response 'renewing_old'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_kyrgyzstan, :how_long_it_takes_ips3]
      assert_phrase_list :cost, [:passport_courier_costs_ips3, :adult_passport_costs_ips3, :passport_costs_ips3]
      assert_phrase_list :send_your_application, [:send_application_ips3, :renewing_new_renewing_old, :send_application_embassy_address]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_ips3]
      expected_location = WorldLocation.find('kazakhstan')
      assert_state_variable :location, expected_location
      assert_state_variable :organisation, expected_location.fco_organisation
      assert_match /British Embassy Astana/, outcome_body
    end
  end # Kyrgyzstan

  context "answer Nigeria, applying, adult passport" do
    should "give the result with custom phrases" do
      worldwide_api_has_organisations_for_location('nigeria', read_fixture_file('worldwide/nigeria_organisations.json'))
      add_response 'nigeria'
      add_response 'applying'
      add_response 'adult'
      assert_current_node :result
      assert_phrase_list :fco_forms, [:adult_fco_forms_nigeria]
      assert_phrase_list :how_long_it_takes, [:how_long_lagos_nigeria]
      assert_phrase_list :cost, [:cost_lagos_nigeria]
      assert_phrase_list :how_to_apply, [:how_to_apply_lagos_nigeria]
      assert_phrase_list :making_application, [:making_application_lagos_nigeria]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_lagos_nigeria]
      assert_phrase_list :helpline, [:helpline_intro, :helpline_pretoria_south_africa, :helpline_fco_webchat]
      expected_location = WorldLocation.find('nigeria')
      assert_state_variable :location, expected_location
      assert_state_variable :organisation, expected_location.fco_organisation
      assert_match /11 Walter Carrington Crescent/, outcome_body
    end
  end # Kyrgyzstan

  context "answer Russia, applying, child passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('russia', read_fixture_file('worldwide/russia_organisations.json'))
      add_response 'russia'
      add_response 'applying'
      add_response 'child'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_applying_ips2, :how_long_it_takes_ips2]
      assert_phrase_list :cost, [:passport_courier_costs_ips2, :child_passport_costs_ips2, :passport_costs_ips2]
      assert_phrase_list :send_your_application, [:send_application_ips2, :send_application_embassy_address]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_ips2]
      expected_location = WorldLocation.find('russia')
      assert_state_variable :location, expected_location
      assert_state_variable :organisation, expected_location.fco_organisation
      assert_match /British Consulate-General St Petersburg/, outcome_body
      assert_match /15A, Gogol Street/, outcome_body
      
    end
  end # Kazakhstan

  context "answer Jamaica, replacement, adult passport" do
    should "give the ips result with custom phrase" do
      worldwide_api_has_organisations_for_location('jamaica', read_fixture_file('worldwide/jamaica_organisations.json'))
      add_response 'jamaica'
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_replacing_ips1, :how_long_it_takes_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :hmpo_2_application_form, :ips_documents_group_3]
      assert_phrase_list :cost, [:passport_courier_costs_replacing_ips1, :adult_passport_costs_replacing_ips1, :passport_costs_ips1]
      expected_location = WorldLocation.find('jamaica')
      assert_state_variable :location, expected_location
      assert_state_variable :organisation, expected_location.fco_organisation
      assert_match /Millburngate House/, outcome_body
    end
  end # Jamaica

  context "answer Djibouti, applying, adult passport" do
    should "give the generic result with custom phrases" do
      worldwide_api_has_organisations_for_location('kenya', read_fixture_file('worldwide/kenya_organisations.json'))
      add_response 'djibouti'
      add_response 'applying'
      add_response 'adult'
      assert_current_node :result
      assert_phrase_list :how_long_it_takes, [:how_long_nairobi_kenya_applying]
      assert_phrase_list :cost, [:cost_nairobi_kenya_applying]
      assert_phrase_list :supporting_documents, [:supporting_documents_nairobi_kenya_applying]
      assert_phrase_list :making_application, [:making_application_nairobi_kenya]
      assert_phrase_list :helpline, [:helpline_intro, :helpline_pretoria_south_africa, :helpline_fco_webchat]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_djibouti]
      expected_location = WorldLocation.find('kenya')
      assert_state_variable :location, expected_location
      assert_state_variable :organisation, expected_location.fco_organisation
      assert_match /Upper Hill Road/, outcome_body
    end
  end # Djibouti

end
