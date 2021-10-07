require "test_helper"
require "support/flow_test_helper"

class ChildcareCostsForTaxCreditsFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    testing_flow ChildcareCostsForTaxCreditsFlow
  end

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: currently_claiming?" do
    setup { testing_node :currently_claiming? }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of have_costs_changed? for a 'yes' response" do
        assert_next_node :have_costs_changed?, for_response: "yes"
      end

      should "have a next node of how_often_use_childcare? for a 'no' response" do
        assert_next_node :how_often_use_childcare?, for_response: "no"
      end
    end
  end

  context "question: how_often_use_childcare?" do
    setup do
      testing_node :how_often_use_childcare?
      add_responses currently_claiming?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_often_pay_1? for a 'regularly_less_than_year' response" do
        assert_next_node :how_often_pay_1?, for_response: "regularly_less_than_year"
      end

      should "have a next node of pay_same_each_time? for a 'regularly_more_than_year' response" do
        assert_next_node :pay_same_each_time?, for_response: "regularly_more_than_year"
      end

      should "have a next node of call_helpline_detailed for a 'only_short_while' response" do
        assert_next_node :call_helpline_detailed, for_response: "only_short_while"
      end
    end
  end

  context "question: have_costs_changed?" do
    setup do
      testing_node :have_costs_changed?
      add_responses currently_claiming?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_often_pay_2? for a 'yes' response" do
        assert_next_node :how_often_pay_2?, for_response: "yes"
      end

      should "have a next node of no_change for a 'no' response" do
        assert_next_node :no_change, for_response: "no"
      end
    end
  end

  context "question: how_often_pay_1?" do
    setup do
      testing_node :how_often_pay_1?
      add_responses currently_claiming?: "no",
                    how_often_use_childcare?: "regularly_less_than_year"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of round_up_weekly for a 'weekly_same_amount' response" do
        assert_next_node :round_up_weekly, for_response: "weekly_same_amount"
      end

      should "have a next node of how_much_52_weeks_1? for a 'weekly_diff_amount' response" do
        assert_next_node :how_much_52_weeks_1?, for_response: "weekly_diff_amount"
      end

      should "have a next node of how_much_each_month? for a 'monthly_same_amount' response" do
        assert_next_node :how_much_each_month?, for_response: "monthly_same_amount"
      end

      should "have a next node of how_much_12_months_1? for a 'monthly_diff_amount' response" do
        assert_next_node :how_much_12_months_1?, for_response: "monthly_diff_amount"
      end

      should "have a next node how_much_12_months_1? how_often_pay_2? for a 'other' response" do
        assert_next_node :how_much_12_months_1?, for_response: "other"
      end
    end
  end

  context "question: how_often_pay_2?" do
    setup do
      testing_node :how_often_pay_2?
      add_responses currently_claiming?: "yes",
                    have_costs_changed?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of new_weekly_costs? for a 'weekly_same_amount' response" do
        assert_next_node :new_weekly_costs?, for_response: "weekly_same_amount"
      end

      should "have a next node of how_much_52_weeks_2? for a 'weekly_diff_amount' response" do
        assert_next_node :how_much_52_weeks_2?, for_response: "weekly_diff_amount"
      end

      should "have a next node of new_monthly_cost? for a 'monthly_same_amount' response" do
        assert_next_node :new_monthly_cost?, for_response: "monthly_same_amount"
      end

      should "have a next node of how_much_12_months_2? for a 'monthly_diff_amount' response" do
        assert_next_node :how_much_12_months_2?, for_response: "monthly_diff_amount"
      end

      should "have a next node how_much_52_weeks_2? how_often_pay_2? for a 'other' response" do
        assert_next_node :how_much_52_weeks_2?, for_response: "other"
      end
    end
  end

  context "question: how_much_12_months_1?" do
    setup do
      testing_node :how_much_12_months_1?
      add_responses currently_claiming?: "no",
                    how_often_use_childcare?: "regularly_less_than_year",
                    how_often_pay_1?: "monthly_diff_amount"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of weekly_costs_are_x for any response" do
        assert_next_node :weekly_costs_are_x, for_response: "200.00"
      end
    end
  end

  context "question: how_much_52_weeks_1?" do
    setup do
      testing_node :how_much_52_weeks_1?
      add_responses currently_claiming?: "no",
                    how_often_use_childcare?: "regularly_less_than_year",
                    how_often_pay_1?: "weekly_diff_amount"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of weekly_costs_are_x for any response" do
        assert_next_node :weekly_costs_are_x, for_response: "200.00"
      end
    end
  end

  context "question: how_much_52_weeks_2?" do
    setup do
      testing_node :how_much_52_weeks_2?
      add_responses currently_claiming?: "yes",
                    have_costs_changed?: "yes",
                    how_often_pay_2?: "weekly_diff_amount"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of no_longer_paying for a '0' response" do
        assert_next_node :no_longer_paying, for_response: "0"
      end

      should "have a next node of old_weekly_amount_1? for any non-zero response" do
        assert_next_node :old_weekly_amount_1?, for_response: "100.00"
      end
    end
  end

  context "question: how_much_12_months_2?" do
    setup do
      testing_node :how_much_12_months_2?
      add_responses currently_claiming?: "yes",
                    have_costs_changed?: "yes",
                    how_often_pay_2?: "monthly_diff_amount"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of no_longer_paying for a '0' response" do
        assert_next_node :no_longer_paying, for_response: "0"
      end

      should "have a next node of old_monthly_amount? for any non-zero response" do
        assert_next_node :old_monthly_amount?, for_response: "100.00"
      end
    end
  end

  context "question: how_much_each_month?" do
    setup do
      testing_node :how_much_each_month?
      add_responses currently_claiming?: "no",
                    how_often_use_childcare?: "regularly_more_than_year",
                    pay_same_each_time?: "yes",
                    how_often_pay_providers?: "every_month"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of weekly_costs_are_x for any response" do
        assert_next_node :weekly_costs_are_x, for_response: "200.00"
      end
    end
  end

  context "question: pay_same_each_time?" do
    setup do
      testing_node :pay_same_each_time?
      add_responses currently_claiming?: "no",
                    how_often_use_childcare?: "regularly_more_than_year"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_often_pay_providers? for a 'yes' response" do
        assert_next_node :how_often_pay_providers?, for_response: "yes"
      end

      should "have a next node of how_much_spent_last_12_months? for a 'no' response" do
        assert_next_node :how_much_spent_last_12_months?, for_response: "no"
      end
    end
  end

  context "question: how_often_pay_providers?" do
    setup do
      testing_node :how_often_pay_providers?
      add_responses currently_claiming?: "no",
                    how_often_use_childcare?: "regularly_more_than_year",
                    pay_same_each_time?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of round_up_weekly for a 'weekly' response" do
        assert_next_node :round_up_weekly, for_response: "weekly"
      end

      should "have a next node of how_much_fortnightly? for a 'fortnightly' response" do
        assert_next_node :how_much_fortnightly?, for_response: "fortnightly"
      end

      should "have a next node of how_much_4_weeks? for a 'every_4_weeks' response" do
        assert_next_node :how_much_4_weeks?, for_response: "every_4_weeks"
      end

      should "have a next node of how_much_each_month? for a 'every_month' response" do
        assert_next_node :how_much_each_month?, for_response: "every_month"
      end

      should "have a next node of call_helpline_plain for a 'termly' response" do
        assert_next_node :call_helpline_plain, for_response: "termly"
      end

      should "have a next node of how_much_yearly? for a 'yearly' response" do
        assert_next_node :how_much_yearly?, for_response: "yearly"
      end

      should "have a next node of call_helpline_plain for a 'other' response" do
        assert_next_node :call_helpline_plain, for_response: "other"
      end
    end
  end

  context "question: how_much_fortnightly?" do
    setup do
      testing_node :how_much_fortnightly?
      add_responses currently_claiming?: "no",
                    how_often_use_childcare?: "regularly_more_than_year",
                    pay_same_each_time?: "yes",
                    how_often_pay_providers?: "fortnightly"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of weekly_costs_are_x for any response" do
        assert_next_node :weekly_costs_are_x, for_response: "200.00"
      end
    end
  end

  context "question: how_much_4_weeks?" do
    setup do
      testing_node :how_much_4_weeks?
      add_responses currently_claiming?: "no",
                    how_often_use_childcare?: "regularly_more_than_year",
                    pay_same_each_time?: "yes",
                    how_often_pay_providers?: "every_4_weeks"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of weekly_costs_are_x for any response" do
        assert_next_node :weekly_costs_are_x, for_response: "200.00"
      end
    end
  end

  context "question: how_much_yearly?" do
    setup do
      testing_node :how_much_yearly?
      add_responses currently_claiming?: "no",
                    how_often_use_childcare?: "regularly_more_than_year",
                    pay_same_each_time?: "yes",
                    how_often_pay_providers?: "yearly"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of weekly_costs_are_x for any response" do
        assert_next_node :weekly_costs_are_x, for_response: "200.00"
      end
    end
  end

  context "question: how_much_spent_last_12_months?" do
    setup do
      testing_node :how_much_spent_last_12_months?
      add_responses currently_claiming?: "no",
                    how_often_use_childcare?: "regularly_more_than_year",
                    pay_same_each_time?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of weekly_costs_are_x for any response" do
        assert_next_node :weekly_costs_are_x, for_response: "200.00"
      end
    end
  end

  context "question: new_weekly_costs?" do
    setup do
      testing_node :new_weekly_costs?
      add_responses currently_claiming?: "yes",
                    have_costs_changed?: "yes",
                    how_often_pay_2?: "weekly_same_amount"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of no_longer_paying for a '0' response" do
        assert_next_node :no_longer_paying, for_response: "0"
      end

      should "have a next node of old_weekly_amount_2? for any non-zero response" do
        assert_next_node :old_weekly_amount_2?, for_response: "100.00"
      end
    end
  end

  context "question: old_weekly_amount_1?" do
    setup do
      testing_node :old_weekly_amount_1?
      add_responses currently_claiming?: "yes",
                    have_costs_changed?: "yes",
                    how_often_pay_2?: "weekly_diff_amount",
                    how_much_52_weeks_2?: "200.00"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of cost_changed for any response" do
        assert_next_node :cost_changed, for_response: "100.00"
      end
    end
  end

  context "question: new_monthly_cost?" do
    setup do
      testing_node :new_monthly_cost?
      add_responses currently_claiming?: "yes",
                    have_costs_changed?: "yes",
                    how_often_pay_2?: "monthly_same_amount"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of no_longer_paying for a '0' response" do
        assert_next_node :no_longer_paying, for_response: "0"
      end

      should "have a next node of old_monthly_amount? for any non-zero response" do
        assert_next_node :old_monthly_amount?, for_response: "100.00"
      end
    end
  end

  context "question: old_weekly_amount_2?" do
    setup do
      testing_node :old_weekly_amount_2?
      add_responses currently_claiming?: "yes",
                    have_costs_changed?: "yes",
                    how_often_pay_2?: "weekly_same_amount",
                    new_weekly_costs?: "200.00"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of cost_changed for any response" do
        assert_next_node :cost_changed, for_response: "100.00"
      end
    end
  end

  context "question: old_monthly_amount?" do
    setup do
      testing_node :old_monthly_amount?
      add_responses currently_claiming?: "yes",
                    have_costs_changed?: "yes",
                    how_often_pay_2?: "monthly_diff_amount",
                    how_much_12_months_2?: "200.00"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of cost_changed for any response" do
        assert_next_node :cost_changed, for_response: "100.00"
      end
    end
  end

  context "outcome: cost_changed" do
    setup do
      testing_node :cost_changed
      add_responses currently_claiming?: "yes",
                    have_costs_changed?: "yes",
                    how_often_pay_2?: "weekly_same_amount",
                    old_weekly_amount_2?: "100.00"
    end

    should "render 'This does not affect your tax credits.' if the difference in amount is than £10" do
      add_responses new_weekly_costs?: "109.00"
      assert_rendered_outcome text: "This does not affect your tax credits."
    end

    should "render 'Call HM Revenue and Customs (HMRC)' if the difference in amount is more than £10 when a cost change of 4 weeks is true" do
      add_responses new_weekly_costs?: "110.00"
      assert_rendered_outcome text: "Call HM Revenue and Customs (HMRC)"
    end

    should "render 'Tell HM Revenue and Customs (HMRC)' if the difference in amount is more than £10 when a cost change of 4 weeks is false" do
      add_responses how_often_pay_2?: "weekly_diff_amount",
                    how_much_52_weeks_2?: "100.00",
                    old_weekly_amount_1?: "12.00"
      assert_rendered_outcome text: "Tell HM Revenue and Customs (HMRC)"
    end
  end
end
