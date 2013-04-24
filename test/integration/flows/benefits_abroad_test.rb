# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class BenefitsAbroadTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'benefits-abroad'
  end

  # Q0
  should "ask which case applies" do
    assert_current_node :which_case?
  end

  context "when currently abroad" do
    setup do
      add_response "currently_abroad"
    end

    # Q1
    should "ask 'have you paid ni in the uk?'" do
      assert_current_node :have_you_paid_ni_in_the_uk?
    end
    # A1
    context "answer no" do
      should "give the no NI outcome" do
        add_response 'no'
        assert_current_node :not_paid_ni
      end
    end
    context "answer yes" do
      setup do
        add_response 'yes'
      end
      should "ask which benefit you want to claim" do
        assert_current_node :which_benefit?
      end
      context "answer JSA" do
        setup do
          add_response 'jsa'
        end
        should "ask which country you are going to" do
          assert_current_node :which_country_jsa?
        end
        context "answer EEA" do
          should "state JSA entitlement in the EEA" do
            add_response 'eea_country'
            assert_current_node :jsa_eea
          end
        end
        context "answer outside EEA" do
          should "state JSA entitlement outside the EEA" do
            add_response 'outside_eea'
            assert_current_node :not_entitled_jsa_with_exceptions
          end
        end
        context "answer none of the above" do
          should "state you are not entitled to JSA" do
            add_response 'none_of_the_above'
            assert_current_node :not_entitled_jsa
          end
        end
      end # JSA
      context "answer pension" do
        should "give the pension outcome" do
          add_response 'pension'
          assert_current_node :pension_outcome
        end
      end # Pension
    end # Yes paid NI
  end
end
