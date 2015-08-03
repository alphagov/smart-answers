require_relative '../../test_helper'
require_relative 'flow_test_helper'

require "smart_answer_flows/calculate-your-part-year-profit"

class CalculateYourPartYearProfitTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::CalculateYourPartYearProfitFlow
  end

  should 'reach the outcome' do
    assert_current_node :when_did_your_tax_credits_award_end?
    add_response '2016-02-20'
    assert_current_node :when_do_your_business_accounts_start?
    add_response '2015-04-06'
    assert_current_node :what_is_your_taxable_profit?
    add_response '15000'
    assert_current_node :outcome
  end
end
