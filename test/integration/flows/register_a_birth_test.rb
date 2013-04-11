# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class RegisterABirthTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'register-a-birth'
  end

  should "ask which country the child was born in" do
    assert_current_node :country_of_birth?
  end

  context "answer Turkey" do
    setup do
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
        should "ask where you are now" do
          assert_current_node :where_are_you_now?
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
      add_response 'andorra'
      assert_state_variable :registration_country, 'spain'
    end
  end # Andorra

  context "answer Iran" do
    should "give the no embassy outcome and be done" do
      add_response 'iran'
      assert_current_node :no_embassy_result
    end
  end # Iran

  context "answer Spain" do
    setup do
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
          should "give the fco result" do
            add_response 'in_the_uk'
            assert_state_variable :registration_country, 'spain'
            assert_current_node :fco_result
            assert_phrase_list :intro, [:intro]
            assert_state_variable :embassy_high_commission_or_consulate, "British embassy"
          end
        end
        context "answer in another country" do
          setup do
            add_response "another_country"
          end
          context "answer which country" do
            should "Ireland and get the commonwealth result" do 
              add_response 'ireland'
              assert_state_variable :another_country, true
              assert_state_variable :registration_country, 'ireland'
              assert_current_node :embassy_result
            end # now in Ireland
            should "USA and get the embassy outcome" do
              add_response 'united-states'
              assert_current_node :embassy_result
              assert_state_variable :embassy_high_commission_or_consulate, "British embassy"
              assert_state_variable :registration_country_name, "United States"
              assert_phrase_list :documents_you_must_provide, [:documents_you_must_provide_all]
              assert_phrase_list :go_to_the_embassy, [:registering_clickbooks, :registering_either_parent]
              assert_state_variable :multiple_clickbooks, true
              assert_match /Book an appointment in New York/, current_state.clickbook
              assert_state_variable :postal_form_url, nil
              assert_phrase_list :postal, [:"postal_info_united-states"]
              assert_match /3100 Massachusetts Ave, NW/, current_state.embassy_details
              assert_phrase_list :footnote, [:footnote_another_country]
            end # now in USA
            should "answer Yemen and get the no embassy outcome" do
              add_response 'yemen'
              assert_current_node :no_embassy_result
              assert_state_variable :registration_country_name, "Yemen"
            end # now in Yemen 
          end # in another country
        end # mother and father british citizens
      end # married
    end # Spain
  end
  context "answer Afghanistan" do
    should "give the embassy result" do
      add_response "afghanistan"
      add_response "mother_and_father"
      add_response "yes"
      add_response "same_country"
      assert_current_node :embassy_result
      assert_state_variable :embassy_high_commission_or_consulate, "British embassy"
      assert_state_variable :registration_country_name, "Afghanistan"
      assert_state_variable :british_national_parent, 'mother_and_father'
      assert_phrase_list :documents_you_must_provide, [:documents_you_must_provide_all]
      assert_phrase_list :go_to_the_embassy, [:registering_all, :registering_either_parent]
      assert_state_variable :postal_form_url, nil 
      assert_state_variable :postal, ""
      assert_phrase_list :footnote, [:footnote_exceptions] 
    end
  end # Afghanistan
  context "answer Pakistan" do
    should "give the embassy result" do
      add_response "pakistan"
      add_response "father"
      add_response "yes"
      add_response "in_the_uk"
      assert_current_node :embassy_result
    end
  end # Pakistan
  context "answer Taiwan" do
    should "give the embassy result" do
      add_response "taiwan"
      add_response "mother_and_father"
      add_response "yes"
      add_response "same_country"
      assert_current_node :embassy_result
      assert_state_variable :british_national_parent, 'mother_and_father'
      assert_phrase_list :documents_you_must_provide, [:documents_you_must_provide_taiwan]
    end
  end # Taiwan
  context "answer Taiwan now in the UK" do
    should "give the FCO result" do
      add_response "taiwan"
      add_response "mother_and_father"
      add_response "yes"
      add_response "in_the_uk"
      assert_current_node :fco_result
      assert_state_variable :intro, ''
      assert_state_variable :british_national_parent, 'mother_and_father'
    end
  end # Taiwan
  context "answer Central African Republic now in the UK" do
    should "give the FCO result" do
      add_response "central-african-republic"
      add_response "mother_and_father"
      add_response "yes"
      add_response "in_the_uk"
      assert_current_node :fco_result
      assert_state_variable :intro, ''
      assert_state_variable :british_national_parent, 'mother_and_father'
    end
  end # Central African Republic
  context "answer Belize" do
    should "give the embassy result" do
      add_response "belize"
      add_response "father"
      add_response "no"
      add_response "2006-07-01"
      add_response "same_country"
      assert_current_node :embassy_result
      assert_state_variable :british_national_parent, 'father'
      assert_phrase_list :documents_you_must_provide, [:documents_you_must_provide_all]
      assert_phrase_list :go_to_the_embassy, [:registering_clickbook, :registering_paternity_declaration]
    end # Not married or CP
  end # Belize

  context "el-salvador, where you have to register in guatemala" do
    setup do
      add_response "el-salvador"
    end

    should "calculate the registration country as Guatemala" do
      assert_state_variable :registration_country, "guatemala"
      assert_state_variable :registration_country_name, "Guatemala"
    end

  end
end
