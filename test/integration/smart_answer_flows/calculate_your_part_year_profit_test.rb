require_relative '../../test_helper'
require_relative 'flow_test_helper'

require "smart_answer_flows/calculate-your-part-year-profit"

class CalculateYourPartYearProfitTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::CalculateYourPartYearProfitFlow
  end

  should 'reach the result outcome' do
    assert_current_node :when_did_your_tax_credits_award_end?
    add_response '2016-02-20'
    assert_current_node :what_date_do_your_accounts_go_up_to?
    add_response '0000-04-06'
    assert_current_node :do_your_accounts_cover_a_12_month_period?
    add_response 'yes'
    assert_current_node :what_is_your_taxable_profit?
    add_response '15000'
    assert_current_node :result
  end

  should 'reach the unsupported outcome' do
    assert_current_node :when_did_your_tax_credits_award_end?
    add_response '2016-02-20'
    assert_current_node :what_date_do_your_accounts_go_up_to?
    add_response '0000-04-06'
    assert_current_node :do_your_accounts_cover_a_12_month_period?
    add_response 'no'
    assert_current_node :unsupported
  end
end
