require_relative '../../test_helper'
require_relative 'flow_test_helper'

require "smart_answer_flows/calculate-your-part-year-profit"

class CalculateYourPartYearProfitTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::CalculateYourPartYearProfitFlow
  end

  context 'when the business is still trading' do
    setup do
      assert_current_node :when_did_your_tax_credits_award_end?
      add_response '2016-02-20'
      assert_current_node :what_date_do_your_accounts_go_up_to?
      add_response '0000-04-05'
      assert_current_node :have_you_stopped_trading?
      add_response 'no'
    end

    context 'and their accounts cover a 12 month period' do
      should 'reach the result outcome' do
        assert_current_node :do_your_accounts_cover_a_12_month_period?
        add_response 'yes'
        assert_current_node :what_is_your_taxable_profit?
        add_response '15000'
        assert_current_node :result
      end
    end

    context "but their accounts don't cover a 12 month period" do
      should 'reach the unsupported outcome' do
        assert_current_node :do_your_accounts_cover_a_12_month_period?
        add_response 'no'
        assert_current_node :unsupported
      end
    end
  end

  context "when the business has stopped trading" do
    setup do
      assert_current_node :when_did_your_tax_credits_award_end?
      add_response '2016-02-20'
      assert_current_node :what_date_do_your_accounts_go_up_to?
      add_response '0000-04-05'
      assert_current_node :have_you_stopped_trading?
      add_response 'yes'
    end

    context "and they started trading before the relevant accounting period started" do
      should 'reach the result outcome' do
        assert_current_node :did_you_start_trading_before_the_relevant_accounting_period?
        add_response 'yes'
        assert_current_node :when_did_you_stop_trading?
        add_response '2016-02-20'
        assert_current_node :what_is_your_taxable_profit?
        add_response '15000'
        assert_current_node :result
      end
    end

    context "and they started trading after the relevant accounting period started" do
      should "reach the unsupported outcome" do
        assert_current_node :did_you_start_trading_before_the_relevant_accounting_period?
        add_response 'no'
        assert_current_node :unsupported
      end
    end
  end
end
