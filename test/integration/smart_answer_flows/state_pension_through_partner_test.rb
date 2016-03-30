
require_relative '../../test_helper'
require_relative 'flow_test_helper'
require 'gds_api/test_helpers/worldwide'

require "smart_answer_flows/state-pension-through-partner"

class StatePensionThroughPartnerTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::StatePensionThroughPartnerFlow
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

      context "old3 - before specific date" do
        setup { add_response "partner_pension_age_before_specific_date" }
        should "go to current_rules_no_additional_pension_outcome" do
          assert_current_node :current_rules_no_additional_pension_outcome
        end
      end
    end
  end #end married old old

  context "widow" do
    setup { add_response "widowed" }
    should "ask when will reach pension age" do
      assert_current_node :when_will_you_reach_pension_age?
    end

    context "new2 - after specific date" do
      setup { add_response "your_pension_age_after_specific_date" }

      should "go to question gender" do
        assert_current_node :what_is_your_gender?
      end

      context "male" do
        setup { add_response "male_gender" }
        should "go to impossibility_to_increase_pension_outcome" do
          assert_current_node :impossibility_to_increase_pension_outcome
        end
      end
    end
  end

  context "divorced" do
    setup do
      add_response "divorced"
      add_response "male_gender"
    end
    should "ask male or female, answer male then go to result" do
      assert_current_node :impossibility_due_to_divorce_outcome
    end
  end

  #START OF QUICK TESTS
  #current_rules_no_additional_pension
  context "old1 old2 old3 == current_rules_no_additional_pension" do
    setup do
      add_response "married"
      add_response "your_pension_age_before_specific_date"
      add_response "partner_pension_age_before_specific_date"
    end
    should "take you to current_rules_no_additional_pension_outcome" do
      assert_current_node :current_rules_no_additional_pension_outcome
    end
  end
  context "new1 new2 old3, female == married_woman_no_state_pension" do
    setup do
      add_response "will_marry_on_or_after_specific_date"
      add_response "your_pension_age_after_specific_date"
      add_response "partner_pension_age_before_specific_date"
      add_response "female_gender"
    end
    should "take you to married_woman_no_state_pension_outcome" do
      assert_current_node :married_woman_no_state_pension_outcome
    end
  end
  context "new1 old2 old3 == current_rules_no_additional_pension" do
    setup do
      add_response "will_marry_on_or_after_specific_date"
      add_response "your_pension_age_before_specific_date"
      add_response "partner_pension_age_before_specific_date"
    end
    should "take you to current_rules_no_additional_pension_outcome" do
      assert_current_node :current_rules_no_additional_pension_outcome
    end
  end
  #end current_rules_no_additional_pension
  #current_rules_and_additional_pension
  context "widow old2 old3== current_rules_and_additional_pension" do
    setup do
      add_response "widowed"
      add_response "your_pension_age_before_specific_date"
    end
    should "take you to widow_and_old_pension_outcome" do
      assert_current_node :widow_and_old_pension_outcome
    end
  end #end current_rules_and_additional_pension
  #current_rules_national_insurance_no_state_pension
  context "old1 old2 new3 == current_rules_national_insurance_no_state_pension" do
    setup do
      add_response "married"
      add_response "your_pension_age_before_specific_date"
      add_response "partner_pension_age_after_specific_date"
    end
    should "take you to current_rules_national_insurance_no_state_pension_outcome" do
      assert_current_node :current_rules_national_insurance_no_state_pension_outcome
    end
  end #end current_rules_national_insurance_no_state_pension
  #married_woman_no_state_pension
  context "old1 new2 new3 == married_woman_no_state_pension" do
    setup do
      add_response "married"
      add_response "your_pension_age_after_specific_date"
      add_response "partner_pension_age_after_specific_date"
      add_response "female_gender"
    end
    should "take you to married_woman_no_state_pension_outcome" do
      assert_current_node :married_woman_no_state_pension_outcome
    end
  end
  context "new1 new2 new3 == married_woman_no_state_pension" do
    setup do
      add_response "will_marry_on_or_after_specific_date"
      add_response "your_pension_age_after_specific_date"
      add_response "partner_pension_age_after_specific_date"
      add_response "female_gender"
    end
    should "take you to married_woman_no_state_pension_outcome" do
      assert_current_node :married_woman_no_state_pension_outcome
    end
  end
  context "old1 new2 old3 == married_woman_no_state_pension" do
    setup do
      add_response "married"
      add_response "your_pension_age_after_specific_date"
      add_response "partner_pension_age_before_specific_date"
      add_response "female_gender"
    end
    should "take you to married_woman_no_state_pension_outcome" do
      assert_current_node :married_woman_no_state_pension_outcome
    end
  end#end married_woman_no_state_pension
  #married_woman_and_state_pension
  context "widow new2 old3 female_gender == married_woman_and_state_pension" do
    setup do
      add_response "widowed"
      add_response "your_pension_age_after_specific_date"
      add_response "female_gender"
    end
    should "take you to married_woman_and_state_pension_outcome" do
      assert_current_node :married_woman_and_state_pension_outcome
    end
  end
  context "widow new2 new3 female_gender == married_woman_and_state_pension" do
    setup do
      add_response "widowed"
      add_response "your_pension_age_after_specific_date"
      add_response "female_gender"
    end
    should "take you to female_gender_outcome" do
      assert_current_node :married_woman_and_state_pension_outcome
    end
  end #end married_woman_and_state_pension
  #impossibility_to_increase_pension
  context "widow new2 new3 male_gender == impossibility_to_increase_pension" do
    setup do
      add_response "widowed"
      add_response "your_pension_age_after_specific_date"
      add_response "male_gender"
    end
    should "take you to impossibility_to_increase_pension_outcome" do
      assert_current_node :impossibility_to_increase_pension_outcome
    end
  end  #end impossibility_to_increase_pension
  context "divorced woman" do
    setup do
      add_response "divorced"
      add_response "female_gender"
    end
    should "take you to age_dependent_pension_outcome" do
      assert_current_node :age_dependent_pension_outcome
    end
  end # end testing for outcome 10
  context "new1 new2 old3 female go to current_rules_and_additional_pension" do
    setup do
      add_response "will_marry_on_or_after_specific_date"
      add_response "your_pension_age_after_specific_date"
      add_response "partner_pension_age_before_specific_date"
      add_response "female_gender"
    end
    should "take user to outcome married_woman_no_state_pension" do
      assert_current_node :married_woman_no_state_pension_outcome
    end
  end
end
