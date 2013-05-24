# coding:utf-8

require_relative '../test_helper'

module SmartAnswer
  class CalendarTest < ActiveSupport::TestCase

    setup do
      @state = State.new(:example).transition_to(:result, 'y')
    end

    test "a calendar returns an instance of CalendarState when evaluated" do
      calendar = Calendar.new do |response|
        date :event_date, Date.parse("1 October 2012")
      end
      CalendarState.stubs(:new).with(@state).returns("Calendar state")
      calendar_state = calendar.evaluate(@state)

      assert_equal "Calendar state", calendar_state
    end

    test "can create an ics renderer with a calendar state" do
      calendar = Calendar.new
      calendar_state = CalendarState.new(@state)
      calendar_state.stubs(:dates).returns([:date_one, :date_two])

      stub_renderer = stub(:render => "calendar output")

      ICSRenderer.any_instance.stubs(:dtstamp).returns("20121017T0100Z")
      ICSRenderer.expects(:new).with([:date_one, :date_two], "example").returns(stub_renderer)

      assert_equal "calendar output", calendar.to_ics(calendar_state)
    end
  end
end
