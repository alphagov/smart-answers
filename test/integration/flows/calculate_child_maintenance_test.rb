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
  
  ## Old scheme
  context "answer 3" do
    setup do
      add_response '3_children'
    end
    should "ask if person paying child benefit receives benefits" do
      assert_current_node :gets_benefits_old?
    end

    context "answer yes to benefits" do
      setup { add_response 'yes' }

      should "ask about shared care" do
        assert_current_node :how_many_nights_children_stay_with_payee?
      end

      context "no shared care" do
        setup { add_response '0' }

        should "display flat rate result" do
          assert_state_variable "flat_rate_amount", 5
          assert_current_node :flat_rate_result
        end
      end 

      context "shared care" do
        setup { add_response '1' }

        should "display nil rate result" do
          assert_current_node :nil_rate_result
        end
      end
    end # yes to benefits

    context "no to benefits" do
      setup { add_response 'no' }

      ## Q3
      should "ask what the weekly net income of the payee" do
        assert_current_node :net_income_of_payee?
      end
      context "answer 4.99" do
        should "give flat rate result" do
          add_response 4.99
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
        ## Q4
        should "ask how many other children there are in the payees household" do
          assert_current_node :how_many_other_children_in_payees_household?
        end
      
        context "answer 3" do
          setup do
            add_response 3
          end
          ## Q5
          should "ask how many nights a week the children stay with the payee" do
            assert_current_node :how_many_nights_children_stay_with_payee?
          end
          context "answer more than 3 nights a week" do
            setup do
              add_response "4"
            end
          
            should "give the reduced and basic rates result" do
              #test just the flow here - calculation values should be in the unit tests
              assert_current_node :reduced_and_basic_rates_result
              assert_state_variable "rate_type_formatted", "reduced"
            end
          end
        end
      end
    end
  end # Old scheme
  
  # New scheme
  context "answer 4 children (with 1 other parent)" do
    setup do
      add_response '4_children'
    end

    should "ask about benefits" do
       assert_current_node :gets_benefits_new?
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
          assert_state_variable "flat_rate_amount", 5
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

      context "answer 5000" do
        should "cap the income at 3000" do
          add_response 4000.0
          add_response 0
          add_response 0
          assert_current_node :reduced_and_basic_rates_result
          assert_state_variable "child_maintenance_payment", "482"
        end
      end
    end
  end # new scheme
end
