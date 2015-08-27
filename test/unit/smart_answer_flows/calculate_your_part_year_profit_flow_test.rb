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

      should 'go to do_your_accounts_cover_a_12_month_period? question' do
        assert_equal :do_your_accounts_cover_a_12_month_period?, @new_state.current_node
        assert_node_exists :do_your_accounts_cover_a_12_month_period?
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

        should 'go to unsupported outcome' do
          assert_equal :unsupported, @new_state.current_node
          assert_node_exists :unsupported
        end
      end
    end

    context 'when answering what_is_your_taxable_profit? question' do
      setup do
        accounting_period = YearRange.new(begins_on: Date.parse('2015-04-06'))
        @calculator.stubs(accounting_period: accounting_period)
        setup_states_for_question(:what_is_your_taxable_profit?, responding_with: '15000', calculator: @calculator)
      end

      should 'make accounts_begin_on available for interpolation in question title' do
        assert_equal Date.parse('2015-04-06'), @precalculated_state.accounts_begin_on
      end

      should 'make accounts_end_on available for interpolation in question title' do
        assert_equal Date.parse('2016-04-05'), @precalculated_state.accounts_end_on
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
      question = @flow.node(key)
      state = SmartAnswer::State.new(question)
      initial_state.each do |variable, value|
        state.send("#{variable}=", value)
      end
      @precalculated_state = question.evaluate_precalculations(state)
      @new_state = question.transition(@precalculated_state, responding_with)
    end

    def assert_node_exists(key)
      assert @flow.node_exists?(key), "Node #{key} does not exist."
    end
  end
end
