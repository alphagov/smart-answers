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
      should "ask which country the child was born in" do
        assert_current_node :country_of_birth?
      end
      context "answer with a commonwealth country" do
        should "give the commonwealth result" do
          add_response 'australia'
          assert_current_node :commonwealth_result
        end
      end # commonweath result
      context "answer Spain" do
        setup do
          add_response 'spain'
        end
        should "ask if you are married or civil partnered" do
          assert_current_node :married_couple_or_civil_partnership?
        end
      end # Spain
    end # mother
    context "answer father" do
      setup do
        add_response 'father'
      end
    end # father
    context "answer mother and father" do
      setup do
        add_response 'mother_and_father'
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
