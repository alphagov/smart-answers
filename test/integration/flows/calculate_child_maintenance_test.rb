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
  
  ## Old scheme
  context "answer less than 4" do
    setup do
      add_response 3
    end
    ## Q2
    should "ask what the weekly income of the payee" do
      assert_current_node :net_income_of_payee?
    end
    context "answer 5" do
      should "give nil rate result" do
        add_response 5
        assert_current_node :nil_rate_result
      end
    end
    context "answer 100" do
      should "give flat rate result" do
        add_response 100
        assert_state_variable "flat_rate_amount", 5
        assert_current_node :flat_rate_result
      end
    end
    context "answer 101" do
      setup do
        add_response 101
      end
      ## Q3
      should "ask how many other children there are in the payees household" do
        assert_current_node :how_many_other_children_in_payees_household?
      end
      
      context "answer 3" do
        setup do
          add_response 3
        end
        ## Q4
        should "ask how many nights a week the children stay with the payee" do
          assert_current_node :how_many_nights_children_stay_with_payee?
        end
        context "answer more than 3 nights a week" do
          setup do
            add_response "4"
          end
          
          should "give the reduced and basic rates result" do
            assert_state_variable "child_maintenance_payment", 2.66
            assert_current_node :reduced_and_basic_rates_result
          end
        end
      end
    end
  end # Old scheme
  
  ## New scheme
  context "answer 4" do
    setup do
      add_response 4
    end
    ## Q2
    should "ask what the weekly income of the payee" do
      assert_current_node :net_income_of_payee?
    end
    context "answer 100" do
      should "give flat rate result" do
        add_response 100
        assert_state_variable "flat_rate_amount", 7
        assert_current_node :flat_rate_result
      end
      should "flow through to calculation result" do
        add_response 173.00
        add_response 1
        add_response 1
        assert_state_variable "child_maintenance_payment", 29.25
        assert_current_node :reduced_and_basic_rates_result
      end
    end
  end
end
