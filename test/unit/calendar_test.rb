# coding:utf-8

require_relative '../test_helper'

module SmartAnswer
  class CalendarTest < ActiveSupport::TestCase

    test "a calendar has no dates when initialized" do
      calendar = Calendar.new
      assert_equal [ ], calendar.dates
    end

    test "can initialize a calendar with a date" do
      calendar = Calendar.new do
        date :event_date, Date.parse("17 October 2012")
      end

      assert_equal [[:event_date, Date.parse("17 October 2012")]], calendar.dates
    end

    test "can initialize a calendar with a range" do
      calendar = Calendar.new do
        date :event_range, Date.parse("20 October 2012")..Date.parse("21 October 2012")
      end

      assert_equal [[:event_range, Date.parse("20 October 2012")..Date.parse("21 October 2012")]], calendar.dates
    end

    test "will output ics for given dates" do
      calendar = Calendar.new do
        date :event_one, Date.parse("13 October 2012")..Date.parse("14 October 2012")
        date :event_two, Date.parse("20 October 2012")..Date.parse("21 October 2012")
        date :event_three, Date.parse("4 November 2012")
      end

      output = calendar.to_ics

      assert_match "BEGIN:VEVENT\nDTEND;VALUE=DATE:20121014\nDTSTART;VALUE=DATE:20121013\nSUMMARY:event_one\nEND:VEVENT", output
      assert_match "BEGIN:VEVENT\nDTEND;VALUE=DATE:20121021\nDTSTART;VALUE=DATE:20121020\nSUMMARY:event_two\nEND:VEVENT", output
      assert_match "BEGIN:VEVENT\nDTEND;VALUE=DATE:20121104\nDTSTART;VALUE=DATE:20121104\nSUMMARY:event_three\nEND:VEVENT", output
    end
  end
end
