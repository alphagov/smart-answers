require_relative '../test_helper'

class FriendlyTimeDiffTest < Minitest::Test
  include FriendlyTimeDiff

  should "calculate whole years" do
    diff = friendly_time_diff(Date.parse('2013-01-01'), Date.parse('2014-01-01'))
    assert_equal "1 year", diff
  end

  should "calculate whole months" do
    diff = friendly_time_diff(Date.parse('2013-01-01'), Date.parse('2013-02-01'))
    assert_equal "1 month", diff
  end

  should "calculate whole days" do
    diff = friendly_time_diff(Date.parse('2013-01-01'), Date.parse('2013-01-02'))
    assert_equal "1 day", diff
  end

  should "pluralize" do
    diff = friendly_time_diff(Date.parse('2013-01-01'), Date.parse('2013-01-03'))
    assert_equal "2 days", diff
  end

  should "combine whole years, months and days" do
    diff = friendly_time_diff(Date.parse('2013-01-01'), Date.parse('2014-02-02'))
    assert_equal "1 year, 1 month, 1 day", diff
  end

  should "skip empty elements" do
    diff = friendly_time_diff(Date.parse('2013-01-01'), Date.parse('2014-01-02'))
    assert_equal "1 year, 1 day", diff
  end

  should "not be confused by differing month lengths" do
    diff = friendly_time_diff(Date.parse('2013-02-01'), Date.parse('2013-03-01'))
    assert_equal "1 month", diff
  end

  should "not be confused by leap years" do
    diff = friendly_time_diff(Date.parse('2008-02-01'), Date.parse('2008-03-01'))
    assert_equal "1 month", diff
  end

  should "perform calculations using the UTC date" do
    from = Time.zone.parse('2008-01-02 01:59 +02:00') # equivalent to 2008-01-01 23:59 +00:00
    diff = friendly_time_diff(from, Date.parse("2008-01-02"))
    assert_equal "1 day", diff
  end

  should "avoid edge cases with dates at the end of the month" do
    assert_equal "9 months", friendly_time_diff(Date.parse('1960-12-30'), Date.parse("1961-09-30"))
  end

  should "avoid year rounding errors" do
    assert_equal "11 months, 29 days", friendly_time_diff(Date.parse('1960-12-31'), Date.parse("1961-12-29"))
  end

  should "avoid edge cases for 29th feb" do
    assert_equal "4 years", friendly_time_diff(Date.parse('2004-02-29'), Date.parse("2008-02-29"))
    assert_equal "4 years, 1 day", friendly_time_diff(Date.parse('2004-02-29'), Date.parse("2008-03-01"))
  end
end
