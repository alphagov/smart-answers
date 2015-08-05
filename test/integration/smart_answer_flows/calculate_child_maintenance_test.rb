require_relative '../../test_helper'
require_relative 'flow_test_helper'

require "smart_answer_flows/calculate-your-child-maintenance"

class CalculateChildMaintentanceTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::CalculateYourChildMaintenanceFlow
  end

  ## Q0
  should "ask if you are paying or receiving" do
    assert_current_node :are_you_paying_or_receiving?
  end

  context "answer paying" do
    setup do
      add_response "pay"
    end

    should "ask you how many children you're paying for" do
      assert_current_node :how_many_children_paid_for?
    end

    context "answer 1 child" do
      setup do
        add_response "1_child"
      end

      should "ask do you get any of these benefits" do
        assert_current_node :gets_benefits?
        assert_phrase_list :paying_or_receiving_hint, [:pay_hint]
      end

      context "answer yes" do
        setup do
          add_response "yes"
        end

        should "ask how many night's child stays with parent paying maintenance" do
          assert_current_node :how_many_nights_children_stay_with_payee?
        end

        context "answer less than 52" do
          setup do
            add_response "0"
          end

          should "take you to the flat rate outcome" do
            assert_current_node :flat_rate_result
            assert_state_variable "flat_rate_amount", "7.00"
          end
        end
        context "answer 104 to 103" do
          setup do
            add_response "1"
          end

          should "take you to the nil rate outcome" do
            assert_current_node :nil_rate_result
          end
        end
      end

      context "answer no" do
        setup do
          add_response "no"
        end

        should "ask for gross weekly income of payee" do
          assert_current_node :gross_income_of_payee?
        end

        context "answer £100" do
          should "give flat rate result" do
            add_response "100"
            assert_state_variable "flat_rate_amount", "7.00"
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
            assert_state_variable "child_maintenance_payment", "294.00"
          end
        end
      end
    end

    context "answer 2 children, receives benefits, child stays less than once a week" do
      setup do
        add_response "2_children"
        add_response "yes"
        add_response "0"
      end

      should "take you to flat rate result" do
        assert_current_node :flat_rate_result
      end
    end

    context "answer 2 children, receives benefits, child stays more than once a week" do
      setup do
        add_response "2_children"
        add_response "yes"
        add_response "4"
      end

      should "take you to flat rate result" do
        assert_current_node :nil_rate_result
      end
    end

    context "answer 2 children, doesn't receives benefits, income £500, one other child in house, child stays more than once a week" do
      setup do
        add_response "2_children"
        add_response "no"
        add_response "500"
        add_response "1"
        add_response "0"
      end

      should "take you to flat rate result" do
        assert_current_node :reduced_and_basic_rates_result
        assert_state_variable "child_maintenance_payment", "71.00"
      end
    end

    context "answer 2 children, doesn't receives benefits, income £850, one other child in house, child stays 2 or three nights a week" do
      setup do
        add_response "2_children"
        add_response "no"
        add_response "850"
        add_response "1"
        add_response "3"
      end

      should "take you to flat rate result" do
        assert_current_node :reduced_and_basic_rates_result
        assert_state_variable "child_maintenance_payment", "70.00"
      end
    end
  end

  context "answer receiving" do
    setup do
      add_response "receive"
    end

    should "ask how many children you're receiving maintenance for" do
      assert_current_node :how_many_children_paid_for?
    end
  end
end
