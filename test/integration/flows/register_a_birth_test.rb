# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class RegisterABirthTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'register-a-birth'
  end

  should "ask if you adopted the child" do
    assert_current_node :have_you_adopted_the_child?
  end

  context "answer yes" do
    should "give the no registration result and be done" do
      add_response 'yes'
      assert_current_node :no_registration_result
    end
  end # Yes - no registration

  context "answer no" do
    setup do
      add_response 'no'
    end
    should "ask which parent has british nationality" do
      assert_current_node :who_has_british_nationality?
    end
    context "answer mother" do
      setup do
        add_response 'mother'
      end
      should "store the answer as british_national_parent" do
        assert_state_variable :british_national_parent, 'mother'
      end
      should "ask which country the child was born in" do
        assert_current_node :country_of_birth?
      end
      context "answer Turkey" do
        setup do
          add_response 'turkey'
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
      end # Turkey
      context "answer with a commonwealth country" do
        should "give the commonwealth result" do
          add_response 'australia'
          assert_current_node :commonwealth_result
        end
      end # commonweath result
    end # mother
    context "answer father" do
      setup do
        add_response 'father'
      end
      should "store the answer as british_national_parent" do
        assert_state_variable :british_national_parent, 'father'
      end
      should "ask where the child was born" do
        assert_current_node :country_of_birth?
      end
      context "answer Spain" do
        setup do
          add_response 'spain'
        end
        should "ask if you are married or civil partnered" do
          assert_current_node :married_couple_or_civil_partnership?
        end
        should "store this as the registration country" do
          assert_state_variable :registration_country, 'spain'
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
              add_response '2007-06-30'
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
            end
          end
          context "answer in another country" do
            setup do
              add_response "another_country"
            end
            should "answer Ireland and get the commonwealth result" do 
              add_response 'ireland'
              assert_state_variable :registration_country, 'ireland'
              assert_current_node :commonwealth_result
            end # now in Ireland
            should "answer USA and get the embassy outcome" do
              add_response 'united-states'
              assert_current_node :embassy_result
            end # now in USA
          end # in another country
        end # married/cp
      end # Spain
      context "answer Pakistan" do
        should "give the embassy result" do
          add_response "pakistan"
          add_response "yes"
          add_response "in_the_uk"
          assert_current_node :embassy_result
        end
      end # Pakistan
    end # father
    context "answer mother and father" do
      setup do
        add_response 'mother_and_father'
      end
      should "store the answer as british_national_parent" do
        assert_state_variable :british_national_parent, 'mother_and_father'
      end
    end # mother and father
    context "answer neither" do
      should "give the no registration result" do
        add_response 'neither'
        assert_current_node :no_registration_result
      end
    end # neither
  end
end
