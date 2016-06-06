require_relative '../../test_helper'
require_relative 'flow_unit_test_helper'

require 'smart_answer_flows/estimate-self-assessment-penalties'

module SmartAnswer
  class EstimateSelfAssessmentPenaltiesFlowTest < ActiveSupport::TestCase
    include FlowUnitTestHelper

    setup do
      @calculator = Calculators::SelfAssessmentPenalties.new
      @flow = EstimateSelfAssessmentPenaltiesFlow.build
    end

    context 'when answering when_submitted? question' do
      setup do
        @calculator.stubs(:valid_filing_date?).returns(true)
        setup_states_for_question(:when_submitted?,
          responding_with: '2017-05-01',
          initial_state: { calculator: @calculator })
      end

      should 'store parsed response on calculator as filing_date' do
        assert_equal Date.parse('2017-05-01'), @calculator.filing_date
      end

      should 'go to when_paid? question' do
        assert_equal :when_paid?, @new_state.current_node
        assert_node_exists :when_paid?
      end

      context 'responding with an invalid response' do
        setup do
          @calculator.stubs(:valid_filing_date?).returns(false)
        end

        should 'raise an exception' do
          assert_raise(SmartAnswer::InvalidResponse) do
            setup_states_for_question(:when_submitted?,
              responding_with: '2017-05-01',
              initial_state: { calculator: @calculator })
          end
        end
      end
    end
  end
end
