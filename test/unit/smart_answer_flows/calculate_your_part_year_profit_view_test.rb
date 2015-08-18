require_relative '../../test_helper'

require 'smart_answer_flows/calculate-your-part-year-profit'

module SmartAnswer
  class CalculateYourPartYearProfitFlowTest < ActiveSupport::TestCase
    setup do
      @flow = CalculateYourPartYearProfitFlow.build(@calculator)
      @i18n_prefix = "flow.#{@flow.name}"
    end

    context 'when rendering what_is_your_taxable_profit? question' do
      setup do
        question = @flow.node(:what_is_your_taxable_profit?)
        state = SmartAnswer::State.new(question)
        state.from_date = Date.parse('2015-04-06')
        state.to_date = Date.parse('2016-04-05')
        presenter = QuestionPresenter.new(@i18n_prefix, question, state)
        @title = presenter.title
      end

      should 'display title with interpolated from_date & to_date' do
        assert_equal "What is your actual or estimated taxable profit between  6 April 2015 and  5 April 2016?", @title
      end
    end

    context 'when rendering the outcome' do
      setup do
        outcome = @flow.node(:outcome)
        state = SmartAnswer::State.new(outcome)
        state.calculator = stub('calculator',
          part_year_profit: 13154,
          basis_period: DateRange.new(begins_on: Date.parse('2015-04-06'), duration: 1.year),
          tax_credits_awarded_on: Date.parse('2016-02-20'),
          accounts_start_on: Date.parse('2015-04-06'),
          profit_for_current_period: 15000
        ).responds_like_instance_of(Calculators::PartYearProfitCalculator)
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state)
        @body = presenter.body(html: false)
      end

      should 'display part_year_profit' do
        assert_match 'Your part-year taxable profit is £13,154.', @body
      end

      should 'display tax_credits_awarded_on' do
        assert_match 'Your tax credits award ended on: 20 February 2016', @body
      end

      should 'display accounts_start_on' do
        assert_match 'Your business accounts started on:  6 April 2015', @body
      end

      should 'display profit_for_current_period' do
        assert_match 'Your estimated taxable profit between  6 April 2015 and  5 April 2016 was: £15,000', @body
      end
    end
  end
end
