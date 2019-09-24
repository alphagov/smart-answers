require_relative "../test_helper"

module SmartAnswer
  class DateRangeTest < ActiveSupport::TestCase
    context "when range is built with begins_on & ends_on" do
      setup do
        @date_range = DateRange.new(begins_on: Date.parse("2000-01-01"), ends_on: Date.parse("2000-01-07"))
      end

      should "begin on begins_on date" do
        assert_equal Date.parse("2000-01-01"), @date_range.begins_on
      end

      should "end on ends_on date" do
        assert_equal Date.parse("2000-01-07"), @date_range.ends_on
      end

      should "include begins_on date" do
        assert @date_range.include?(Date.parse("2000-01-01"))
      end

      should "include ends_on date" do
        assert @date_range.include?(Date.parse("2000-01-07"))
      end

      should "include date between begins_on and ends_on" do
        assert @date_range.include?(Date.parse("2000-01-03"))
      end

      should "include time between begins_on and ends_on" do
        assert @date_range.include?(Time.parse("2000-01-03 03:03:03"))
      end

      should "not include date before begins_on" do
        refute @date_range.include?(Date.parse("1999-12-31"))
      end

      should "not include date infinitely before begins_on" do
        refute @date_range.include?(-Date::Infinity.new)
      end

      should "not include date infinitely after ends_on" do
        refute @date_range.include?(Date::Infinity.new)
      end

      should "not include date after ends_on" do
        refute @date_range.include?(Date.parse("2000-01-08"))
      end

      should "calculate number of days in range" do
        assert_equal 7, @date_range.number_of_days
      end

      should "calculate non_inclusive_days days in range" do
        assert_equal 6, @date_range.non_inclusive_days
      end

      should "equal another DateRange with the same begins_on & ends_on" do
        assert @date_range == @date_range.dup
      end

      should "not equal another DateRange with a different begins_on" do
        refute @date_range == DateRange.new(begins_on: @date_range.begins_on + 1, ends_on: @date_range.ends_on)
      end

      should "not equal another DateRange with a different ends_on" do
        refute @date_range == DateRange.new(begins_on: @date_range.begins_on, ends_on: @date_range.ends_on + 1)
      end

      should "equal an object which is a subclass of DateRange" do
        sub_class_instance = Class.new(DateRange).new(begins_on: @date_range.begins_on, ends_on: @date_range.ends_on)
        assert @date_range == sub_class_instance
      end

      should "be equivalent to another DateRange with the same begins_on & ends_on" do
        assert @date_range.eql?(@date_range.dup)
      end

      should "not be equivalent to an object which is a subclass of DateRange" do
        sub_class_instance = Class.new(DateRange).new(begins_on: @date_range.begins_on, ends_on: @date_range.ends_on)
        refute @date_range.eql?(sub_class_instance)
      end

      should "have same hash as another DateRange with the same begins_on & ends_on" do
        assert_equal @date_range.hash, @date_range.dup.hash
      end

      should "not have same hash as a subclass of DateRange with the same begins_on & ends_on" do
        sub_class_instance = Class.new(DateRange).new(begins_on: @date_range.begins_on, ends_on: @date_range.ends_on)
        refute_equal sub_class_instance.hash, @date_range.hash
      end

      should "allow increase by X days" do
        new_range = @date_range + 10
        assert_equal new_range.begins_on, @date_range.begins_on + 10
        assert_equal new_range.ends_on, @date_range.ends_on + 10
      end

      should "allow increase by X weeks" do
        new_range = @date_range.weeks_after 1
        assert_equal new_range.begins_on, @date_range.begins_on + 7
        assert_equal new_range.ends_on, @date_range.ends_on + 7

        new_range = @date_range.weeks_after 2
        assert_equal new_range.begins_on, @date_range.begins_on + 7 * 2
        assert_equal new_range.ends_on, @date_range.ends_on + 7 * 2
      end

      should "return a formatted string" do
        assert_equal "01 January 2000 to 07 January 2000", @date_range.to_s
      end
    end

    context "when range is built with begins_on & ends_on as instances of Time" do
      setup do
        @date_range = DateRange.new(begins_on: Time.parse("2000-01-01 01:01:01"), ends_on: Time.parse("2000-01-07 07:07:07"))
      end

      should "begin on begins_on date" do
        assert_equal Date.parse("2000-01-01"), @date_range.begins_on
      end

      should "end on ends_on date" do
        assert_equal Date.parse("2000-01-07"), @date_range.ends_on
      end
    end

    context "when range is built with no ends_on" do
      setup do
        @date_range = DateRange.new(begins_on: Date.parse("2000-01-01"))
      end

      should "have infinite ends_on" do
        assert @date_range.ends_on.infinite?
      end

      should "include date far in the future" do
        assert @date_range.include?(Date.parse("9999-01-01"))
      end

      should "include date infinitely far in the future" do
        assert @date_range.include?(Date::Infinity.new)
      end

      should "have infinite number of days" do
        assert @date_range.number_of_days.infinite?
      end

      should "be infinite" do
        assert @date_range.infinite?
      end
    end

    context "when range is built with nil ends_on" do
      setup do
        @date_range = DateRange.new(ends_on: nil)
      end

      should "have infinite ends_on" do
        assert @date_range.ends_on.infinite?
      end
    end

    context "when range is built with no begins_on" do
      setup do
        @date_range = DateRange.new(ends_on: Date.parse("2000-01-01"))
      end

      should "have infinite begins_on" do
        assert @date_range.begins_on.infinite?
      end

      should "include date far in the past" do
        assert @date_range.include?(Date.parse("0000-01-01"))
      end

      should "include date infinitely far in the past" do
        assert @date_range.include?(-Date::Infinity.new)
      end

      should "have infinite number of days" do
        assert @date_range.number_of_days.infinite?
      end

      should "be infinite" do
        assert @date_range.infinite?
      end
    end

    context "when range is built with nil begins_on" do
      setup do
        @date_range = DateRange.new(begins_on: nil)
      end

      should "have infinite begins_on" do
        assert @date_range.begins_on.infinite?
      end
    end

    context "when range includes leap day" do
      setup do
        @date_range = DateRange.new(begins_on: Date.parse("2000-01-01"), ends_on: Date.parse("2000-12-31"))
      end

      should "include leap day" do
        assert @date_range.include?(Date.parse("2000-02-29"))
      end

      should "count leap day in number of days" do
        assert_equal 366, @date_range.number_of_days
      end
    end

    context "when range ends on the same day it begins" do
      setup do
        @date_range = DateRange.new(begins_on: Date.parse("2000-01-01"), ends_on: Date.parse("2000-01-01"))
      end

      should "include begins_on date" do
        assert @date_range.include?(@date_range.begins_on)
      end

      should "contain one day" do
        assert_equal 1, @date_range.number_of_days
      end

      should "not be empty" do
        refute @date_range.empty?
      end

      should "not be infinite" do
        refute @date_range.infinite?
      end
    end

    context "when range ends before it begins" do
      setup do
        @date_range = DateRange.new(begins_on: Date.parse("2000-12-31"), ends_on: Date.parse("2000-01-01"))
      end

      should "not include begins_on date" do
        refute @date_range.include?(@date_range.begins_on)
      end

      should "not include ends_on date" do
        refute @date_range.include?(@date_range.ends_on)
      end

      should "contain a non positive amount days" do
        refute @date_range.number_of_days.positive?
      end

      should "be empty" do
        assert @date_range.empty?
      end

      should "not modify the ends_on date" do
        assert_equal Date.parse("2000-01-01"), @date_range.ends_on
      end
    end

    context "intersection of" do
      context "two overlapping DateRanges" do
        setup do
          @date_range = DateRange.new(begins_on: Date.parse("2000-01-01"), ends_on: Date.parse("2000-12-31"))
          @overlapping = DateRange.new(begins_on: Date.parse("2000-06-01"), ends_on: Date.parse("2001-05-31"))
        end

        should "be the intersection of the two periods" do
          intersection = @date_range & @overlapping
          assert_equal DateRange.new(begins_on: @overlapping.begins_on, ends_on: @date_range.ends_on), intersection
        end
      end

      context "two non-overlapping DateRanges" do
        setup do
          @date_range = DateRange.new(begins_on: Date.parse("2000-01-01"), ends_on: Date.parse("2000-12-31"))
          @non_overlapping = DateRange.new(begins_on: Date.parse("2002-01-01"), ends_on: Date.parse("2002-12-31"))
        end

        should "be an empty DateRange" do
          intersection = @date_range & @non_overlapping
          assert intersection.empty?
        end
      end

      context "two infinite overlapping DateRanges" do
        setup do
          @date_range = DateRange.new(ends_on: Date.parse("2000-12-31"))
          @overlapping = DateRange.new(begins_on: Date.parse("2000-06-01"))
        end

        should "be the intersection of the two periods" do
          intersection = @date_range & @overlapping
          assert_equal DateRange.new(begins_on: @overlapping.begins_on, ends_on: @date_range.ends_on), intersection
        end
      end
    end

    context "begins_before?" do
      setup do
        @date_range = DateRange.new(begins_on: Date.parse("2000-01-02"))
      end

      should "be true if date range starts before specified date range" do
        starts_before = DateRange.new(begins_on: Date.parse("2000-01-01"))
        assert starts_before.begins_before?(@date_range)
      end

      should "be true if date range starts infinitely before specified date range" do
        starts_before = DateRange.new(begins_on: nil)
        assert starts_before.begins_before?(@date_range)
      end

      should "be false if date range starts on same day as specified date range" do
        does_not_start_before = @date_range.dup
        refute does_not_start_before.begins_before?(@date_range)
      end

      should "be false if date range starts after specified infinite date range" do
        does_not_start_after = DateRange.new(begins_on: nil)
        refute @date_range.begins_before?(does_not_start_after)
      end
    end

    context "between" do
      context "two overlapping date ranges" do
        setup do
          @date_range = DateRange.new(begins_on: Date.parse("2000-01-01"), ends_on: Date.parse("2000-12-31"))
          @overlapping = DateRange.new(begins_on: Date.parse("2000-06-01"), ends_on: Date.parse("2001-05-31"))
        end

        should "return an empty date range, because there is no gap" do
          gap = @date_range.gap_between(@overlapping)
          assert gap.empty?
        end
      end

      context "two infinite overlapping date ranges" do
        setup do
          @date_range = DateRange.new(ends_on: Date.parse("2000-12-31"))
          @overlapping = DateRange.new(begins_on: Date.parse("2000-06-01"))
        end

        should "return an empty date range, because there is no gap" do
          gap = @date_range.gap_between(@overlapping)
          assert gap.empty?
        end
      end

      context "two non-overlapping date ranges" do
        setup do
          @date_range = DateRange.new(begins_on: Date.parse("2000-01-01"), ends_on: Date.parse("2000-12-31"))
          @non_overlapping = DateRange.new(begins_on: Date.parse("2002-01-01"), ends_on: Date.parse("2002-12-31"))
        end

        should "return the gap between the two date ranges" do
          gap = @date_range.gap_between(@non_overlapping)
          assert_equal DateRange.new(begins_on: Date.parse("2001-01-01"), ends_on: Date.parse("2001-12-31")), gap
        end

        should "be commutative" do
          gap = @non_overlapping.gap_between(@date_range)
          assert_equal DateRange.new(begins_on: Date.parse("2001-01-01"), ends_on: Date.parse("2001-12-31")), gap
        end
      end

      context "two non-overlapping infinite date ranges" do
        setup do
          @date_range = DateRange.new(ends_on: Date.parse("2000-12-31"))
          @non_overlapping = DateRange.new(begins_on: Date.parse("2002-01-01"))
        end

        should "return the gap between the two date ranges" do
          gap = @date_range.gap_between(@non_overlapping)
          assert_equal DateRange.new(begins_on: Date.parse("2001-01-01"), ends_on: Date.parse("2001-12-31")), gap
        end
      end
    end

    context "friendly_time_diff" do
      should "calculate whole years" do
        diff = DateRange.new(
          begins_on: Date.parse("2013-01-01"),
          ends_on: Date.parse("2014-01-01"),
        ).friendly_time_diff
        assert_equal "1 year", diff
      end

      should "calculate whole months" do
        diff = DateRange.new(
          begins_on: Date.parse("2013-01-01"),
          ends_on: Date.parse("2013-02-01"),
        ).friendly_time_diff
        assert_equal "1 month", diff
      end

      should "calculate whole days" do
        diff = DateRange.new(
          begins_on: Date.parse("2013-01-01"),
          ends_on: Date.parse("2013-01-02"),
        ).friendly_time_diff
        assert_equal "1 day", diff
      end

      should "pluralize" do
        diff = DateRange.new(
          begins_on: Date.parse("2013-01-01"),
          ends_on: Date.parse("2013-01-03"),
        ).friendly_time_diff
        assert_equal "2 days", diff
      end

      should "combine whole years, months and days" do
        diff = DateRange.new(
          begins_on: Date.parse("2013-01-01"),
          ends_on: Date.parse("2014-02-02"),
        ).friendly_time_diff
        assert_equal "1 year, 1 month, 1 day", diff
      end

      should "skip empty elements" do
        diff = DateRange.new(
          begins_on: Date.parse("2013-01-01"),
          ends_on: Date.parse("2014-01-02"),
        ).friendly_time_diff
        assert_equal "1 year, 1 day", diff
      end

      should "not be confused by differing month lengths" do
        diff = DateRange.new(
          begins_on: Date.parse("2013-02-01"),
          ends_on: Date.parse("2013-03-01"),
        ).friendly_time_diff
        assert_equal "1 month", diff
      end

      should "not be confused by leap years" do
        diff = DateRange.new(
          begins_on: Date.parse("2008-02-01"),
          ends_on: Date.parse("2008-03-01"),
        ).friendly_time_diff
        assert_equal "1 month", diff
      end

      should "perform calculations using the UTC date" do
        from = Time.zone.parse("2008-01-02 01:59 +02:00") # equivalent to 2008-01-01 23:59 +00:00
        diff = DateRange.new(
          begins_on: from,
          ends_on: Date.parse("2008-01-02"),
        ).friendly_time_diff
        assert_equal "1 day", diff
      end

      should "avoid edge cases with dates at the end of the month" do
        assert_equal "9 months", DateRange.new(
          begins_on: Date.parse("1960-12-30"),
          ends_on: Date.parse("1961-09-30"),
        ).friendly_time_diff
      end

      should "avoid year rounding errors" do
        assert_equal "11 months, 29 days", DateRange.new(
          begins_on: Date.parse("1960-12-31"),
          ends_on: Date.parse("1961-12-29"),
        ).friendly_time_diff
      end

      should "avoid edge cases for 29th feb" do
        assert_equal "4 years", DateRange.new(
          begins_on: Date.parse("2004-02-29"),
          ends_on: Date.parse("2008-02-29"),
        ).friendly_time_diff
        assert_equal "4 years, 1 day", DateRange.new(
          begins_on: Date.parse("2004-02-29"),
          ends_on: Date.parse("2008-03-01"),
        ).friendly_time_diff
      end
    end
  end
end
