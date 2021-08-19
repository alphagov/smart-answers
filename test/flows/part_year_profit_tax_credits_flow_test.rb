require "test_helper"
require "support/flow_test_helper"

class PartYearProfitTaxCreditsFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup { testing_flow PartYearProfitTaxCreditsFlow }

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: :when_did_your_tax_credits_award_end?" do
    setup { testing_node :when_did_your_tax_credits_award_end? }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of what_date_do_your_accounts_go_up_to? for any response" do
        assert_next_node :what_date_do_your_accounts_go_up_to?, for_response: "2020-01-01"
      end
    end
  end

  context "question: what_date_do_your_accounts_go_up_to?" do
    setup do
      testing_node :what_date_do_your_accounts_go_up_to?
      add_responses when_did_your_tax_credits_award_end?: "2020-01-01"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of have_you_stopped_trading? for any response" do
        assert_next_node :have_you_stopped_trading?, for_response: "2020-01-01"
      end
    end
  end

  context "question: have_you_stopped_trading?" do
    setup do
      testing_node :have_you_stopped_trading?
      add_responses when_did_your_tax_credits_award_end?: "2020-01-01",
                    what_date_do_your_accounts_go_up_to?: "2020-01-01"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of did_you_start_trading_before_the_relevant_accounting_year? for a 'yes' on_response" do
        assert_next_node :did_you_start_trading_before_the_relevant_accounting_year?, for_response: "yes"
      end

      should "have a next node of do_your_accounts_cover_a_12_month_period? for a 'no' response" do
        assert_next_node :do_your_accounts_cover_a_12_month_period?, for_response: "no"
      end
    end
  end

  context "question: did_you_start_trading_before_the_relevant_accounting_year?" do
    setup do
      testing_node :did_you_start_trading_before_the_relevant_accounting_year?
      add_responses when_did_your_tax_credits_award_end?: "2020-01-01",
                    what_date_do_your_accounts_go_up_to?: "2020-01-01",
                    have_you_stopped_trading?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of when_did_you_stop_trading? for a 'yes' on_response" do
        assert_next_node :when_did_you_stop_trading?, for_response: "yes"
      end

      should "have a next node of when_did_you_start_trading? for a 'no' response" do
        assert_next_node :when_did_you_start_trading?, for_response: "no"
      end
    end
  end

  context "question: when_did_you_stop_trading?" do
    setup do
      testing_node :when_did_you_stop_trading?
      add_responses when_did_your_tax_credits_award_end?: "2020-01-01",
                    what_date_do_your_accounts_go_up_to?: "2020-01-01",
                    have_you_stopped_trading?: "yes",
                    did_you_start_trading_before_the_relevant_accounting_year?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid for stop trading date not in same tax year as tax credits award end date" do
        assert_invalid_response "2020-04-10"
      end
    end

    context "next_node" do
      should "have a next node of what_is_your_taxable_profit? for any response" do
        assert_next_node :what_is_your_taxable_profit?, for_response: "2020-01-01"
      end
    end
  end

  context "question: do_your_accounts_cover_a_12_month_period?" do
    setup do
      testing_node :do_your_accounts_cover_a_12_month_period?
      add_responses when_did_your_tax_credits_award_end?: "2020-01-01",
                    what_date_do_your_accounts_go_up_to?: "2020-01-01",
                    have_you_stopped_trading?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of what_is_your_taxable_profit? for a 'yes' response" do
        assert_next_node :what_is_your_taxable_profit?, for_response: "yes"
      end

      should "have a next node of when_did_you_start_trading? for a 'no' response" do
        assert_next_node :when_did_you_start_trading?, for_response: "no"
      end
    end
  end

  context "question: when_did_you_start_trading?" do
    setup do
      testing_node :when_did_you_start_trading?
      add_responses when_did_your_tax_credits_award_end?: "2020-01-01",
                    what_date_do_your_accounts_go_up_to?: "2020-01-01",
                    have_you_stopped_trading?: "no",
                    do_your_accounts_cover_a_12_month_period?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid for start trading date after before tax credits award end date" do
        assert_invalid_response "2020-01-02"
      end
    end

    context "next_node" do
      should "have a next node of when_did_you_stop_trading? for any response if have_you_stopped_trading? is 'yes'" do
        add_responses did_you_start_trading_before_the_relevant_accounting_year?: "no",
                      have_you_stopped_trading?: "yes"
        assert_next_node :when_did_you_stop_trading?, for_response: "2019-12-01"
      end

      should "have a next node of what_is_your_taxable_profit? for any response if have_you_stopped_trading? is 'no'" do
        assert_next_node :what_is_your_taxable_profit?, for_response: "2019-12-01"
      end
    end
  end

  context "question: what_is_your_taxable_profit?" do
    setup do
      testing_node :what_is_your_taxable_profit?
      add_responses when_did_your_tax_credits_award_end?: "2020-01-01",
                    what_date_do_your_accounts_go_up_to?: "2020-01-01",
                    have_you_stopped_trading?: "no",
                    do_your_accounts_cover_a_12_month_period?: "no",
                    when_did_you_start_trading?: "2019-12-01"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of result for any response" do
        assert_next_node :result, for_response: "1.00"
      end
    end
  end

  context "outcome: result" do
    setup do
      testing_node :result
      add_responses when_did_your_tax_credits_award_end?: "2020-01-01",
                    what_date_do_your_accounts_go_up_to?: "2020-01-01",
                    have_you_stopped_trading?: "no",
                    do_your_accounts_cover_a_12_month_period?: "no",
                    when_did_you_start_trading?: "2019-12-01",
                    what_is_your_taxable_profit?: "1.00"
    end

    should "render stopped trading information if stopped trading" do
      add_responses did_you_start_trading_before_the_relevant_accounting_year?: "no",
                    have_you_stopped_trading?: "yes",
                    when_did_you_stop_trading?: "2020-01-01"
      assert_rendered_outcome text: "Your business stopped trading"
    end

    should "render account ends on information if still trading" do
      assert_rendered_outcome text: "Your business accounts end on"
    end
  end
end
