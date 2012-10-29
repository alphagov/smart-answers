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
        add_response 13.months.ago.to_date
        assert_current_node :cant_challenge_or_appeal
        assert_state_variable("appeal_expiry_date", nil)
      end
    end
    
    context "answer 'less than thirteen months from decision letter date' to 'date of decision letter?'" do
      
      # Q4
      should "ask 'had written explanation?'" do
        add_response 1.year.ago.to_date
        assert_current_node :had_written_explanation?
      end
      
      context "answer 'spoken explanation' to 'had written explanation?' when letter date was less than a month ago" do
        setup do
          add_response 7.days.ago.to_date
          add_response :spoken_explanation
        end
        # Q8
        should "ask 'have you been asked to reconsider?'" do
          assert_current_node :asked_to_reconsider?
        end
        
        should "calculate the appeal expiry date" do
          assert_state_variable("appeal_expiry_date", 1.month.since(7.days.ago.to_date))
        end
        
      end
      
      context "answer 'spoken explanation' to 'had written explanation?' when letter date was more than a month ago" do
        setup do
          add_response 3.months.ago.to_date # Decision letter received 3 months ago
          add_response :spoken_explanation
        end
        # Q7
        should "ask 'special circumstances?'" do
          assert_current_node :special_circumstances?
        end
        
      end
      
      context "answer 'no' to 'had written explanation?' when letter date was less than a month ago" do
        setup do
          add_response 7.days.ago.to_date
          add_response :no
        end
        # Q8
        should "say 'ask for an explanation / statement of reasons'" do
          assert_current_node :ask_for_an_explanation
        end
      end
      
      context "answer 'no' to 'had written explanation?' when letter date was more than a month ago" do
        setup do
          add_response 3.months.ago.to_date # date of decision letter, three months ago
          add_response :no
        end
        # Q7
        should "ask 'special circumstances?'" do
          assert_current_node :special_circumstances?
        end
      end
      
      # Various written explanation scenarios...
      #
      
      # 1. The written statement was received within a month of requesting it 
      #    and the decision letter was received less than 1 month and 14 days ago.
      #
      context "answer 'written statement' to 'had written explanation?'" do
        setup do
          add_response 1.month.ago.to_date # Date of decision letter, 1 month ago
          add_response :written_explanation
        end
        
        # Q5
        should "ask 'when did you ask for it?'" do
          assert_current_node :when_did_you_ask_for_it?
        end
        
        context "the statement was requested less than a month ago" do
          setup do
            add_response 21.days.ago # Statement requested 21 days ago
          end
          
          # Q6
          should "ask 'when did you get it?'" do
            assert_current_node :when_did_you_get_it?
          end
          
          context "the statement was received within one month and the decision letter was received less than one month and 14 days ago" do
            setup do
              add_response 7.days.ago # Statement received 7 days ago
            end
            
            # Q7
            should "ask 'asked to reconsider?'" do
              assert_current_node :asked_to_reconsider?
            end
            
            should "calculate the appeal expiry date" do
              assert_state_variable("appeal_expiry_date", 1.fortnight.since(1.month.since(1.month.ago.to_date)))
            end
          end
          
        end
      end

      # 2. The written statement was received within a month of requesting it 
      #    and the decision letter was received more than 1 month and 14 days ago.
      #    
      context "answer 'written statement' to 'had written explanation?'" do
        setup do
          add_response 3.months.ago # Date of decision letter, 3 months ago
          add_response :written_explanation
        end
        
        # Q5
        should "ask 'when did you ask for it?'" do
          assert_current_node :when_did_you_ask_for_it?
        end
        
        context "the statement was requested more than a month ago" do
          setup do
            add_response 21.days.ago(1.month.ago) # Statement requested a month and 21 days ago
          end
          
          # Q6
          should "ask 'when did you get it?'" do
            assert_current_node :when_did_you_get_it?
          end
          
          context "the statement was received after one month and 14 days have since passed" do
            setup do
              add_response 15.days.ago # Statement received 15 days ago
              assert_state_variable("appeal_expiry_date", nil)
            end
            
            # Q7
            should "ask 'special circumstances?'" do
              assert_current_node :special_circumstances?
            end
          end
          
        end
      end

      # 3. The written statement was received after a month from request date 
      #    but within the past 14 days.
      #      
      context "answer 'written statement' to 'had written explanation?'" do
        setup do
          add_response 3.months.ago # Date of decision letter, 3 months ago
          add_response :written_explanation
        end
        
        # Q5
        should "ask 'when did you ask for it?'" do
          assert_current_node :when_did_you_ask_for_it?
        end
        
        context "the statement was requested more than a month ago" do
          setup do
            add_response 21.days.ago(1.month.ago) # Statement requested a month and 21 days ago
          end
          
          # Q6
          should "ask 'when did you get it?'" do
            assert_current_node :when_did_you_get_it?
          end
          
          context "the statement was received after one month and 14 days have noy yet passed" do
            setup do
              add_response 7.days.ago # Statement received 7 days ago
            end
            
            # Q7
            should "ask 'asked to reconsider?'" do
              assert_current_node :asked_to_reconsider?
            end
            
            should "calculate the appeal expiry date" do
              assert_state_variable("appeal_expiry_date", 1.fortnight.since(7.days.ago).to_date)
            end
            
          end
          
        end
      end

      # 4. The written statement was received after a month from request date 
      #    and over 14 days ago.
      #       
      context "answer 'written statement' to 'had written explanation?'" do
        setup do
          add_response 2.months.ago # Date of decision letter, 2 months ago
          add_response :written_explanation
        end
        
        # Q5
        should "ask 'when did you ask for it?'" do
          assert_current_node :when_did_you_ask_for_it?
        end
        
        context "the statement was requested more than a month ago" do
          setup do
            add_response 21.days.ago(1.month.ago) # Statement requested one month and 21 days ago
          end
          
          # Q6
          should "ask 'when did you get it?'" do
            assert_current_node :when_did_you_get_it?
          end
          
          context "the statement was received within one month and the decision letter was received more than one month and 14 days ago" do
            setup do
              add_response 15.days.ago(1.month.ago) # Statement received one month and 15 days ago (received within a month)
            end
            
            # Q7
            should "ask 'special circumstances?'" do
              assert_current_node :special_circumstances?
            end
            
            context "answer 'no' to 'special circumstances?'" do
              should "say 'cant appeal'" do
                add_response :no
                assert_current_node :cant_appeal
              end
            end
            
            context "answer 'yes' to 'special circumstances?'" do
              setup do
                add_response :yes
              end
              
              # Q8
              should "ask 'asked to reconsider?'" do
                assert_current_node :asked_to_reconsider?
              end
              
              context "answer 'no' to 'asked to reconsider?'" do
                should "" do
                  add_response :no
                  assert_current_node :ask_to_reconsider
                end
              end
              
              context "answer 'yes' to 'asked to reconsider?'" do
                setup do
                  add_response :yes
                end
                
                # Q9
                should "ask 'kind of benefit or credit?'" do
                  assert_current_node :kind_of_benefit_or_credit?
                end
                
                context "answer 'budgeting loan' to 'kind of benefit or credit?'" do
                  should "say 'apply to the independent service review'" do
                    add_response :budgeting_loan
                    assert_current_node :apply_to_the_independent_review_service
                  end
                end
                
                context "answer 'housing benefit' to 'kind of benefit or credit?'" do
                  should "say 'appeal to your council'" do
                    add_response :housing_benefit
                    assert_current_node :appeal_to_your_council
                  end
                end
                
                context "answer 'tax credits' to 'kind of benefit or credit?'" do
                  should "say 'appeal to HMRC leaflet WTC/AP'" do
                    add_response :tax_credits
                    assert_current_node :appeal_to_hmrc_wtc
                  end
                end
                
                context "answer 'child benefit' to 'kind of benefit or credit?'" do
                  should "say 'appeal to HMRC leaflet CH24A'" do
                    add_response :child_benefit
                    assert_current_node :appeal_to_hmrc_ch24a
                  end
                end
                
                context "answer 'any other credit or benefit' to 'kind of benefit or credit?'" do
                  should "say 'appeal to the social security'" do
                    add_response :other_credit_or_benefit
                    assert_current_node :appeal_to_social_security
                  end
        
                end
                
              end
              
            end
            
          end
          
        end
        
      end
      
    end
    
  end
  
end
