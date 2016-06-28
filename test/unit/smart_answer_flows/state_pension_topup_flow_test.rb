require_relative '../../test_helper'
require_relative 'flow_unit_test_helper'

require 'smart_answer_flows/state-pension-topup'

module SmartAnswer
  class StatePensionTopupFlowTest < ActiveSupport::TestCase
    include FlowUnitTestHelper

    setup do
      @calculator = Calculators::StatePensionTopupCalculator.new
      @flow = StatePensionTopupFlow.build
    end

    context 'when answering how_much_extra_per_week? question' do
      setup do
        @calculator.stubs(:valid_whole_number_weekly_amount?).returns(true)
        setup_states_for_question(:how_much_extra_per_week?,
          responding_with: '12',
          initial_state: { calculator: @calculator })
      end

      should 'store parsed response on calculator as weekly_amount' do
        assert_equal Money.new(12), @calculator.weekly_amount
      end

      should 'go to outcome_topup_calculations outcome' do
        assert_equal :outcome_topup_calculations, @new_state.current_node
        assert_node_exists :outcome_topup_calculations
      end

      context 'responding with an amount which is not a whole number' do
        setup do
          @calculator.stubs(:valid_whole_number_weekly_amount?).returns(false)
        end

        should 'raise an exception' do
          e = assert_raise(SmartAnswer::InvalidResponse) do
            setup_states_for_question(:how_much_extra_per_week?,
              responding_with: '12.5',
              initial_state: { calculator: @calculator })
          end
          assert_equal 'error_not_whole_number', e.message
        end
      end
    end
  end
end
