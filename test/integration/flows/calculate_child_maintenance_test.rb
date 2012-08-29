# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class CalculateChildMaintentanceTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'calculate-child-maintenance'
  end
  
  ## Q1
  should "ask how many children maintenance is paid for" do
    assert_current_node :how_many_children_paid_for?
  end
  
  context "answer 0" do
    should "raise an error" do
      add_response 0
      assert_current_node_is_error
    end
  end
  
  context "answer less than 4" do
    setup do
      add_response 3
    end
    ## Q2
    should "ask what the weekly income of the payee" do
      assert_current_node :net_income_of_payee?
    end
    context "answer 7" do
      should "give nil rate result" do
        add_response 7
        assert_current_node :nil_rate_result
      end
    end
    context "answer 100" do
      should "give nil rate result" do
        add_response 100
        assert_current_node :flat_rate_result
      end
    end
    context "answer 101" do
      setup do
        add_response 101
      end
      
      should "ask how many children there are in the payees household" do
        assert_current_node :how_many_children_in_payees_household?
      end
    end
  end

end
