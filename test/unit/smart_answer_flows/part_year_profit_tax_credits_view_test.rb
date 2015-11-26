require_relative '../../test_helper'

require 'smart_answer_flows/part-year-profit-tax-credits'

module SmartAnswer
  class PartYearProfitTaxCreditsViewTest < ActiveSupport::TestCase
    setup do
      @flow = PartYearProfitTaxCreditsFlow.build
      @i18n_prefix = "flow.#{@flow.name}"
    end

    context 'when rendering when_did_your_tax_credits_award_end? question' do
      setup do
        question = @flow.node(:when_did_your_tax_credits_award_end?)
        @state = SmartAnswer::State.new(question)
        @presenter = QuestionPresenter.new(question, @state)
      end

      should 'have a default error message' do
        @state.error = 'error-message'
        assert_equal 'You need to enter a date to continue.', @presenter.error
      end
    end

    context 'when rendering what_date_do_your_accounts_go_up_to? question' do
      setup do
        question = @flow.node(:what_date_do_your_accounts_go_up_to?)
        @state = SmartAnswer::State.new(question)
        @presenter = QuestionPresenter.new(question, @state)
      end

      should 'have a default error message' do
        @state.error = 'error-message'
        assert_equal 'You need to enter a date to continue.', @presenter.error
      end
    end

    context 'when rendering have_you_stopped_trading? question' do
      setup do
        question = @flow.node(:have_you_stopped_trading?)
        @state = SmartAnswer::State.new(question)
        @presenter = QuestionPresenter.new(question, @state)
      end

      should 'have options with labels' do
        assert_equal({ 'yes' => 'Yes', 'no' => 'No' }, values_vs_labels(@presenter.options))
      end

      should 'have a default error message' do
        @state.error = 'error-message'
        assert_equal 'You need to select yes or no to continue.', @presenter.error
      end
    end

    context 'when rendering do_your_accounts_cover_a_12_month_period? question' do
      setup do
        question = @flow.node(:do_your_accounts_cover_a_12_month_period?)
        @state = SmartAnswer::State.new(question)
        @state.accounting_year_ends_on = Date.parse('2016-04-05')
        @presenter = QuestionPresenter.new(question, @state)
      end

      should 'display title with interpolated basis_period_ends_on' do
        expected = "Do your accounts cover the 12 month period up to  5 April 2016?"
        assert_equal expected, @presenter.title
      end

      should 'have options with labels' do
        assert_equal({ 'yes' => 'Yes', 'no' => 'No' }, values_vs_labels(@presenter.options))
      end

      should 'have a default error message' do
        @state.error = 'error-message'
        assert_equal 'You need to select yes or no to continue.', @presenter.error
      end
    end

    context 'when rendering what_is_your_taxable_profit? question' do
      setup do
        question = @flow.node(:what_is_your_taxable_profit?)
        @state = SmartAnswer::State.new(question)
        @state.basis_period_begins_on = Date.parse('2015-04-06')
        @state.basis_period_ends_on = Date.parse('2016-04-05')
        @presenter = QuestionPresenter.new(question, @state)
      end

      should 'display title with interpolated basis_period_begins_on and basis_period_ends_on' do
        expected = "What is your actual or estimated taxable profit between  6 April 2015 and  5 April 2016?"
        assert_equal expected, @presenter.title
      end

      should 'have a default error message' do
        @state.error = 'error-message'
        assert_equal 'Enter your taxable profit.', @presenter.error
      end
    end

    context 'when rendering did_you_start_trading_before_the_relevant_accounting_year? question' do
      setup do
        question = @flow.node(:did_you_start_trading_before_the_relevant_accounting_year?)
        @state = SmartAnswer::State.new(question)
        @state.accounting_year_begins_on = Date.parse('2015-04-06')
        @presenter = QuestionPresenter.new(question, @state)
      end

      should 'have options with labels' do
        assert_equal({ 'yes' => 'Yes', 'no' => 'No' }, values_vs_labels(@presenter.options))
      end

      should 'have a default error message' do
        @state.error = 'error-message'
        assert_equal 'You need to select yes or no to continue.', @presenter.error
      end

      should 'display title with interpolated accounting_year_begins_on' do
        expected = "Did you start trading before  6 April 2015?"
        assert_equal expected, @presenter.title
      end
    end

    context 'when rendering when_did_you_stop_trading? question' do
      setup do
        question = @flow.node(:when_did_you_stop_trading?)
        @state = SmartAnswer::State.new(question)
        @state.tax_year_begins_on = Date.parse('2015-04-06')
        @state.tax_year_ends_on = Date.parse('2016-04-05')
        @presenter = QuestionPresenter.new(question, @state)
      end

      should 'display hint with interpolated tax_year_begins_on and tax_year_ends_on' do
        expected = "This date must be between  6 April 2015 and  5 April 2016"
        assert_match expected, @presenter.hint
      end

      should 'have a default error message' do
        @state.error = 'error-message'
        assert_equal 'You need to enter a date to continue.', @presenter.error
      end

      should 'display a useful error message when an invalid date is entered' do
        @state.error = 'not_in_tax_year_error'
        expected = "The date must be between  6 April 2015 and  5 April 2016."
        assert_equal expected, @presenter.error
      end
    end

    context 'when rendering when_did_you_start_trading? question' do
      setup do
        question = @flow.node(:when_did_you_start_trading?)
        @state = SmartAnswer::State.new(question)
        @state.award_period_ends_on = Date.parse('2015-08-01')
        @presenter = QuestionPresenter.new(question, @state)
      end

      should 'display hint with interpolated award_period_ends_on' do
        expected = "This date must be before  1 August 2015."
        assert_equal expected, @presenter.hint
      end

      should 'have a default error message' do
        @state.error = 'error-message'
        assert_equal 'You need to enter a date to continue.', @presenter.error
      end
    end

    context 'when rendering the result outcome' do
      setup do
        @outcome = @flow.node(:result)
        calculator_options = {
          tax_credits_award_ends_on: Date.parse('2016-02-20'),
          basis_period: YearRange.new(begins_on: Date.parse('2015-04-06')),
          taxable_profit: Money.new(15000),
          award_period_taxable_profit: Money.new(13154),
          stopped_trading_on: nil
        }
        @calculator = stub('calculator', calculator_options)
        @calculator.responds_like_instance_of(Calculators::PartYearProfitTaxCreditsCalculator)
        @state = SmartAnswer::State.new(@outcome)
        @state.calculator = @calculator
      end

      context 'common output' do
        setup do
          presenter = OutcomePresenter.new(@outcome, @state)
          @body = presenter.body(html: false)
        end

        should 'display award_period_taxable_profit' do
          assert_match 'Your part-year taxable profit is £13,154', @body
        end

        should 'display tax_credits_award_ends_on' do
          assert_match 'Your tax credits award ended on: 20 February 2016', @body
        end

        should 'display taxable_profit' do
          assert_match 'Your estimated taxable profit between  6 April 2015 and  5 April 2016 was: £15,000', @body
        end
      end

      context 'and the stopped_trading_on date is not set' do
        setup do
          @calculator.stubs(stopped_trading_on: nil)
          presenter = OutcomePresenter.new(@outcome, @state)
          @body = presenter.body(html: false)
        end

        should 'display basis_period ends_on' do
          assert_match 'Your business accounts end on:  5 April 2016', @body
        end
      end

      context 'and the stopped_trading_on date is set' do
        setup do
          @calculator.stubs(stopped_trading_on: Date.parse('2016-04-05'))
          presenter = OutcomePresenter.new(@outcome, @state)
          @body = presenter.body(html: false)
        end

        should 'display the date the business stopped trading' do
          assert_match 'Your business stopped trading on:  5 April 2016', @body
        end
      end
    end

    private

    def values_vs_labels(options)
      options.inject({}) { |h, o| h[o.value] = o.label; h }
    end
  end
end
