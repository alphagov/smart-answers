# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class AppealABenefitsDecisionTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'appeal-a-benefits-decision'
  end
  
  should "ask 'already appealed the decision?'" do
    assert_current_node :already_appealed_the_decision?
  end

  context "answer 'yes' to 'already appealed the decision?'" do
    setup do
      add_response :yes
    end
    
    should "ask 'problem with tribunal procedure?'" do
      assert_current_node :problem_with_tribunal_proceedure?
    end
  end
  
end
