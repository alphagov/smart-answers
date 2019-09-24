require_relative "../test_helper"

module SmartAnswer
  class YearRangeTest < ActiveSupport::TestCase
    context "not including the 29th Feb of a leap year" do
      setup do
        @year_range = YearRange.new(begins_on: Date.parse("2000-03-01"))
      end

      should "begin on begins_on date" do
        assert_equal Date.parse("2000-03-01"), @year_range.begins_on
      end

      should "end a day before a year after the begins_on date" do
        assert_equal Date.parse("2001-02-28"), @year_range.ends_on
      end

      should "be 365 days long, because it does not include 29th Feb" do
        assert_equal 365, @year_range.number_of_days
      end
    end

    context "including the 29th Feb of a leap year" do
      setup do
        @year_range = YearRange.new(begins_on: Date.parse("2000-02-01"))
      end

      should "end a day before a year after the begins_on date" do
        assert_equal Date.parse("2001-01-31"), @year_range.ends_on
      end

      should "be 366 days long, because it does include 29th Feb" do
        assert_equal 366, @year_range.number_of_days
      end
    end

    context "beginning on 29th February of a leap year" do
      setup do
        @year_range = YearRange.new(begins_on: Date.parse("2000-02-29"))
      end

      should "end a day before a year after the begins_on date" do
        assert_equal Date.parse("2001-02-28"), @year_range.ends_on
      end

      should "be 366 days long, because it does include 29th Feb" do
        assert_equal 366, @year_range.number_of_days
      end
    end

    context "ending on 29th February of a leap year" do
      setup do
        @year_range = YearRange.new(begins_on: Date.parse("1999-03-01"))
      end

      should "end a day before a year after the begins_on date" do
        assert_equal Date.parse("2000-02-29"), @year_range.ends_on
      end

      should "be 366 days long, because it does include 29th Feb" do
        assert_equal 366, @year_range.number_of_days
      end
    end

    context "scrolling through ranges" do
      setup do
        @year_range = YearRange.new(begins_on: Date.parse("2000-01-01"))
      end

      should "give the next year range" do
        assert_equal Date.parse("2001-01-01"), @year_range.next.begins_on
        assert_equal Date.parse("2001-12-31"), @year_range.next.ends_on
      end

      should "give the previous year range" do
        assert_equal Date.parse("1999-01-01"), @year_range.previous.begins_on
        assert_equal Date.parse("1999-12-31"), @year_range.previous.ends_on
      end
    end
  end
end
