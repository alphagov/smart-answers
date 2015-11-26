require_relative '../../test_helper'

require 'smart_answer_flows/calculate-statutory-sick-pay'

module SmartAnswer
  class CalculateStatutorySickPayViewTest < ActiveSupport::TestCase
    setup do
      @flow = CalculateStatutorySickPayFlow.build
    end

    context 'when rendering linked_sickness_end_date? question' do
      setup do
        question = @flow.node(:linked_sickness_end_date?)
        @state = SmartAnswer::State.new(question)
        @presenter = QuestionPresenter.new(question, @state)
      end

      should 'have a must_be_within_eight_weeks error message' do
        @state.error = 'must_be_within_eight_weeks'
        assert_equal "You need to enter a date within 8 weeks of the current period of sickness or it isn't a linked period of sickness.", @presenter.error
      end

      should 'have a must_be_at_least_1_day_before_first_sick_day error message' do
        @state.error = 'must_be_at_least_1_day_before_first_sick_day'
        assert_equal "You need to enter a date at least 1 day before the start of the current period of sickness or it isn't a separate linked period of sickness.", @presenter.error
      end

      should 'have a start_before_end error message' do
        @state.error = 'must_be_valid_period_of_incapacity_for_work'
        assert_equal 'The linked period of sickness must be at least 4 calendar days long.', @presenter.error
      end
    end
  end
end
