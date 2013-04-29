# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class BenefitsAbroadTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'benefits-abroad'
  end

  # Q1
  should "ask if you are going or are already abroad" do
    assert_current_node :going_or_already_abroad?
  end

  context "when currently abroad" do
    setup do
      add_response "going_abroad"
    end
    # Q2
    should "ask which benefit you want to claim" do
      assert_current_node :which_benefit?
    end
    context "answer JSA" do
      setup do
        add_response 'jsa'
      end
      # Q3
      should "ask which country you are moving to" do
        assert_current_node :which_country_are_you_moving_to_jsa?
      end
      context "answer a country within the EEA" do
        should "state JSA entitlement in the EEA" do
          add_response 'austria'
          assert_current_node :jsa_eea
        end
      end
      context "answer outside EEA" do
        should "state JSA entitlement outside the EEA" do
          add_response 'bosnia-and-herzegovina'
          assert_current_node :jsa_social_security
        end
      end
      context "answer India" do
        should "state you are not entitled to JSA" do
          add_response 'india'
          assert_current_node :jsa_not_entitled
        end
      end
    end # JSA
    context "answer pension" do
      should "give the pension outcome" do
        add_response 'pension'
        assert_current_node :pension_outcome
      end
    end # Pension
    context "answer winter fuel payments" do
      setup do
        add_response 'wfp'
      end
      # Q4
      should "ask which country you are moving to" do
      end
      context "answer Austria (EEA country)" do
        setup do
          add_response 'austria'
        end
        should "ask if you already qualify for WFP" do
          assert_current_node :qualify_for_wfp?
        end
        context "answer yes" do
          should "state WFP entitlement" do
            add_response 'yes'
            assert_current_node :wfp_outcome
          end
        end
        context "answer no" do
          should "state not entitled to WFP" do
            add_response 'no'
            assert_current_node :wfp_not_entitled
          end
        end
      end
      context "answer Australia (outside EEA)" do
        should "state not entitled to WFP" do
          add_response 'australia'
          assert_current_node :wfp_not_entitled
        end
      end
    end # Winter fuel payments
    context "answer maternity pay" do
      setup do
        add_response 'maternity'
      end
      should "ask which country you are moving to" do
        context "answer austria (EEA country)" do
          setup do
            add_response 'austria'
          end
          should "ask if you will be working for a UK employer" do
            assert_current_node :working_for_a_uk_employer?
          end
        end
      end
    end # Maternity
  end
end
