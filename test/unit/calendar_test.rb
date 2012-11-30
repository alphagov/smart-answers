# coding:utf-8

require_relative '../test_helper'

module SmartAnswer
  class CalendarTest < ActiveSupport::TestCase

    setup do
      @state = State.new(:example).transition_to(:result, 'y')
    end

    test "a calendar has no dates when initialized" do
      calendar = Calendar.new
      assert_equal [ ], calendar.evaluate(@state).dates
    end

    test "can initialize a calendar with a date" do
      calendar = Calendar.new do
        date :event_date, Date.parse("17 October 2012")
      end

      assert_equal [ OpenStruct.new(:title => :event_date, :date => Date.parse("17 October 2012")) ], calendar.evaluate(@state).dates
    end

    test "can initialize a calendar with a range" do
      calendar = Calendar.new do
        date :event_range, Date.parse("20 October 2012")..Date.parse("21 October 2012")
      end

      assert_equal [ OpenStruct.new(:title => :event_range, :date => Date.parse("20 October 2012")..Date.parse("21 October 2012")) ], calendar.evaluate(@state).dates
    end

    test "can create an ics renderer with the dates and the path" do
      calendar = Calendar.new
      calendar.stubs(:dates).returns([:date_one, :date_two])

      stub_renderer = stub(:render => "calendar output")

      ICSRenderer.any_instance.stubs(:dtstamp).returns("20121017T0100Z")
      ICSRenderer.expects(:new).with([:date_one, :date_two], "example").returns(stub_renderer)

      assert_equal "calendar output", calendar.evaluate(@state).to_ics
    end
  end
end
