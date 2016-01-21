require_relative '../../test_helper'
require_relative 'flow_test_helper'

require "smart_answer_flows/apply-tier-4-visa"

class ApplyTier4VisaTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::ApplyTier4VisaFlow
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
        add_response "48909JVC1"
      end
      should "show :outcome outcome" do
        assert_state_variable :sponsor_name, "Eastbourne School of English"
        assert_state_variable :sponsor_id, "48909JVC1"
        assert_current_node :outcome
      end
    end
    context "existing sponsor id provided (online)" do
      setup do
        add_response "1GC8FDP33"
      end
      should "show :outcome outcome" do
        assert_state_variable :sponsor_name, "Alpha Omega College"
        assert_state_variable :sponsor_id, "1GC8FDP33"
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
    should "show :outcome outcome" do
      assert_state_variable :sponsor_name, "WIMBLEDON HIGH SCHOOL"
      assert_state_variable :sponsor_id, "YYAX6VCR8"
      assert_current_node :outcome
    end
  end
  context "Switching child visa" do
    setup do
      add_response "switch_child"
      add_response "2W8TVPP77"
    end
    should "show :outcome outcome" do
      assert_state_variable :sponsor_name, "14 Stars (London) Ltd t/a EUROPEAN COLLEGE FOR HIGHER EDUCATION"
      assert_state_variable :sponsor_id, "2W8TVPP77"
      assert_current_node :outcome
    end
  end
  context "Extending general visa" do
    setup do
      add_response "extend_general"
      add_response "GFHRH18H5"
    end
    should "show :outcome outcome" do
      assert_state_variable :sponsor_name, "Kaplan International Cambridge"
      assert_state_variable :sponsor_id, "GFHRH18H5"
      assert_current_node :outcome
    end
  end
end
