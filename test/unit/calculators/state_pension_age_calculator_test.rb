require_relative "../../test_helper"

module SmartAnswer::Calculators
  class StatePensionAgeCalculatorTest < ActiveSupport::TestCase

    context '#state_pension_date' do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAgeCalculator.new(
          gender: "male", dob: Date.parse("28 February 1961"))
      end

      should 'simply delegate to StatePensionDateQuery.state_pension_date' do
        assert_equal @calculator.state_pension_date,
          StatePensionDateQuery.state_pension_date(@calculator.dob, @calculator.gender)
      end
    end

    context "#state_pension_age" do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAgeCalculator.new(
          gender: "male", dob: Date.parse("28 February 1961"))
      end

      context 'given a state_pension_date on a different year to the date of birth' do
        setup do
          @calculator.stubs(:state_pension_date).returns(Date.parse('28 Feb 2022'))
        end

        should 'return the number of years to your state pension' do
          assert_equal @calculator.state_pension_age, '61 years'
        end
      end

      context 'given a state_pension_date on a different year and month to the date of birth' do
        setup do
          @calculator.stubs(:state_pension_date).returns(Date.parse('28 March 2022'))
        end

        should 'return the number of years to your state pension' do
          assert_equal @calculator.state_pension_age, '61 years, 1 month'
        end
      end

      context 'given a state_pension_date on a different year, month and day to the date of birth' do
        setup do
          @calculator.stubs(:state_pension_date).returns(Date.parse('30 March 2022'))
        end

        should 'return the number of years to your state pension' do
          assert_equal @calculator.state_pension_age, '61 years, 1 month, 2 days'
        end
      end

      context 'given a state_pension_date on the 29th of Feb' do
        setup do
          @calculator.stubs(:dob).returns(Date.parse("29 Feb 1980"))
          @calculator.stubs(:state_pension_date).returns(Date.parse('1 March 2040'))
        end

        should 'subtract one day from your state_pension age, and return number of years, months and days to your state pension' do
          assert_equal @calculator.state_pension_age, '60 years'
        end
      end
    end

    context "#birthday_on_feb_29??" do
      should "be true for a date that is a the 29th of feb" do
        @calculator = SmartAnswer::Calculators::StatePensionAgeCalculator.new(
          gender: "male", dob: Date.parse("29 February 1976"))
        assert_equal true, @calculator.birthday_on_feb_29?
      end

      should "be false for a date that is not the 29th of feb" do
        @calculator = SmartAnswer::Calculators::StatePensionAgeCalculator.new(
          gender: "male", dob: Date.parse("7 June 1960"))
        assert_equal false, @calculator.birthday_on_feb_29?
      end
    end

    context '#before_state_pension_date?' do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAgeCalculator.new({})
      end

      should 'return true for someone yet to reach their state pension date' do
        Timecop.freeze do
          @calculator.stubs(:state_pension_date).returns(Date.today + 1.minute)
          assert @calculator.before_state_pension_date?
        end
      end

      should 'return false for someone who has reached their state pension date' do
        Timecop.freeze do
          @calculator.stubs(:state_pension_date).returns(Date.today)
          assert_not @calculator.before_state_pension_date?
        end
      end

      should 'return false for someone who has just passed their state pension date' do
        Timecop.freeze do
          @calculator.stubs(:state_pension_date).returns(Date.today - 1.minute)
          assert_not @calculator.before_state_pension_date?
        end
      end
    end

    context '#before_state_pension_date?(days: 30)' do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAgeCalculator.new({})
      end

      should 'return true for someone just over 30 days away from their pension_credit_date' do
        Timecop.freeze do
          @calculator.stubs(:state_pension_date).returns(Date.today + 31.days)
          assert @calculator.before_state_pension_date?(days: 2)
        end
      end

      should 'return false for someone exactly 30 days away' do
        Timecop.freeze do
          @calculator.stubs(:state_pension_date).returns(Date.today + 30.days)
          assert_not @calculator.before_state_pension_date?(days: 30)
        end
      end

      should 'return false for someone less than 30 days to their pension credit date' do
        Timecop.freeze do
          @calculator.stubs(:state_pension_date).returns(Date.today + 29.days)
          assert_not @calculator.before_state_pension_date?(days: 30)
        end
      end
    end

    context '#before_pension_credit_date?' do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAgeCalculator.new({})
      end

      should 'return true for someone yet to reach their pension credit date' do
        Timecop.freeze do
          @calculator.stubs(:pension_credit_date).returns(Date.today + 1.minute)
          assert @calculator.before_pension_credit_date?
        end
      end

      should 'return false for someone has just reached their pension credit date' do
        Timecop.freeze do
          @calculator.stubs(:pension_credit_date).returns(Date.today)
          assert_not @calculator.before_pension_credit_date?
        end
      end

      should 'return false for someone who has just passed their pension credit date' do
        Timecop.freeze do
          @calculator.stubs(:pension_credit_date).returns(Date.today - 1.minute)
          assert_not @calculator.before_pension_credit_date?
        end
      end
    end

    context '#old_state_pension?' do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAgeCalculator.new({})
      end

      should 'return true when the state_pension_date falls before 6 April 2016' do
        @calculator.stubs(:state_pension_date).returns(Date.parse('5 April 2016'))
        assert @calculator.old_state_pension?
      end

      should 'return false when the state_pension_date falls on 6 April 2016'  do
        @calculator.stubs(:state_pension_date).returns(Date.parse('6 April 2016'))
        assert_not @calculator.old_state_pension?
      end

      should 'return false when the state_pension_date falls after 6 April 2016'  do
        @calculator.stubs(:state_pension_date).returns(Date.parse('7 April 2016'))
        assert_not @calculator.old_state_pension?
      end
    end

    context "#over_16_years_old?" do
      should "be true for someone just older than 16" do
        Timecop.freeze do
          date_of_birth = (16.years + 1.minute).ago

          calculator = SmartAnswer::Calculators::StatePensionAgeCalculator.new(dob: date_of_birth)
          assert calculator.over_16_years_old?
        end
      end

      should 'return false for someone exactly 16 years old' do
        Timecop.freeze do
          date_of_birth = 16.years.ago

          calculator = SmartAnswer::Calculators::StatePensionAgeCalculator.new(dob: date_of_birth)
          assert_not calculator.over_16_years_old?
        end
      end

      should 'return false for someone just under 16 years old' do
        Timecop.freeze do
          date_of_birth = (16.years - 1.minute).ago

          calculator = SmartAnswer::Calculators::StatePensionAgeCalculator.new(dob: date_of_birth)
          assert_not calculator.over_16_years_old?
        end
      end
    end
  end
end
