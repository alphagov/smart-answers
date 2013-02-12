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

  context "answer UK" do
    setup do
      add_response 'uk'
    end
    should "ask whether the death was expected" do
      assert_current_node :was_death_expected?
    end
    context "answer yes" do
      
    end
    context "answer no" do
    end
  end # UK

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
          assert_current_node :commonwealth_result
        end
      end # Australia (commonwealth country)
      context "answer Spain" do
        setup do
          add_response 'spain'
        end
        should "ask where you want to register the death" do
          assert_current_node :where_do_you_want_to_register_the_death?
        end
        context "answer embassy" do
          setup do
            add_response 'embassy'
          end
          should "give the embassy result and be done" do
            assert_current_node :embassy_result
          end
        end # Answer embassy
        context "answer fco office in the uk" do
          setup do
            add_response 'fco_uk'
          end
          should "give the fco result and be done" do
            assert_current_node :fco_result
          end
        end # Answer fco 
      end
    end # Answer yes

    context "answer no" do
      setup do
        add_response 'no'
      end
      should "ask which country" do
        assert_current_node :which_country?
      end
    end
  end # Overseas
end
