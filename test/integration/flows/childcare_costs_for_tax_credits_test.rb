# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class ChildcareCostsForTaxCreditsTest < ActiveSupport::TestCase
  include FlowTestHelper
  
  setup do
    setup_for_testing_flow 'childcare-costs-for-tax-credits'
  end
  
  context "ask 'is the the first time you have claimed?'" do
    should "be true" do
      assert_current_node :first_time_claim?
    end
  end
  
end
