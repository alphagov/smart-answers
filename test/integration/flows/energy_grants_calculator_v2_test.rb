# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class EnergyGrantsCalculatorV2Test < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'energy-grants-calculator-v2'
  end

  context "Energy grants calculator" do
    should "ask what you are looking for" do
      assert_current_node :what_are_you_looking_for?
    end

# help with fuel bills (bills_help)
    context "answer 'help with fuel bill" do
      setup do
        add_response :help_with_fuel_bill
      end
      should "ask what are your circumstances" do
        assert_current_node :what_are_your_circumstances?
      end
      # rent privately (permission)
      context "choose rent privately" do
        setup do
          add_response 'permission'
        end
        should "ask what's your date of birth" do
          assert_current_node :date_of_birth?
        end
        context "answer before 5th July 1951" do
          setup do
            add_response ' 4/07/1951'
          end
          should "be eligible for winter fuel payment" do
            assert_state_variable 'age_variant', :winter_fuel_payment
          end
          should "take you to help with bills outcome" do
            assert_current_node :outcome_help_with_bills # outcome 1
            assert_phrase_list :eligibilities_bills, [:winter_fuel_payments, :cold_weather_payment, :microgeneration]
          end
        end
        context "answer over 60" do
          setup do
            add_response 60.years.ago(Date.today).strftime("%Y-%m-%d")
          end
          should "store over 60 variable" do
            assert_state_variable 'age_variant', :over_60
          end
          should "take you to help with bills outcome" do
            assert_current_node :outcome_help_with_bills # outcome 1
            assert_phrase_list :eligibilities_bills, [:warm_home_discount, :microgeneration]
          end
        end
        context "answer under 60" do
          setup do
            add_response ' 9/09/1970'
          end
          should "take you to the help with bills outcome" do
            assert_current_node :outcome_help_with_bills # outcome 1
            assert_phrase_list :eligibilities_bills, [:warm_home_discount, :microgeneration,]
          end
        end
      end
      # claim benefits (benefits)
      context "choose benefits" do
        setup do
          add_response 'benefits'
        end
        should "ask what's your date of birth" do
          assert_current_node :date_of_birth?
        end
        # born before 5th July 1951
        context "answer before 5th July 1951" do
          setup do
            add_response ' 4/07/1951'
          end
          should "be eligible for winter fuel payment" do
            assert_state_variable 'age_variant', :winter_fuel_payment
          end
          should "ask which benefits you're claiming" do
            assert_current_node :which_benefits?
          end
          # types of benefit claimed
          context "answer pension credit" do
            setup do
              add_response 'pension_credit'
            end
            should "take you to help with bills outcome" do
              assert_current_node :outcome_help_with_bills # outcome 1
            end
          end
          context "answer income support" do
            setup do
              add_response 'income_support'
            end
            should "ask if you're elderly or disabled" do
              assert_current_node :disabled_or_have_children?
            end
            context "answer disabled" do
              setup do
                add_response 'disabled'
              end
              should "take you to help with bills outcome" do
                assert_current_node :outcome_help_with_bills # outcome 1
                assert_state_variable 'incomesupp_jobseekers_1', :incomesupp_jobseekers_1
              end
            end
          end
          context "answer child tax credit, esa , income_support, jsa and pension_credit" do
            setup do
              add_response 'child_tax_credit,esa,income_support,jsa,pension_credit'
            end
            should "ask if you're elderly or disabled" do
              assert_current_node :disabled_or_have_children?
            end
            context "answer child under 16" do
              setup do
                add_response 'child_under_16'
              end
              should "take you to help with bills outcome with incomesupp_jobseekers_2" do
                assert_current_node :outcome_help_with_bills # outcome 1
                assert_state_variable 'incomesupp_jobseekers_2', :incomesupp_jobseekers_2
              end
            end
          end
          context "answer child tax credit and esa" do
            setup do
              add_response 'child_tax_credit,esa'
            end
            should "take you to the help with bills outcome" do
              assert_current_node :outcome_help_with_bills # outcome 1
            end
          end
          context "answer none of these benefits" do
            setup do
              add_response 'none'
            end
            should "take you to help with bills outcome" do
              assert_current_node :outcome_help_with_bills # outcome 1
            end
          end
        end # END born before 5th July 1951

        # over 60 years old
        context "answer over 60" do
          setup do
            add_response 60.years.ago(Date.today).strftime("%Y-%m-%d")
          end
          should "store over 60 variable" do
            assert_state_variable 'age_variant', :over_60
          end
          should "ask which benefits you're claiming" do
            assert_current_node :which_benefits?
          end

          context "answer child tax credit" do
            setup do
              add_response 'child_tax_credit'
            end
            should "take you to help with bills outcome" do
              assert_current_node :outcome_help_with_bills # outcome 1
            end
          end
          context "answer working tax credit" do
            setup do
              add_response 'working_tax_credit'
            end
            should "ask if you're elderly or disabled" do
              assert_state_variable 'incomesupp_jobseekers_2', :incomesupp_jobseekers_2
              assert_current_node :disabled_or_have_children?
            end
            context "answer pensioner premium" do
              setup do
                add_response 'pensioner_premium'
              end
              should "take you to help with bills outcome with incomesupp_jobseekers_2" do
                assert_current_node :outcome_help_with_bills # outcome 1
                assert_state_variable 'incomesupp_jobseekers_1', :incomesupp_jobseekers_1
              end
            end
          end
          context "answer child tax credit, esa, income_support & pension credit" do
            setup do
              add_response 'child_tax_credit,esa,income_support,pension_credit'
            end
            should "ask if you're elderly or disabled" do
              assert_current_node :disabled_or_have_children?
            end

          end
          context "answer child tax credit, esa & pension credit" do
            setup do
              add_response 'child_tax_credit,esa,pension_credit'
            end
            should "take you to help with bills outcome" do
              assert_current_node :outcome_help_with_bills # outcome 1
            end
          end
          context "answer none of these benefits" do
            setup do
              add_response 'none'
            end
            should "take you to help with bills outcome" do
              assert_current_node :outcome_help_with_bills # outcome 1
            end
          end
        end
      end
    end # END help with fuel bills (help_with_bills)

# help to make home more energy efficient (measure_help)
    context "answer 'help to make home more energy efficient" do
      setup do
        add_response :help_energy_efficiency
      end
      should "ask what are your circumstances" do
        assert_current_node :what_are_your_circumstances?
      end

      context "choose benefits & social housing tenant" do
        setup do
          add_response 'benefits,social_housing'
        end
        should "ask which benefits you're claiming" do
          assert_current_node :which_benefits?
        end

        context "answer child tax credit" do
          setup do
            add_response 'child_tax_credit'
          end
          should "ask when your property was built" do
            assert_current_node :when_property_built?
          end
          context "answer modern" do
            setup do
              add_response '1985-2000s'
            end
            should "ask which of these do you have?" do
              assert_current_node :home_features_modern?
              assert_state_variable 'modern', :modern 
            end
            context "answer mains gas" do
              setup do
                add_response 'mains_gas'
              end
              should "take you to measures_help and eco_eligible outcome" do
                assert_current_node :outcome_measures_help_and_eco_eligible
                assert_phrase_list :title_end, [:title_energy_supplier]
                assert_phrase_list :eligibilities, [:a_condensing_boiler, :e_loft_roof_insulation, :eco_affordable_warmth, :eco_help, :heating, :h_fan_assisted_heater, :i_warm_air_unit, :j_better_heating_controls, :hot_water, :k_hot_water_cyclinder_jacket, :windows_and_doors, :m_replacement_glazing , :n_secondary_glazing, :o_external_doors, :microgeneration_renewables, :x_green_deal, :y_renewal_heat]
              end
            end
          end
        end
        
        context "answer working tax credit" do
          setup do
            add_response 'working_tax_credit'
          end
          should "ask if you're elderly or disabled" do
            assert_current_node :disabled_or_have_children?
          end
          context "answer child under 5" do
            setup do
              add_response "child_under_5"
            end
            should "ask when property built" do
              assert_current_node :when_property_built?
              assert_state_variable 'incomesupp_jobseekers_1', :incomesupp_jobseekers_1
            end
            context "answer older" do
              setup do
                add_response '1940s-1984'
              end
              should "ask what features does it have" do
                assert_current_node :home_features_older?
                assert_state_variable 'older', :older
              end
              context "answer cavity wall insulation, loft insulation, mains gas, modern boiler" do
                setup do
                  add_response 'cavity_wall_insulation,loft_insulation,mains_gas,modern_boiler'
                end
                should "take you to measures_help and eco_eligible outcome" do
                  assert_current_node :outcome_measures_help_and_eco_eligible
                  assert_phrase_list :title_end, [:title_energy_supplier]
                  assert_phrase_list :eligibilities, [:g_under_floor_insulation, :eco_affordable_warmth, :eco_help, :heating, :h_fan_assisted_heater, :i_warm_air_unit, :j_better_heating_controls, :hot_water, :k_hot_water_cyclinder_jacket, :l_cylinder_thermostat, :windows_and_doors, 
                    :m_replacement_glazing, :n_secondary_glazing, :o_external_doors, :microgeneration_renewables, :x_green_deal, :y_renewal_heat]
                end
              end
            end
          end
        end

        context "answer child tax credit, esa, jsa & pension credit" do
          setup do
            add_response 'child_tax_credit,esa,jsa,pension_credit'
          end
          should "ask if you're elderly or disabled" do
            assert_current_node :disabled_or_have_children?
          end
          context "answer none" do
            setup do
              add_response 'none'
            end
            should "ask when property was built" do
              assert_current_node :when_property_built?
            end
            context "answer historic" do
              setup do
                add_response 'before-1940'
              end
              should "ask which features your home has" do
                assert_current_node :home_features_historic?
              end
              context "answer loft_insulation, mains_gas, modern_boiler, modern_double_glazing" do
                setup do
                  add_response 'loft_insulation,mains_gas,modern_boiler,modern_double_glazing'
                end
                should "take you to measure help and eco_eligible outcome with variants" do
                  assert_current_node :outcome_measures_help_and_eco_eligible
                  assert_phrase_list :title_end, [:title_energy_supplier]
                  assert_phrase_list :eligibilities, [:g_under_floor_insulation, :eco_affordable_warmth, :eco_help, :heating, :h_fan_assisted_heater, :i_warm_air_unit, :j_better_heating_controls, :hot_water, :k_hot_water_cyclinder_jacket, :l_cylinder_thermostat, :microgeneration_renewables, :x_green_deal, :y_renewal_heat]
                end
              end
            end
          end
        end

        context "answer esa & pension credit" do
          setup do
            add_response 'esa,pension_credit'
          end
          should "ask when property built" do
            assert_current_node :when_property_built?
          end
          context "answer 1940s to 1984" do
            setup do
              add_response '1940s-1984'
            end
            should "ask what features your home has" do
              assert_current_node :home_features_older?
            end
            context "answer electric_heating and mains_gas" do
              setup do
                add_response 'electric_heating,mains_gas'
              end
              should "take you to measure help & eco_eligible outcome, with electric heating & mains gas variants" do
                assert_current_node :outcome_measures_help_and_eco_eligible
                assert_phrase_list :title_end, [:title_energy_supplier]
                assert_phrase_list :eligibilities, [:a_condensing_boiler, :e_loft_roof_insulation, :g_under_floor_insulation, :eco_affordable_warmth, :eco_help, :heating, :h_fan_assisted_heater, :i_warm_air_unit, :j_better_heating_controls, :hot_water, :k_hot_water_cyclinder_jacket, :l_cylinder_thermostat, :windows_and_doors, :m_replacement_glazing, :n_secondary_glazing, :o_external_doors, :microgeneration_renewables, :x_green_deal, :y_renewal_heat]
              end
            end
          end
        end

        context "answer none" do
          setup do
            add_response 'none'
          end
          should "ask when property built" do
            assert_current_node :when_property_built?
          end
          context "answer before 1940" do
            setup do
              add_response 'before-1940'
            end
            should "ask which features your home has" do
              assert_current_node :home_features_historic?
            end
            context "answer mains gas and modern boiler" do
              setup do
                add_response 'mains_gas,modern_boiler'
              end
              should "take you to measures help and eco eligible outcome" do
                assert_current_node :outcome_measures_help_green_deal
              end
            end
          end
        end
      end

    end

# help with a new boiler or other measures (measure_help)
    context "answer 'help with a new boiler, insulation or other measure" do
      setup do
        add_response :help_boiler_measure
      end
      should "ask what are your circumstances" do
        assert_current_node :what_are_your_circumstances?
      end
      context "choose property" do
        setup do
          add_response 'property'
        end
        should "ask when you're property was built" do
          assert_current_node :when_property_built?
        end
        context "answer modern" do
          setup do
            add_response '1985-2000s'
          end
          should "ask what features your modern home has" do
            assert_current_node :home_features_modern?
          end
          context "answer mains gas" do
            setup do
              add_response 'mains_gas'
            end
            should "take you to measure help & eco eligible outcome with mains gas variants" do
              assert_current_node :outcome_measures_help_and_eco_eligible
              assert_phrase_list :title_end, [:title_energy_supplier]
              assert_phrase_list :eligibilities, [:a_condensing_boiler, :e_loft_roof_insulation, :eco_affordable_warmth, :eco_help, :heating, :h_fan_assisted_heater, :i_warm_air_unit, :j_better_heating_controls, :hot_water, :k_hot_water_cyclinder_jacket, :windows_and_doors, :m_replacement_glazing, :n_secondary_glazing, :o_external_doors, :microgeneration_renewables, :x_green_deal, :y_renewal_heat]
            end
          end
        end
      end
    end

# all types of help (both_help)
    context "answer 'all of the above" do
      setup do
        add_response :all_help
      end
      should "ask what are your circumstances" do
        assert_current_node :what_are_your_circumstances?
      end
      context "choose permission" do
        setup do
          add_response 'permission'
        end
        should "ask what's your date of birth" do
          assert_current_node :date_of_birth?
        end
        context "answer under 60" do
          setup do
            add_response '12/12/1967'
          end
          should "ask when property was built" do
            assert_current_node :when_property_built?
          end
          context "answer before 1940s" do
            setup do
              add_response 'before-1940'
            end
            should "ask which home features you have" do
              assert_current_node :home_features_historic?
            end
            context "answer gas and glazing" do
              setup do
                add_response 'mains_gas,modern_double_glazing'
              end
              should "take you to bills and measures, no benefits outcome" do
                assert_current_node :outcome_bills_and_measures_no_benefits
                assert_phrase_list :eligibilities_bills, [:warm_home_discount, :microgeneration]
                assert_phrase_list :eligibilities, [:a_condensing_boiler, :e_loft_roof_insulation, :g_under_floor_insulation, :heating, :j_better_heating_controls, :hot_water, :k_hot_water_cyclinder_jacket, :l_cylinder_thermostat, :microgeneration_renewables, :x_green_deal, :y_renewal_heat]
              end
            end
          end
        end
      end
      context "answer benefits, under 60, working tax credit, child under 5, older house, loft conversion & mains gas" do
        setup do
          add_response 'benefits'
          add_response '12/05/1973'
          add_response 'working_tax_credit'
          add_response 'child_under_5'
          add_response '1940s-1984'
          add_response 'loft_attic_conversion,mains_gas'
        end
        should "take you to bills & measures, on benefits with variants" do
          assert_current_node :outcome_bills_and_measures_on_benefits_eco_eligible
          assert_phrase_list :eligibilities_bills, [:warm_home_discount, :cold_weather_payment, :energy_company_obligation]
          assert_phrase_list :eligibilities, [:a_condensing_boiler, :f_room_roof_insulation, :g_under_floor_insulation, :eco_help, :heating, :j_better_heating_controls, :hot_water, :k_hot_water_cyclinder_jacket, :l_cylinder_thermostat, :windows_and_doors, :m_replacement_glazing, :n_secondary_glazing, :o_external_doors, :microgeneration_renewables, :y_renewal_heat]
        end
      end
      context "answer benefits, under 60, income support, no disabilities, older house, loft_insulation & mains gas" do
        setup do
          add_response 'benefits'
          add_response '12/05/1970'
          add_response 'income_support'
          add_response 'none'
          add_response '1940s-1984'
          add_response 'loft_insulation,mains_gas'
        end
        should "take you to bills & measures, on benefits, not eco" do
          assert_current_node :outcome_bills_and_measures_on_benefits_not_eco_eligible
          assert_phrase_list :eligibilities, [:a_condensing_boiler, :g_under_floor_insulation, :eco_help, :heating, :j_better_heating_controls, :hot_water, :k_hot_water_cyclinder_jacket, :l_cylinder_thermostat, :windows_and_doors, :m_replacement_glazing, :n_secondary_glazing, :o_external_doors, :microgeneration_renewables, :x_green_deal, :y_renewal_heat]
        end
      end
    end

# test for incomesupp_jobseekers_2
    context "test that incomesupp_jobseekers_2 is being calculated correctly at Q4" do
      setup do
        add_response 'all_help'
        add_response 'benefits'
        add_response '08/06/1952'
        add_response 'working_tax_credit'
      end
      should "take you to next question" do
        assert_current_node :disabled_or_have_children?
        assert_state_variable 'incomesupp_jobseekers_2', :incomesupp_jobseekers_2
      end
    end

# test for mutually exclusive options in Q2
    context "check that mutually exclusive answers can't be selected in Q2" do
      setup do
        add_response 'help_with_fuel_bill'
      end
      should "raise error if selecting property and permission" do
        add_response 'property,permission'
        assert_current_node_is_error
      end
      should "raise error if property and social housing tenant" do
        add_response 'property,social_housing'
        assert_current_node_is_error
      end
      should "raise error if selecting permission and social housing tenant" do
        add_response 'permission,social_housing'
        assert_current_node_is_error
      end
      should "raise error if property, permission and social housing tenant" do
        add_response 'property,permission,social_housing'
        assert_current_node_is_error
      end
    end
  
# test for help with bills outcome variations
    context "winter fuel payment, benfits = pension credit" do
      setup do
        add_response 'help_with_fuel_bill'
        add_response 'benefits'
        add_response '08/06/1950'
        add_response 'pension_credit'
      end
      should "take you to help with bills outcome, winter fuel payment, benefits = pension credit" do
        assert_current_node :outcome_help_with_bills
        assert_phrase_list :eligibilities_bills, [:winter_fuel_payments, :warm_home_discount, :cold_weather_payment, :energy_company_obligation]
      end
    end
    context "no winter fuel payment, benefits = esa" do
      setup do
        add_response 'help_with_fuel_bill'
        add_response 'benefits'
        add_response '08/08/1970'
        add_response 'esa'
        add_response 'none'
      end
      should "take you to help with bills outcome, no winter fuel payment, benefit = ESA" do
        assert_current_node :outcome_help_with_bills
        assert_phrase_list :eligibilities_bills, [:warm_home_discount, :cold_weather_payment, :energy_company_obligation]
      end
    end
    context "no winter fuel payment, benefits = child tax credit" do
      setup do
        add_response 'help_with_fuel_bill'
        add_response 'benefits'
        add_response '08/08/1970'
        add_response 'child_tax_credit'
      end
      should "take you to help with bills outcome, no winter fuel, benefits = child tax credit" do
        assert_current_node :outcome_help_with_bills
        assert_phrase_list :eligibilities_bills, [:energy_company_obligation]
      end
    end
    context "winter fuel payment, no benefits" do
      setup do
        add_response 'help_with_fuel_bill'
        add_response 'none'
        add_response '08/06/1950'
      end
      should "take to help with bills outcome, winter fuel payment, no benefits" do
        assert_current_node :outcome_help_with_bills
        assert_phrase_list :eligibilities_bills, [:winter_fuel_payments, :cold_weather_payment, :microgeneration]
      end
    end
    context "no winter fuel payment, no benefits" do
      setup do
        add_response 'help_with_fuel_bill'
        add_response 'none'
        add_response '07/05/1965'
      end
      should "take you to help with bills outcome, no winter fuel, no benefits" do
        assert_current_node :outcome_help_with_bills
        assert_phrase_list :eligibilities_bills, [:warm_home_discount, :microgeneration]
      end
    end

# test for measure_help green deal outcomes
    context "circumstances = none, modern house, no features" do
      setup do
        add_response 'help_boiler_measure'
        add_response 'none'
        add_response '1985-2000s'
        add_response 'none'
      end
      should "take you to the green deal outcome with these variations" do
        assert_current_node :outcome_measures_help_green_deal
        assert_phrase_list :eligibilities, [:a_condensing_boiler, :b_cavity_wall_insulation, :c_solid_wall_insulation, :d_draught_proofing, :e_loft_roof_insulation, :heating, :h_fan_assisted_heater, :i_warm_air_unit, :j_better_heating_controls, :hot_water, :k_hot_water_cyclinder_jacket, :windows_and_doors, :m_replacement_glazing, :n_secondary_glazing, :o_external_doors, :microgeneration_renewables, :x_green_deal, :y_renewal_heat]
      end
    end
    context "social housing, historic house, mains gas" do
      setup do
        add_response 'help_boiler_measure'
        add_response 'social_housing'
        add_response 'before-1940'
        add_response 'mains_gas'
      end
      should "take you to green deal outcome with mains gas variants" do
        assert_current_node :outcome_measures_help_green_deal
        assert_phrase_list :eligibilities, [:a_condensing_boiler, :b_cavity_wall_insulation, :c_solid_wall_insulation, :d_draught_proofing, :e_loft_roof_insulation, :g_under_floor_insulation, :heating, :j_better_heating_controls, :hot_water, :k_hot_water_cyclinder_jacket, :windows_and_doors, :m_replacement_glazing, :n_secondary_glazing, :o_external_doors, :microgeneration_renewables, :x_green_deal, :y_renewal_heat]
      end
    end

  end
end
