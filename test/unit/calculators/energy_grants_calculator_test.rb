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

      should 'return :over_60 if date of birth is more than 60 years from tomorrow' do
        @calculator.date_of_birth = 60.years.ago(Date.tomorrow) - 1
        assert_equal :over_60, @calculator.age_variant
      end

      should 'return nil if date of birth is 60 years ago or less from tomorrow' do
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

    context '#incomesupp_jobseekers_1?' do
      should 'return false by default i.e. when no responses have been set' do
        refute @calculator.incomesupp_jobseekers_1?
      end

      should 'return true when only disabled option selected' do
        @calculator.disabled_or_have_children = %w(disabled)
        assert @calculator.incomesupp_jobseekers_1?
      end

      should 'return true when only disabled_child option selected' do
        @calculator.disabled_or_have_children = %w(disabled_child)
        assert @calculator.incomesupp_jobseekers_1?
      end

      should 'return true when only child_under_5 option selected' do
        @calculator.disabled_or_have_children = %w(child_under_5)
        assert @calculator.incomesupp_jobseekers_1?
      end

      should 'return true when only pensioner_premium option selected' do
        @calculator.disabled_or_have_children = %w(pensioner_premium)
        assert @calculator.incomesupp_jobseekers_1?
      end

      should 'return false when only child_under_16 option selected' do
        @calculator.disabled_or_have_children = %w(child_under_16)
        refute @calculator.incomesupp_jobseekers_1?
      end

      should 'return false when only work_support_esa option selected' do
        @calculator.disabled_or_have_children = %w(work_support_esa)
        refute @calculator.incomesupp_jobseekers_1?
      end

      should 'return false when any two options selected' do
        @calculator.disabled_or_have_children = %w(disabled,child_under_5)
        refute @calculator.incomesupp_jobseekers_1?
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

    context '#incomesupp_jobseekers_2_part_1?' do
      should 'return false by default i.e. when no responses have been set' do
        refute @calculator.incomesupp_jobseekers_2_part_1?
      end

      context 'when only working_tax_credit benefit is claimed' do
        setup do
          @calculator.benefits_claimed = %w(working_tax_credit)
        end

        should 'return true when age_variant is :over_60' do
          @calculator.stubs(:age_variant).returns(:over_60)
          assert @calculator.incomesupp_jobseekers_2_part_1?
        end

        should 'return false when age_variant is not :over_60' do
          @calculator.stubs(:age_variant).returns(:winter_fuel_payment)
          refute @calculator.incomesupp_jobseekers_2_part_1?
        end
      end

      context 'when when not only working_tax_credit benefit is claimed' do
        setup do
          @calculator.benefits_claimed = %w(income_support working_tax_credit)
        end

        should 'return false when age_variant is :over_60' do
          @calculator.stubs(:age_variant).returns(:over_60)
          refute @calculator.incomesupp_jobseekers_2_part_1?
        end

        should 'return false when age_variant is not :over_60' do
          @calculator.stubs(:age_variant).returns(:winter_fuel_payment)
          refute @calculator.incomesupp_jobseekers_2_part_1?
        end
      end
    end

    context '#incomesupp_jobseekers_2_part_2?' do
      should 'return false by default i.e. when no responses have been set' do
        refute @calculator.incomesupp_jobseekers_2_part_2?
      end

      context 'when only child_under_16 option selected' do
        setup do
          @calculator.disabled_or_have_children = %w(child_under_16)
        end

        should 'return false when social housing tenant' do
          @calculator.circumstances = %w(social_housing)
          refute @calculator.incomesupp_jobseekers_2_part_2?
        end

        should 'return false when claiming working tax credit and not over 60' do
          @calculator.benefits_claimed = %(working_tax_credit)
          @calculator.stubs(:age_variant).returns(:winter_fuel_payment)
          refute @calculator.incomesupp_jobseekers_2_part_2?
        end

        context 'when not social housing tenant' do
          setup do
            @calculator.circumstances = %w(permission)
          end

          should 'return true when not claiming working tax credit' do
            @calculator.benefits_claimed = %(income_support)
            assert @calculator.incomesupp_jobseekers_2_part_2?
          end

          should 'return true when over 60' do
            @calculator.stubs(:age_variant).returns(:over_60)
            assert @calculator.incomesupp_jobseekers_2_part_2?
          end
        end
      end

      context 'when only work_support_esa option selected' do
        setup do
          @calculator.disabled_or_have_children = %w(work_support_esa)
        end

        should 'return false when social housing tenant' do
          @calculator.circumstances = %w(social_housing)
          refute @calculator.incomesupp_jobseekers_2_part_2?
        end

        should 'return false when claiming working tax credit and not over 60' do
          @calculator.benefits_claimed = %(working_tax_credit)
          @calculator.stubs(:age_variant).returns(:winter_fuel_payment)
          refute @calculator.incomesupp_jobseekers_2_part_2?
        end

        context 'when not social housing tenant' do
          setup do
            @calculator.circumstances = %w(permission)
          end

          should 'return true when not claiming working tax credit' do
            @calculator.benefits_claimed = %(income_support)
            assert @calculator.incomesupp_jobseekers_2_part_2?
          end

          should 'return true when over 60' do
            @calculator.stubs(:age_variant).returns(:over_60)
            assert @calculator.incomesupp_jobseekers_2_part_2?
          end
        end
      end

      context 'when another option is selected' do
        setup do
          @calculator.disabled_or_have_children = %w(disabled_child)
        end

        should 'always return false' do
          @calculator.circumstances = %w(permission)
          @calculator.benefits_claimed = %(income_support)
          refute @calculator.incomesupp_jobseekers_2_part_2?
        end
      end

      context 'when more than one option is selectedd' do
        setup do
          @calculator.disabled_or_have_children = %w(child_under_16 work_support_esa)
        end

        should 'always return false' do
          @calculator.circumstances = %w(permission)
          @calculator.benefits_claimed = %(income_support)
          refute @calculator.incomesupp_jobseekers_2_part_2?
        end
      end
    end

    context '#incomesupp_jobseekers_2?' do
      should 'return false by default i.e. when no responses have been set' do
        refute @calculator.incomesupp_jobseekers_2?
      end

      context 'when disabled_or_have_children? question has been answered' do
        setup do
          @calculator.disabled_or_have_children = %w(disabled_child)
          @calculator.stubs(
            incomesupp_jobseekers_2_part_1?: :incomesupp_jobseekers_2_part_1,
            incomesupp_jobseekers_2_part_2?: :incomesupp_jobseekers_2_part_2
          )
        end

        should 'return incomesupp_jobseekers_2_part_2' do
          assert_equal :incomesupp_jobseekers_2_part_2, @calculator.incomesupp_jobseekers_2?
        end
      end

      context 'when disabled_or_have_children? question has not been answered' do
        setup do
          @calculator.disabled_or_have_children = []
          @calculator.stubs(
            incomesupp_jobseekers_2_part_1?: :incomesupp_jobseekers_2_part_1,
            incomesupp_jobseekers_2_part_2?: :incomesupp_jobseekers_2_part_2
          )
        end

        should 'return incomesupp_jobseekers_2_part_1' do
          assert_equal :incomesupp_jobseekers_2_part_1, @calculator.incomesupp_jobseekers_2?
        end
      end
    end

    context "#features" do
      should 'get features for modern home' do
        assert @calculator.home_features_modern.key?(:mains_gas)
        assert @calculator.home_features_modern.key?(:electric_heating)
        assert @calculator.home_features_modern.key?(:loft_attic_conversion)
        assert @calculator.home_features_modern.key?(:draught_proofing)
        refute @calculator.home_features_modern.key?(:modern_double_glazing)
        refute @calculator.home_features_modern.key?(:loft_insulation)
        refute @calculator.home_features_modern.key?(:solid_wall_insulation)
        refute @calculator.home_features_modern.key?(:modern_boiler)
        refute @calculator.home_features_modern.key?(:cavity_wall_insulation)

        assert_equal 4, @calculator.home_features_modern.count
      end

      should 'get features for older home' do
        assert @calculator.home_features_older.key?(:mains_gas)
        assert @calculator.home_features_older.key?(:electric_heating)
        assert @calculator.home_features_older.key?(:loft_attic_conversion)
        assert @calculator.home_features_older.key?(:draught_proofing)
        assert @calculator.home_features_older.key?(:modern_double_glazing)
        assert @calculator.home_features_older.key?(:loft_insulation)
        assert @calculator.home_features_older.key?(:solid_wall_insulation)
        assert @calculator.home_features_older.key?(:modern_boiler)
        assert @calculator.home_features_older.key?(:cavity_wall_insulation)

        assert_equal 9, @calculator.home_features_older.count
      end

      should 'get features for historic home' do
        assert @calculator.home_features_historic.key?(:mains_gas)
        assert @calculator.home_features_historic.key?(:electric_heating)
        assert @calculator.home_features_historic.key?(:loft_attic_conversion)
        assert @calculator.home_features_historic.key?(:draught_proofing)
        assert @calculator.home_features_historic.key?(:modern_double_glazing)
        assert @calculator.home_features_historic.key?(:loft_insulation)
        assert @calculator.home_features_historic.key?(:solid_wall_insulation)
        assert @calculator.home_features_historic.key?(:modern_boiler)
        refute @calculator.home_features_historic.key?(:cavity_wall_insulation)

        assert_equal 8, @calculator.home_features_historic.count
      end
    end

    context '#eligible_for_cold_weather_payment?' do
      should 'be true if claiming benefits, benefits claimed include esa or pension_credit and is over 60' do
        @calculator.circumstances = %w(benefits)
        @calculator.benefits_claimed = %w(esa pension_credit)
        @calculator.stubs(:age_variant).returns(:over_60)

        assert @calculator.eligible_for_cold_weather_payment?
      end

      should 'be true if is disabled, has disabled_child, has child under 5, or getting pension pensioner_premium' do
        @calculator.stubs(:incomesupp_jobseekers_1?).returns(true)
        assert @calculator.eligible_for_cold_weather_payment?
      end

      should 'be false if eligible for winter_fuel_payment' do
        @calculator.stubs(:age_variant).returns(:winter_fuel_payment)

        refute @calculator.eligible_for_cold_weather_payment?
      end
    end

    context '#eligible_for_winter_fuel_payment?' do
      should 'be true when date of birth is above the winter fuel payment threshold' do
        @calculator.stubs(:age_variant).returns(:winter_fuel_payment)
      end
    end

    context "#under_green_deal" do
      context "#under_green_deal_part_1" do
        should 'return true when looking for help with all, and not claiming benefits' do
          @calculator.which_help = 'all_help'
          @calculator.circumstances = %w(permission)
          assert @calculator.under_green_deal_part_1?
        end
      end

      context "#under_green_deal_part_2" do
        should 'return true when not looking for help with all and does not own property' do
          @calculator.which_help = 'help_with_fuel_bill'
          @calculator.circumstances = %w(permission benefits)
          assert @calculator.under_green_deal_part_2?
        end

        should 'return true if needs help with boiler and not claiming benefits, does not own property or have permission to install boiler' do
          @calculator.which_help = 'help_boiler_measure'
          @calculator.circumstances = []
          assert @calculator.under_green_deal_part_2?
        end

        should 'return true if benefits claimed and benefits do not include esa, child_tax_credit or working_tax_credit' do
          @calculator.circumstances = %w(benefits)
          @calculator.benefits_claimed = %w(universal_credit)
          assert @calculator.under_green_deal_part_2?
        end
      end

      context '#under_green_deal_part_3' do
        should 'return true if needs help with all, is over 60 years old and benefits claimed includes ESA, child and working tax credit' do
          @calculator.which_help = 'all_help'
          @calculator.stubs(:age_variant).returns(:over_60)
          @calculator.benefits_claimed = %w(esa child_tax_credit working_tax_credit)
          assert @calculator.under_green_deal_part_3?
        end

        should 'return true if needs help with all, is over 60 years old and incomesupp_jobseekers_1? is true' do
          @calculator.which_help = 'all_help'
          @calculator.stubs(:age_variant).returns(:over_60)
          @calculator.stubs(:incomesupp_jobseekers_1?).returns(true)
          assert @calculator.under_green_deal_part_3?
        end

        should 'return true if needs help with all, is over 60 years old and incomesupp_jobseekers_2? is true' do
          @calculator.which_help = 'all_help'
          @calculator.stubs(:age_variant).returns(:over_60)
          @calculator.stubs(:incomesupp_jobseekers_2?).returns(true)
          assert @calculator.under_green_deal_part_3?
        end
      end

      #part_1 and under_green_deal_part_1
      should 'return true if needs all help and not claiming benefits, does not own property or has permission to install boiler' do
        @calculator.which_help = 'all_help'
        @calculator.circumstances = []
        @calculator.benefits_claimed = []
        assert @calculator.under_green_deal?
      end

      #part_2 and under_green_deal_part_2
      should 'return true if needs help with boiler, claiming pension credit and owns property' do
        @calculator.which_help = 'help_boiler_measure'
        @calculator.circumstances = %w(benefits property)
        @calculator.benefits_claimed = %w(pension_credit)
        assert @calculator.under_green_deal?
      end

      #part_3 and under_green_deal_part_3
      should 'return true if needs all help, is over 60 years old and claiming child tax credit' do
        @calculator.which_help = 'all_help'
        @calculator.circumstances = %w(benefits)
        @calculator.stubs(:age_variant).returns(:over_60)
        @calculator.benefits_claimed = %w(child_tax_credit)
        assert @calculator.under_green_deal?
      end
      should 'return false if eligible for winter fuel payment' do
        @calculator.stubs(:age_variant).returns(:winter_fuel_payment)
        refute @calculator.under_green_deal?
      end

      should 'return true if eligible for cold weather payment and needs all help' do
        @calculator.stubs(:eligible_for_cold_weather_payment?).returns(true)
        @calculator.which_help = 'all_help'
        assert @calculator.under_green_deal?
      end

      should 'be true if eligible for cold weather payment, needs all help and disabled, has disabled_child, has child under 5, or getting pension pensioner_premium?' do
        @calculator.stubs(:eligible_for_cold_weather_payment?).returns(true)
        @calculator.which_help = 'all_help'
        @calculator.stubs(:incomesupp_jobseekers_1?).returns(true)

        assert @calculator.under_green_deal?
      end
    end
  end
end
