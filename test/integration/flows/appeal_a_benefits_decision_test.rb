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
  
  context "answer 'no' to 'already appealed the decision?'" do
    setup do
      add_response :no
    end
    
    #Q3
    should "ask 'date of decision letter?'" do
      assert_current_node :date_of_decision_letter?
    end
    
    context "answer 'greater than thirteen months ago' to 'date of decision letter?'" do
      should "say 'cant challenge or appeal'" do
        @decision_letter_date = Date.today << 14
        add_response @decision_letter_date
        assert_current_node :cant_challenge_or_appeal
      end
    end
    
    context "answer 'less than thirteen months from decision letter date' to 'date of decision letter?'" do
      
      # Q4
      should "ask 'had written explanation?'" do
        add_response Date.today << 12
        assert_current_node :had_written_explanation?
      end
      
      context "answer 'spoken explanation' to 'had written explanation?' when letter date was less than a month ago" do
        setup do
          add_response Date.today - 7
          add_response :spoken_explanation
        end
        # Q8
        should "ask 'have you been asked to reconsider?'" do
          assert_current_node :asked_to_reconsider?
        end
      end
      
      context "answer 'spoken explanation' to 'had written explanation?' when letter date was more than a month ago" do
        setup do
          add_response Date.today << 3
          add_response :spoken_explanation
        end
        # Q7
        should "ask 'special circumstances?'" do
          assert_current_node :special_circumstances?
        end
      end
      
    end
    
  end
  
end
