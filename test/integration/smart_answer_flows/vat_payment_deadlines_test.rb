require_relative '../../test_helper'
require_relative 'flow_test_helper'

require "smart_answer_flows/vat-payment-deadlines"

class VatPaymentDeadlinesTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    WebMock.stub_request(:get, WorkingDays::BANK_HOLIDAYS_URL).
      to_return(body: File.open(fixture_file('bank_holidays.json')))
    setup_for_testing_flow SmartAnswer::VatPaymentDeadlinesFlow
  end

  should "ask when your VAT accounting period ends" do
    assert_current_node :when_does_your_vat_accounting_period_end?
  end

  context "invalid dates" do
    should "show error with non end-of-month date" do
      add_response '2013-05-30'
      assert_current_node :when_does_your_vat_accounting_period_end?, error: true
    end

    should "handle leap years correctly" do
      add_response '2012-02-28'
      assert_current_node :when_does_your_vat_accounting_period_end?, error: true
    end
  end

  context "given a date that's the end of a month" do
    setup do
      add_response '2013-04-30'
    end

    should "ask how you want to pay" do
      assert_current_node :how_do_you_want_to_pay?
    end
  end
end
