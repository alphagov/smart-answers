require_relative "../../test_helper"

module SmartAnswer::Calculators
  class VatPaymentDeadlinesTest < ActiveSupport::TestCase
    setup do
      WebMock.stub_request(:get, WorkingDays::BANK_HOLIDAYS_URL).
        to_return(:body => File.open(fixture_file('bank_holidays.json')))
    end

    context "dates for direct-debit" do
      setup do
        @method = 'direct-debit'
      end

      should "calculate last_payment_date as end_date + 1 month + 5 working days" do
        calc = VatPaymentDeadlines.new(Date.parse('2013-04-30'), @method)
        assert_equal Date.parse('2013-06-06'), calc.last_payment_date
      end

      should "calculate funds_received_by as end_date + 1 month + 7 days + 3 working days" do
        calc = VatPaymentDeadlines.new(Date.parse('2013-04-30'), @method)
        assert_equal Date.parse('2013-06-11'), calc.funds_received_by
      end
    end

    context "dates for online/telephone banking" do
      setup do
        @method = 'online-telephone-banking'
      end

      should "calculate last_payment_date as end_date + 1 month + 7 days" do
        calc = VatPaymentDeadlines.new(Date.parse('2013-04-30'), @method)
        assert_equal Date.parse('2013-06-06'), calc.last_payment_date
      end

      should "handle different month lengths correctly" do
        # 31st Jan + 1 month should be 28th Feb
        calc = VatPaymentDeadlines.new(Date.parse('2013-01-31'), @method)
        assert_equal Date.parse('2013-03-07'), calc.last_payment_date
      end

      should "be last_payment_date for funds_received_by" do
        # This is called for all payment methods, so it needs to return a date
        calc = VatPaymentDeadlines.new(Date.parse('2013-04-30'), @method)
        assert_equal calc.last_payment_date, calc.funds_received_by
      end
    end

    ['online-debit-credit-card', 'bacs-direct-credit', 'bank-giro'].each do |method|
      context "dates for #{method}" do
        should "calculate last_payment_date as end_date + 1 month + 4 working days" do
          calc = VatPaymentDeadlines.new(Date.parse('2013-04-30'), method)
          assert_equal Date.parse('2013-06-05'), calc.last_payment_date
        end

        should "calculate funds_received_by as end_date + 1 month + 7 days" do
          calc = VatPaymentDeadlines.new(Date.parse('2013-04-30'), method)
          assert_equal Date.parse('2013-06-06'), calc.funds_received_by
        end
      end
    end

    context "dates for CHAPS" do
      setup do
        @method = 'chaps'
      end

      should "calculate last_payment_date as end_date + 1 month + 7 working days" do
        calc = VatPaymentDeadlines.new(Date.parse('2013-04-30'), @method)
        assert_equal Date.parse('2013-06-10'), calc.last_payment_date
      end

      should "calculate funds_received_by as end_date + 1 month + 7 working days" do
        calc = VatPaymentDeadlines.new(Date.parse('2013-04-30'), @method)
        assert_equal Date.parse('2013-06-10'), calc.funds_received_by
      end
    end

    context "dates for cheque" do
      setup do
        @method = 'cheque'
      end

      should "calculate last_payment_date as end_date - 3 days - 3 working days" do
        calc = VatPaymentDeadlines.new(Date.parse('2013-04-30'), @method)
        assert_equal Date.parse('2013-04-23'), calc.last_payment_date
      end

      should "calculate funds_received_by as last working day before end_date" do
        calc = VatPaymentDeadlines.new(Date.parse('2013-04-30'), @method)
        assert_equal Date.parse('2013-04-30'), calc.funds_received_by

        calc = VatPaymentDeadlines.new(Date.parse('2013-03-31'), @method)
        assert_equal Date.parse('2013-03-28'), calc.funds_received_by
      end
    end

    context "with an invalid payment method" do

      should "raise an ArgumentError for last_payment_date" do
        assert_raise ArgumentError do
          VatPaymentDeadlines.new(Date.parse('2013-04-30'), 'fooey').last_payment_date
        end
      end

      should "raise an ArgumentError for funds_received_by" do
        assert_raise ArgumentError do
          VatPaymentDeadlines.new(Date.parse('2013-04-30'), 'fooey').funds_received_by
        end
      end
    end
  end
end
