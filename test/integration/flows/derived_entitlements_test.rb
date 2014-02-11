# encoding: UTF-8

#??????
require_relative '../../test_helper'
#??????
require_relative 'flow_test_helper'
#??????
require 'gds_api/test_helpers/worldwide'

#??????
class DerivedEntitlementsTest < ActiveSupport::TestCase
  include FlowTestHelper
  # include GdsApi::TestHelpers::Worldwide


  setup do
    setup_for_testing_flow 'derived-entitlements'
  end

  context "old1 - married" do
    setup { add_response "married" }
    should "ask when will reach pension age" do
      assert_current_node :when_will_you_reach_pension_age?
    end

    context "old2 - before specific date" do
      setup { add_response "your_pension_age_before_specific_date" }
      should "ask when partner will reach pension age" do
        assert_current_node :when_will_your_partner_reach_pension_age?
      end

      # WORKING 
      context "old3 - before specific date" do
        setup { add_response "partner_pension_age_before_specific_date" }
        should "give outcome 1" do
          assert_current_node :outcome_1
          # assert_phrase_list :result, [:phrase1]
        end
      end
    end
  end #end married before before
  
  context "widow" do
    setup { add_response "widowed" }
    should "ask when will reach pension age" do
      assert_current_node :when_will_you_reach_pension_age?
    end

    context "new2 - after specific date" do
      setup { add_response "your_pension_age_after_specific_date" }
      should "ask when partner will reach pension age" do
        assert_current_node :when_will_your_partner_reach_pension_age?
      end

      #WORKING 
      # context "old3 - before specific date" do
      #   setup { add_response "partner_pension_age_before_specific_date" }
      #   should "give outcome 1" do
      #     assert_current_node :outcome_1
      #     # assert_phrase_list :result, [:phrase1]
      #   end
      # end
      # WORKING 
      context "new3 - after specific date" do
        setup { add_response "partner_pension_age_after_specific_date" }
        should "go to question gender" do
          assert_current_node :what_is_your_gender?
          # assert_phrase_list :result, [:phrase1]
        end
        
        context "male" do
          setup { add_response "male_gender"}
          should "go to outcome 1 with phraselist 7" do
            assert_current_node :outcome_1
            assert_phrase_list :result, [:phrase7]
          end
        end
      end
    end
  end #end married before before
  
  #   context "married" do
  #   setup { add_response "married" }
    
  #   should "ask when will reach pension age" do
  #     assert_current_node :when_will_you_reach_pension_age?
  #   end

  #   context "before specific date" do
  #     setup { add_response "your_pension_age_before_specific_date" }
      
  #     should "ask when partner will reach pension age" do
  #       assert_current_node :when_will_your_partner_reach_pension_age?
  #     end

  #     context "after specific date" do
  #       setup { add_response "partner_pension_age_after_specific_date" }
  #       should "give outcome 3" do
          
  #         assert_current_node :outcome_3
  #       end
  #     end
  #   end
  # end #end married before after
  
  # context "widowed" do
  #   setup { add_response "widowed" }
    
  #   should "ask when will reach pension age" do
  #     assert_current_node :when_will_you_reach_pension_age?
  #   end

  #   context "before specific date" do
  #     setup { add_response "your_pension_age_before_specific_date" }
      
  #     should "ask when partner will reach pension age" do
  #       assert_current_node :when_will_your_partner_reach_pension_age?
  #     end

  #     context "before specific date" do
  #       setup { add_response "partner_pension_age_before_specific_date" }
  #       should "give outcome 2" do
  #         assert_current_node :outcome_2
  #       end
  #     end
  #   end
  # end #end widowed before after
  # context "widowed" do
  #   setup { add_response "widowed" }
    
  #   should "ask when will reach pension age" do
  #     assert_current_node :when_will_you_reach_pension_age?
  #   end

  #   context "before specific date" do
  #     setup { add_response "your_pension_age_before_specific_date" }
      
  #     should "ask when partner will reach pension age" do
  #       assert_current_node :when_will_your_partner_reach_pension_age?
  #     end

  #     context "after specific date" do
  #       setup { add_response "partner_pension_age_after_specific_date" }
  #       should "give outcome 4" do
  #         assert_current_node :outcome_4
  #       end
  #     end
  #   end
  # end #end widowed before after
  

  
  # context "will marry before certain date" do
  #   setup { add_response "will_marry_before_specific_date" }
    
  #   should "ask when will reach pension age" do
  #     assert_current_node :when_will_you_reach_pension_age?
  #   end

  #   context "before specific date" do
  #     setup { add_response "your_pension_age_before_specific_date" }
      
  #     should "ask when partner will reach pension age" do
  #       assert_current_node :when_will_your_partner_reach_pension_age?
  #     end

  #     context "before specific date" do
  #       setup { add_response "partner_pension_age_before_specific_date" }

  #       should "give outcome 1" do
  #         assert_current_node :outcome_1
  #         # assert_phrase_list :next_step_links, [:wills_link]
  #       end
  #     end
  #   end
  # end #end will marry before certain date context
  
  # context "will marry on or after certain date" do
  #   setup { add_response "will_marry_on_or_after_specific_date" }
    
  #   should "ask when will reach pension age" do
  #     assert_current_node :when_will_you_reach_pension_age?
  #   end

  #   context "before specific date" do
  #     setup { add_response "your_pension_age_before_specific_date" }
      
  #     should "ask when partner will reach pension age" do
  #       assert_current_node :when_will_your_partner_reach_pension_age?
  #     end

  #     context "before specific date" do
  #       setup { add_response "partner_pension_age_before_specific_date" }

  #       should "give outcome 1" do
  #         assert_current_node :outcome_1
  #         # assert_phrase_list :next_step_links, [:wills_link]
  #       end
  #     end
  #   end
  # end #end will marry on or after certain date context

end
