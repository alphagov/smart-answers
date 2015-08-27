require_relative '../../test_helper'

require 'smart_answer_flows/calculate-your-part-year-profit'

module SmartAnswer
  class CalculateYourPartYearProfitViewTest < ActiveSupport::TestCase
    setup do
      @flow = CalculateYourPartYearProfitFlow.build
      @i18n_prefix = "flow.#{@flow.name}"
    end

    context 'when rendering what_is_your_taxable_profit? question' do
      setup do
        question = @flow.node(:what_is_your_taxable_profit?)
        state = SmartAnswer::State.new(question)
        state.accounts_begin_on = Date.parse('2015-04-06')
        state.accounts_end_on = Date.parse('2016-04-05')
        presenter = QuestionPresenter.new(@i18n_prefix, question, state)
        @title = presenter.title
      end

      should 'display title with interpolated accounts_begin_on and accounts_end_on' do
        expected = "What is your actual or estimated taxable profit between  6 April 2015 and  5 April 2016?"
        assert_equal expected, @title
      end
    end

    context 'when rendering the result outcome' do
      setup do
        outcome = @flow.node(:result)
        calculator_options = {
          tax_credits_award_ends_on: Date.parse('2016-02-20'),
          accounting_period: YearRange.new(begins_on: Date.parse('2015-04-06')),
          taxable_profit: Money.new(15000),
          part_year_taxable_profit: Money.new(13154)
        }
        calculator = stub('calculator', calculator_options)
        calculator.responds_like_instance_of(Calculators::PartYearProfitCalculator)
        state = SmartAnswer::State.new(outcome)
        state.calculator = calculator
        presenter = OutcomePresenter.new('i18n-prefix', outcome, state)
        @body = presenter.body(html: false)
      end

      should 'display part_year_taxable_profit' do
        assert_match 'Your part-year taxable profit is £13,154', @body
      end

      should 'display tax_credits_award_ends_on' do
        assert_match 'Your tax credits award ended on: 20 February 2016', @body
      end

      should 'display accounts_end_on' do
        assert_match 'Your business accounts end on:  5 April 2016', @body
      end

      should 'display taxable_profit' do
        assert_match 'Your estimated taxable profit between  6 April 2015 and  5 April 2016 was: £15,000', @body
      end
    end
  end
end
