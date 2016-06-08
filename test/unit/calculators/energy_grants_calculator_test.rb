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

    context '#measure_help?' do
      should 'return true if which_help is the help_energy_efficiency option' do
        @calculator.which_help = 'help_energy_efficiency'
        assert @calculator.measure_help?
      end

      should 'return true if which_help is the help_boiler_measure option' do
        @calculator.which_help = 'help_boiler_measure'
        assert @calculator.measure_help?
      end

      should 'return false if which_help is any other option' do
        @calculator.which_help = 'help_with_fuel_bill'
        refute @calculator.measure_help?
      end
    end

    context '#both_help?' do
      should 'return true if which_help is the all_help option' do
        @calculator.which_help = 'all_help'
        assert @calculator.both_help?
      end

      should 'return false if which_help is not the all_help option' do
        @calculator.which_help = 'help_energy_efficiency'
        refute @calculator.both_help?
      end
    end

    context '#incomesupp_jobseekers_1' do
      should 'return nil by default i.e. when no responses have been set' do
        assert_nil @calculator.incomesupp_jobseekers_1
      end
    end

    context '#disabled_or_have_children_question?' do
      should 'return false by default i.e. when no responses have been set' do
        refute @calculator.disabled_or_have_children_question?
      end

      should 'return true if only claiming income_support benefit' do
        @calculator.benefits_claimed = %w(income_support)
        assert @calculator.disabled_or_have_children_question?
      end

      should 'return false if claiming income_support benefit with other benefits' do
        @calculator.benefits_claimed = %w(income_support jsa)
        refute @calculator.disabled_or_have_children_question?
      end

      should 'return true if only claiming jsa benefit' do
        @calculator.benefits_claimed = %w(jsa)
        assert @calculator.disabled_or_have_children_question?
      end

      should 'return false if claiming jsa benefit with other benefits' do
        @calculator.benefits_claimed = %w(jsa esa)
        refute @calculator.disabled_or_have_children_question?
      end

      should 'return true if only claiming esa benefit' do
        @calculator.benefits_claimed = %w(esa)
        assert @calculator.disabled_or_have_children_question?
      end

      should 'return false if claiming esa benefit with other benefits' do
        @calculator.benefits_claimed = %w(esa working_tax_credit)
        refute @calculator.disabled_or_have_children_question?
      end

      should 'return true if only claiming working_tax_credit benefit' do
        @calculator.benefits_claimed = %w(working_tax_credit)
        assert @calculator.disabled_or_have_children_question?
      end

      should 'return false if claiming working_tax_credit benefit with other benefits' do
        @calculator.benefits_claimed = %w(working_tax_credit income_support)
        refute @calculator.disabled_or_have_children_question?
      end

      should 'return true if claiming universal_credit benefit' do
        @calculator.benefits_claimed = %w(universal_credit income_support)
        assert @calculator.disabled_or_have_children_question?
      end

      should 'return false if only claiming pension_credit benefit' do
        @calculator.benefits_claimed = %w(pension_credit)
        refute @calculator.disabled_or_have_children_question?
      end

      should 'return false if only claiming child_tax_credit benefit' do
        @calculator.benefits_claimed = %w(child_tax_credit)
        refute @calculator.disabled_or_have_children_question?
      end

      context 'when claiming income_support benefit' do
        setup do
          @calculator.benefits_claimed = %w(income_support)
        end

        should 'return false even if also claiming child_tax_credit & esa benefits' do
          @calculator.benefits_claimed += %w(child_tax_credit income_support)
          refute @calculator.disabled_or_have_children_question?
        end

        should 'return false even if also claiming esa & pension_credit benefits' do
          @calculator.benefits_claimed += %w(esa pension_credit)
          refute @calculator.disabled_or_have_children_question?
        end

        should 'return false even if claiming child_tax_credit & pension_credit benefits' do
          @calculator.benefits_claimed += %w(child_tax_credit pension_credit)
          refute @calculator.disabled_or_have_children_question?
        end
      end

      context 'when claiming jsa benefit' do
        setup do
          @calculator.benefits_claimed = %w(jsa)
        end

        should 'return false even if also claiming child_tax_credit & esa benefits' do
          @calculator.benefits_claimed += %w(child_tax_credit income_support)
          refute @calculator.disabled_or_have_children_question?
        end

        should 'return false even if also claiming esa & pension_credit benefits' do
          @calculator.benefits_claimed += %w(esa pension_credit)
          refute @calculator.disabled_or_have_children_question?
        end

        should 'return false even if claiming child_tax_credit & pension_credit benefits' do
          @calculator.benefits_claimed += %w(child_tax_credit pension_credit)
          refute @calculator.disabled_or_have_children_question?
        end
      end

      context 'when claiming child_tax_credit, esa & pension_credit benefits' do
        setup do
          @calculator.benefits_claimed = %w(child_tax_credit esa pension_credit)
        end

        should 'return false if not claiming any other benefits' do
          refute @calculator.disabled_or_have_children_question?
        end

        should 'return true if also claiming income_support benefit' do
          @calculator.benefits_claimed << 'income_support'
          assert @calculator.disabled_or_have_children_question?
        end

        should 'return true if also claiming income_support benefit with other benefits' do
          @calculator.benefits_claimed += %w(income_support working_tax_credit)
          assert @calculator.disabled_or_have_children_question?
        end

        should 'return true if also claiming jsa benefit' do
          @calculator.benefits_claimed << 'income_support'
          assert @calculator.disabled_or_have_children_question?
        end

        should 'return true if also claiming jsa benefit with other benefits' do
          @calculator.benefits_claimed += %w(jsa working_tax_credit)
          assert @calculator.disabled_or_have_children_question?
        end

        should 'return true if also claiming income_support & jsa benefits' do
          @calculator.benefits_claimed += %w(income_support jsa)
          assert @calculator.disabled_or_have_children_question?
        end
      end
    end
  end
end
