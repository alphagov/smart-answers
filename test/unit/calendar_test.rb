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
  end
end
