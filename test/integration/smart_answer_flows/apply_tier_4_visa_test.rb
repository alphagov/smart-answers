# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class ApplyTier4VisaTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'apply-tier-4-visa'
  end

  should "Ask are you going to do" do
    assert_current_node :extending_or_switching?
  end
  context "Switching general student visa" do
    setup do
      add_response 'switch_general'
    end
    should "ask sponsor number" do
      assert_current_node :sponsor_id?
    end
    context "existing sponsor id provided (post)" do
      setup do
        add_response "01HXM2CP2"
      end
      should "show outcome with post phraselist" do
        assert_state_variable :sponsor_name, "CAPITAL COLLEGE UK"
        assert_state_variable :sponsor_id, "01HXM2CP2"
        assert_phrase_list :application_link, [:post_and_switch_link]
        assert_current_node :outcome
      end
    end
    context "existing sponsor id provided (online)" do
      setup do
        add_response "1GC8FDP33"
      end
      should "show outcome with online and switching general phraselists" do
        assert_state_variable :sponsor_name, "Alpha Omega College"
        assert_state_variable :sponsor_id, "1GC8FDP33"
        assert_phrase_list :application_link, [:online_and_switch_link]
        assert_phrase_list :extend_or_switch_visa, [:you_must_be_in_uk, :general_switch]
        assert_current_node :outcome
      end
    end
    context "non existing sponsor id provided (online)" do
      setup do
        add_response "egrwijadvwbjdsva nk."
      end
      should "raise an error" do
        assert_current_node_is_error
      end
    end
  end
  context "Extending child visa" do
    setup do
      add_response "extend_child"
      add_response "YYAX6VCR8"
    end
    should "show outcome with extending child phraselists" do
      assert_state_variable :sponsor_name, "WIMBLEDON HIGH SCHOOL"
      assert_state_variable :sponsor_id, "YYAX6VCR8"
      assert_phrase_list :application_link, [:online_and_extend_link]
      assert_phrase_list :extend_or_switch_visa, [:child_extend]
      assert_current_node :outcome
    end
  end
  context "Switching child visa" do
    setup do
      add_response "switch_child"
      add_response "2W8TVPP77"
    end
    should "show outcome with extending child phraselists" do
      assert_state_variable :sponsor_name, "14 Stars (London) Ltd t/a EUROPEAN COLLEGE FOR HIGHER EDUCATION"
      assert_state_variable :sponsor_id, "2W8TVPP77"
      assert_phrase_list :application_link, [:post_and_switch_link]
      assert_phrase_list :extend_or_switch_visa, [:you_must_be_in_uk, :child_switch]
      assert_current_node :outcome
    end
  end
  context "Extending general visa" do
    setup do
      add_response "extend_general"
      add_response "GFHRH18H5"
    end
    should "show outcome with extending child phraselists" do
      assert_state_variable :sponsor_name, "Kaplan International Colleges Cambridge"
      assert_state_variable :sponsor_id, "GFHRH18H5"
      assert_phrase_list :application_link, [:post_and_extend_link]
      assert_phrase_list :extend_or_switch_visa, [:general_extend]
      assert_current_node :outcome
    end
  end
end
