# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class AppealABenefitsDecisionTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'appeal-a-benefits-decision'
  end
  # Q1
  should "ask 'already appealed the decision?'" do
    assert_current_node :already_appealed_the_decision?
  end

  context "answer 'yes' to 'already appealed the decision?'" do
    setup do
      add_response :yes
    end
    #Q2
    should "ask 'problem with tribunal procedure?'" do
      assert_current_node :problem_with_tribunal_proceedure?
    end
    
    context "answer 'missing doc or not present' to 'problem with tribunal procedure?'" do
      should "say 'you can challenge decision'" do
        add_response :missing_doc_or_not_present
        assert_current_node :you_can_challenge_decision
      end
    end
    
    context "answer 'mistake in law' to 'problem with tribunal procedure?'" do
      should "say 'you can challenge decision'" do
        add_response :mistake_in_law
        assert_current_node :can_appeal_to_upper_tribunal
      end
    end
    
    context "answer 'none' to 'problem with tribunal procedure?'" do
      should "say 'cant challenge or appeal'" do
        add_response :none
        assert_current_node :cant_challenge_or_appeal
      end
    end
    
  end
  
end
