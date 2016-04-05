
require_relative '../../test_helper'
require_relative 'flow_test_helper'
require 'gds_api/test_helpers/worldwide'

require "smart_answer_flows/state-pension-through-partner"

class StatePensionThroughPartnerTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::StatePensionThroughPartnerFlow
  end

  context "married (old1)" do
    setup { add_response "married" }
    should "ask when will reach pension age" do
      assert_current_node :when_will_you_reach_pension_age?
    end

    context "you reached pension age before specific date (old2)" do
      setup { add_response "your_pension_age_before_specific_date" }
      should "ask when partner will reach pension age" do
        assert_current_node :when_will_your_partner_reach_pension_age?
      end
      #married, before, before
      context "your spouse reached pension age before specific date (old3)" do
        setup { add_response "partner_pension_age_before_specific_date" }
        should "show current_rules_no_additional_pension_outcome" do
          assert_current_node :current_rules_no_additional_pension_outcome
        end
      end

      #married, before, after
      context "your spouse reached pension age after specific date (old3)" do
        setup { add_response "partner_pension_age_after_specific_date" }
        should "show current_rules_national_insurance_no_state_pension_outcome" do
          assert_current_node :current_rules_national_insurance_no_state_pension_outcome
        end
      end
    end

    context "you reached pension age after specific date (old2)" do
      setup { add_response "your_pension_age_after_specific_date" }
      should "ask when partner will reach pension age" do
        assert_current_node :when_will_your_partner_reach_pension_age?
      end
      #married, after, after
      context "your spouse reached pension age after specific date (old3)" do
        setup { add_response "partner_pension_age_after_specific_date" }

        context "male" do
          setup { add_response "male_gender" }
          should "show impossibility_to_increase_pension_outcome" do
            assert_current_node :impossibility_to_increase_pension_outcome
          end
        end

        context "female" do
          setup { add_response "female_gender" }
          should "show married_woman_no_state_pension_outcome" do
            assert_current_node :married_woman_no_state_pension_outcome
          end
        end
      end
      #married, before, before
      context "your spouse reached pension age before specific date (old3)" do
        setup { add_response "partner_pension_age_before_specific_date" }

        context "male" do
          setup { add_response "male_gender" }
          should "show impossibility_to_increase_pension_outcome" do
            assert_current_node :impossibility_to_increase_pension_outcome
          end
        end

        context "female" do
          setup { add_response "female_gender" }
          should "show married_woman_no_state_pension_outcome" do
            assert_current_node :married_woman_no_state_pension_outcome
          end
        end
      end
    end
  end #end married old old

  context "widow" do
    setup { add_response "widowed" }
    should "ask when will reach pension age" do
      assert_current_node :when_will_you_reach_pension_age?
    end

    context "you will reach pension age before specific date (old2 old3)" do
      setup { add_response "your_pension_age_before_specific_date" }
      should "show widow_and_old_pension_outcome" do
        assert_current_node :widow_and_old_pension_outcome
      end
    end

    context "you will reach pension age after specific date (new2 old3)" do
      setup { add_response "your_pension_age_after_specific_date" }

      should "show question gender" do
        assert_current_node :what_is_your_gender?
      end

      context "female" do
        setup { add_response "female_gender" }
        should "show married_woman_and_state_pension_outcome" do
          assert_current_node :married_woman_and_state_pension_outcome
        end
      end

      context "male" do
        setup { add_response "male_gender" }
        should "show widow_male_reaching_pension_age" do
          assert_current_node :widow_male_reaching_pension_age
        end
      end
    end
  end

  context "divorced" do
    setup do
      add_response "divorced"
    end
    context "woman" do
      setup do
        add_response "female_gender"
      end
      should "show age_dependent_pension_outcome" do
        assert_current_node :age_dependent_pension_outcome
      end
    end

    context "man" do
      setup do
        add_response "male_gender"
      end
      should "ask male or female, answer male then show result" do
        assert_current_node :impossibility_due_to_divorce_outcome
      end
    end
  end
end
