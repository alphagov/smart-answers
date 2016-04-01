require_relative "../../test_helper"

module SmartAnswer::Calculators
  class PIPDatesTest < ActiveSupport::TestCase
    context "in_group_65?" do
      setup do
        @calc = PIPDates.new
      end

      should "be true if born before 1948-04-08" do
        @calc.dob = Date.parse('1948-04-07')
        assert @calc.in_group_65?
      end

      should "be true if born on 1948-04-08" do
        @calc.dob = Date.parse('1948-04-08')
        assert @calc.in_group_65?
      end

      should "be false if born after 1948-04-08" do
        @calc.dob = Date.parse('1948-04-09')
        assert ! @calc.in_group_65?
      end
    end

    context "in_middle_group?" do
      setup do
        @calc = PIPDates.new
      end

      should "be false if born on 1948-04-08" do
        @calc.dob = Date.parse('1948-04-08')
        assert ! @calc.in_middle_group?
      end

      should "be true if born just after 1948-04-08" do
        @calc.dob = Date.parse('1948-04-09')
        assert @calc.in_middle_group?
      end

      should "be true if born just before 1997-04-08" do
        @calc.dob = Date.parse('1997-04-07')
        assert @calc.in_middle_group?
      end

      should "be false if born on 1997-04-08" do
        @calc.dob = Date.parse('1997-04-08')
        assert ! @calc.in_middle_group?
      end
    end

    context "turning_16_before_oct_2013?" do
      setup do
        @calc = PIPDates.new
        Timecop.travel('2013-06-07')
      end

      should "be true if born on or after 8th April 1997 and turning 16 before 7th October 2013" do
        @calc.dob = Date.parse('1997-04-08')
        assert @calc.turning_16_before_oct_2013?
        @calc.dob = Date.parse('1997-04-09')
        assert @calc.turning_16_before_oct_2013?
        @calc.dob = Date.parse('1997-10-06')
        assert @calc.turning_16_before_oct_2013?
      end

      should "be false if born before 8th April 1997" do
        @calc.dob = Date.parse('1997-04-07')
        refute @calc.turning_16_before_oct_2013?
      end

      should "be false if under 16 on 7th Oct 2013" do
        @calc.dob = Date.parse('1997-10-08')
        assert ! @calc.turning_16_before_oct_2013?
      end
    end

    context "is_65_or_over?" do
      setup do
        @calc = PIPDates.new
        Timecop.travel('2013-06-07')
      end
      should "be true for someone born 65 years ago or more" do
        @calc.dob = Date.parse('1948-06-07')
        assert @calc.is_65_or_over?
      end
      should "be false for someone born less than 65 years ago" do
        @calc.dob = Date.parse('1948-06-08')
        refute @calc.is_65_or_over?
      end
    end

    context "is_16_to_64?" do
      setup do
        @calc = PIPDates.new
        Timecop.travel('2013-06-07')
      end
      should "be true for someone who is 64" do
        @calc.dob = Date.parse('1948-06-08')
        assert @calc.is_16_to_64?
      end
      should "be true for someone who is 16" do
        @calc.dob = Date.parse('1997-06-07')
        assert @calc.is_16_to_64?
      end
      should "be false for someone who is 15" do
        @calc.dob = Date.parse('1997-06-08')
        refute @calc.is_16_to_64?
      end
      should "be false for someone who is 65" do
        @calc.dob = Date.parse('1948-06-07')
        refute @calc.is_16_to_64?
      end
    end
  end
end
