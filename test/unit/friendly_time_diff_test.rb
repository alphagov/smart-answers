require_relative '../test_helper'

class FriendlyTimeDiffTest < MiniTest::Unit::TestCase
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
end
