require_relative '../../test_helper'

module SmartAnswer::Calculators
  class EnergyGrantsCalculatorTest < ActiveSupport::TestCase
    setup do
      @calculator = EnergyGrantsCalculator.new
    end

    context '#circumstances' do
      should 'return empty array by default i.e. when no responses have been set' do
        assert_equal [], @calculator.circumstances
      end
    end

    context '#benefits_claimed' do
      should 'return empty array by default i.e. when no responses have been set' do
        assert_equal [], @calculator.benefits_claimed
      end
    end

    context '#age_variant' do
      should 'return :winter_fuel_payment if date of birth before 05-07-1951' do
        @calculator.date_of_birth = Date.new(1951, 7, 5) - 1
        assert_equal :winter_fuel_payment, @calculator.age_variant
      end

      should 'return :over_60 if date of birth before 60 years ago tomorrow' do
        @calculator.date_of_birth = 60.years.ago(Date.tomorrow) - 1
        assert_equal :over_60, @calculator.age_variant
      end

      should 'return nil if date of birth on or after 60 years ago tomorrow' do
        @calculator.date_of_birth = 60.years.ago(Date.tomorrow)
        assert_nil @calculator.age_variant
      end

      should 'return nil by default i.e. no date of birth specified' do
        assert_nil @calculator.age_variant
      end
    end

    context '#bills_help?' do
      should 'return true if which_help is the help_with_fuel_bill option' do
        @calculator.which_help = 'help_with_fuel_bill'
        assert @calculator.bills_help?
      end

      should 'return false if which_help is not the help_with_fuel_bill option' do
        @calculator.which_help = 'help_energy_efficiency'
        refute @calculator.bills_help?
      end
    end

    context '#incomesupp_jobseekers_1' do
      should 'return nil by default i.e. when no responses have been set' do
        assert_nil @calculator.incomesupp_jobseekers_1
      end
    end
  end
end
