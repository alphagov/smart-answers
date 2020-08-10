require_relative "../../test_helper"
require_relative "flow_unit_test_helper"

require "smart_answer_flows/child-benefit-tax-calculator"

module SmartAnswer
  class ChildBenefitTaxCalculatorFlowTest < ActiveSupport::TestCase
    context ChildBenefitTaxCalculatorFlow do
      include FlowUnitTestHelper

      setup do
        @calculator = Calculators::ChildBenefitTaxCalculator.new
        @flow = ChildBenefitTaxCalculatorFlow.build
      end

      should "start with how_many_children? question" do
        assert_equal :how_many_children?, @flow.start_state.current_node
      end

      # Q1
      context "when answering how_many_children? question" do
        setup do
          Calculators::ChildBenefitTaxCalculator.stubs(:new).returns(@calculator)
          setup_states_for_question(
            :how_many_children?,
            responding_with: "2",
          )
        end

        should "instantiate and store calculator" do
          assert_same @calculator, @new_state.calculator
        end

        should "store parsed response on calculator as children_count" do
          assert_equal 2, @calculator.children_count
        end

        should "go to which_tax_year? question" do
          assert_equal :which_tax_year?, @new_state.current_node
          assert_node_exists :which_tax_year?
        end
      end

      # Q2
      context "when answering which_tax_year? question" do
        setup do
          setup_states_for_question(
            :which_tax_year?,
            responding_with: "2012",
            initial_state: { calculator: @calculator },
          )
        end

        should "instantiate and store calculator" do
          assert_same @calculator, @new_state.calculator
        end

        should "store parsed response on calculator as tax_year" do
          assert_equal "2012", @calculator.tax_year
        end

        should "go to is_part_year_claim? question" do
          assert_equal :is_part_year_claim?, @new_state.current_node
          assert_node_exists :is_part_year_claim?
        end
      end

      # Q3
      context "when answering is_part_year_claim? question" do
        context "responding with yes" do
          setup do
            setup_states_for_question(
              :is_part_year_claim?,
              responding_with: "yes",
              initial_state: { calculator: @calculator },
            )
          end

          should "instantiate and store calculator" do
            assert_same @calculator, @new_state.calculator
          end

          should "go to how_many_children_part_year? question" do
            assert_equal :how_many_children_part_year?, @new_state.current_node
            assert_node_exists :how_many_children_part_year?
          end
        end

        context "responding with no" do
          setup do
            setup_states_for_question(
              :is_part_year_claim?,
              responding_with: "no",
              initial_state: { calculator: @calculator },
            )
          end

          should "instantiate and store calculator" do
            assert_same @calculator, @new_state.calculator
          end

          should "go to income_details? question" do
            setup do
              setup_states_for_question(
                :is_part_year_claim?,
                responding_with: "no",
                initial_state: { calculator: @calculator },
              )
            end
            assert_equal :income_details?, @new_state.current_node
            assert_node_exists :income_details?
          end
        end
      end

      # Q3a
      context "when answering how_many_children_part_year? question" do
        context "when the number is valid" do
          setup do
            @calculator.children_count = 8
            setup_states_for_question(
              :how_many_children_part_year?,
              responding_with: "2",
              initial_state: { calculator: @calculator },
            )
          end

          should "instantiate and store calculator" do
            assert_same @calculator, @new_state.calculator
          end

          should "go to child_benefit_start? question" do
            assert_equal :child_benefit_start?, @new_state.current_node
            assert_node_exists :child_benefit_start?
          end
        end
      end

      # Q3b
      context "when answering how_many_children_part_year? question" do
        context "when the date is valid" do
          setup do
            @calculator.tax_year = "2015"
            setup_states_for_question(
              :child_benefit_start?,
              responding_with: "2015-06-09",
              initial_state: { calculator: @calculator },
            )
          end

          should "instantiate and store calculator" do
            assert_same @calculator, @new_state.calculator
          end

          should "go to add_child_benefit_stop? question" do
            assert_equal :add_child_benefit_stop?, @new_state.current_node
            assert_node_exists :add_child_benefit_stop?
          end
        end
      end

      # Q3c
      context "when answering how_many_children_part_year? question" do
        context "when answering yes" do
          setup do
            setup_states_for_question(
              :add_child_benefit_stop?,
              responding_with: "yes",
              initial_state: { calculator: @calculator },
            )
          end

          should "instantiate and store calculator" do
            assert_same @calculator, @new_state.calculator
          end

          should "go to child_benefit_stop? question" do
            assert_equal :child_benefit_stop?, @new_state.current_node
            assert_node_exists :child_benefit_stop?
          end
        end

        context "when answering no" do
          setup do
            setup_states_for_question(
              :add_child_benefit_stop?,
              responding_with: "no",
              initial_state: { calculator: @calculator },
            )
          end

          should "instantiate and store calculator" do
            assert_same @calculator, @new_state.calculator
          end

          should "go to income_details? question" do
            assert_equal :income_details?, @new_state.current_node
            assert_node_exists :income_details?
          end
        end
      end

      # Q3d
      context "when answering child_benefit_stop? question" do
        setup do
          @calculator.tax_year = "2015"
          @calculator.stubs(:valid_end_date?).returns true
        end

        context "when there are more part year children" do
          setup do
            @calculator.child_index = 2
            @calculator.part_year_children_count = 6
            setup_states_for_question(
              :child_benefit_stop?,
              responding_with: "2015-06-09",
              initial_state: { calculator: @calculator },
            )
          end

          should "instantiate and store calculator" do
            assert_same @calculator, @new_state.calculator
          end

          should "go to child_benefit_start? question" do
            assert_equal :child_benefit_start?, @new_state.current_node
            assert_node_exists :child_benefit_start?
          end
        end

        context "when the final part year child" do
          setup do
            setup_states_for_question(
              :child_benefit_stop?,
              responding_with: "2015-06-09",
              initial_state: { calculator: @calculator },
            )
          end

          should "instantiate and store calculator" do
            assert_same @calculator, @new_state.calculator
          end

          should "go to income_details? question" do
            assert_equal :income_details?, @new_state.current_node
            assert_node_exists :income_details?
          end
        end
      end

      # Q4
      context "when answering income_details? question" do
        setup do
          setup_states_for_question(
            :income_details?,
            responding_with: "60000",
            initial_state: { calculator: @calculator },
          )
        end

        should "instantiate and store calculator" do
          assert_same @calculator, @new_state.calculator
        end

        should "store parsed response on calculator as income_details" do
          assert_equal 60_000, @calculator.income_details
        end

        should "go to add_allowable_deductions? question" do
          assert_equal :add_allowable_deductions?, @new_state.current_node
          assert_node_exists :add_allowable_deductions?
        end
      end

      # Q5
      context "when answering add_allowable_deductions? question" do
        context "responding with yes" do
          setup do
            setup_states_for_question(
              :add_allowable_deductions?,
              responding_with: "yes",
              initial_state: { calculator: @calculator },
            )
          end

          should "instantiate and store calculator" do
            assert_same @calculator, @new_state.calculator
          end

          should "go to allowable_deductions? question" do
            assert_equal :allowable_deductions?, @new_state.current_node
            assert_node_exists :allowable_deductions?
          end
        end

        context "responding with no" do
          setup do
            setup_states_for_question(
              :add_allowable_deductions?,
              responding_with: "no",
              initial_state: { calculator: @calculator },
            )
          end

          should "instantiate and store calculator" do
            assert_same @calculator, @new_state.calculator
          end

          should "go to outcome" do
            assert_equal :results, @new_state.current_node
            assert_node_exists :results
          end
        end
      end

      # Q5a
      context "when answering allowable_deductions? question" do
        setup do
          setup_states_for_question(
            :allowable_deductions?,
            responding_with: "8000",
            initial_state: { calculator: @calculator },
          )
        end

        should "instantiate and store calculator" do
          assert_same @calculator, @new_state.calculator
        end

        should "store parsed response on calculator as allowable_deductions" do
          assert_equal SmartAnswer::Money.new(8000), @calculator.allowable_deductions
        end

        should "go to add_other_allowable_deductions? question" do
          assert_equal :add_other_allowable_deductions?, @new_state.current_node
          assert_node_exists :add_other_allowable_deductions?
        end
      end

      # Q6
      context "when answering add_other_allowable_deductions? question" do
        context "responding with yes" do
          setup do
            setup_states_for_question(
              :add_other_allowable_deductions?,
              responding_with: "yes",
              initial_state: { calculator: @calculator },
            )
          end

          should "instantiate and store calculator" do
            assert_same @calculator, @new_state.calculator
          end

          should "go to other_allowable_deductions? question" do
            assert_equal :other_allowable_deductions?, @new_state.current_node
            assert_node_exists :other_allowable_deductions?
          end
        end

        context "responding with no" do
          setup do
            setup_states_for_question(
              :add_other_allowable_deductions?,
              responding_with: "no",
              initial_state: { calculator: @calculator },
            )
          end

          should "instantiate and store calculator" do
            assert_same @calculator, @new_state.calculator
          end

          should "go to outcome" do
            assert_equal :results, @new_state.current_node
            assert_node_exists :results
          end
        end
      end

      # Q6a
      context "when answering other_allowable_deductions? question" do
        setup do
          setup_states_for_question(
            :other_allowable_deductions?,
            responding_with: "1000",
            initial_state: { calculator: @calculator },
          )
        end

        should "instantiate and store calculator" do
          assert_same @calculator, @new_state.calculator
        end

        should "store parsed response on calculator as other_allowable_deductions" do
          assert_equal SmartAnswer::Money.new(1000), @calculator.other_allowable_deductions
        end

        should "go to results page" do
          assert_equal :results, @new_state.current_node
          assert_node_exists :results
        end
      end
    end
  end
end
