require_relative "../test_helper"

module SmartAnswer
  class DateOfBirthTest < ActiveSupport::TestCase
    setup do
      @today = Date.parse("2015-05-15")
      Timecop.freeze(@today)
    end

    teardown do
      Timecop.return
    end

    context "when birthday has not yet occurred in this year" do
      setup do
        @dob = DateOfBirth.new(@today - 50.years + 1.day)
      end

      should "calculate birthday" do
        assert_equal Date.parse("2015-05-16"), @dob.birthday
      end

      should "calculate age" do
        assert_equal 49, @dob.age
      end
    end

    context "when birthday has already occurred in this year" do
      setup do
        @dob = DateOfBirth.new(@today - 50.years)
      end

      should "calculate birthday" do
        assert_equal Date.parse("2015-05-15"), @dob.birthday
      end

      should "calculate birthday for specified year" do
        assert_equal Date.parse("2016-05-15"), @dob.birthday(year: 2016)
      end

      should "calculate age" do
        assert_equal 50, @dob.age
      end

      should "calculate age for specified date" do
        assert_equal 51, @dob.age(on: @today + 1.year)
      end
    end

    context "when birthday was on 29th February of a leap year" do
      setup do
        @dob = DateOfBirth.new(Date.parse("1964-02-29"))
      end

      should "consider birthday to be on 1st March in non-leap year" do
        assert_equal Date.parse("2015-03-01"), @dob.birthday
      end

      should "calculate age on 1st March in non-leap year" do
        assert_equal 51, @dob.age(on: Date.parse("2015-03-01"))
      end
    end
  end
end
