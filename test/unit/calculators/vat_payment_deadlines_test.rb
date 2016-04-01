require_relative "../../test_helper"

module SmartAnswer::Calculators
  class VatPaymentDeadlinesTest < ActiveSupport::TestCase
    setup do
      WebMock.stub_request(:get, WorkingDays::BANK_HOLIDAYS_URL).
        to_return(body: File.open(fixture_file('bank_holidays.json')))
    end

    context "payment dates for direct-debit" do
      should "calculate last_payment_date where end of month is not a work day" do
        ['direct-debit'].each do |pay_method|
          calc = VatPaymentDeadlines.new(Date.parse('2013-10-31'), pay_method)
          assert_equal Date.parse('2013-12-04'), calc.last_payment_date

          calc = VatPaymentDeadlines.new(Date.parse('2014-04-30'), pay_method)
          assert_equal Date.parse('2014-06-04'), calc.last_payment_date

          calc = VatPaymentDeadlines.new(Date.parse('2014-07-31'), pay_method)
          assert_equal Date.parse('2014-09-03'), calc.last_payment_date
        end
      end
    end

    context "bank-giro" do
      should "calculate last_payment_date where end of month is not a work day" do
        ['bank-giro'].each do |pay_method|
          calc = VatPaymentDeadlines.new(Date.parse('2013-10-31'), pay_method)
          assert_equal Date.parse('2013-12-04'), calc.last_payment_date

          calc = VatPaymentDeadlines.new(Date.parse('2014-04-30'), pay_method)
          assert_equal Date.parse('2014-06-04'), calc.last_payment_date

          calc = VatPaymentDeadlines.new(Date.parse('2014-07-31'), pay_method)
          assert_equal Date.parse('2014-09-03'), calc.last_payment_date
        end
      end
    end

    context "dates for direct-debit" do
      should "calculate last_payment_date as end_of_month_after(end_date) + 7 calendar days - 2 working days" do
        calc = VatPaymentDeadlines.new(Date.parse('2013-04-30'), 'direct-debit')
        assert_equal Date.parse('2013-06-05'), calc.last_payment_date
      end

      should "calculate funds_received_by as end_of_month_after(end_date) + 7 calendar days + 3 working days where end_of_month_after(end_date) is a work day" do
        calc = VatPaymentDeadlines.new(Date.parse('2013-04-30'), 'direct-debit')
        assert_equal Date.parse('2013-06-05'), calc.last_payment_date
        assert_equal Date.parse('2013-06-12'), calc.funds_received_by
      end

      should "calculate funds_received_by as end_of_month_after(end_date) + 7 calendar days + 3 working days where end_of_month_after(end_date) is not a work day" do
        calc = VatPaymentDeadlines.new(Date.parse('2014-04-30'), 'direct-debit')
        assert_equal Date.parse('2014-06-04'), calc.last_payment_date
        assert_equal Date.parse('2014-06-11'), calc.funds_received_by
      end
    end

    context "dates for online/telephone banking" do
      setup do
        @method = 'online-telephone-banking'
      end

      should "calculate last_payment_date as end_of_month_after(end_date) + 7 days" do
        calc = VatPaymentDeadlines.new(Date.parse('2013-04-30'), @method)
        assert_equal Date.parse('2013-06-07'), calc.last_payment_date
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
        should "calculate last_payment_date as end_of_month_after(end_date) + 7 calendar days - 3 working days" do
          calc = VatPaymentDeadlines.new(Date.parse('2013-04-30'), method)
          assert_equal Date.parse('2013-06-05'), calc.last_payment_date
        end

        should "calculate funds_received_by as end_of_month_after(end_date) + 7 days if that's a work day" do
          calc = VatPaymentDeadlines.new(Date.parse('2013-04-30'), method)
          assert_equal Date.parse('2013-06-07'), calc.funds_received_by
        end

        should "calculate funds_received_by as last working day before end_of_month_after(end_date) + 7 days if that's a non-work day" do
          calc = VatPaymentDeadlines.new(Date.parse('2013-05-31'), method)
          assert_equal Date.parse('2013-07-05'), calc.funds_received_by
        end
      end
    end

    context "dates for CHAPS" do
      setup do
        @method = 'chaps'
      end

      should "The last date you can pay is [period_end_date + 1 calendar month + 7 calendar days. If the 7th is a BH or WE go back to the last preceding working day. Same for either payment date and funds_received_by date" do
        calc = VatPaymentDeadlines.new(Date.parse('2013-11-30'), @method)
        assert_equal Date.parse('2014-01-07'), calc.last_payment_date
        assert_equal Date.parse('2014-01-07'), calc.funds_received_by

        calc = VatPaymentDeadlines.new(Date.parse('2014-03-31'), @method)
        assert_equal Date.parse('2014-05-07'), calc.last_payment_date
        assert_equal Date.parse('2014-05-07'), calc.funds_received_by

        calc = VatPaymentDeadlines.new(Date.parse('2014-11-30'), @method)
        assert_equal Date.parse('2015-01-07'), calc.last_payment_date
        assert_equal Date.parse('2015-01-07'), calc.funds_received_by

        calc = VatPaymentDeadlines.new(Date.parse('2015-02-28'), @method)
        assert_equal Date.parse('2015-04-07'), calc.last_payment_date
        assert_equal Date.parse('2015-04-07'), calc.funds_received_by

        calc = VatPaymentDeadlines.new(Date.parse('2015-03-31'), @method)
        assert_equal Date.parse('2015-05-07'), calc.last_payment_date
        assert_equal Date.parse('2015-05-07'), calc.funds_received_by

        calc = VatPaymentDeadlines.new(Date.parse('2015-11-30'), @method)
        assert_equal Date.parse('2016-01-07'), calc.last_payment_date
        assert_equal Date.parse('2016-01-07'), calc.funds_received_by
      end
    end

    context "dates for cheque" do
      setup do
        @method = 'cheque'
      end

      should "calculate last_payment_date as last working day of end_of_month_after(end_date) - 6 working days" do
        calc = VatPaymentDeadlines.new(Date.parse('2013-04-30'), @method)
        assert_equal Date.parse('2013-05-22'), calc.last_payment_date
      end

      should "calculate funds_received_by as last working day of end_of_month_after(end_date)" do
        calc = VatPaymentDeadlines.new(Date.parse('2013-04-30'), @method)
        assert_equal Date.parse('2013-05-31'), calc.funds_received_by

        calc = VatPaymentDeadlines.new(Date.parse('2013-03-31'), @method)
        assert_equal Date.parse('2013-04-30'), calc.funds_received_by
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
