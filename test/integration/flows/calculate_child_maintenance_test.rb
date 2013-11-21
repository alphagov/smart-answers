# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class CalculateChildMaintentanceTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'calculate-your-child-maintenance'
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

  context "answer 2+ children" do
    setup do
      add_response '2_children'
    end

    should "ask about benefits" do
       assert_current_node :gets_benefits?
    end

    context "no to benefits" do
      setup { add_response 'no' }

      ## Q3a
      should "ask what the weekly gross income of the payee" do
        assert_current_node :gross_income_of_payee?
      end

      context "answer 100" do
        should "give flat rate result" do
          add_response 100
          assert_state_variable "flat_rate_amount", 7
          assert_current_node :flat_rate_result
        end

        should "flow through to calculation result" do
          add_response 250.00
          add_response 1
          add_response 1
          assert_current_node :reduced_and_basic_rates_result
          assert_state_variable "rate_type_formatted", "basic"
        end
      end

      context "answer 4000" do
        should "cap the income at 3000" do
          add_response 4000.0
          add_response 0
          add_response 0
          assert_current_node :reduced_and_basic_rates_result
          assert_state_variable "child_maintenance_payment", "392"
        end
      end
    end
  end
end
