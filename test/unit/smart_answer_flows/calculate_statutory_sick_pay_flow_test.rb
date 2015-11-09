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
                calculator: stub('calculator',
                  linked_sickness_start_date: Date.parse('2015-01-01'),
                  days_of_the_week_worked: %w(1 2 3 4 5),
                  within_eight_weeks_of_current_sickness_period?: false,
                  at_least_1_day_before_first_sick_day?: true,
                  valid_linked_period_of_incapacity_for_work?: true
                ),
              })
          end
          assert_equal 'must_be_within_eight_weeks', exception.message
        end
      end

      context 'and linked sickness ends the day before sickness starts' do
        should 'raise an exception' do
          exception = assert_raise(SmartAnswer::InvalidResponse) do
            setup_states_for_question(:linked_sickness_end_date?,
              responding_with: '2015-01-31',
              initial_state: {
                calculator: stub('calculator',
                  linked_sickness_start_date: Date.parse('2015-01-01'),
                  days_of_the_week_worked: %w(1 2 3 4 5),
                  within_eight_weeks_of_current_sickness_period?: true,
                  at_least_1_day_before_first_sick_day?: false,
                  valid_linked_period_of_incapacity_for_work?: true
                ),
              })
          end
          assert_equal 'must_be_at_least_1_day_before_first_sick_day', exception.message
        end
      end

      context 'and linked sickness period is less than 4 calendar days long' do
        should 'raise an exception' do
          exception = assert_raise(SmartAnswer::InvalidResponse) do
            setup_states_for_question(:linked_sickness_end_date?,
              responding_with: '2015-01-03',
              initial_state: {
                calculator: stub('calculator',
                  sick_start_date: Date.parse('2015-02-01'),
                  linked_sickness_start_date: Date.parse('2015-01-01'),
                  days_of_the_week_worked: %w(1 2 3 4 5),
                  within_eight_weeks_of_current_sickness_period?: true,
                  at_least_1_day_before_first_sick_day?: true,
                  valid_linked_period_of_incapacity_for_work?: false
                ),
              })
          end
          assert_equal 'must_be_valid_period_of_incapacity_for_work', exception.message
        end
      end
    end
  end
end
