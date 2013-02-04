require_relative "../../test_helper"

module SmartAnswer::Calculators
  class PIPDatesTest < ActiveSupport::TestCase

    context "in_selected_area?" do
      setup do
        @calculator = PIPDates.new
      end

      should "be true for full included areas" do
        %w(BL CA CW DH FY L M NE PR SR WA WN).each do |code|
          @calculator.postcode = "#{code}5"
          assert @calculator.in_selected_area?, "Expected #{code}5 to be in area"
        end
      end

      should "not include areas that prefix-match included areas" do
        @calculator.postcode = "MM3"
        assert ! @calculator.in_selected_area?

        @calculator.postcode = "LW4"
        assert ! @calculator.in_selected_area?
      end

      should "handle CH area correctly" do
        %w(5 6 7 8).each do |district|
          @calculator.postcode = "CH#{district}"
          assert ! @calculator.in_selected_area?, "Expected CH#{district} not to be in area"
        end
        %w(1 2 3 4 9 10 11 55 66 77 88).each do |district|
          @calculator.postcode = "CH#{district}"
          assert @calculator.in_selected_area?, "Expected CH#{district} to be in area"
        end
      end

      should "handle DL area correctly" do
        %w(6 7 8 9 10 11).each do |district|
          @calculator.postcode = "DL#{district}"
          assert ! @calculator.in_selected_area?, "Expected DL#{district} not to be in area"
        end
        %w(1 2 3 4 5 12 13 66 72 88).each do |district|
          @calculator.postcode = "DL#{district}"
          assert @calculator.in_selected_area?, "Expected DL#{district} to be in area"
        end
      end

      should "handle LA area correctly" do
        [[2, 7], [2, 8], [6, 2], [6, 3]].each do |(district, sector)|
          @calculator.postcode = "LA#{district} #{sector}AB"
          assert ! @calculator.in_selected_area?, "Expected LA#{district} #{sector}AB not to be in area"
        end
        [[2, 6], [2, 9], [6, 1], [6, 4]].each do |(district, sector)|
          @calculator.postcode = "LA#{district} #{sector}AB"
          assert @calculator.in_selected_area?, "Expected LA#{district} #{sector}AB to be in area"
        end
        %w(1 3 4 5 7 8 9 12 13 66 72 88).each do |district|
          @calculator.postcode = "LA#{district} 7AB"
          assert @calculator.in_selected_area?, "Expected LA#{district} to be in area"
        end
      end

      should "handle TS area correctly" do
        %w(9).each do |district|
          @calculator.postcode = "TS#{district}"
          assert ! @calculator.in_selected_area?, "Expected TS#{district} not to be in area"
        end
        %w(1 2 3 4 5 6 7 8 10 11 12 13 66 72 88).each do |district|
          @calculator.postcode = "TS#{district}"
          assert @calculator.in_selected_area?, "Expected TS#{district} to be in area"
        end
      end
    end

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
