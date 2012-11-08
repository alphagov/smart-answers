# coding:utf-8

require_relative '../test_helper'

module SmartAnswer
  class CalendarTest < ActiveSupport::TestCase

    setup do
      @state = State.new(:example)
    end

    test "a calendar has no dates when initialized" do
      calendar = Calendar.new
      assert_equal [ ], calendar.evaluate(@state).dates
    end

    test "can initialize a calendar with a date" do
      calendar = Calendar.new do
        date :event_date, Date.parse("17 October 2012")
      end

      assert_equal [[:event_date, Date.parse("17 October 2012")]], calendar.evaluate(@state).dates
    end

    test "can initialize a calendar with a range" do
      calendar = Calendar.new do
        date :event_range, Date.parse("20 October 2012")..Date.parse("21 October 2012")
      end

      assert_equal [[:event_range, Date.parse("20 October 2012")..Date.parse("21 October 2012")]], calendar.evaluate(@state).dates
    end

    test "will output ics for given dates" do
      calendar = Calendar.new do
        date :event_one, Date.parse("13 October 2012")..Date.parse("14 October 2012")
        date :event_two, Date.parse("20 October 2012")..Date.parse("21 October 2012")
        date :event_three, Date.parse("4 November 2012")
      end

      output = calendar.evaluate(@state).to_ics

      assert_match "BEGIN:VEVENT\r\nDTEND;VALUE=DATE:20121014\r\nDTSTART;VALUE=DATE:20121013\r\nSUMMARY:event_one\r\nEND:VEVENT", output
      assert_match "BEGIN:VEVENT\r\nDTEND;VALUE=DATE:20121021\r\nDTSTART;VALUE=DATE:20121020\r\nSUMMARY:event_two\r\nEND:VEVENT", output
      assert_match "BEGIN:VEVENT\r\nDTEND;VALUE=DATE:20121104\r\nDTSTART;VALUE=DATE:20121104\r\nSUMMARY:event_three\r\nEND:VEVENT", output
    end
  end
end
