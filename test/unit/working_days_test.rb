require_relative "../test_helper"
require 'working_days'

class WorkingDaysTest < ActiveSupport::TestCase
  setup do
    WebMock.stub_request(:get, WorkingDays::BANK_HOLIDAYS_URL).
      to_return(body: File.open(fixture_file('bank_holidays.json')))
  end

  context "adding working days" do
    should "add the given number of days to the date" do
      assert_equal Date.parse('2013-04-11'), 3.working_days.after(Date.parse('2013-04-08'))
    end

    should "not include weekends" do
      assert_equal Date.parse('2013-04-16'), 3.working_days.after(Date.parse('2013-04-11'))
    end

    should "not include bank holidays" do
      assert_equal Date.parse('2013-05-08'), 4.working_days.after(Date.parse('2013-05-01'))
    end

    should "handle starting on a weekend or bank holiday" do
      # Saturday
      assert_equal Date.parse('2013-04-10'), 3.working_days.after(Date.parse('2013-04-06'))
      # Sunday
      assert_equal Date.parse('2013-04-10'), 3.working_days.after(Date.parse('2013-04-07'))
      # Bank holiday
      assert_equal Date.parse('2013-04-04'), 3.working_days.after(Date.parse('2013-04-01'))
    end

    should "handle ending on a weekend or bank holiday" do
      # Sunday
      assert_equal Date.parse('2013-04-15'), 2.working_days.after(Date.parse('2013-04-11'))
      # Bank holiday
      assert_equal Date.parse('2013-05-28'), 2.working_days.after(Date.parse('2013-05-23'))
    end
  end

  context "subtracting working days" do
    should "subtract the given number of days from the date" do
      assert_equal Date.parse('2013-04-08'), 3.working_days.before(Date.parse('2013-04-11'))
    end

    should "not inlcude weekends" do
      assert_equal Date.parse('2013-04-11'), 3.working_days.before(Date.parse('2013-04-16'))
    end

    should "not include bank holidays" do
      assert_equal Date.parse('2013-05-01'), 4.working_days.before(Date.parse('2013-05-08'))
    end

    should "handle starting on a weekend or bank holiday" do
      # Saturday
      assert_equal Date.parse('2013-04-03'), 3.working_days.before(Date.parse('2013-04-06'))
      # Sunday
      assert_equal Date.parse('2013-04-03'), 3.working_days.before(Date.parse('2013-04-07'))
      # Bank holiday
      assert_equal Date.parse('2013-03-26'), 3.working_days.before(Date.parse('2013-03-29'))
    end

    should "handle ending on a weekend or bank holiday" do
      # Sunday
      assert_equal Date.parse('2013-04-12'), 2.working_days.before(Date.parse('2013-04-16'))
      # Bank holiday
      assert_equal Date.parse('2013-05-24'), 2.working_days.before(Date.parse('2013-05-29'))
    end
  end

  context "loading bank holidays" do
    setup do
      WorkingDays.instance_variable_set('@bank_holidays', nil)
    end

    should "load the bank holidays for england and wales from www.gov.uk" do
      holidays = WorkingDays.bank_holidays
      expected = [
        Date.parse("2013-01-01"),
        Date.parse("2013-03-29"),
        Date.parse("2013-04-01"),
        Date.parse("2013-05-06"),
        Date.parse("2013-05-27"),
        Date.parse("2013-08-26"),
      ]
      assert_equal expected, holidays
    end

    should "memoize the loaded holidays" do
      WorkingDays.bank_holidays
      WorkingDays.bank_holidays

      WebMock.assert_requested(:get, "https://www.gov.uk/bank-holidays.json", times: 1)
    end
  end
end
