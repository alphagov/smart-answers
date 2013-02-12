# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class InheritsSomeoneDiesWithoutWillV2Test < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'inherits-someone-dies-without-will-v2'
  end

  should "ask where the deceased lived" do
    assert_current_node :where_did_the_deceased_live?
  end

  context "england and wales" do
    setup do
      add_response "england-and-wales"
    end
    should "ask is there a living spouse?" do
      assert_current_node :is_there_a_living_spouse_or_civil_partner?
    end
    
      context "living spouse, estate worth <250,000" do
        should "give outcome 1" do
          add_response "yes"
          add_response "no"
          assert_current_node :outcome_1
          assert_phrase_list :next_step_links, [:wills_link_only]
        end
      end      
      context "living spouse, estate worth >250,000, living children" do
        should "give outcome 2" do
          add_response "yes"
          add_response "yes"
          add_response "yes"
          assert_current_node :outcome_2
          assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
        end
      end
      context "living spouse, estate worth >250,000, no living children, no living parents" do
        should "give outcome 3" do
          add_response "yes"
          add_response "yes"
          add_response "no"
          add_response "no"
          assert_current_node :outcome_3
          assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
        end
      end
      context "living spouse, estate worth >250,000, no living children, living parents, siblings (same parents)" do
        should "give outcome 4" do
          add_response "yes"
          add_response "yes"
          add_response "no"
          add_response "yes"
          add_response "yes"
          assert_current_node :outcome_4
          assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
        end
      end
      context "living spouse, estate worth >250,000, no living children, living parents, no siblings (same parents)" do
        should "give outcome 5" do
          add_response "yes"
          add_response "yes"
          add_response "no"
          add_response "yes"
          add_response "no"
          assert_current_node :outcome_5
          assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
        end
      end
      context "no living spouse, has living children" do
        should "give outcome 6" do
          add_response "no"
          add_response "living-children-ew"
          assert_current_node :outcome_6
          assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
        end
      end
      context "no living spouse, has living parents" do
        should "give outcome 7" do
          add_response "no"
          add_response "living-parents-ew"
          assert_current_node :outcome_7
          assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
        end
      end
      context "no living spouse, has siblings (same parents)" do
        should "give outcome 8" do
          add_response "no"
          add_response "siblings-same-parents-ew"
          assert_current_node :outcome_8
          assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
        end
      end
      context "no living spouse, has siblings (half-blood)" do
        should "give outcome 9" do
          add_response "no"
          add_response "siblings-halfblood-ew"
          assert_current_node :outcome_9
          assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
        end
      end
      context "no living spouse, has grandparents" do
        should "give outcome 10" do
          add_response "no"
          add_response "living-grandparents-ew"
          assert_current_node :outcome_10
          assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
        end
      end
      context "no living spouse, has aunts or uncles" do
        should "give outcome 11" do
          add_response "no"
          add_response "aunts-or-uncles-ew"
          assert_current_node :outcome_11
          assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
        end
      end
      context "no living spouse, has half-blood aunts or uncles" do
        should "give outcome 12" do
          add_response "no"
          add_response "aunts-or-uncles-halfblood-ew"
          assert_current_node :outcome_12
          assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
        end
      end
      context "no living spouse, no living relatives" do
        should "give outcome 13" do
          add_response "no"
          add_response "no-living-relatives-ew"
          assert_current_node :outcome_13
          assert_phrase_list :next_step_links, [:bona_vacantia_link_only]
        end
      end
    end

  context "scotland" do
    setup do
      add_response "scotland"
    end
    should "ask is there a living spouse?" do
      assert_current_node :is_there_a_living_spouse_or_civil_partner?
    end

      context "living spouse, living children" do
        should "give outcome 14" do
          add_response "yes"
          add_response "yes"
          assert_current_node :outcome_14
          assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
        end
      end
      context "living spouse, no living children, living parents, has siblings (same parents)" do
        should "give outcome 15a" do
          add_response "yes"
          add_response "no"
          add_response "yes"
          add_response "yes"
          assert_current_node :outcome_15a
          assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
        end
      end
      context "living spouse, no living children, no living parents, has siblings (same parents)" do
        should "give outcome 15b" do
          add_response "yes"
          add_response "no"
          add_response "no"
          add_response "yes"
          assert_current_node :outcome_15b
          assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
        end
      end
      context "living spouse, no living children, living parents, no siblings (same parents)" do
        should "give outcome 16a" do
          add_response "yes"
          add_response "no"
          add_response "yes"
          add_response "no"
          assert_current_node :outcome_16a
          assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
        end
      end
      context "living spouse, no living children, no living parents, no siblings (same parents)" do
        should "give outcome 16b" do
          add_response "yes"
          add_response "no"
          add_response "no"
          add_response "no"
          assert_current_node :outcome_16b
          assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
        end
      end
      context "no living spouse, living children" do
        should "give outcome 17" do
          add_response "no"
          add_response "yes"
          assert_current_node :outcome_17
          assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
        end
      end
      context "no living spouse, no living children, living parents, has siblings (same parents)" do
        should "give outcome 18" do
          add_response "no"
          add_response "no"
          add_response "yes"
          add_response "yes"
          assert_current_node :outcome_18
          assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
        end
      end
      context "no living spouse, no living children, no living parents, has siblings (same parents)" do
        should "give outcome 19" do
          add_response "no"
          add_response "no"
          add_response "no"
          add_response "yes"
          assert_current_node :outcome_19
          assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
        end
      end
      context "no living spouse, no living children, living parents, no siblings (same parents)" do
        should "give outcome 20" do
          add_response "no"
          add_response "no"
          add_response "yes"
          add_response "no"
          assert_current_node :outcome_20
          assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
        end
      end
      context "no living spouse, no living children, no living parents, no siblings (same parents), has aunts and uncles" do
        should "give outcome 21" do
          add_response "no"
          add_response "no"
          add_response "no"
          add_response "no"
          add_response "yes"
          assert_current_node :outcome_21
          assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
        end
      end
      context "no living spouse, no living children, no living parents, no siblings (same parents), no aunts and uncles, has grandparents" do
        should "give outcome 22" do
          add_response "no"
          add_response "no"
          add_response "no"
          add_response "no"
          add_response "no"
          add_response "yes"
          assert_current_node :outcome_22
          assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
        end
      end
      context "no living spouse, no living children, no living parents, no siblings (same parents), no aunts and uncles, no grandparents, has great aunts and uncles" do
        should "give outcome 23" do
          add_response "no"
          add_response "no"
          add_response "no"
          add_response "no"
          add_response "no"
          add_response "no"
          add_response "yes"
          assert_current_node :outcome_23
          assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
        end
      end
      context "no living spouse, no living children, no living parents, no siblings (same parents), no aunts and uncles, no grandparents, no great aunts and uncles" do
        should "give outcome 24" do
          add_response "no"
          add_response "no"
          add_response "no"
          add_response "no"
          add_response "no"
          add_response "no"
          add_response "no"
          assert_current_node :outcome_24
          assert_phrase_list :next_step_links, [:bona_vacantia_link_only]
        end
      end
    end

  context "Northern Ireland" do
    setup do
      add_response "northern-ireland"
    end
    should "ask is there a living spouse?" do
      assert_current_node :is_there_a_living_spouse_or_civil_partner?
    end

    context "living spouse, estate worth <250,000" do
      should "give outcome 25" do
        add_response "yes"
        add_response "no"
        assert_current_node :outcome_25
        assert_phrase_list :next_step_links, [:wills_link_only]
      end
    end      
    context "living spouse, estate worth >250,000, living children, only one child" do
      should "give outcome 26" do
        add_response "yes"
        add_response "yes"
        add_response "yes"
        add_response "no"
        assert_current_node :outcome_26
        assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
      end
    end      
    context "living spouse, estate worth >250,000, living children, more then one child" do
      should "give outcome 27" do
        add_response "yes"
        add_response "yes"
        add_response "yes"
        add_response "yes"        
        assert_current_node :outcome_27
        assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
      end
    end      
    context "living spouse, estate worth >250,000, no living children, no living parents" do
      should "give outcome 28" do
        add_response "yes"
        add_response "yes"
        add_response "no"
        add_response "no"        
        assert_current_node :outcome_28
        assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
      end
    end      
    context "living spouse, estate worth >250,000, no living children, has living parents, has siblings (same parents)" do
      should "give outcome 29" do
        add_response "yes"
        add_response "yes"
        add_response "no"
        add_response "yes"
        add_response "yes"      
        assert_current_node :outcome_29
        assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
      end
    end
    context "living spouse, estate worth >250,000, no living children, has living parents, no siblings (same parents)" do
      should "give outcome 30" do
        add_response "yes"
        add_response "yes"
        add_response "no"
        add_response "yes"
        add_response "no"      
        assert_current_node :outcome_30
        assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
      end
    end
    context "no living spouse, living children" do
      should "give outcome 31" do
        add_response "no"
        add_response "living-children-ni"
        assert_current_node :outcome_31
        assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
      end
    end      
    context "no living spouse, living parents" do
      should "give outcome 32" do
        add_response "no"
        add_response "living-parents-ni"
        assert_current_node :outcome_32
        assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
      end
    end
    context "no living spouse, has siblings (same parents)" do
      should "give outcome 33" do
        add_response "no"
        add_response "siblings-same-parents-ni"
        assert_current_node :outcome_33
        assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
      end
    end
    context "no living spouse, has aunts and uncles" do
      should "give outcome 34" do
        add_response "no"
        add_response "aunts-or-uncles-ni"
        assert_current_node :outcome_34
        assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
      end
    end      
    context "no living spouse, has grandparents" do
      should "give outcome 35" do
        add_response "no"
        add_response "living-grandparents-ni"
        assert_current_node :outcome_35
        assert_phrase_list :next_step_links, [:wills_and_inheritance_links]
      end
    end
    context "no living spouse, no living relatives" do
      should "give outcome 36" do
        add_response "no"
        add_response "no-living-relatives-ni"
        assert_current_node :outcome_36
        assert_phrase_list :next_step_links, [:bona_vacantia_link_only]
      end
    end        



    
  end
end
