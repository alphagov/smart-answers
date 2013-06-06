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
      end

      should "be false if born just before 08-04-1997" do
        @calc.dob = Date.parse('1997-04-07')
        assert ! @calc.turning_16_before_oct_2013?
      end

      should "be true if born on or after 08-04-1997" do
        @calc.dob = Date.parse('1997-04-08')
        assert @calc.turning_16_before_oct_2013?
        @calc.dob = Date.parse('1997-04-09')
        assert @calc.turning_16_before_oct_2013?
      end

      should "be true if born just before 07-10-1997" do
        @calc.dob = Date.parse('1997-10-06')
        assert @calc.turning_16_before_oct_2013?
      end

      should "be false if born on or after 07-10-1997" do
        @calc.dob = Date.parse('1997-10-07')
        assert ! @calc.turning_16_before_oct_2013?
        @calc.dob = Date.parse('1997-10-08')
        assert ! @calc.turning_16_before_oct_2013?
      end

    end
  end
end
