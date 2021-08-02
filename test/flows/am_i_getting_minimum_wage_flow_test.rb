require "test_helper"
require "support/flow_test_helper"
require "support/shared_flows/minimum_wage_flow_test_helper"

class AmIGettingMinimumWageFlowTest < ActiveSupport::TestCase
  include FlowTestHelper
  extend MinimumWageFlowTestHelper

  setup do
    testing_flow AmIGettingMinimumWageFlow
    @living_wage_age = "25"
  end

  should "render a start page" do
    assert_rendered_start_page
  end

  context "test shared questions" do
    test_shared_minimum_wage_flow_questions
  end

  context "outcome: current_payment_above" do
    setup do
      testing_node :current_payment_above
      add_responses what_would_you_like_to_check?: "current_payment",
                    are_you_an_apprentice?: "not_an_apprentice",
                    how_old_are_you?: "16",
                    how_often_do_you_get_paid?: "15",
                    how_many_hours_do_you_work?: "5",
                    how_much_are_you_paid_during_pay_period?: "1000",
                    is_provided_with_accommodation?: "yes_charged",
                    current_accommodation_charge?: "1",
                    current_accommodation_usage?: "5",
                    does_employer_charge_for_job_requirements?: "no",
                    current_additional_work_outside_shift?: "yes",
                    current_paid_for_work_outside_shift?: "yes"
    end

    should "render living wage copy if a user is eligible for the national living wage" do
      add_responses how_old_are_you?: @living_wage_age
      assert_rendered_outcome text: "you appear to be getting the National Living Wage"
    end

    should "render minimum wage copy if a user is not eligible for the national living wage" do
      assert_rendered_outcome text: "you appear to be getting the National Minimum Wage"
    end

    should "render underpayment information for someone underpaid" do
      # may be underpaid if they have a job requirement charge
      add_responses does_employer_charge_for_job_requirements?: "yes"
      assert_rendered_outcome text: "you might have been underpaid"
    end

    should "render complaint information for someone underpaid" do
      # may be underpaid if they are not paid for work outside a shift
      add_responses current_paid_for_work_outside_shift?: "no"
      assert_rendered_outcome text: "You can also make a complaint to HM Revenue and Customs"
    end

    should "render guidance information for someone who is not underpaid" do
      assert_rendered_outcome text: "Read the guidance on the National Minimum Wage"
    end
  end

  context "outcome: current_payment_below" do
    setup do
      testing_node :current_payment_below
      add_responses what_would_you_like_to_check?: "current_payment",
                    are_you_an_apprentice?: "not_an_apprentice",
                    how_old_are_you?: "16",
                    how_often_do_you_get_paid?: "15",
                    how_many_hours_do_you_work?: "5",
                    how_much_are_you_paid_during_pay_period?: "1",
                    is_provided_with_accommodation?: "yes_charged",
                    current_accommodation_charge?: "1",
                    current_accommodation_usage?: "5",
                    does_employer_charge_for_job_requirements?: "no",
                    current_additional_work_outside_shift?: "yes",
                    current_paid_for_work_outside_shift?: "yes"
    end

    should "render living wage copy if a user is eligible for the national living wage" do
      add_responses how_old_are_you?: @living_wage_age
      assert_rendered_outcome text: "you appear to be not getting the National Living Wage"
    end

    should "render minimum wage copy if a user is not eligible for the national living wage" do
      assert_rendered_outcome text: "you appear to be not getting the National Minimum Wage"
    end

    should "render underpayment information for someone underpaid" do
      add_responses does_employer_charge_for_job_requirements?: "yes"
      assert_rendered_outcome text: "had money taken from your pay for things you need for your job"
    end
  end

  context "outcome: past_payment_above" do
    setup do
      testing_node :past_payment_above
      add_responses what_would_you_like_to_check?: "past_payment",
                    were_you_an_apprentice?: "no",
                    how_old_were_you?: "16",
                    how_often_did_you_get_paid?: "15",
                    how_many_hours_did_you_work?: "5",
                    how_much_were_you_paid_during_pay_period?: "1000",
                    was_provided_with_accommodation?: "yes_charged",
                    past_accommodation_charge?: "1",
                    past_accommodation_usage?: "5",
                    did_employer_charge_for_job_requirements?: "no",
                    past_additional_work_outside_shift?: "yes",
                    past_paid_for_work_outside_shift?: "yes"
    end

    should "render underpayment information for someone underpaid" do
      # may be underpaid if they have a job requirement charge
      add_responses did_employer_charge_for_job_requirements?: "yes"
      assert_rendered_outcome text: "you might have been underpaid"
    end

    should "render complaint information for someone underpaid" do
      # may be underpaid if they are not paid for work outside a shift
      add_responses past_paid_for_work_outside_shift?: "no"
      assert_rendered_outcome text: "You can also make a complaint to HM Revenue and Customs"
    end

    should "render guidance information for someone who is not underpaid" do
      assert_rendered_outcome text: "Read the guidance on the National Minimum Wage"
    end
  end

  context "outcome: past_payment_below" do
    setup do
      testing_node :past_payment_below
      add_responses what_would_you_like_to_check?: "past_payment",
                    were_you_an_apprentice?: "no",
                    how_old_were_you?: "16",
                    how_often_did_you_get_paid?: "15",
                    how_many_hours_did_you_work?: "5",
                    how_much_were_you_paid_during_pay_period?: "1",
                    was_provided_with_accommodation?: "yes_charged",
                    past_accommodation_charge?: "1",
                    past_accommodation_usage?: "5",
                    did_employer_charge_for_job_requirements?: "no",
                    past_additional_work_outside_shift?: "yes",
                    past_paid_for_work_outside_shift?: "yes"
    end

    should "render underpayment information for someone underpaid" do
      add_responses did_employer_charge_for_job_requirements?: "yes"
      assert_rendered_outcome text: "had money taken from your pay for things you needed for your job"
    end
  end
end
