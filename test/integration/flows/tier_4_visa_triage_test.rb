# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class Tier4VisaTriageTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'tier-4-visa-triage'
  end

  should "Ask are you going to do" do
    assert_current_node :extending_or_switching?
  end
  context "Extending general student visa" do
    setup do
      add_response 'extend_general'
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
        assert_phrase_list :application_link, [:post_link]
        assert_current_node :outcome
      end
    end
    context "existing sponsor id provided (online)" do
      setup do
        add_response "1GC8FDP33"
      end
      should "show outcome with online phraselist" do
        assert_state_variable :sponsor_name, "Alpha Omega College"
        assert_state_variable :sponsor_id, "1GC8FDP33"
        assert_phrase_list :application_link, [:online_link]
        assert_current_node :outcome
      end
    end
    context "existing sponsor id provided (online)" do
      setup do
        add_response "egrwijadvwbjdsva nk."
      end
      should "raise an error" do
        assert_current_node_is_error
      end
    end
  end
end
