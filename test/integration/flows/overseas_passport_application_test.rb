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
          end
        end
        context "answer born in the uk after 31 Dec 1982 with father born in UK" do
          should "give the australian result" do
            add_response 'born-in-uk-post-dec-1982-father'
          end
        end
        context "answer born in the uk before 1 Jan 1983 with mother born in UK" do
          should "give the australian result" do
            add_response 'born-in-uk-post-dec-1982-mother'
          end
        end
        context "answer born outside the uk with british father married to mother" do
          should "give the australian result" do
            add_response 'born-outside-uk-parents-married'
          end
        end
        context "answer born outside the uk with british mother" do
          should "give the australian result" do
            add_response 'born-outside-uk-mother-uk'
          end
        end
        context "answer born in UK after 31 Dec 1983 with british citizen father" do
          should "give the australian result" do
            add_response 'born-in-uk-post-1983-father-citizen'
          end
        end
        context "answer born in UK after 31 Dec 1983 with british citizen mother" do
          should "give the australian result" do
            add_response 'born-in-uk-post-1983-mother-citizen'
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
          assert_current_node :australian_result
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
      assert_state_variable :application_type, 'Afghanistan'
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
          assert_current_node :result # TODO: Individual outcomes...?
        end
      end
    end
  end # Afghanistan

  # Austria (An example of IPS application 1).
  context "answer Austria" do
    setup do
      add_response 'austria'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
      assert_state_variable :current_location, 'austria'
      assert_state_variable :application_type, 'ips_application_1'
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
          assert_current_node :country_of_birth?
        end
        context "TODO" do
        end
      end
    end # Applying
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
          assert_current_node :ips_application_1
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
            assert_current_node :ips_application_2
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
    end
    context "answer applying" do
      setup do
        add_response 'applying'
      end
    end # Applying
    context "renewing old" do
      
    end
  end # Azerbaijan - IPS_application_3

  # Andorra (an example of FCO application)
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
      context "answer adult" do
        should "give the FCO result and be done" do
          add_response 'adult'
          assert_current_node :fco_result
        end
      end
    end
  end
end
