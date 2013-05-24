# coding:utf-8

require_relative '../test_helper'

module SmartAnswer
  class CalendarTest < ActiveSupport::TestCase
    setup do
      @state = State.new(:example).transition_to(:result, 'y')
    end

    test "a CalendarState has no dates when initialized" do
      calendar_state = CalendarState.new(@state)
      assert_equal [ ], calendar_state.dates
    end

    test "can initialize a CalendarState with a block of dates" do
      calendar_state = CalendarState.new(@state) do
        date :event_date, Date.parse("17 October 2012")
      end

      assert_equal [ OpenStruct.new(:title => :event_date, :date => Date.parse("17 October 2012")) ], calendar_state.dates
    end

    test "can initialize a CalendarState with a range" do
      calendar_state = CalendarState.new(@state) do
        date :event_range, Date.parse("20 October 2012")..Date.parse("21 October 2012")
      end

      assert_equal [ OpenStruct.new(:title => :event_range, :date => Date.parse("20 October 2012")..Date.parse("21 October 2012")) ], calendar_state.dates
    end

    test "joins the path of the current state" do
      state = @state.transition_to(:question, 'test').transition_to(:result_two, 'test')
      calendar_state = CalendarState.new(state)
      assert_equal "example/result/question", calendar_state.path
    end

    test "can create an ics renderer with a calendar state" do
      calendar_state = CalendarState.new(@state)
      calendar_state.stubs(:dates).returns([:date_one, :date_two])

      stub_renderer = stub(:render => "calendar output")

      ICSRenderer.any_instance.stubs(:dtstamp).returns("20121017T0100Z")
      ICSRenderer.expects(:new).with([:date_one, :date_two], "example").returns(stub_renderer)

      assert_equal "calendar output", calendar_state.to_ics
    end
  end
end
