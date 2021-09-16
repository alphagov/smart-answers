require "test_helper"
require "support/flow_test_helper"

class StatePensionThroughPartnerFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup { testing_flow StatePensionThroughPartnerFlow }

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: what_is_your_marital_status?" do
    setup { testing_node :what_is_your_marital_status? }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of what_is_your_gender? for a 'divorced' response" do
        assert_next_node :what_is_your_gender?, for_response: "divorced"
      end

      %w[married widowed].each do |marital_status|
        should "have a next node of when_will_you_reach_pension_age? for a '#{marital_status}' response" do
          assert_next_node :when_will_you_reach_pension_age?, for_response: marital_status
        end
      end
    end
  end

  context "question: when_will_you_reach_pension_age?" do
    setup do
      testing_node :when_will_you_reach_pension_age?
      add_responses what_is_your_marital_status?: "widowed"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of what_is_your_gender? for 'your_pension_age_after_specific_date'" \
             "response when widowed" do
        assert_next_node :what_is_your_gender?, for_response: "your_pension_age_after_specific_date"
      end

      should "have a next node of widow_and_old_pension_outcome for a 'your_pension_age_before_specific_date'" \
             "response when widowed" do
        assert_next_node :widow_and_old_pension_outcome, for_response: "your_pension_age_before_specific_date"
      end

      %w[your_pension_age_after_specific_date your_pension_age_before_specific_date].each do |pension_age|
        should "have a next node of when_will_your_partner_reach_pension_age? for a '#{pension_age}'" \
               "response when married" do
          add_responses what_is_your_marital_status?: "married"
          assert_next_node :when_will_your_partner_reach_pension_age?, for_response: pension_age
        end
      end
    end
  end

  context "question: when_will_your_partner_reach_pension_age?" do
    setup do
      testing_node :when_will_your_partner_reach_pension_age?
      add_responses what_is_your_marital_status?: "married",
                    when_will_you_reach_pension_age?: "your_pension_age_before_specific_date"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of current_rules_no_additional_pension_outcome when" \
             "both you and your partner's pension age reached before specific date" do
        assert_next_node :current_rules_no_additional_pension_outcome,
                         for_response: "partner_pension_age_before_specific_date"
      end

      should "have a next node of current_rules_national_insurance_no_state_pension_outcome when" \
             "you reached persion age before a specific date and your partner reached" \
             "pension age after a specific date" do
        assert_next_node :current_rules_national_insurance_no_state_pension_outcome,
                         for_response: "partner_pension_age_after_specific_date"
      end

      should "have a next node of what_is_your_gender? when" \
             "both you and your partner's pension age reached after a specific date" do
        add_responses when_will_you_reach_pension_age?: "your_pension_age_after_specific_date"
        assert_next_node :what_is_your_gender?, for_response: "partner_pension_age_after_specific_date"
      end

      should "have a next node of what_is_your_gender? when" \
             "you reached persion age after a specific date and your partner reached" \
             "pension age before a specific date" do
        add_responses when_will_you_reach_pension_age?: "your_pension_age_after_specific_date"
        assert_next_node :what_is_your_gender?, for_response: "partner_pension_age_before_specific_date"
      end
    end
  end

  context "question: what_is_your_gender?" do
    setup do
      testing_node :what_is_your_gender?
      add_responses what_is_your_marital_status?: "married",
                    when_will_you_reach_pension_age?: "your_pension_age_after_specific_date",
                    when_will_your_partner_reach_pension_age?: "partner_pension_age_after_specific_date"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      context "male_gender response" do
        should "have a next node of impossibility_due_to_divorce_outcome when divorced" do
          add_responses what_is_your_marital_status?: "divorced"
          assert_next_node :impossibility_due_to_divorce_outcome, for_response: "male_gender"
        end

        should "have a next node of widow_male_reaching_pension_age when widowed" do
          add_responses what_is_your_marital_status?: "widowed"
          assert_next_node :widow_male_reaching_pension_age, for_response: "male_gender"
        end

        should "have a next node of impossibility_to_increase_pension_outcome when married" do
          assert_next_node :impossibility_to_increase_pension_outcome, for_response: "male_gender"
        end
      end

      context "female_gender response" do
        should "have a next node of age_dependent_pension_outcome when divorced" do
          add_responses what_is_your_marital_status?: "divorced"
          assert_next_node :age_dependent_pension_outcome, for_response: "female_gender"
        end

        should "have a next node of married_woman_and_state_pension_outcome when widowed" do
          add_responses what_is_your_marital_status?: "widowed"
          assert_next_node :married_woman_and_state_pension_outcome, for_response: "female_gender"
        end

        should "have a next node of married_woman_no_state_pension_outcome when married" do
          assert_next_node :married_woman_no_state_pension_outcome, for_response: "female_gender"
        end
      end
    end
  end
end
