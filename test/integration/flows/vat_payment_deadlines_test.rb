# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class TowingRulesTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'vat-payment-deadlines'
  end

  should "ask when your VAT accounting period ends" do
    assert_current_node :when_does_your_vat_accounting_period_end?
  end

  context "given a date" do
    setup do
      add_response '2013-04-05'
    end

    should "ask how you want to pay" do
      assert_current_node :how_do_you_want_to_pay?
    end

    should "give result for Direct debit" do
      add_response 'direct-debit'
      assert_current_node :result_direct_debit
      assert_state_variable :last_dd_setup_date, "10 May 2013"
      assert_state_variable :date_funds_taken, "15 May 2013"
    end

    should "give result for online or telephone banking" do
      add_response 'online-telephone-banking'
      assert_current_node :result_online_telephone_banking
      assert_state_variable :last_payment_date, "12 May 2013"
    end

    should "give result for online debit or credit card" do
      add_response 'online-debit-credit-card'
      assert_current_node :result_online_debit_credit_card
      assert_state_variable :last_payment_date, "9 May 2013"
      assert_state_variable :funds_cleared_by, "10 May 2013"
    end

    should "give result for BACS Direct Credit" do
      add_response 'bacs-direct-credit'
      assert_current_node :result_bacs_direct_credit
      assert_state_variable :last_payment_date, "9 May 2013"
      assert_state_variable :funds_cleared_by, "10 May 2013"
    end

    should "give result for Bank Giro" do
      add_response 'bank-giro'
      assert_current_node :result_bank_giro
    end

    should "give result for CHAPS" do
      add_response 'chaps'
      assert_current_node :result_chaps
      assert_state_variable :last_payment_date, "14 May 2013"
      assert_state_variable :payment_received_by, "14 May 2013"
    end

    should "give result for Cheque" do
      add_response 'cheque'
      assert_current_node :result_cheque
      assert_state_variable :last_posting_date, "23 March 2013"
      assert_state_variable :funds_cleared_by, "5 April 2013"
    end
  end
end
