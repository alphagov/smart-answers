require_relative '../../test_helper'
require_relative 'flow_unit_test_helper'

require 'smart_answer_flows/calculate-statutory-sick-pay'

module SmartAnswer
  class CalculateStatutorySickPayFlowTest < ActiveSupport::TestCase
    include FlowUnitTestHelper

    setup do
      @flow = CalculateStatutorySickPayFlow.build
    end

    context 'when answering linked_sickness_end_date? question' do
      context 'and linked sickness ends more than 8 weeks before sickness starts' do
        should 'raise an exception' do
          exception = assert_raise(SmartAnswer::InvalidResponse) do
            setup_states_for_question(:linked_sickness_end_date?,
              responding_with: '2015-01-07',
              initial_state: {
                sick_start_date: Date.parse('2015-04-01'),
                sick_start_date_for_awe: Date.parse('2015-01-01'),
                usual_work_days: '1,2,3,4,5'
              }
            )
          end
          assert_equal 'must_be_within_eight_weeks', exception.message
        end
      end

      context 'and linked sickness end 1 day before sickness starts' do
        should 'raise an exception' do
          exception = assert_raise(SmartAnswer::InvalidResponse) do
            setup_states_for_question(:linked_sickness_end_date?,
              responding_with: '2015-01-31',
              initial_state: {
                sick_start_date: Date.parse('2015-02-01'),
                sick_start_date_for_awe: Date.parse('2015-01-01'),
                usual_work_days: '1,2,3,4,5'
              }
            )
          end
          assert_equal 'must_be_at_least_1_day_before_first_sick_day', exception.message
        end
      end

      context 'and linked sickness ends before linked sickness starts' do
        should 'raise an exception' do
          exception = assert_raise(SmartAnswer::InvalidResponse) do
            setup_states_for_question(:linked_sickness_end_date?,
              responding_with: '2015-01-01',
              initial_state: {
                sick_start_date: Date.parse('2015-02-01'),
                sick_start_date_for_awe: Date.parse('2015-01-02'),
                usual_work_days: '1,2,3,4,5'
              }
            )
          end
          assert_equal 'start_before_end', exception.message
        end
      end
    end
  end
end
