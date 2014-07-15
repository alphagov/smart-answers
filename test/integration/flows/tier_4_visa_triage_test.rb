# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class Tier4VisaTriageTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'tier-4-visa-triage'
  end

  should "Ask are you going to do" do
    assert_current_node :are_you?
  end
  context "Extending general student visa" do
    setup do
      add_response 'extend_general'
    end
    should "ask sponsor number" do
      assert_current_node :sponsor_number?
    end
  end
end