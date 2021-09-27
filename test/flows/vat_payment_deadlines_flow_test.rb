require "test_helper"
require "support/flow_test_helper"

class VatPaymentDeadlinesFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    WebMock.stub_request(:get, WorkingDays::BANK_HOLIDAYS_URL)
      .to_return(body: File.open(fixture_file("bank_holidays.json")))
    testing_flow VatPaymentDeadlinesFlow
  end

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: when_does_your_vat_accounting_period_end?" do
    setup { testing_node :when_does_your_vat_accounting_period_end? }

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid if non end-of-month date" do
        assert_invalid_response "2013-05-15"
      end

      should "be valid if a leap year is given" do
        assert_valid_response "2012-02-29"
      end

      should "be invalid if a non leap year is given" do
        assert_invalid_response "2011-02-29"
      end
    end

    context "next_node" do
      should "have a next node of how_do_you_want_to_pay? for a valid response" do
        assert_next_node :how_do_you_want_to_pay?, for_response: "2013-04-30"
      end
    end
  end

  context "question: how_do_you_want_to_pay?" do
    setup do
      testing_node :how_do_you_want_to_pay?
      add_responses when_does_your_vat_accounting_period_end?: "2013-04-30"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of result_direct_debit" do
        assert_next_node :result_direct_debit, for_response: "direct-debit"
      end

      should "have a next node of result_online_telephone_banking" do
        assert_next_node :result_online_telephone_banking, for_response: "online-telephone-banking"
      end

      should "have a next node of result_online_debit_credit_card" do
        assert_next_node :result_online_debit_credit_card, for_response: "online-debit-credit-card"
      end

      should "have a next node of result_bacs_direct_credit" do
        assert_next_node :result_bacs_direct_credit, for_response: "bacs-direct-credit"
      end

      should "have a next node of result_bank_giro" do
        assert_next_node :result_bank_giro, for_response: "bank-giro"
      end

      should "have a next node of result_chaps" do
        assert_next_node :result_chaps, for_response: "chaps"
      end

      should "have a next node of result_cheque" do
        assert_next_node :result_cheque, for_response: "cheque"
      end
    end
  end
end
