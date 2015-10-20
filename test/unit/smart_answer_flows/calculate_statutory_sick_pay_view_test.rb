require_relative '../../test_helper'

require 'smart_answer_flows/calculate-statutory-sick-pay'

module SmartAnswer
  class CalculateStatutorySickPayViewTest < ActiveSupport::TestCase
    setup do
      @flow = CalculateStatutorySickPayFlow.build
      @i18n_prefix = "flow.#{@flow.name}"
    end

    context 'when rendering linked_sickness_end_date? question' do
      setup do
        question = @flow.node(:linked_sickness_end_date?)
        @state = SmartAnswer::State.new(question)
        @presenter = QuestionPresenter.new(@i18n_prefix, question, @state)
      end

      should 'have a must_be_within_eight_weeks error message' do
        @state.error = 'must_be_within_eight_weeks'
        assert_equal "You need to enter a date within 8 weeks of the current period of sickness or it isn't a linked period of sickness.", @presenter.error
      end

      should 'have a must_be_before_first_sick_day error message' do
        @state.error = 'must_be_before_first_sick_day'
        assert_equal "You need to enter a date before the start of the current period of sickness or it isn't a separate linked period of sickness.", @presenter.error
      end

      should 'have a start_before_end error message' do
        @state.error = 'start_before_end'
        assert_equal 'End date should be on or after start date', @presenter.error
      end
    end
  end
end
