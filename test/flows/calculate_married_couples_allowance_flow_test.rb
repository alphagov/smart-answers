require "test_helper"
require "support/flow_test_helper"

class CalculateMarriedCouplesAllowanceFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup { testing_flow CalculateMarriedCouplesAllowanceFlow }

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: were_you_or_your_partner_born_on_or_before_6_april_1935?" do
    setup { testing_node :were_you_or_your_partner_born_on_or_before_6_april_1935? }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have next node of did_you_marry_or_civil_partner_before_5_december_2005? for a 'yes' response" do
        assert_next_node :did_you_marry_or_civil_partner_before_5_december_2005?, for_response: "yes"
      end

      should "have next node of sorry for a 'no' response" do
        assert_next_node :sorry, for_response: "no"
      end
    end
  end

  context "question: did_you_marry_or_civil_partner_before_5_december_2005?" do
    setup do
      testing_node :did_you_marry_or_civil_partner_before_5_december_2005?
      add_responses were_you_or_your_partner_born_on_or_before_6_april_1935?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of whats_the_husbands_date_of_birth? for a 'yes' response" do
        assert_next_node :whats_the_husbands_date_of_birth?, for_response: "yes"
      end

      should "have next node of whats_the_highest_earners_date_of_birth? for a 'no' response" do
        assert_next_node :whats_the_highest_earners_date_of_birth?, for_response: "no"
      end
    end
  end

  context "question: whats_the_husbands_date_of_birth?" do
    setup do
      testing_node :whats_the_husbands_date_of_birth?
      add_responses were_you_or_your_partner_born_on_or_before_6_april_1935?: "yes",
                    did_you_marry_or_civil_partner_before_5_december_2005?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    should "have a next node of whats_the_husbands_date_of_birth? for any response" do
      assert_next_node :whats_the_husbands_income?, for_response: "1970-01-01"
    end
  end

  context "question: whats_the_highest_earners_date_of_birth?" do
    setup do
      testing_node :whats_the_highest_earners_date_of_birth?
      add_responses were_you_or_your_partner_born_on_or_before_6_april_1935?: "yes",
                    did_you_marry_or_civil_partner_before_5_december_2005?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    should "have a next node of whats_the_highest_earners_income? for any response" do
      assert_next_node :whats_the_highest_earners_income?, for_response: "1970-01-01"
    end
  end

  context "question: whats_the_husbands_income?" do
    setup do
      testing_node :whats_the_husbands_income?
      add_responses were_you_or_your_partner_born_on_or_before_6_april_1935?: "yes",
                    did_you_marry_or_civil_partner_before_5_december_2005?: "yes",
                    whats_the_husbands_date_of_birth?: "1970-01-01"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid for an income of '0' or less" do
        assert_invalid_response "0"
      end
    end

    context "next_node" do
      should "have a next node of husband_done for a response less than income_limit_for_personal_allowances" do
        assert_next_node :husband_done, for_response: "1.00"
      end

      should "have a next node of paying_into_a_pension? for a response greater than income_limit_for_personal_allowances" do
        assert_next_node :paying_into_a_pension?, for_response: "1000000.00"
      end
    end
  end

  context "question: whats_the_highest_earners_income?" do
    setup do
      testing_node :whats_the_highest_earners_income?
      add_responses were_you_or_your_partner_born_on_or_before_6_april_1935?: "yes",
                    did_you_marry_or_civil_partner_before_5_december_2005?: "no",
                    whats_the_highest_earners_date_of_birth?: "1970-01-01"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid for an income of '0' or less" do
        assert_invalid_response "0"
      end
    end

    context "next_node" do
      should "have a next node of highest_earner_done for a response less than income_limit_for_personal_allowances" do
        assert_next_node :highest_earner_done, for_response: "1"
      end

      should "have a next node of paying_into_a_pension? for a response greater than income_limit_for_personal_allowances" do
        assert_next_node :paying_into_a_pension?, for_response: "1000000.00"
      end
    end
  end

  context "question: paying_into_a_pension?" do
    setup do
      testing_node :paying_into_a_pension?
      add_responses were_you_or_your_partner_born_on_or_before_6_april_1935?: "yes",
                    did_you_marry_or_civil_partner_before_5_december_2005?: "no",
                    whats_the_highest_earners_date_of_birth?: "1970-01-01",
                    whats_the_highest_earners_income?: "1000000.00"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_much_expected_contributions_before_tax? for a response of 'yes'" do
        assert_next_node :how_much_expected_contributions_before_tax?, for_response: "yes"
      end

      should "have a next node of how_much_expected_gift_aided_donations? for a response of 'no'" do
        assert_next_node :how_much_expected_gift_aided_donations?, for_response: "no"
      end
    end
  end

  context "question: how_much_expected_contributions_before_tax?" do
    setup do
      testing_node :how_much_expected_contributions_before_tax?
      add_responses were_you_or_your_partner_born_on_or_before_6_april_1935?: "yes",
                    did_you_marry_or_civil_partner_before_5_december_2005?: "no",
                    whats_the_highest_earners_date_of_birth?: "1970-01-01",
                    whats_the_highest_earners_income?: "1000000.00",
                    paying_into_a_pension?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_much_expected_contributions_with_tax_relief? for any" do
        assert_next_node :how_much_expected_contributions_with_tax_relief?, for_response: "1"
      end
    end
  end

  context "question: how_much_expected_contributions_with_tax_relief?" do
    setup do
      testing_node :how_much_expected_contributions_with_tax_relief?
      add_responses were_you_or_your_partner_born_on_or_before_6_april_1935?: "yes",
                    did_you_marry_or_civil_partner_before_5_december_2005?: "no",
                    whats_the_highest_earners_date_of_birth?: "1970-01-01",
                    whats_the_highest_earners_income?: "10000000.00",
                    paying_into_a_pension?: "yes",
                    how_much_expected_contributions_before_tax?: "1"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_much_expected_gift_aided_donations? for any" do
        assert_next_node :how_much_expected_gift_aided_donations?, for_response: "1"
      end
    end
  end

  context "question: how_much_expected_gift_aided_donations?" do
    setup do
      testing_node :how_much_expected_gift_aided_donations?
      add_responses were_you_or_your_partner_born_on_or_before_6_april_1935?: "yes",
                    did_you_marry_or_civil_partner_before_5_december_2005?: "no",
                    whats_the_highest_earners_date_of_birth?: "1970-01-01",
                    whats_the_highest_earners_income?: "1000000.00",
                    paying_into_a_pension?: "yes",
                    how_much_expected_contributions_before_tax?: "1",
                    how_much_expected_contributions_with_tax_relief?: "1"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of husband_done for any response if did_you_marry_or_civil_partner_before_5_december_2005? is yes" do
        add_responses did_you_marry_or_civil_partner_before_5_december_2005?: "yes",
                      whats_the_husbands_date_of_birth?: "1970-01-01",
                      whats_the_husbands_income?: "1000000.00"
        assert_next_node :husband_done, for_response: "1"
      end

      should "have a next node of highest_earner_done for any response if did_you_marry_or_civil_partner_before_5_december_2005? is no" do
        assert_next_node :highest_earner_done, for_response: "1"
      end
    end
  end
end
