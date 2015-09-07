require_relative '../../test_helper'

require 'smart_answer_flows/calculate-your-part-year-profit'

module SmartAnswer
  class CalculateYourPartYearProfitFlowTest < ActiveSupport::TestCase
    setup do
      @calculator = Calculators::PartYearProfitCalculator.new
      @flow = CalculateYourPartYearProfitFlow.build
    end

    should 'start when_did_your_tax_credits_award_end? question' do
      assert_equal :when_did_your_tax_credits_award_end?, @flow.start_state.current_node
    end

    context 'when answering when_did_your_tax_credits_award_end? question' do
      setup do
        Calculators::PartYearProfitCalculator.stubs(:new).returns(@calculator)
        setup_states_for_question(:when_did_your_tax_credits_award_end?, responding_with: '2016-02-20')
      end

      should 'instantiate and store calculator' do
        assert_same @calculator, @new_state.calculator
      end

      should 'store parsed response on calculator as tax_credits_award_ends_on' do
        assert_equal Date.parse('2016-02-20'), @calculator.tax_credits_award_ends_on
      end

      should 'go to what_date_do_your_accounts_go_up_to? question' do
        assert_equal :what_date_do_your_accounts_go_up_to?, @new_state.current_node
        assert_node_exists :what_date_do_your_accounts_go_up_to?
      end
    end

    context 'when answering what_date_do_your_accounts_go_up_to? question' do
      setup do
        setup_states_for_question(:what_date_do_your_accounts_go_up_to?, responding_with: '0000-04-06', calculator: @calculator)
      end

      should 'store parsed response on calculator as accounts_end_month_and_day' do
        assert_equal Date.parse('0000-04-06'), @calculator.accounts_end_month_and_day
      end

      should 'go to have_you_stopped_trading? question' do
        assert_equal :have_you_stopped_trading?, @new_state.current_node
        assert_node_exists :have_you_stopped_trading?
      end
    end

    context 'when answering have_you_stopped_trading? question' do
      context 'responding with yes' do
        setup do
          setup_states_for_question(:have_you_stopped_trading?, responding_with: 'yes', calculator: @calculator)
        end

        should 'set stopped_trading to true on the calculator' do
          assert_equal true, @calculator.stopped_trading
        end

        should 'go to did_you_start_trading_before_the_relevant_accounting_period? question' do
          assert_equal :did_you_start_trading_before_the_relevant_accounting_period?, @new_state.current_node
          assert_node_exists :did_you_start_trading_before_the_relevant_accounting_period?
        end
      end

      context 'responding with no' do
        setup do
          setup_states_for_question(:have_you_stopped_trading?, responding_with: 'no', calculator: @calculator)
        end

        should 'set stopped_trading to false on the calculator' do
          assert_equal false, @calculator.stopped_trading
        end

        should 'go to do_your_accounts_cover_a_12_month_period? question' do
          assert_equal :do_your_accounts_cover_a_12_month_period?, @new_state.current_node
          assert_node_exists :do_your_accounts_cover_a_12_month_period?
        end
      end
    end

    context 'when answering did_you_start_trading_before_the_relevant_accounting_period? question' do
      setup do
        accounting_period = YearRange.new(begins_on: Date.parse('2015-04-06'))
        @calculator.stubs(accounting_period: accounting_period)
        setup_states_for_question(:did_you_start_trading_before_the_relevant_accounting_period?, responding_with: 'yes', calculator: @calculator)
      end

      should 'make accounting_period_begins_on available for interpolation in question title' do
        assert_equal Date.parse('2015-04-06'), @precalculated_state.accounting_period_begins_on
      end

      context 'responding with yes' do
        setup do
          setup_states_for_question(:did_you_start_trading_before_the_relevant_accounting_period?, responding_with: 'yes', calculator: @calculator)
        end

        should 'go to when_did_you_stop_trading? question' do
          assert_equal :when_did_you_stop_trading?, @new_state.current_node
          assert_node_exists :when_did_you_stop_trading?
        end
      end

      context 'responding with no' do
        setup do
          setup_states_for_question(:did_you_start_trading_before_the_relevant_accounting_period?, responding_with: 'no', calculator: @calculator)
        end

        should 'go to when_did_you_start_trading question' do
          assert_equal :when_did_you_start_trading?, @new_state.current_node
          assert_node_exists :when_did_you_start_trading?
        end
      end
    end

    context 'when answering when_did_you_start_trading? question' do
      setup do
        tax_credits_part_year = DateRange.new(
          begins_on: Date.parse('2015-04-06'),
          ends_on:   Date.parse('2015-08-01')
        )
        @calculator.stubs(:tax_credits_part_year).returns(tax_credits_part_year)
        setup_states_for_question(:when_did_you_start_trading?, responding_with: '2015-02-01', calculator: @calculator)
      end

      should 'set the from date of the date select to 2 years ago from now' do
        assert_equal Date.today.year - 2, @question.range.begin.year
      end

      should 'set the to date of the date select to 4 years from now' do
        assert_equal Date.today.year + 4, @question.range.end.year
      end

      should 'make tax_credits_part_year_ends_on available' do
        assert_equal Date.parse('2015-08-01'), @new_state.tax_credits_part_year_ends_on
      end

      should 'store parsed response on calculator as started_trading_on' do
        assert_equal Date.parse('2015-02-01'), @calculator.started_trading_on
      end

      context 'responding with an invalid start trading date' do
        setup do
          @calculator.stubs(:valid_start_trading_date?).returns(false)
        end

        should 'raise an exception' do
          exception = assert_raise(SmartAnswer::InvalidResponse) do
            setup_states_for_question(:when_did_you_start_trading?, responding_with: '0000-01-01', calculator: @calculator)
          end
          assert_equal 'invalid_start_trading_date', exception.message
        end
      end

      context 'and the business has stopped trading' do
        setup do
          @calculator.stopped_trading = true
          setup_states_for_question(:when_did_you_start_trading?, responding_with: '0000-01-01', calculator: @calculator)
        end

        should 'go to when_did_you_stop_trading? question' do
          assert_equal :when_did_you_stop_trading?, @new_state.current_node
          assert_node_exists :when_did_you_stop_trading?
        end
      end

      context 'and the business is still trading' do
        setup do
          @calculator.stopped_trading = false
          setup_states_for_question(:when_did_you_start_trading?, responding_with: '0000-01-01', calculator: @calculator)
        end

        should 'go to when_did_you_stop_trading? question' do
          assert_equal :what_is_your_taxable_profit?, @new_state.current_node
          assert_node_exists :what_is_your_taxable_profit?
        end
      end
    end

    context 'when answering when_did_you_stop_trading? question' do
      setup do
        tax_year = TaxYear.new(begins_in: 2015)
        @calculator.stubs(tax_year: tax_year)
        setup_states_for_question(:when_did_you_stop_trading?, responding_with: '2015-06-01', calculator: @calculator)
      end

      should 'set the from date of the date select to 2 years ago from now' do
        assert_equal Date.today.year - 2, @question.range.begin.year
      end

      should 'set the to date of the date select to 4 years from now' do
        assert_equal Date.today.year + 4, @question.range.end.year
      end

      should 'make tax_year_begins_on available for interpolation in question title' do
        assert_equal Date.parse('2015-04-06'), @precalculated_state.tax_year_begins_on
      end

      should 'make tax_year_ends_on available for interpolation in question title' do
        assert_equal Date.parse('2016-04-05'), @precalculated_state.tax_year_ends_on
      end

      should 'store parsed response on calculator as stopped_trading_on' do
        assert_equal Date.parse('2015-06-01'), @calculator.stopped_trading_on
      end

      should 'go to what_is_your_taxable_profit? question' do
        assert_equal :what_is_your_taxable_profit?, @new_state.current_node
        assert_node_exists :what_is_your_taxable_profit?
      end

      context 'responding with an invalid stopped trading date' do
        setup do
          @calculator.stubs(:valid_stopped_trading_date?).returns(false)
        end

        should 'raise an exception' do
          exception = assert_raise(SmartAnswer::InvalidResponse) do
            setup_states_for_question(:when_did_you_stop_trading?, responding_with: '0000-01-01', calculator: @calculator)
          end
          assert_equal 'not_in_tax_year_error', exception.message
        end
      end
    end

    context 'when answering do_your_accounts_cover_a_12_month_period? question' do
      context 'responding with yes' do
        setup do
          setup_states_for_question(:do_your_accounts_cover_a_12_month_period?, responding_with: 'yes', calculator: @calculator)
        end

        should 'go to what_is_your_taxable_profit? question' do
          assert_equal :what_is_your_taxable_profit?, @new_state.current_node
          assert_node_exists :what_is_your_taxable_profit?
        end
      end

      context 'responding with no' do
        setup do
          setup_states_for_question(:do_your_accounts_cover_a_12_month_period?, responding_with: 'no', calculator: @calculator)
        end

        should 'go to when_did_you_start_trading question' do
          assert_equal :when_did_you_start_trading?, @new_state.current_node
          assert_node_exists :when_did_you_start_trading?
        end
      end
    end

    context 'when answering what_is_your_taxable_profit? question' do
      setup do
        basis_period = YearRange.new(begins_on: Date.parse('2015-04-06'))
        @calculator.stubs(basis_period: basis_period)
        setup_states_for_question(:what_is_your_taxable_profit?, responding_with: '15000', calculator: @calculator)
      end

      should 'make basis_period_begins_on available for interpolation in question title' do
        assert_equal Date.parse('2015-04-06'), @precalculated_state.basis_period_begins_on
      end

      should 'make basis_period_ends_on available for interpolation in question title' do
        assert_equal Date.parse('2016-04-05'), @precalculated_state.basis_period_ends_on
      end

      should 'store parsed response on calculator as taxable_profit' do
        assert_equal Money.new(15000), @calculator.taxable_profit
      end

      should 'go to result outcome' do
        assert_equal :result, @new_state.current_node
        assert_node_exists :result
      end
    end

    def setup_states_for_question(key, responding_with:, **initial_state)
      @question = @flow.node(key)
      @state = SmartAnswer::State.new(@question)
      initial_state.each do |variable, value|
        @state.send("#{variable}=", value)
      end
      @precalculated_state = @question.evaluate_precalculations(@state)
      @new_state = @question.transition(@precalculated_state, responding_with)
    end

    def assert_node_exists(key)
      assert @flow.node_exists?(key), "Node #{key} does not exist."
    end
  end
end
