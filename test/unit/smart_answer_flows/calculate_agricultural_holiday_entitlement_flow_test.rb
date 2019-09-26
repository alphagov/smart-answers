require_relative "../../test_helper"
require_relative "flow_unit_test_helper"

require "smart_answer_flows/calculate-agricultural-holiday-entitlement"

module SmartAnswer
  class CalculateAgriculturalHolidayEntitlementFlowTest < ActiveSupport::TestCase
    include FlowUnitTestHelper

    setup do
      @calculator = Calculators::AgriculturalHolidayEntitlementCalculator.new
      @flow = CalculateAgriculturalHolidayEntitlementFlow.build
    end

    context "when answering how_many_total_days? question" do
      setup do
        @calculator.stubs(:valid_total_days_worked?).returns(true)
        setup_states_for_question(:how_many_total_days?,
                                  responding_with: "50",
                                  initial_state: { calculator: @calculator })
      end

      should "store parsed response on calculator as total_days_worked" do
        assert_equal 50, @calculator.total_days_worked
      end

      should "go to worked_for_same_employer? question" do
        assert_equal :worked_for_same_employer?, @new_state.current_node
        assert_node_exists :worked_for_same_employer?
      end

      context "responding with an invalid response" do
        setup do
          @calculator.stubs(:valid_total_days_worked?).returns(false)
        end

        should "raise an exception" do
          assert_raise(SmartAnswer::InvalidResponse) do
            setup_states_for_question(:how_many_total_days?,
                                      responding_with: "500",
                                      initial_state: { calculator: @calculator })
          end
        end
      end
    end

    context "when answering how_many_weeks_at_current_employer? question" do
      setup do
        @calculator.stubs(:valid_weeks_at_current_employer?).returns(true)
        setup_states_for_question(:how_many_weeks_at_current_employer?,
                                  responding_with: "25",
                                  initial_state: { calculator: @calculator })
      end

      should "store parsed response on calculator as weeks_at_current_employer" do
        assert_equal 25, @calculator.weeks_at_current_employer
      end

      should "go to done_with_number_formatting outcomeuestion" do
        assert_equal :done_with_number_formatting, @new_state.current_node
        assert_node_exists :done_with_number_formatting
      end

      context "responding with an invalid response" do
        setup do
          @calculator.stubs(:valid_weeks_at_current_employer?).returns(false)
        end

        should "raise an exception" do
          assert_raise(SmartAnswer::InvalidResponse) do
            setup_states_for_question(:how_many_weeks_at_current_employer?,
                                      responding_with: "55",
                                      initial_state: { calculator: @calculator })
          end
        end
      end
    end
  end
end
