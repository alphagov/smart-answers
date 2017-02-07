require_relative "../../test_helper"

module SmartAnswer::Calculators
  class StatePensionTopupCalculatorTest < ActiveSupport::TestCase
    setup do
      @calculator = StatePensionTopupCalculator.new
    end

    context "lump_sum_amount" do
      should "be 8010 for age of 69" do
        assert_equal 8010, @calculator.send(:lump_sum_amount, 69, 10)
      end

      should "be rate for 100 year olds for age of over 100" do
        rate_for_100_year_olds = @calculator.send(:lump_sum_amount, 100, 1)
        assert_equal rate_for_100_year_olds, @calculator.send(:lump_sum_amount, 150, 1)
      end

      should "be 2,720 for age of 80" do
        assert_equal 2720, @calculator.send(:lump_sum_amount, 80, 5)
      end
    end

    context "age_at_date" do
      should "Show age of 64" do
        assert_equal 64, @calculator.send(:age_at_date, Date.parse('1951-04-06'), Date.parse('2015-10-12'))
      end

      should "Show age of 85" do
        assert_equal 85, @calculator.send(:age_at_date, Date.parse('1930-04-06'), Date.parse('2015-10-12'))
      end
    end

    context "top-up start date" do
      context "Should show current year" do
        should "be 2015" do
          Timecop.freeze("2015-10-31")
          assert_equal 2015, @calculator.topup_start_year
        end

        should "be 2016" do
          Timecop.freeze("2016-10-31")
          assert_equal 2016, @calculator.topup_start_year
        end

        should "be 2015 if year is before scheme start date" do
          Timecop.freeze("2014-10-31")
          assert_equal 2015, @calculator.topup_start_year
        end
      end
    end

    context "lump_sum_and_age" do
      context "when male" do
        setup do
          Timecop.freeze('2016-12-01')
          @calculator.gender = "male"
        end

        should "show one rate for age 86" do
          @calculator.date_of_birth = Date.parse('1930-04-06')
          @calculator.weekly_amount = 10
          expectation = [
            { amount: 3660.0, age: 86 }
          ]
          assert_equal expectation, @calculator.lump_sum_and_age
        end

        should "show two rates when born on 1951-04-05 and with top-up of £1 a week" do
          @calculator.date_of_birth = Date.parse('1951-04-05')
          @calculator.weekly_amount = 1
          expectation = [
            { amount: 890.0, age: 65 },
            { amount: 871.0, age: 66 },
          ]
          assert_equal expectation, @calculator.lump_sum_and_age
        end

        should "show no rates when born on 1951-04-06 or after (too young to qualify)" do
          @calculator.date_of_birth = Date.parse('1953-04-06')
          assert_equal [], @calculator.lump_sum_and_age
        end

        should "show one rate when born on 1944-05-01 and with top-up of £1 a week" do
          @calculator.date_of_birth = Date.parse('1944-05-01')
          @calculator.weekly_amount = 1
          expectation = [
            { amount: 738.0, age: 72 },
          ]
          assert_equal expectation, @calculator.lump_sum_and_age
        end

        should "show one rate when born on 1949-10-14 and with top-up of £1 a week" do
          @calculator.date_of_birth = Date.parse('1949-10-14')
          @calculator.weekly_amount = 1
          expectation = [
            { amount: 847.0, age: 67 },
          ]
          assert_equal expectation, @calculator.lump_sum_and_age
        end
      end

      context "when female" do
        setup do
          Timecop.freeze('2016-12-01')
          @calculator.gender = "female"
        end

        should "show three rates when born on 1953-04-05 and with top-up of £1 a week" do
          @calculator.date_of_birth = Date.parse('1953-04-05')
          @calculator.weekly_amount = 1
          expectation = [
            { amount: 934.0, age: 63 },
            { amount: 913.0, age: 64 },
          ]
          assert_equal expectation, @calculator.lump_sum_and_age
        end

        should "show one rate when born on 1952-10-13 and with top-up of £1 a week" do
          @calculator.date_of_birth = Date.parse('1952-10-13')
          @calculator.weekly_amount = 1
          expectation = [
            { amount: 913.0, age: 64 },
          ]
          assert_equal expectation, @calculator.lump_sum_and_age
        end

        should "show no rates when born on 1953-04-06 or after (too young to qualify)" do
          @calculator.date_of_birth = Date.parse('1953-04-06')
          assert_equal [], @calculator.lump_sum_and_age
        end

        should "show two rates when born on 1951-04-05 and with top-up of £20 per week" do
          @calculator.date_of_birth = Date.parse('1951-04-05')
          @calculator.weekly_amount = 20
          expectation = [
            { amount: 17800.0, age: 65 },
            { amount: 17420.0, age: 66 },
          ]
          assert_equal expectation, @calculator.lump_sum_and_age
        end
      end

      context "end of scheme" do
        setup do
          Timecop.freeze('2017-02-01')
          @calculator.gender = "male"
        end

        teardown do
          Timecop.return
        end

        should "show two rates for final year of scheme when birthday before end of scheme" do
          @calculator.date_of_birth = Date.parse('1950-04-05')
          @calculator.weekly_amount = 1
          expectation = [
            { amount: 871.0, age: 66 },
            { amount: 847.0, age: 67 },
          ]
          assert_equal expectation, @calculator.lump_sum_and_age
        end

        should "show one rate for final year of scheme when birthday in final month of scheme but after scheme ends" do
          @calculator.date_of_birth = Date.parse('1950-04-07')
          @calculator.weekly_amount = 1
          expectation = [
            { amount: 871.0, age: 66 },
          ]
          assert_equal expectation, @calculator.lump_sum_and_age
        end
      end
    end

    context 'too_young?' do
      context 'when gender is female' do
        setup do
          @calculator.gender = "female"
          @threshold_date = StatePensionTopupCalculator::FEMALE_YOUNGEST_DOB
        end

        should 'be true if date of birth is after threshold date' do
          @calculator.date_of_birth = @threshold_date + 1
          assert @calculator.too_young?
        end

        should 'be false if date of birth is on threshold date' do
          @calculator.date_of_birth = @threshold_date
          refute @calculator.too_young?
        end
      end

      context 'when gender is male' do
        setup do
          @calculator.gender = "male"
          @threshold_date = StatePensionTopupCalculator::MALE_YOUNGEST_DOB
        end

        should 'be true if date of birth is after threshold date' do
          @calculator.date_of_birth = @threshold_date + 1
          assert @calculator.too_young?
        end

        should 'be false if date of birth is on threshold date' do
          @calculator.date_of_birth = @threshold_date
          refute @calculator.too_young?
        end
      end
    end

    context 'valid_whole_number_weekly_amount?' do
      should 'be true if weekly_amount is whole number of pounds' do
        @calculator.weekly_amount = SmartAnswer::Money.new(12.00)
        assert @calculator.valid_whole_number_weekly_amount?
      end

      should 'be false if weekly_amount is not whole number of pounds' do
        @calculator.weekly_amount = SmartAnswer::Money.new(12.50)
        refute @calculator.valid_whole_number_weekly_amount?
      end
    end

    context 'valid_weekly_amount_in_range?' do
      should 'be true if weekly_amount is between 1 and 25 inclusive' do
        @calculator.weekly_amount = SmartAnswer::Money.new(12.50)
        assert @calculator.valid_weekly_amount_in_range?
      end

      should 'be false if weekly_amount is less than 1' do
        @calculator.weekly_amount = SmartAnswer::Money.new(0.99)
        refute @calculator.valid_weekly_amount_in_range?
      end

      should 'be false if weekly_amount is more than 25' do
        @calculator.weekly_amount = SmartAnswer::Money.new(25.01)
        refute @calculator.valid_weekly_amount_in_range?
      end
    end
  end
end
