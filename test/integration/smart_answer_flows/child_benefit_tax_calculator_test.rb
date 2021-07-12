require_relative "../../test_helper"
require_relative "flow_integration_test_helper"

class ChildBenefitTaxCalculatorTest < ActiveSupport::TestCase
  include FlowIntegrationTestHelper

  setup do
    setup_for_testing_flow ChildBenefitTaxCalculatorFlow
  end

  context "Child Benefit tax calculator" do
    context "When claiming for one full year child, no deductions" do
      should "should go though basic flow and to results page" do
        # Q1
        assert_current_node :how_many_children?
        add_response "1"
        # Q2
        assert_current_node :which_tax_year?
        add_response "2012"
        # Q3
        assert_current_node :is_part_year_claim?
        add_response "no"
        # Q4
        assert_current_node :income_details?
        add_response "30000"
        # Q5
        assert_current_node :add_allowable_deductions?
        add_response "no"

        assert_current_node :results
      end
    end

    context "When claiming for one full year child, two part year children" do
      should "should iterate part time questions and to results page" do
        # Q1
        assert_current_node :how_many_children?
        add_response "2"
        # Q2
        assert_current_node :which_tax_year?
        add_response "2015"
        # Q3
        assert_current_node :is_part_year_claim?
        add_response "yes"
        # Q3a
        assert_current_node :how_many_children_part_year?
        add_response "2"
        # Q3b
        assert_current_node :child_benefit_1_start?
        add_response "2015-06-01"
        # Q3c
        assert_current_node :add_child_benefit_1_stop?
        add_response "yes"
        # Q3d
        assert_current_node :child_benefit_1_stop?
        add_response "2016-03-01"
        # Q3b
        assert_current_node :child_benefit_2_start?
        add_response "2015-06-06"
        # Q3c
        assert_current_node :add_child_benefit_2_stop?
        add_response "no"
        # Q4
        assert_current_node :income_details?
        add_response "30000"
        # Q5
        assert_current_node :add_allowable_deductions?
        add_response "yes"
        # Q5a
        assert_current_node :allowable_deductions?
        add_response "8000"
        # Q6
        assert_current_node :add_other_allowable_deductions?
        add_response "yes"
        # Q6a
        assert_current_node :other_allowable_deductions?
        add_response "1000"

        assert_current_node :results
      end
    end
  end
end
