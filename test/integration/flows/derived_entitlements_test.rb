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
  end
    #START OF QUICK TESTS
    
#phrase 1
  context "old1 old2 old3 == phrase1" do
    setup do
      add_response "married"
      add_response "your_pension_age_before_specific_date"
      add_response "partner_pension_age_before_specific_date"
    end
    should "take you to outcome with phraselist 1" do
      assert_current_node :outcome_1
      assert_phrase_list :result, [:phrase1]
    end
  end 
  context "new1 new2 old3 == phrase1" do
    setup do
      add_response "will_marry_on_or_after_specific_date"
      add_response "your_pension_age_after_specific_date"
      add_response "partner_pension_age_before_specific_date"
    end
    should "take you to outcome with phraselist 1" do
      assert_current_node :outcome_1
      assert_phrase_list :result, [:phrase1]
    end
  end
  context "new1 old2 old3 == phrase1" do
    setup do
      add_response "will_marry_on_or_after_specific_date"
      add_response "your_pension_age_before_specific_date"
      add_response "partner_pension_age_before_specific_date"
    end
    should "take you to outcome with phraselist 1" do
      assert_current_node :outcome_1
      assert_phrase_list :result, [:phrase1]
    end
  end
  #end phrase 1
  #phrase 2
  context "widow old2 old3== phrase2" do
    setup do
      add_response "widowed"
      add_response "your_pension_age_before_specific_date"
      add_response "partner_pension_age_before_specific_date"
    end
    should "take you to outcome with phraselist 2" do
      assert_current_node :outcome_1
      assert_phrase_list :result, [:phrase2]
    end
  end #end phrase 2
    #phrase 3
  context "old1 old2 new3 == phrase3" do
    setup do
      add_response "married"
      add_response "your_pension_age_before_specific_date"
      add_response "partner_pension_age_after_specific_date"
    end
    should "take you to outcome with phraselist 3" do
      assert_current_node :outcome_1
      assert_phrase_list :result, [:phrase3]
    end
  end #end phrase 3
    #phrase 4
  context "widow old2 new3== phrase4" do
    setup do
      add_response "widowed"
      add_response "your_pension_age_before_specific_date"
      add_response "partner_pension_age_after_specific_date"
    end
    should "take you to outcome with phraselist 4" do
      assert_current_node :outcome_1
      assert_phrase_list :result, [:phrase4]
    end
  end #end phrase 4
  #phrase 5
  context "old1 new2 new3 == phrase5" do
    setup do
      add_response "married"
      add_response "your_pension_age_after_specific_date"
      add_response "partner_pension_age_after_specific_date"
    end
    should "take you to outcome with phrase5" do
      assert_current_node :outcome_1
      assert_phrase_list :result, [:phrase5]
    end
  end 
  context "new1 new2 new3 == phrase5" do
    setup do
      add_response "will_marry_on_or_after_specific_date"
      add_response "your_pension_age_after_specific_date"
      add_response "partner_pension_age_after_specific_date"
    end
    should "take you to outcome with phrase5" do
      assert_current_node :outcome_1
      assert_phrase_list :result, [:phrase5]
    end
  end
  context "old1 new2 old3 == phrase5" do
    setup do
      add_response "married"
      add_response "your_pension_age_after_specific_date"
      add_response "partner_pension_age_before_specific_date"
    end
    should "take you to outcome with phrase5" do
      assert_current_node :outcome_1
      assert_phrase_list :result, [:phrase5]
    end
  end
  #end phrase 5
  
  
end
