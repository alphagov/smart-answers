# encoding: UTF-8
require_relative 'engine_test_helper'

class CalendarExportTest < EngineIntegrationTest

  should "output calendars correctly" do
    visit "/calendars-sample/y/contestant_c"

    within '.result-info' do
      assert page.has_link? "Add dates to your calendar"
    end

    click_on "Add dates to your calendar"
    assert_calendar_has_event Date.parse("12 January 2013")
  end

  should "not render a calendar if one is not present" do
    visit "/calendars-sample/y/contestant_a"

    within '.result-info' do
      assert ! page.has_link?("Add dates to your calendar")
    end
  end

  should "return a 404 status when loading a calendar if none present" do
    visit "/calendars-sample/y/contestant_a.ics"

    assert_equal 404, page.status_code
  end

  def assert_calendar_has_event(date)
    assert_match "DTEND;VALUE=DATE:#{date.strftime('%Y%m%d')}\nDTSTART;VALUE=DATE:#{date.strftime('%Y%m%d')}", page.body
  end
end
