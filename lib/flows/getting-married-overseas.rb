status :draft
satisfies_need ""

# Q1
multiple_choice :partner_opposite_or_same_sex? do
	option :marriage
	option :cp

	save_input_as :marriage_type

	next_node :country_ceremony_to_take_place_in?
end

# Q2
country_select :country_ceremony_to_take_place_in?, include_uk: true do
	save_input_as :country_ceremony

	calculate :country_name do
		SmartAnswer::Question::CountrySelect::countries.select {|c| c[:slug] == country_ceremony }.first[:name]
	end
	calculate :embassy_data do
    	data = Calculators::PassportAndEmbassyDataQuery.find_embassy_data(country_ceremony)
    	data ? data.first : nil
 	end
  	calculate :embassy_address do
    	address = nil
    	unless ips_number.to_i ==  1
     		address = embassy_data['address'] if embassy_data
    end
    address
  	end
  	calculate :embassy_details do
    	details = nil
    	if embassy_address
      		details = [embassy_address]
      		details << embassy_data['phone'] if embassy_data['phone'].present?
      		details << embassy_data['email'] if embassy_data['email'].present?
      		details << embassy_data['office_hours'] if embassy_data['office_hours'].present?
      		details = details.join("\n")
    	end
    	details
	end
	next_node do |response|
		if response.to_s == 'united-kingdom'
			:outcome_uk
		else
			:where_are_you_legally_resident?
		end
	end
end

# Q3
multiple_choice :where_are_you_legally_resident? do
	option :uk_resident
	option :local_resident
	option :other_resident

	save_input_as :country_of_residence

	next_node do |response|
		if local_resident == 'spain' or local_resident == 'ireland'
			:partner_citizenship_sp_eire?
		else
			:partner_citizenship?
		end
	end
end

# Q4
multiple_choice :partner_citizenship? do
	option :partner_british
	option :partner_irish
	option :partner_local
	option :partner_other

	save_input_as :partner_citizen_of

	next_node do |response|
		if marriage_type == 'marriage'
			case country_ceremony
			when 'antigua-and-barbuda','australia','bahamas','bangladesh','barbados','belize','botswana','brunei','cameroon','canada','cyprus','dominica,-commonwealth-of','fiji','gambia','ghana','grenada','guyana','india','jamaica','kenya','kiribati','lesotho','malawi','malaysia','maldives','malta','mauritius','mozambique','namibia','nauru','new-zealand','nigeria','pakistan','papua-new-guinea','st-kitts-and-nevis','st-lucia','st-vincent-and-the-grenadines','samoa','seychelles','sierra-leone','singapore','solomon-islands','south-africa','sri-lanka','swaziland','tanzania','tonga','trinidad-and-tobago','tuvalu','uganda','vanuatu','zambia','zimbabwe'
				:outcome_marriage_commonwealth
			when 'anguilla','bermuda','british-antarctic-territory','british-indian-ocean-territory','british-virgin-islands','cayman-islands','falkland-islands','gibraltar','montserrat','pitcairn','st-helena','south-georgia-and-south-sandwich-islands','turks-and-caicos-islands'
				:outcome_marriage_bot
			when 'aruba','bonaire-st-eustatius-saba','curacao','st-maarten','jordan','oman','qatar','united-arab-emirates','denmark','germany'
				:outcome_marriage_consular_cni
			when 'italy'
				:outcome_marriage_italy
			when 'greece'
				:outcome_marriage_greece
			when 'egypt'
				:outcome_marriage_egypt
			when 'united-states','germany'
				:outcome_marriage_consular_no_cni
			when 'burma'
				:outcome_marriage_burma
			when 'north-korea'
				:outcome_marriage_north_korea
			when 'iran','somalia','syria'
				:outcome_marriage_iran_somalia_syria
			when 'saudi-arabia'
				:outcome_marriage_saudi_arabia
			else ''
			end
		elsif marriage_type == 'cp'
			case country_ceremony
			when 'australia'
				:outcome_cp_australia
			else ''
			end
		end
	end
end

# Q4 Sp/Eire
multiple_choice :partner_citizenship_sp_eire? do
	option :partner_british_sp_eire
	option :partner_irish_sp_eire
	option :partner_other_eu
	option :partner_non_eu

	save_input_as :partner_citizen_of

	next_node do |response|
		if marriage_type == 'marriage'
			case country_ceremony
			when 'spain'
				:outcome_marriage_consular_cni
			else ''
			end
		elsif marriage_type == 'cp'
			case country_ceremony
			when 'spain'
				:outcome_cp_spain
			else ''
			end
		end	
	end
end




outcome :outcome_uk
outcome :outcome_marriage_commonwealth do
	precalculate :commonwealth_residency do
		if country_of_residence == 'uk_resident'
			PhraseList.new(:commonwealth_uk_resident)
		elsif country_of_residence == 'local_resident'
			PhraseList.new(:commonwealth_local_resident)
		else
			PhraseList.new(:commonwealth_other_resident)
		end
	end
	precalculate :commonwealth_just_cyprus do
		if country_ceremony == 'cyprus' and country_of_residence == 'local_resident'
			PhraseList.new(:commonwealth_cypus)
		else ''
		end
	end
	precalculate :commonwealth_country_variants do
		case country_ceremony
		when 'south-africa'
			PhraseList.new(:commonwealth_south_africa)
		when 'india'
			PhraseList.new(:commonwealth_india)
		when 'malaysia'
			PhraseList.new(:commonwealth_malaysia)
		when 'malta'
			PhraseList.new(:commonwealth_malta)
		when 'new-zealand'
			PhraseList.new(:commonwealth_new_zealand)
		when 'singapore'
			PhraseList.new(:commonwealth_singapore)
		when 'brunei'
			PhraseList.new(:commonwealth_brunei)
		else ''
		end
	end
	precalculate :commonwealth_naturalisation do
		if partner_citizen_of != 'partner_british'
			PhraseList.new(:commonwealth_partner_naturalisation)
		else
			''
		end
	end
end
outcome :outcome_marriage_bot do
	precalculate :british_overseas_territory_marriage_variant do
		if country_ceremony == 'british-indian-ocean-territory'
			PhraseList.new(:british_indian_ocean_territory_text)
		else
			PhraseList.new(:british_overseas_territory_text)
		end
	end
	precalculate :british_overseas_territory_residency_variant do
		if country_of_residence != 'local_resident'
			PhraseList.new(:british_overseas_territory_not_local_resident)
		else ''
		end
	end
	precalculate :british_overseas_territory_naturalisation do
		if partner_citizen_of != 'partner_british'
			PhraseList.new(:british_overseas_territory_partner_naturalisation)
		else
			''
		end
	end
end
outcome :outcome_marriage_consular_cni do
	precalculate :consular_cni_marriage_variant do
		case country_ceremony
		when 'aruba','bonaire-st-eustatius-saba','curacao','st-maarten'
			PhraseList.new(:consular_cni_marriage_dutch_islands)
		else ''
		end
	end
	precalculate :connsular_cni_marriage_residency_variant do
		case country_ceremony
		when 'aruba','bonaire-st-eustatius-saba','curacao','st-maarten'
			if country_of_residence == 'uk_resident'
				PhraseList.new(:counsular_cni_marriage_dutch_islands_uk_resident)
			elsif country_of_residence == 'local_resident'
				PhraseList.new(:counsular_cni_marriage_dutch_islands_local_resident)
			else
				PhraseList.new(:counsular_cni_marriage_dutch_islands_other_resident)
			end
		else
			if country_of_residence == 'uk_resident'
				PhraseList.new(:counsular_cni_marriage_non_dutch_islands_uk_resident)
			elsif country_of_residence == 'local_resident'
				PhraseList.new(:counsular_cni_marriage_non_dutch_islands_local_resident)
			else
				PhraseList.new(:counsular_cni_marriage_non_dutch_islands_other_resident)
			end
		end
	end
	precalculate :consular_cni_middle_east_countries_variant do
		case country_ceremony
		when 'jordan','oman','qatar','united-arab-emirates'
			PhraseList.new(:consular_cni_marriage_middle_east_countries)
		else ''
		end
	end
	precalculate :consular_cni_marriage_middle_east_countries_local_resident_not_irish do
		case country_ceremony
		when 'jordan','oman','qatar','united-arab-emirates'
			if country_of_residence == 'local_resident' and partner_citizen_of != 'partner_irish'
				PhraseList.new(:consular_cni_marriage_middle_east_local_resident_not_irish)
			else ''
			end
		end
	end
	precalculate :consular_cni_marriage_spain_variant do
		case country_ceremony
		when 'spain'
			PhraseList.new(:consular_cni_marriage_spain)
		else ''
		end
	end
	precalculate :consular_cni_marriage_uk_residency_variant do
		if country_of_residence == 'uk_resident'
			PhraseList.new(:consular_cni_marriage_uk_resident)
		else
			PhraseList.new(:consular_cni_marriage_non_uk_resident)
		end
	end
	precalculate :consular_cni_marriage_denmark_germany_spain_variant do
		case country_ceremony
		when 'denmark'
			PhraseList.new(:consular_cni_marriage_denmark_germany_spain_denmark)
		when 'germany'
			PhraseList.new(:consular_cni_marriage_denmark_germany_spain_germany)
		when 'spain'
			PhraseList.new(:consular_cni_marriage_denmark_germany_spain_spain)
		else ''
		end
	end
	precalculate :consular_cni_marriage_uk_resident_second_pass_variant do
		case country_of_residence
		when 'uk_resident'
			if partner_citizen_of == 'partner_irish'
				PhraseList.new(:consular_cni_marriage_uk_resident_second_pass_partner_irish)
			elsif partner_citizen_of != 'partner_irish'
				PhraseList.new(:consular_cni_marriage_uk_resident_second_pass_partner_not_irish)
			else
				PhraseList.new(:consular_cni_marriage_uk_resident_second_pass)
			end
		end
	end
	precalculate :consular_cni_marriage_local_resident_not_german_variant do
		case country_of_residence
		when 'local_resident'
			if country_ceremony == 'germany'
				PhraseList.new(:consular_cni_marriage_local_resident_not_germany)
			else ''
			end
		end
	end
	precalculate :consular_cni_marriage_other_resident_variant do
		if country_of_residence == 'other_resident'
			PhraseList.new(:consular_cni_marriage_other_resident)
		else ''
		end
	end
end

outcome :outcome_marriage_italy
outcome :outcome_marriage_greece
outcome :outcome_marriage_egypt
outcome :outcome_marriage_consular_no_cni
outcome :outcome_marriage_burma do
	precalculate :burma_marriage_variant do
		if partner_citizen_of == 'partner_local'
			PhraseList.new(:burma_local_citizen)
		else ''
		end	
	end
end
outcome :outcome_marriage_north_korea do
	precalculate :north_korea_marriage_variant do
		if partner_citizen_of == 'partner_local'
			PhraseList.new(:north_korea_local_citizen)
		else ''
		end	
	end
end
outcome :outcome_marriage_iran_somalia_syria
outcome :outcome_marriage_saudi_arabia do
	precalculate :saudi_arabia_marriage_variant do
		if country_of_residence != 'local_resident'
			PhraseList.new(:saudi_arabia_local_resident)
		elsif country_of_residence == 'local_resident' and partner_citizen_of == 'partner_irish'
			PhraseList.new(:saudi_arabia_local_resident_partner_irish)
		elsif country_of_residence == 'local_resident' and partner_citizen_of != 'partner_irish'
			PhraseList.new(:saudi_arabia_local_resident_partner_not_irish)
		else ''
		end
	end
end
outcome :outcome_cp_spain
outcome :outcome_cp_australia do
	precalculate :australia_cp_naturalisation do
		if partner_citizen_of != 'partner_british'
			PhraseList.new(:australia_cp_partner_naturalisation)
		else ''
		end	
	end
end
