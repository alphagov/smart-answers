status :draft

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
  calculate :next_steps_links do
    PhraseList.new(:next_steps_links)
  end
  calculate :warm_home_discount_amount do
    if Date.today < Date.civil(2014,4,6)
      135
    else
      ''
    end
  end


  next_node :what_are_your_circumstances? # Q2
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

# Q3
date_question :date_of_birth? do
  from { 100.years.ago }
  to { Date.today }

  calculate :age_variant do
    dob = Date.parse(responses.last)
    if dob < Date.new(1951,7,5)
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
    when 'disabled','disabled_child','child_under_5','pensioner_premium'
      :incomesupp_jobseekers_1
    end
  end
  calculate :incomesupp_jobseekers_2 do
    case responses.last
    when 'child_under_16','work_support_esa'
      if circumstances.include?('social_housing') || (benefits_claimed.include?('working_tax_credit') && age_variant == :over_60)
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
  option :"1985-2000s"
  option :"1940s-1984"
  option :"before-1940"

  calculate :modern do
    %w(1985-2000s).include?(responses.last) ? :modern : nil
  end
  calculate :older do
    %w(1940s-1984).include?(responses.last) ? :older : nil
  end
  calculate :historic do
    %w(before-1940).include?(responses.last) ? :historic : nil
  end

  next_node do |response|
    if response == '1985-2000s'
      :home_features_modern?
    elsif response == 'before-1940'
      :home_features_historic?
    else
      :home_features_older?
    end
  end
end


# Q7a modern
checkbox_question :home_features_modern? do
  option :mains_gas
  option :electric_heating
  option :loft_attic_conversion
  option :draught_proofing

  calculate :features do
    responses.last.split(",")
  end

  next_node do
    if measure_help
      if circumstances.include?('property') || circumstances.include?('permission') && benefits_claimed.include?('pension_credit') || incomesupp_jobseekers_1 || incomesupp_jobseekers_2 || (benefits_claimed & %w(child_tax_credit esa)).any? || benefits_claimed.include?('working_tax_credit') && age_variant == :over_60
        :outcome_measures_help_and_eco_eligible
      else
        :outcome_measures_help_green_deal
      end
    else
      if circumstances.exclude?('benefits')
        :outcome_bills_and_measures_no_benefits
      else
        if circumstances.include?('property') || circumstances.include?('permission') && benefits_claimed.include?('pension_credit') || incomesupp_jobseekers_1 || incomesupp_jobseekers_2 || (benefits_claimed & %w(child_tax_credit esa)).any? || benefits_claimed.include?('working_tax_credit') && age_variant == :over_60
          :outcome_bills_and_measures_on_benefits_eco_eligible
        else
          :outcome_bills_and_measures_on_benefits_not_eco_eligible
        end
      end
    end
  end
end

# Q7b
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
    if measure_help
      if circumstances.include?('property') || circumstances.include?('permission') && benefits_claimed.include?('pension_credit') || incomesupp_jobseekers_1 || incomesupp_jobseekers_2 || (benefits_claimed & %w(child_tax_credit esa)).any? || benefits_claimed.include?('working_tax_credit') && age_variant == :over_60
        :outcome_measures_help_and_eco_eligible
      else
        :outcome_measures_help_green_deal
      end
    else
      if circumstances.exclude?('benefits')
        :outcome_bills_and_measures_no_benefits
      else
        if circumstances.include?('property') || circumstances.include?('permission') && benefits_claimed.include?('pension_credit') || incomesupp_jobseekers_1 || incomesupp_jobseekers_2 || (benefits_claimed & %w(child_tax_credit esa)).any? || benefits_claimed.include?('working_tax_credit') && age_variant == :over_60
          :outcome_bills_and_measures_on_benefits_eco_eligible
        else
          :outcome_bills_and_measures_on_benefits_not_eco_eligible
        end
      end
    end
  end

end

# Q7c
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
    if measure_help
      if circumstances.include?('property') || circumstances.include?('permission') && benefits_claimed.include?('pension_credit') || incomesupp_jobseekers_1 || incomesupp_jobseekers_2 || (benefits_claimed & %w(child_tax_credit esa)).any? || benefits_claimed.include?('working_tax_credit') && age_variant == :over_60
        :outcome_measures_help_and_eco_eligible
      else
        :outcome_measures_help_green_deal
      end
    else
      if circumstances.exclude?('benefits')
        :outcome_bills_and_measures_no_benefits
      else
        if circumstances.include?('property') || circumstances.include?('permission') && benefits_claimed.include?('pension_credit') || incomesupp_jobseekers_1 || incomesupp_jobseekers_2 || (benefits_claimed & %w(child_tax_credit esa)).any? || benefits_claimed.include?('working_tax_credit') && age_variant == :over_60
          :outcome_bills_and_measures_on_benefits_eco_eligible
        else
          :outcome_bills_and_measures_on_benefits_not_eco_eligible
        end
      end
    end
  end
end

outcome :outcome_help_with_bills do
  precalculate :eligibilities_bills do
    phrases = PhraseList.new
    if circumstances.include?('benefits')
      if age_variant == :winter_fuel_payment
        phrases << :winter_fuel_payments
      end
      if (benefits_claimed & %w(esa pension_credit)).any? || incomesupp_jobseekers_1
        phrases << :warm_home_discount << :cold_weather_payment
      end
      if (benefits_claimed & %w(esa child_tax_credit pension_credit)).any? || incomesupp_jobseekers_1 || incomesupp_jobseekers_2 || benefits_claimed.include?('working_tax_credit') && age_variant == :over_60
        phrases << :energy_company_obligation
      end
    else
      if age_variant == :winter_fuel_payment
        phrases << :winter_fuel_payments << :cold_weather_payment << :microgeneration
      else
        phrases << :warm_home_discount << :microgeneration
      end
    end
    phrases
  end
end

outcome :outcome_social_housing

outcome :outcome_measures_help_and_eco_eligible do
  precalculate :title_end do
    if measure_help
      if circumstances.include?('property') || circumstances.include?('permission') && benefits_claimed.include?('pension_credit') || incomesupp_jobseekers_1 || incomesupp_jobseekers_2 || (benefits_claimed & %w(child_tax_credit esa)).any? || benefits_claimed.include?('working_tax_credit') && age_variant == :over_60
        PhraseList.new(:title_energy_supplier)
      else
        PhraseList.new(:title_might_be_eligible)
      end
    else
      PhraseList.new(:title_might_be_eligible)
    end
  end
  precalculate :eligibilities do
    phrases = PhraseList.new
    if measure_help || both_help
      if circumstances.include?('property') || circumstances.include?('permission') && benefits_claimed.include?('pension_credit') || incomesupp_jobseekers_1 || incomesupp_jobseekers_2 || (benefits_claimed & %w(child_tax_credit esa)).any? || benefits_claimed.include?('working_tax_credit') && age_variant == :over_60
        phrases << :a_condensing_boiler unless (features & %w(draught_proofing modern_boiler)).any?
        unless (features & %w(cavity_wall_insulation electric_heating mains_gas)).any? or ((features & %w(loft)).any? and (features & %w(cavity_wall_insulation solid_wall_insulation)).any?)
          :b_cavity_wall_insulation
        end
        unless (features & %w(electric_heating mains_gas solid_wall_insulation)).any? or ((features & %w(loft)).any? and (features & %w(cavity_wall_insulation solid_wall_insulation)).any?)
          :c_solid_wall_insulation
        end
        phrases << :d_draught_proofing unless (features & %w(draught_proofing electric_heating mains_gas)).any?
        phrases << :e_loft_roof_insulation unless (features & %w(loft_insulation loft_attic_conversion)).any?
        phrases << :f_room_roof_insulation if (features & %w(loft_attic_conversion)).any?
        phrases << :g_under_floor_insulation unless modern
        phrases << :eco_affordable_warmth
        phrases << :eco_help
        phrases << :heating << :h_fan_assisted_heater << :i_warm_air_unit << :j_better_heating_controls
        phrases << :hot_water << :k_hot_water_cyclinder_jacket
        phrases << :l_cylinder_thermostat unless modern
        unless (features & %w(modern_double_glazing)).any?
          phrases << :windows_and_doors << :m_replacement_glazing << :n_secondary_glazing << :o_external_doors
        end
        phrases << :microgeneration_renewables
        phrases << :x_green_deal
        phrases << :y_renewal_heat
      end
    end
    phrases
  end
end

outcome :outcome_measures_help_green_deal do
  precalculate :eligibilities do
    phrases = PhraseList.new
    phrases << :a_condensing_boiler unless (features & %w(modern_boiler)).any?
    phrases << :b_cavity_wall_insulation unless (features & %w(cavity_wall_insulation)).any?
    phrases << :c_solid_wall_insulation unless (features & %w(solid_wall_insulation)).any?
    phrases << :d_draught_proofing unless (features & %w(draught_proofing)).any?
    phrases << :e_loft_roof_insulation unless (features & %w(loft_insulation loft_attic_conversion)).any?
    phrases << :f_room_roof_insulation if (features & %w(loft_attic_conversion)).any?
    phrases << :g_under_floor_insulation unless modern
    phrases << :heating
    phrases << :h_fan_assisted_heater unless (features & %w(electric_heating mains_gas)).any?
    phrases << :i_warm_air_unit unless (features & %w(electric_heating mains_gas)).any?
    phrases << :j_better_heating_controls
    phrases << :hot_water << :k_hot_water_cyclinder_jacket
    phrases << :l_cylinder_thermostat unless modern or (features & %w(electric_heating mains_gas)).any?
    unless (features & %w(modern_double_glazing)).any?
      phrases << :windows_and_doors << :m_replacement_glazing << :n_secondary_glazing << :o_external_doors
    end
    phrases << :microgeneration_renewables
    if both_help
      ''
    else
      phrases << :x_green_deal << :y_renewal_heat
    end
    phrases
  end
end

outcome :outcome_bills_and_measures_no_benefits do
  precalculate :eligibilities_bills do
    phrases = PhraseList.new
    if both_help
      if circumstances.include?('benefits')
        if age_variant == :winter_fuel_payment
          phrases << :winter_fuel_payments
        end
        if (benefits_claimed & %w(esa pension_credit)).any? || incomesupp_jobseekers_1
          phrases << :warm_home_discount << :cold_weather_payment
        end
        if (benefits_claimed & %w(esa child_tax_credit pension_credit)).any? || incomesupp_jobseekers_1 || incomesupp_jobseekers_2 || benefits_claimed.include?('working_tax_credit') && age_variant == :over_60
          phrases << :energy_company_obligation
        end
      else
        if age_variant == :winter_fuel_payment
          phrases << :winter_fuel_payments << :cold_weather_payment << :microgeneration
        else
          phrases << :warm_home_discount << :microgeneration
        end
      end
    end
    phrases
  end
  precalculate :eligibilities do
    phrases = PhraseList.new
    phrases << :a_condensing_boiler unless (features & %w(modern_boiler)).any?
    unless (features & %w(cavity_wall_insulation electric_heating mains_gas)).any? or ((features & %w(loft)).any? and (features & %w(cavity_wall_insulation solid_wall_insulation)).any?)
      :b_cavity_wall_insulation
    end
    unless (features & %w(electric_heating mains_gas solid_wall_insulation)).any? or ((features & %w(loft)).any? and (features & %w(cavity_wall_insulation solid_wall_insulation)).any?)
      :c_solid_wall_insulation
    end
    phrases << :d_draught_proofing unless (features & %w(draught_proofing electric_heating mains_gas)).any?
    phrases << :e_loft_roof_insulation unless (features & %w(loft_insulation loft_attic_conversion)).any?
    phrases << :f_room_roof_insulation if (features & %w(loft_attic_conversion)).any?
    phrases << :g_under_floor_insulation unless modern
    phrases << :heating
    phrases << :h_fan_assisted_heater unless (features & %w(electric_heating mains_gas)).any?
    phrases << :i_warm_air_unit unless (features & %w(electric_heating mains_gas)).any?
    phrases << :j_better_heating_controls
    phrases << :hot_water << :k_hot_water_cyclinder_jacket
    phrases << :l_cylinder_thermostat unless modern
    unless (features & %w(modern_double_glazing)).any?
      phrases << :windows_and_doors << :m_replacement_glazing << :n_secondary_glazing << :o_external_doors
    end
    phrases << :microgeneration_renewables
    phrases << :x_green_deal << :y_renewal_heat
    phrases
  end
end

outcome :outcome_bills_and_measures_on_benefits_eco_eligible do
  precalculate :eligibilities_bills do
    phrases = PhraseList.new
    if both_help
      if circumstances.include?('benefits')
        if age_variant == :winter_fuel_payment
          phrases << :winter_fuel_payments
        end
        if (benefits_claimed & %w(esa pension_credit)).any? || incomesupp_jobseekers_1
          phrases << :warm_home_discount << :cold_weather_payment
        end
        if (benefits_claimed & %w(esa child_tax_credit pension_credit)).any? || incomesupp_jobseekers_1 || incomesupp_jobseekers_2 || benefits_claimed.include?('working_tax_credit') && age_variant == :over_60
          phrases << :energy_company_obligation
        end
      else
        if age_variant == :winter_fuel_payment
          phrases << :winter_fuel_payments << :cold_weather_payment << :microgeneration
        else
          phrases << :warm_home_discount << :microgeneration
        end
      end
    end
    phrases
  end
  precalculate :eligibilities do
    phrases = PhraseList.new
    phrases << :a_condensing_boiler unless (features & %w(modern_boiler)).any?
    unless (features & %w(cavity_wall_insulation electric_heating mains_gas)).any? or ((features & %w(loft)).any? and (features & %w(cavity_wall_insulation solid_wall_insulation)).any?)
      :b_cavity_wall_insulation
    end
    unless (features & %w(electric_heating mains_gas solid_wall_insulation)).any? or ((features & %w(loft)).any? and (features & %w(cavity_wall_insulation solid_wall_insulation)).any?)
      :c_solid_wall_insulation
    end
    phrases << :d_draught_proofing unless (features & %w(draught_proofing electric_heating mains_gas)).any?
    phrases << :e_loft_roof_insulation unless (features & %w(loft_insulation loft_attic_conversion)).any?
    phrases << :f_room_roof_insulation if (features & %w(loft_attic_conversion)).any?
    phrases << :g_under_floor_insulation unless modern
    phrases << :eco_help
    phrases << :heating
    phrases << :h_fan_assisted_heater unless (features & %w(electric_heating mains_gas)).any?
    phrases << :i_warm_air_unit unless (features & %w(electric_heating mains_gas)).any?
    phrases << :j_better_heating_controls
    phrases << :hot_water << :k_hot_water_cyclinder_jacket
    phrases << :l_cylinder_thermostat unless modern
    unless (features & %w(modern_double_glazing)).any?
      phrases << :windows_and_doors << :m_replacement_glazing << :n_secondary_glazing << :o_external_doors
    end
    phrases << :microgeneration_renewables
    phrases << :y_renewal_heat
    phrases
  end
end

outcome :outcome_bills_and_measures_on_benefits_not_eco_eligible do
  precalculate :eligibilities_bills do
    phrases = PhraseList.new
    if both_help
      if circumstances.include?('benefits')
        if age_variant == :winter_fuel_payment
          phrases << :winter_fuel_payments
        end
        if (benefits_claimed & %w(esa pension_credit)).any? || incomesupp_jobseekers_1
          phrases << :warm_home_discount << :cold_weather_payment
        end
        if (benefits_claimed & %w(esa child_tax_credit pension_credit)).any? || incomesupp_jobseekers_1 || incomesupp_jobseekers_2 || benefits_claimed.include?('working_tax_credit') && age_variant == :over_60
          phrases << :energy_company_obligation
        end
      else
        if age_variant == :winter_fuel_payment
          phrases << :winter_fuel_payments << :cold_weather_payment << :microgeneration
        else
          phrases << :warm_home_discount << :microgeneration
        end
      end
    end
    phrases
  end
  precalculate :eligibilities do
    phrases = PhraseList.new
    phrases << :a_condensing_boiler unless (features & %w(modern_boiler)).any?
    unless (features & %w(cavity_wall_insulation electric_heating mains_gas)).any? or ((features & %w(loft)).any? and (features & %w(cavity_wall_insulation solid_wall_insulation)).any?)
      :b_cavity_wall_insulation
    end
    unless (features & %w(electric_heating mains_gas solid_wall_insulation)).any? or ((features & %w(loft)).any? and (features & %w(cavity_wall_insulation solid_wall_insulation)).any?)
      :c_solid_wall_insulation
    end
    phrases << :d_draught_proofing unless (features & %w(draught_proofing electric_heating mains_gas)).any?
    phrases << :e_loft_roof_insulation unless (features & %w(loft_insulation loft_attic_conversion)).any?
    phrases << :f_room_roof_insulation if (features & %w(loft_attic_conversion)).any?
    phrases << :g_under_floor_insulation unless modern
    phrases << :eco_help
    phrases << :heating
    phrases << :h_fan_assisted_heater unless (features & %w(electric_heating mains_gas)).any?
    phrases << :i_warm_air_unit unless (features & %w(electric_heating mains_gas)).any?
    phrases << :j_better_heating_controls
    phrases << :hot_water << :k_hot_water_cyclinder_jacket
    phrases << :l_cylinder_thermostat unless modern
    unless (features & %w(modern_double_glazing)).any?
      phrases << :windows_and_doors << :m_replacement_glazing << :n_secondary_glazing << :o_external_doors
    end
    phrases << :microgeneration_renewables
    phrases << :x_green_deal << :y_renewal_heat
    phrases
  end
end