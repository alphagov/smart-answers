require 'smart_answer/calculators/energy_grants_calculator'

module SmartAnswer
  class EnergyGrantsCalculatorFlow < Flow
    def define
      start_page_content_id "20c0a04d-1db4-4828-bd40-bc99954ca5f9"
      name 'energy-grants-calculator'
      status :published
      satisfies_need "100259"

      # Q1
      multiple_choice :what_are_you_looking_for? do
        option :help_with_fuel_bill
        option :help_energy_efficiency
        option :help_boiler_measure
        option :all_help

        on_response do |response|
          self.calculator = Calculators::EnergyGrantsCalculator.new
          calculator.which_help = response
        end

        next_node do
          if calculator.bills_help?
            question :what_are_your_circumstances? # Q2
          else
            question :what_are_your_circumstances_without_bills_help? # Q2A
          end
        end
      end

      # Q2
      checkbox_question :what_are_your_circumstances? do
        option :benefits
        option :property
        option :permission
        option :social_housing

        on_response do |response|
          calculator.circumstances = response.split(",")
        end

        validate(:error_perm_prop_house) { |r| ! r.include?('permission,property,social_housing') }
        validate(:error_prop_house) { |r| ! r.include?('property,social_housing') }
        validate(:error_perm_prop) { |r| ! r.include?('permission,property') }
        validate(:error_perm_house) { |r| ! r.include?('permission,social_housing') }

        next_node do
          question :date_of_birth? # Q3
        end
      end

      # Q2A
      checkbox_question :what_are_your_circumstances_without_bills_help? do
        option :benefits
        option :property
        option :permission

        on_response do |response|
          calculator.circumstances = response.split(",")
        end

        validate(:error_perm_prop) { |r| ! r.include?('permission,property') }

        next_node do
          if calculator.both_help?
            question :date_of_birth?
          elsif calculator.measure_help?
            if calculator.circumstances == %w(benefits)
              question :which_benefits?
            else
              question :when_property_built?
            end
          end
        end
      end

      # Q3
      date_question :date_of_birth? do
        date_of_birth_defaults

        on_response do |response|
          calculator.date_of_birth = response
        end

        next_node do
          if calculator.circumstances.include?('benefits')
            question :which_benefits?
          elsif calculator.bills_help?
            outcome :outcome_help_with_bills # outcome 1
          else
            question :when_property_built? # Q6
          end
        end
      end

      # Q4
      checkbox_question :which_benefits? do
        option :pension_credit
        option :income_support
        option :jsa
        option :esa
        option :child_tax_credit
        option :working_tax_credit
        option :universal_credit

        on_response do |response|
          calculator.benefits_claimed = response.split(",")
        end

        next_node do
          if calculator.claiming_pension_credit_only_or_child_tax_credit_only?
            if calculator.bills_help?
              outcome :outcome_help_with_bills # outcome 1
            else
              question :when_property_built? # Q6
            end
          elsif calculator.disabled_or_have_children_question?
            question :disabled_or_have_children? # Q5
          elsif calculator.bills_help?
            outcome :outcome_help_with_bills # outcome 1
          else
            question :when_property_built? # Q6
          end
        end
      end

      # Q5
      checkbox_question :disabled_or_have_children? do
        option :disabled
        option :disabled_child
        option :child_under_5
        option :child_under_16
        option :pensioner_premium
        option :work_support_esa

        on_response do |response|
          calculator.disabled_or_have_children = response.split(",")
        end

        next_node do
          if calculator.bills_help?
            outcome :outcome_help_with_bills # outcome 1
          else
            question :when_property_built? # Q6
          end
        end
      end

      # Q6
      multiple_choice :when_property_built? do
        option :"on-or-after-1995"
        option :"1940s-1984"
        option :"before-1940"

        on_response do |response|
          calculator.property_age = response
        end

        next_node do
          question :type_of_property?
        end
      end

      # Q7a
      multiple_choice :type_of_property? do
        option :house
        option :flat

        on_response do |response|
          calculator.property_type = response
        end

        next_node do
          if calculator.house_property_type?
            if calculator.modern_property?
              question :home_features_modern?
            elsif calculator.older_property?
              question :home_features_older?
            elsif calculator.historic_property?
              question :home_features_historic?
            end
          elsif calculator.flat_property_type?
            question :type_of_flat?
          end
        end
      end

      # Q7b
      multiple_choice :type_of_flat? do
        option :top_floor
        option :ground_floor

        on_response do |response|
          calculator.flat_type = response
        end

        next_node do
          if calculator.modern_property?
            question :home_features_modern?
          elsif calculator.older_property?
            question :home_features_older?
          elsif calculator.historic_property?
            question :home_features_historic?
          end
        end
      end

      # Q8a modern
      checkbox_question :home_features_modern? do
        option :mains_gas
        option :electric_heating
        option :loft_attic_conversion
        option :draught_proofing

        on_response do |response|
          calculator.features = response.split(",")
        end

        next_node do
          if calculator.modern_and_gas_and_electric_heating?
            outcome :outcome_no_green_deal_no_energy_measures
          elsif calculator.measure_help_and_property_permission_circumstance?
            outcome :outcome_measures_help_green_deal
          elsif calculator.no_benefits?
            outcome :outcome_bills_and_measures_no_benefits
          elsif calculator.property_permission_circumstance_and_benefits?
            outcome :outcome_bills_and_measures_on_benefits_eco_eligible
          else
            outcome :outcome_bills_and_measures_on_benefits_not_eco_eligible
          end
        end
      end

      # Q8b
      checkbox_question :home_features_historic? do
        option :mains_gas
        option :electric_heating
        option :modern_double_glazing
        option :loft_attic_conversion
        option :loft_insulation
        option :solid_wall_insulation
        option :modern_boiler
        option :draught_proofing

        on_response do |response|
          calculator.features = response.split(",")
        end

        next_node do
          if calculator.measure_help_and_property_permission_circumstance?
            outcome :outcome_measures_help_green_deal
          elsif calculator.no_benefits?
            outcome :outcome_bills_and_measures_no_benefits
          elsif calculator.property_permission_circumstance_and_benefits?
            outcome :outcome_bills_and_measures_on_benefits_eco_eligible
          else
            outcome :outcome_bills_and_measures_on_benefits_not_eco_eligible
          end
        end
      end

      # Q8c
      checkbox_question :home_features_older? do
        option :mains_gas
        option :electric_heating
        option :modern_double_glazing
        option :loft_attic_conversion
        option :loft_insulation
        option :solid_wall_insulation
        option :cavity_wall_insulation
        option :modern_boiler
        option :draught_proofing

        on_response do |response|
          calculator.features = response.split(",")
        end

        next_node do
          if calculator.measure_help_and_property_permission_circumstance?
            outcome :outcome_measures_help_green_deal
          elsif calculator.no_benefits?
            outcome :outcome_bills_and_measures_no_benefits
          elsif calculator.property_permission_circumstance_and_benefits?
            outcome :outcome_bills_and_measures_on_benefits_eco_eligible
          else
            outcome :outcome_bills_and_measures_on_benefits_not_eco_eligible
          end
        end
      end

      outcome :outcome_help_with_bills
      outcome :outcome_measures_help_green_deal
      outcome :outcome_bills_and_measures_no_benefits
      outcome :outcome_bills_and_measures_on_benefits_eco_eligible
      outcome :outcome_bills_and_measures_on_benefits_not_eco_eligible
      outcome :outcome_no_green_deal_no_energy_measures
    end
  end
end
