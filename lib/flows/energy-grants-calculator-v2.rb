status :draft
satisfies_need "100259"

# Q1
multiple_choice :what_are_you_looking_for? do
  option :help_with_fuel_bill
  option :help_energy_efficiency
  option :help_boiler_measure
  option :all_help

  calculate :bills_help do
    %w(help_with_fuel_bill).include?(responses.last) ? :bills_help : nil
  end
  calculate :measure_help do
    %w(help_energy_efficiency help_boiler_measure).include?(responses.last) ? :measure_help : nil
  end
  calculate :both_help do
    %w(all_help).include?(responses.last) ? :both_help : nil
  end

  calculate :warm_home_discount_amount do
    if Date.today < Date.civil(2014, 4, 6)
      135
    else
      ''
    end
  end
  next_node do |response|
    unless response.include?('help_with_fuel_bill')
      :what_are_your_circumstances_without_bills_help? #Q2A
    else
      :what_are_your_circumstances? #Q2
    end
  end
end

# Q2
checkbox_question :what_are_your_circumstances? do
  option :benefits
  option :property
  option :permission
  option :social_housing

  calculate :circumstances do
    responses.last.split(",")
  end

  calculate :benefits_claimed do
    []
  end

  next_node do |response|
    if response =~ /permission,property,social_housing/
      raise InvalidResponse, :error_perm_prop_house
    elsif response =~ /property,social_housing/
      raise InvalidResponse, :error_prop_house
    elsif response =~ /permission,property/
      raise InvalidResponse, :error_perm_prop
    elsif response =~ /permission,social_housing/
      raise InvalidResponse, :error_perm_house
    elsif bills_help || both_help
      :date_of_birth? # Q3
    elsif measure_help
      if response.include?('benefits')
        :which_benefits? # Q4
      else
        :when_property_built? # Q6
      end
    end
  end
end

# Q2A
checkbox_question :what_are_your_circumstances_without_bills_help? do
  option :benefits
  option :property
  option :permission

  calculate :circumstances do
    responses.last.split(",")
  end

  calculate :benefits_claimed do
    []
  end

  next_node do |response|
    if response =~ /permission,property/
      raise InvalidResponse, :error_perm_prop
    elsif bills_help || both_help
      :date_of_birth? # Q3
    elsif measure_help
      if response.include?('benefits')
        :which_benefits? # Q4
      else
        :when_property_built? # Q6
      end
    end
  end
end

# Q3
date_question :date_of_birth? do
  from { 100.years.ago }
  to { Date.today }

  calculate :age_variant do
    dob = Date.parse(responses.last)
    if dob < Date.new(1951, 7, 5)
      :winter_fuel_payment
    elsif dob < 60.years.ago(Date.today + 1)
      :over_60
    end
  end

  next_node do |response|
    if circumstances.include?('benefits')
      :which_benefits?
    else
      if bills_help
        :outcome_help_with_bills # outcome 1
      else
        :when_property_built? # Q6
      end
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

  calculate :benefits_claimed do
    responses.last.split(",")
  end
  calculate :incomesupp_jobseekers_2 do
    if %w(working_tax_credit).include?(responses.last)
      if age_variant == :over_60
        :incomesupp_jobseekers_2
      end
    end
  end

  next_node do |response|
    if response == 'pension_credit' || response == 'child_tax_credit'
      if bills_help
        :outcome_help_with_bills # outcome1
      else
        :when_property_built? # Q6
      end

    elsif response == 'income_support' || response == 'jsa' || response == 'esa' || response == 'working_tax_credit'
      :disabled_or_have_children? # Q5

    elsif response =~ /child_tax_credit,esa,income_support,jsa,pension_credit/ || response =~ /child_tax_credit,esa,income_support,pension_credit/ || response =~ /child_tax_credit,esa,jsa,pension_credit/
      :disabled_or_have_children? # Q5

    elsif response =~ /esa,pension_credit/ || response =~ /child_tax_credit,esa/ || response =~ /child_tax_credit,esa,pension_credit/
      if bills_help
        :outcome_help_with_bills # outcome1
      else
        :when_property_built? # Q6
      end
    else
      if bills_help
        :outcome_help_with_bills # outcome1
      else
        :when_property_built? # Q6
      end
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

  calculate :incomesupp_jobseekers_1 do
    case responses.last
    when 'disabled', 'disabled_child', 'child_under_5', 'pensioner_premium'
      :incomesupp_jobseekers_1
    end
  end
  calculate :incomesupp_jobseekers_2 do
    case responses.last
    when 'child_under_16', 'work_support_esa'
      if circumstances.include?('social_housing') || (benefits_claimed.include?('working_tax_credit') && age_variant != :over_60)
        nil
      else
        :incomesupp_jobseekers_2
      end
    end
  end

  next_node do
    if bills_help
      :outcome_help_with_bills
    else
      :when_property_built?
    end
  end
end

# Q6
multiple_choice :when_property_built? do
  option :"on-or-after-1995"
  option :"1940s-1984"
  option :"before-1940"

  calculate :modern do
    %w(on-or-after-1995).include?(responses.last)
  end
  calculate :older do
    %w(1940s-1984).include?(responses.last)
  end
  calculate :historic do
    %w(before-1940).include?(responses.last)
  end

  next_node :type_of_property?
end

# Q7a
multiple_choice :type_of_property? do
  option :house
  option :flat
  save_input_as :property_type

  next_node do |response|
    if %w(house).include?(response)
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
  option :maisonette
  save_input_as :flat_type

  next_node do
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

  calculate :features do
    responses.last.split(",")
  end

  next_node do |response|
    features = response.split(',')
    if modern && features.include?('mains_gas') && features.include?('electric_heating')
      :outcome_no_green_deal_no_energy_measures
    elsif measure_help and (circumstances & %w(property permission)).any?
      if (benefits_claimed & %w(child_tax_credit esa pension_credit)).any? or incomesupp_jobseekers_1 or incomesupp_jobseekers_2
        :outcome_measures_help_and_eco_eligible
      else
        :outcome_measures_help_green_deal
      end
    else
      if circumstances.exclude?('benefits')
        :outcome_bills_and_measures_no_benefits
      else
        if (circumstances & %w(property permission)).any? and ((benefits_claimed & %w(child_tax_credit esa pension_credit)).any? or incomesupp_jobseekers_1 or incomesupp_jobseekers_2)
          :outcome_bills_and_measures_on_benefits_eco_eligible
        else
          :outcome_bills_and_measures_on_benefits_not_eco_eligible
        end
      end
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

  calculate :features do
    responses.last.split(",")
  end

  next_node do
    if measure_help and (circumstances & %w(property permission)).any?
      if (benefits_claimed & %w(child_tax_credit esa pension_credit)).any? or incomesupp_jobseekers_1 or incomesupp_jobseekers_2
        :outcome_measures_help_and_eco_eligible
      else
        :outcome_measures_help_green_deal
      end
    else
      if circumstances.exclude?('benefits')
        :outcome_bills_and_measures_no_benefits
      else
        if (circumstances & %w(property permission)).any? and ((benefits_claimed & %w(child_tax_credit esa pension_credit)).any? or incomesupp_jobseekers_1 or incomesupp_jobseekers_2)
          :outcome_bills_and_measures_on_benefits_eco_eligible
        else
          :outcome_bills_and_measures_on_benefits_not_eco_eligible
        end
      end
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

  calculate :features do
    responses.last.split(",")
  end

  next_node do
    if measure_help and (circumstances & %w(property permission)).any?
      if (benefits_claimed & %w(child_tax_credit esa pension_credit)).any? or incomesupp_jobseekers_1 or incomesupp_jobseekers_2
        :outcome_measures_help_and_eco_eligible
      else
        :outcome_measures_help_green_deal
      end
    else
      if circumstances.exclude?('benefits')
        :outcome_bills_and_measures_no_benefits
      else
        if (circumstances & %w(property permission)).any? and ((benefits_claimed & %w(child_tax_credit esa pension_credit)).any? or incomesupp_jobseekers_1 or incomesupp_jobseekers_2)
          :outcome_bills_and_measures_on_benefits_eco_eligible
        else
          :outcome_bills_and_measures_on_benefits_not_eco_eligible
        end
      end
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

outcome :outcome_social_housing

outcome :outcome_measures_help_and_eco_eligible do
  precalculate :title_end do
    if (measure_help && both_help) || measure_help && (circumstances & %w(property permission)).any? and ((benefits_claimed & %w(child_tax_credit esa pension_credit)).any? or incomesupp_jobseekers_1 or incomesupp_jobseekers_2)
      PhraseList.new(:title_energy_supplier)
    else
      PhraseList.new(:title_under_green_deal)
    end
  end
  precalculate :eligibilities do
    phrases = PhraseList.new
    phrases << :header_boilers_and_insulation
    if measure_help || both_help
      if (circumstances & %w(property permission)).any? and ((benefits_claimed & %w(child_tax_credit esa pension_credit)).any? or incomesupp_jobseekers_1 or incomesupp_jobseekers_2)
        phrases << :opt_condensing_boiler unless (features & %w(modern_boiler)).any?
        phrases << :opt_cavity_wall_insulation unless (features & %w(cavity_wall_insulation mains_gas)).any?
        unless (features & %w(mains_gas solid_wall_insulation)).any? or ((features & %w(loft)).any? and (features & %w(cavity_wall_insulation solid_wall_insulation)).any?)
          phrases << :opt_solid_wall_insulation
        end
        phrases << :opt_draught_proofing unless (features & %w(draught_proofing mains_gas)).any?
        phrases << :opt_loft_roof_insulation unless (features & %w(loft_insulation loft_attic_conversion)).any? || property_type == 'flat'
        phrases << :opt_room_roof_insulation if (features & %w(loft_attic_conversion)).any? || property_type == 'flat' || flat_type != "top_floor"
        phrases << :opt_under_floor_insulation unless modern || flat_type != "top_floor"
        phrases << :opt_eco_affordable_warmth << :opt_eco_help << :header_heating << :opt_better_heating_controls
        (phrases << :opt_heat_pump << :opt_biomass_boilers_heaters << :opt_solar_water_heating) unless (features & %w(mains_gas)).any?
        (phrases << :header_windows_and_doors << :opt_replacement_glazing) unless (features & %w(modern_double_glazing)).any?
        phrases << :opt_renewal_heat
      end
    end
    phrases << :help_and_advice << :help_and_advice_body
    phrases
  end
end

outcome :outcome_measures_help_green_deal do
  precalculate :title_end do
    if measure_help
      PhraseList.new(:title_under_green_deal)
    else
      PhraseList.new(:title_energy_supplier)
    end
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
      if circumstances.include?('benefits')
        phrases << :winter_fuel_payments if age_variant == :winter_fuel_payment
        if (benefits_claimed & %w(esa pension_credit)).any? || incomesupp_jobseekers_1
          phrases << :warm_home_discount if benefits_claimed.include?('pension_credit')
          phrases << :cold_weather_payment
        end
        if (benefits_claimed & %w(esa child_tax_credit pension_credit)).any? || incomesupp_jobseekers_1 || incomesupp_jobseekers_2 || benefits_claimed.include?('working_tax_credit') && age_variant == :over_60
          phrases << :energy_company_obligation
        end
      else
        (phrases << :winter_fuel_payments << :cold_weather_payment) if age_variant == :winter_fuel_payment
        phrases << :smartmeters
      end
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
      if circumstances.include?('benefits')
        phrases << :winter_fuel_payments if age_variant == :winter_fuel_payment
        if (benefits_claimed & %w(esa pension_credit)).any? || incomesupp_jobseekers_1
          phrases << :warm_home_discount if benefits_claimed.include?('pension_credit')
          phrases << :cold_weather_payment
        end
        if (benefits_claimed & %w(esa child_tax_credit pension_credit)).any? || incomesupp_jobseekers_1 || incomesupp_jobseekers_2 || benefits_claimed.include?('working_tax_credit') && age_variant == :over_60
          phrases << :energy_company_obligation
        end
      else
        (phrases << :winter_fuel_payments << :cold_weather_payment) if age_variant == :winter_fuel_payment
        phrases << :smartmeters
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
      if circumstances.include?('benefits')
        phrases << :winter_fuel_payments if age_variant == :winter_fuel_payment
        if (benefits_claimed & %w(esa pension_credit)).any? || incomesupp_jobseekers_1
          phrases << :warm_home_discount if benefits_claimed.include?('pension_credit')
          phrases << :cold_weather_payment
        end
        if (benefits_claimed & %w(esa child_tax_credit pension_credit)).any? || incomesupp_jobseekers_1 || incomesupp_jobseekers_2 || benefits_claimed.include?('working_tax_credit') && age_variant == :over_60
          phrases << :energy_company_obligation
        end
      else
        (phrases << :winter_fuel_payments << :cold_weather_payment) if age_variant == :winter_fuel_payment
        phrases << :smartmeters
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
