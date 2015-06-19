module SmartAnswer
  class EnergyGrantsCalculatorFlow < Flow
    def define
      name 'energy-grants-calculator'
      status :published
      satisfies_need "100259"

      # Q1
      multiple_choice :what_are_you_looking_for? do
        option :help_with_fuel_bill
        option :help_energy_efficiency
        option :help_boiler_measure
        option :all_help
        save_input_as :which_help

        calculate :bills_help do |response|
          %w(help_with_fuel_bill).include?(response) ? :bills_help : nil
        end
        calculate :measure_help do |response|
          %w(help_energy_efficiency help_boiler_measure).include?(response) ? :measure_help : nil
        end
        calculate :both_help do |response|
          %w(all_help).include?(response) ? :both_help : nil
        end

        calculate :warm_home_discount_amount do
          ''
        end

        next_node do |response|
          if ['help_with_fuel_bill'].include?(response)
            :what_are_your_circumstances? # Q2
          else
            :what_are_your_circumstances_without_bills_help? # Q2A
          end
        end
      end

      # Q2
      checkbox_question :what_are_your_circumstances? do
        option :benefits
        option :property
        option :permission
        option :social_housing

        calculate :circumstances do |response|
          response.split(",")
        end

        calculate :benefits_claimed do
          []
        end

        validate(:error_perm_prop_house) { |r| ! r.include?('permission,property,social_housing') }
        validate(:error_prop_house) { |r| ! r.include?('property,social_housing') }
        validate(:error_perm_prop) { |r| ! r.include?('permission,property') }
        validate(:error_perm_house) { |r| ! r.include?('permission,social_housing')}

        next_node do |response|
          :date_of_birth? # Q3
        end
      end

      # Q2A
      checkbox_question :what_are_your_circumstances_without_bills_help? do
        option :benefits
        option :property
        option :permission

        calculate :circumstances do |response|
          response.split(",")
        end

        calculate :benefits_claimed do
          []
        end

        validate(:error_perm_prop) { |r| ! r.include?('permission,property') }

        next_node do |response|
          if both_help
            :date_of_birth?
          elsif %w(help_energy_efficiency help_boiler_measure).include?(which_help)
            if ['benefits'].include?(response)
              :which_benefits?
            else
              :when_property_built?
            end
          end
        end
      end

      # Q3
      date_question :date_of_birth? do
        date_of_birth_defaults

        calculate :age_variant do |response|
          dob = response
          if dob < Date.new(1951, 7, 5)
            :winter_fuel_payment
          elsif dob < 60.years.ago(Date.today + 1)
            :over_60
          end
        end

        next_node do |response|
          if circumstances.include?('benefits')
            :which_benefits?
          elsif bills_help
            :outcome_help_with_bills # outcome 1
          else
            :when_property_built? # Q6
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

        calculate :benefits_claimed do |response|
          response.split(",")
        end
        calculate :incomesupp_jobseekers_2 do |response|
          if %w(working_tax_credit).include?(response)
            if age_variant == :over_60
              :incomesupp_jobseekers_2
            end
          end
        end

        next_node do |response|
          if ['pension_credit', 'child_tax_credit'].include?(response)
            if bills_help
              next :outcome_help_with_bills # outcome 1
            else
              next :when_property_built? # Q6
            end
          elsif response == 'income_support' ||
                response == 'jsa' ||
                response == 'esa' ||
                response == 'working_tax_credit' ||
                %w{child_tax_credit esa income_support jsa pension_credit}.all? {|key| response.include? key} ||
                %w{child_tax_credit esa income_support pension_credit}.all? {|key| response.include? key} ||
                %w{child_tax_credit esa jsa pension_credit}.all? {|key| response.include? key}
            next :disabled_or_have_children? # Q5
          elsif bills_help
            next :outcome_help_with_bills # outcome 1
          else
            next :when_property_built? # Q6
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

        calculate :incomesupp_jobseekers_1 do |response|
          case response
          when 'disabled', 'disabled_child', 'child_under_5', 'pensioner_premium'
            :incomesupp_jobseekers_1
          end
        end
        calculate :incomesupp_jobseekers_2 do |response|
          case response
          when 'child_under_16', 'work_support_esa'
            if circumstances.include?('social_housing') || (benefits_claimed.include?('working_tax_credit') && age_variant != :over_60)
              nil
            else
              :incomesupp_jobseekers_2
            end
          end
        end

        next_node do |response|
          if bills_help
            :outcome_help_with_bills # outcome 1
          else
            :when_property_built? # Q6
          end
        end
      end

      # Q6
      multiple_choice :when_property_built? do
        option :"on-or-after-1995"
        option :"1940s-1984"
        option :"before-1940"
        save_input_as :property_age

        calculate :modern do |response|
          %w(on-or-after-1995).include?(response)
        end
        calculate :older do |response|
          %w(1940s-1984).include?(response)
        end
        calculate :historic do |response|
          %w(before-1940).include?(response)
        end

        next_node do
          :type_of_property?
        end
      end

      # Q7a
      multiple_choice :type_of_property? do
        option :house
        option :flat
        save_input_as :property_type

        next_node do |response|
          if ['house'].include?(response)
            if modern
              :home_features_modern?
            elsif older
              :home_features_older?
            else
              :home_features_historic?
            end
          else
            :type_of_flat?
          end
        end
      end

      # Q7b
      multiple_choice :type_of_flat? do
        option :top_floor
        option :ground_floor
        save_input_as :flat_type

        next_node do |response|
          if modern
            :home_features_modern?
          elsif older
            :home_features_older?
          else
            :home_features_historic?
          end
        end
      end

      # Q8a modern
      checkbox_question :home_features_modern? do
        option :mains_gas
        option :electric_heating
        option :loft_attic_conversion
        option :draught_proofing

        calculate :features do |response|
          response.split(",")
        end

        next_node do |response|
          if modern && response.include?('mains_gas') && response.include?('electric_heating')
            :outcome_no_green_deal_no_energy_measures
          elsif measure_help && (circumstances & %w(property permission)).any?
            :outcome_measures_help_green_deal
          elsif circumstances.exclude?('benefits')
            :outcome_bills_and_measures_no_benefits
          elsif (circumstances & %w(property permission)).any? and ((benefits_claimed & %w(child_tax_credit esa pension_credit)).any? or incomesupp_jobseekers_1 or incomesupp_jobseekers_2)
            :outcome_bills_and_measures_on_benefits_eco_eligible
          else
            :outcome_bills_and_measures_on_benefits_not_eco_eligible
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

        calculate :features do |response|
          response.split(",")
        end

        next_node do |response|
          if measure_help && (circumstances & %w(property permission)).any?
            :outcome_measures_help_green_deal
          elsif circumstances.exclude?('benefits')
            :outcome_bills_and_measures_no_benefits
          elsif (circumstances & %w(property permission)).any? and ((benefits_claimed & %w(child_tax_credit esa pension_credit)).any? or incomesupp_jobseekers_1 or incomesupp_jobseekers_2)
            :outcome_bills_and_measures_on_benefits_eco_eligible
          else
            :outcome_bills_and_measures_on_benefits_not_eco_eligible
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

        calculate :features do |response|
          response.split(",")
        end

        next_node do |response|
          if measure_help && (circumstances & %w(property permission)).any?
            :outcome_measures_help_green_deal
          elsif circumstances.exclude?('benefits')
            :outcome_bills_and_measures_no_benefits
          elsif (circumstances & %w(property permission)).any? and ((benefits_claimed & %w(child_tax_credit esa pension_credit)).any? or incomesupp_jobseekers_1 or incomesupp_jobseekers_2)
            :outcome_bills_and_measures_on_benefits_eco_eligible
          else
            :outcome_bills_and_measures_on_benefits_not_eco_eligible
          end
        end
      end

      outcome :outcome_help_with_bills do
        precalculate :help_with_bills_outcome_title do
          if age_variant == :winter_fuel_payment
            PhraseList.new(:title_help_with_bills_outcome)
          elsif circumstances.include?('benefits')
            if (benefits_claimed & %w(esa child_tax_credit pension_credit)).any? || incomesupp_jobseekers_1 || incomesupp_jobseekers_2 || benefits_claimed.include?('working_tax_credit') && age_variant == :over_60
              PhraseList.new(:title_help_with_bills_outcome)
            else
              PhraseList.new(:title_no_help_with_bills_outcome)
            end
          else
            PhraseList.new(:title_no_help_with_bills_outcome)
          end
        end

        precalculate :eligibilities_bills do
          phrases = PhraseList.new
          if circumstances.include?('benefits')
            if age_variant == :winter_fuel_payment
              phrases << :winter_fuel_payments
            end
            if (benefits_claimed & %w(esa pension_credit)).any? || incomesupp_jobseekers_1
              if benefits_claimed.include?('pension_credit')
                phrases << :warm_home_discount << :cold_weather_payment
              else
                phrases << :cold_weather_payment
              end
            end
            if (benefits_claimed & %w(esa child_tax_credit pension_credit)).any? || incomesupp_jobseekers_1 || incomesupp_jobseekers_2 || benefits_claimed.include?('working_tax_credit') && age_variant == :over_60
              phrases << :energy_company_obligation
            end
          else
            if age_variant == :winter_fuel_payment
              phrases << :winter_fuel_payments
            end
          end
          phrases << :smartmeters
          if circumstances.include?('benefits') or bills_help
            phrases << :microgeneration
          end
          phrases
        end
      end

      outcome :outcome_measures_help_green_deal do
        precalculate :title_end do
          PhraseList.new(:title_under_green_deal)
        end
        precalculate :eligibilities do
          phrases = PhraseList.new
          phrases << :header_boilers_and_insulation
          phrases << :opt_condensing_boiler unless (features & %w(modern_boiler)).any?
          phrases << :opt_cavity_wall_insulation << :opt_solid_wall_insulation
          phrases << :opt_draught_proofing unless (features & %w(draught_proofing)).any?
          phrases << :opt_loft_roof_insulation unless (features & %w(loft_insulation loft_attic_conversion)).any? || property_type == 'flat'
          unless flat_type == "top_floor"
            phrases << :opt_room_roof_insulation if (features & %w(loft_attic_conversion)).any? || property_type == 'flat'
            phrases << :opt_under_floor_insulation unless modern
          end
          phrases << :header_heating << :opt_better_heating_controls
          (phrases << :opt_heat_pump << :opt_biomass_boilers_heaters << :opt_solar_water_heating) unless (features & %w(mains_gas)).any?
          (phrases << :header_windows_and_doors << :opt_replacement_glazing) unless (features & %w(modern_double_glazing)).any?
          phrases << :opt_renewal_heat unless bills_help
          phrases << :help_and_advice << :help_and_advice_body
          phrases
        end
      end

      outcome :outcome_bills_and_measures_no_benefits do
        precalculate :eligibilities_bills do
          phrases = PhraseList.new
          if both_help
            (phrases << :winter_fuel_payments << :cold_weather_payment) if age_variant == :winter_fuel_payment
            phrases << :smartmeters
          end
          phrases
        end

        precalculate :title_end do
          if both_help && !circumstances.include?('benefits')
            PhraseList.new(:title_under_green_deal)
          else
            PhraseList.new(:title_energy_supplier)
          end
        end

        precalculate :eligibilities do
          phrases = PhraseList.new
          phrases << :header_boilers_and_insulation
          phrases << :opt_condensing_boiler unless (features & %w(modern_boiler)).any?
          phrases << :opt_cavity_wall_insulation unless (features & %w(mains_gas)).any?
          phrases << :opt_solid_wall_insulation unless (features & %w(mains_gas solid_wall_insulation)).any?
          phrases << :opt_draught_proofing unless (features & %w(draught_proofing mains_gas)).any?
          phrases << :opt_loft_roof_insulation unless (features & %w(loft_insulation loft_attic_conversion)).any? || property_type == 'flat'
          unless flat_type == "top_floor"
            phrases << :opt_room_roof_insulation if (features & %w(loft_attic_conversion)).any? || property_type == 'flat'
            phrases << :opt_under_floor_insulation unless modern
          end
          phrases << :header_heating << :opt_better_heating_controls
          (phrases << :opt_heat_pump << :opt_biomass_boilers_heaters << :opt_solar_water_heating) unless (features & %w(mains_gas)).any?
          (phrases << :header_windows_and_doors << :opt_replacement_glazing) unless (features & %w(modern_double_glazing)).any?
          phrases << :opt_renewal_heat << :help_and_advice << :help_and_advice_body
          phrases
        end
      end

      outcome :outcome_bills_and_measures_on_benefits_eco_eligible do
        precalculate :eligibilities_bills do
          phrases = PhraseList.new
          if both_help
            phrases << :winter_fuel_payments if age_variant == :winter_fuel_payment
            if (benefits_claimed & %w(esa pension_credit)).any? || incomesupp_jobseekers_1
              phrases << :warm_home_discount if benefits_claimed.include?('pension_credit')
              phrases << :cold_weather_payment
            end
            if (benefits_claimed & %w(esa child_tax_credit pension_credit)).any? || incomesupp_jobseekers_1 || incomesupp_jobseekers_2 || benefits_claimed.include?('working_tax_credit') && age_variant == :over_60
              phrases << :energy_company_obligation
            end
          end
          phrases
        end

        precalculate :title_end do
          if (both_help && circumstances.include?('property')) || (circumstances.include?('permission') && circumstances.include?('pension_credit')) || incomesupp_jobseekers_1 || incomesupp_jobseekers_2 || (benefits_claimed & %w(esa child_tax_credit working_tax_credit)).any?
            PhraseList.new(:title_energy_supplier)
          else
            PhraseList.new(:title_under_green_deal)
          end
        end

        precalculate :eligibilities do
          phrases = PhraseList.new
          phrases << :header_boilers_and_insulation
          phrases << :opt_condensing_boiler unless (features & %w(modern_boiler)).any?
          phrases << :opt_cavity_wall_insulation unless (features & %w(cavity_wall_insulation mains_gas)).any?
          phrases << :opt_solid_wall_insulation unless (features & %w(mains_gas solid_wall_insulation)).any?
          phrases << :opt_draught_proofing unless (features & %w(draught_proofing mains_gas)).any?
          phrases << :opt_loft_roof_insulation unless (features & %w(loft_insulation loft_attic_conversion)).any? || property_type == 'flat'
          unless flat_type == "top_floor"
            phrases << :opt_room_roof_insulation if (features & %w(loft_attic_conversion)).any? || property_type == 'flat'
            phrases << :opt_under_floor_insulation unless modern
          end
          phrases << :opt_eco_help << :header_heating << :opt_better_heating_controls
          (phrases << :opt_heat_pump << :opt_biomass_boilers_heaters << :opt_solar_water_heating) unless (features & %w(mains_gas)).any?
          (phrases << :header_windows_and_doors << :opt_replacement_glazing) unless (features & %w(modern_double_glazing)).any?
          phrases << :opt_renewal_heat << :help_and_advice << :help_and_advice_body
          phrases
        end
      end

      outcome :outcome_bills_and_measures_on_benefits_not_eco_eligible do
        precalculate :eligibilities_bills do
          phrases = PhraseList.new
          if both_help
            phrases << :winter_fuel_payments if age_variant == :winter_fuel_payment
            if (benefits_claimed & %w(esa pension_credit)).any? || incomesupp_jobseekers_1
              phrases << :warm_home_discount if benefits_claimed.include?('pension_credit')
              phrases << :cold_weather_payment
            end
            if (benefits_claimed & %w(esa child_tax_credit pension_credit)).any? || incomesupp_jobseekers_1 || incomesupp_jobseekers_2 || benefits_claimed.include?('working_tax_credit') && age_variant == :over_60
              phrases << :energy_company_obligation
            end
          end
          phrases
        end

        precalculate :title_end do
          unless both_help && age_variant == :over_60 && (benefits_claimed & %w(esa child_tax_credit working_tax_credit) || incomesupp_jobseekers_1 || incomesupp_jobseekers_2)
            PhraseList.new(:title_energy_supplier)
          else
            PhraseList.new(:title_under_green_deal)
          end
        end

        precalculate :eligibilities do
          phrases = PhraseList.new
          phrases << :header_boilers_and_insulation
          phrases << :opt_condensing_boiler unless (features & %w(modern_boiler)).any?
          (phrases << :opt_cavity_wall_insulation << :opt_solid_wall_insulation) unless (features & %w(mains_gas)).any?
          phrases << :opt_draught_proofing unless (features & %w(draught_proofing mains_gas)).any?
          phrases << :opt_loft_roof_insulation unless (features & %w(loft_insulation loft_attic_conversion)).any? || property_type == 'flat'
          unless flat_type == "top_floor"
            phrases << :opt_room_roof_insulation if (features & %w(loft_attic_conversion)).any? || property_type == 'flat'
            phrases << :opt_under_floor_insulation unless modern
          end
          phrases << :opt_eco_help << :header_heating << :opt_better_heating_controls
          (phrases << :opt_heat_pump << :opt_biomass_boilers_heaters << :opt_solar_water_heating) unless (features & %w(mains_gas)).any?
          (phrases << :header_windows_and_doors << :opt_replacement_glazing) unless (features & %w(modern_double_glazing)).any?
          phrases << :opt_renewal_heat << :help_and_advice << :help_and_advice_body
          phrases
        end
      end

      outcome :outcome_no_green_deal_no_energy_measures do
        precalculate :eligibilities do
          PhraseList.new(:help_and_advice_body)
        end
      end
    end
  end
end
