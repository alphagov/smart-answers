status :draft
satisfies_need ""

data_query = SmartAnswer::Calculators::MarriageOverseasDataQuery.new
reg_data_query = SmartAnswer::Calculators::RegistrationsDataQuery.new
i18n_prefix = 'flow.marriage-overseas'

# Q1
country_select :country_of_ceremony? do
	save_input_as :ceremony_country

	calculate :ceremony_country_name do
		SmartAnswer::Question::CountrySelect.countries.find { |c| c[:slug] == responses.last }[:name]
	end
	calculate :country_name_lowercase_prefix do
		case ceremony_country
		when 'bahamas','gambia','british-virgin-islands','cayman-islands','falkland-islands','turks-and-caicos-islands','dominican-republic','russian-federation'
			"the #{ceremony_country_name}"
		else
			"#{ceremony_country_name}"
		end
	end
	calculate :country_name_uppercase_prefix do
		case ceremony_country
		when 'bahamas','gambia','british-virgin-islands','cayman-islands','falkland-islands','turks-and-caicos-islands','dominican-republic','russian-federation'
			"The #{ceremony_country_name}"
		else
			"#{ceremony_country_name}"
		end
	end

	calculate :embassy_address do
    	data = data_query.find_embassy_data(ceremony_country)
    	data.first['address'] if data
  	end
  	calculate :embassy_website do
    	data = data_query.find_embassy_data(ceremony_country)
    	data.first['website'] if data
  	end		
  	calculate :embassy_email do
    	data = data_query.find_embassy_data(ceremony_country)
    	data.first['email'] if data
  	end
  	calculate :embassy_phone do
    	data = data_query.find_embassy_data(ceremony_country)
    	data.first['phone'] if data
  	end
  	calculate :embassy_fax do
    	data = data_query.find_embassy_data(ceremony_country)
    	data.first['fax'] if data
  	end
  	calculate :embassy_office_hours do
    	data = data_query.find_embassy_data(ceremony_country)
    	data.first['office_hours'] if data
  	end
  	calculate :embassy_details do
  		PhraseList.new(:embassy_details_all)
  	end
	
	next_node do |response|
		if response == 'ireland'
			:partner_opposite_or_same_sex?
		else
			:legal_residency?
		end
	end
end

# Q2
multiple_choice :legal_residency? do
	option :uk => :residency_uk?
	option :other => :residency_nonuk?

	save_input_as :resident_of
end


# Q3a
multiple_choice :residency_uk? do
	option :uk_england
    option :uk_wales
    option :uk_scotland
    option :uk_ni
    option :uk_iom
    option :uk_ci

    save_input_as :residency_uk_region

    next_node :what_is_your_partners_nationality?
end

# Q3b
country_select :residency_nonuk? do
	save_input_as :residency_country

	calculate :residency_country_name do
		SmartAnswer::Question::CountrySelect.countries.find { |c| c[:slug] == responses.last }[:name]
	end

	next_node :what_is_your_partners_nationality?
end

# Q4
multiple_choice :what_is_your_partners_nationality? do
	option :partner_british
	option :partner_irish
    option :partner_local
    option :partner_other

    save_input_as :partner_nationality

    next_node :partner_opposite_or_same_sex?
end

# Q5
multiple_choice :partner_opposite_or_same_sex? do
	option :opposite_sex
	option :same_sex

	save_input_as :sex_of_your_partner

	calculate :ceremony_type do
		if responses.last == 'opposite_sex'
			PhraseList.new(:ceremony_type_marriage)
		else
			PhraseList.new(:ceremony_type_civil_partnership)
		end
	end

	next_node do |response|
		if response == 'opposite_sex'
			case ceremony_country
			when 'ireland'
				:outcome_ireland
			when 'antigua-and-barbuda','australia','bahamas','bangladesh','barbados','belize','botswana','brunei','cameroon','canada','cyprus','dominica,-commonwealth-of','fiji','gambia','ghana','grenada','guyana','india','jamaica','kenya','kiribati','lesotho','malawi','malaysia','maldives','malta','mauritius','mozambique','namibia','nauru','new-zealand','nigeria','pakistan','papua-new-guinea','st-kitts-and-nevis','st-lucia','st-vincent-and-the-grenadines','samoa','seychelles','sierra-leone','singapore','solomon-islands','south-africa','sri-lanka','swaziland','tanzania','tonga','trinidad-and-tobago','tuvalu','uganda','vanuatu','zambia','zimbabwe'
				:outcome_os_commonwealth
			when 'anguilla','bermuda','british-antarctic-territory','british-indian-ocean-territory','british-virgin-islands','cayman-islands','falkland-islands','gibraltar','montserrat','pitcairn','st-helena','south-georgia-and-south-sandwich-islands','turks-and-caicos-islands'
				:outcome_os_bot
			when 'albania','algeria','angola','argentina','armenia','austria','azerbaijan','bahrain','belarus','belgium','bolivia','bosnia-and-herzegovina','brazil','bulgaria','cambodia','chile','china','colombia','croatia','cuba','czech-republic','denmark','dominican-republic','ecuador','el-salvador','estonia','ethiopia','finland','georgia','germany','greece','guatemala','honduras','hungary','iceland','indonesia','italy','japan','jordan','kazakhstan','kuwait','kyrgyzstan','latvia','libya','lithuania','luxembourg','macedonia','moldova','mongolia','netherlands','nepal','norway','oman','panama','peru','philippines','poland','portugal','qatar','romania','russian-federation','serbia','slovakia','slovenia','spain','sudan','sweden','switzerland','tajikistan','tunisia','turkey','turkmenistan','ukraine','united-arab-emirates','uzbekistan','venezuela','vietnam'
				:outcome_os_consular_cni
			end
		elsif response == 'same_sex'
			case ceremony_country
			when 'ireland'
				:outcome_ireland
			when 'bahamas'
				:outcome_ss_commonwealth
			end
		end
	end

end









outcome :outcome_ireland do
	precalculate :ireland_partner_sex_variant do
		if sex_of_your_partner == 'opposite_sex'
			PhraseList.new(:outcome_ireland_opposite_sex)
		else
			PhraseList.new(:outcome_ireland_same_sex)
		end
	end
end
outcome :outcome_os_commonwealth do
	precalculate :commonwealth_os_zimbabwe_variant do
		phrases = PhraseList.new
		if ceremony_country != 'zimbabwe'
			if resident_of == 'uk'
				phrases << :uk_resident_os_ceremony_not_zimbabwe
			elsif residency_country == ceremony_country
				phrases << :local_resident_os_ceremony_not_zimbabwe
			else
				phrases << :other_resident_os_ceremony_not_zimbabwe
			end
		else
			if resident_of == 'uk'
				phrases << :uk_resident_os_ceremony_zimbabwe
			elsif residency_country == ceremony_country
				phrases << :local_resident_os_ceremony_zimbabwe
			else
				phrases << :other_resident_os_ceremony_zimbabwe
			end
		end
	end
	precalculate :commonwealth_os_other_countries_variant do
		case ceremony_country
		when 'south-africa'
			if partner_nationality == 'partner_local'
				PhraseList.new(:commonwealth_os_other_countries_south_africe)
			end
		when 'india'
			PhraseList.new(:commonwealth_os_other_countries_india)
		when 'malaysia'
			PhraseList.new(:commonwealth_os_other_countries_malaysia)
		when 'singapore'
			PhraseList.new(:commonwealth_os_other_countries_singapore)
		when 'brunei'
			PhraseList.new(:commonwealth_os_other_countries_brunei)
		when 'cyprus'
			if residency_country == 'cyprus'
				PhraseList.new(:commonwealth_os_other_countries_cyprus)
			end
		end
	end
	precalculate :commonwealth_os_naturalisation_variant do
		if partner_nationality != 'partner_british'
			PhraseList.new(:commonwealth_os_naturalisation)
		else ''
		end
	end

end

outcome :outcome_os_bot do
	precalculate :bot_outcome do
		phrases = PhraseList.new
		if ceremony_country == 'british-indian-ocean-territory'
		  phrases << :bot_os_ceremony_biot
		else
		  phrases << :bot_os_ceremony_non_biot
		  if residency_country == ceremony_country
		  	phrases << :bot_os_local_resident
		  end
		  unless partner_nationality == 'partner_british'
		  	phrases << :bot_os_naturalisation
		  end
		end
		phrases
	end
end


outcome :outcome_os_consular_cni do

  precalculate :clickbook_data do
    reg_data_query.clickbook(ceremony_country)
 	end
  precalculate :multiple_clickbooks do
    clickbook_data and clickbook_data.class == Hash
  end
  precalculate :clickbooks do
    result = ''
    if multiple_clickbooks
      clickbook_data.each do |k,v|
        result += I18n.translate!(i18n_prefix + ".phrases.multiple_clickbook_link", city: k, url: v)
    	end
    end
    result
  end



	precalculate :consular_cni_os_residency_variant do
		if resident_of == 'uk'
			PhraseList.new(:uk_resident_os_consular_cni)
		elsif residency_country == ceremony_country
			PhraseList.new(:local_resident_os_consular_cni)
		else
			unless resident_of == 'uk' or ceremony_country == residency_country
			PhraseList.new(:other_resident_os_consular_cni)
			end
		end
	end

	precalculate :consular_cni_os_gulf_states_variant do
		case ceremony_country
		when 'jordan','oman','qatar','united-arab-emirates'
			PhraseList.new(:gulf_states_os_consular_cni)
		end
	end
	precalculate :consular_cni_os_gulf_states_local_resident_not_irish do
		case ceremony_country
		when 'jordan','oman','qatar','united-arab-emirates'
			if residency_country == ceremony_country and partner_nationality != 'partner_irish'
				PhraseList.new(:gulf_states_os_consular_cni_local_resident_partner_not_irish)
			end
		end
	end
	precalculate :consular_cni_os_spain_variant do
		if ceremony_country == 'spain'
			PhraseList.new(:spain_os_consular_cni)
		end
	end
	precalculate :consular_cni_os_residency_variant_two do
		if resident_of == 'uk'
			PhraseList.new(:uk_resident_os_consular_cni_two)
		else
			PhraseList.new(:other_resident_os_consular_cni_two)
		end
	end
	precalculate :consular_cni_os_italy_variant do
		if ceremony_country == 'italy'
			if resident_of == 'uk' and partner_nationality == 'partner_british'
				PhraseList.new(:consular_cni_os_italy_scenario_one)
			elsif resident_of == 'uk' and partner_nationality != 'partner_british' and partner_nationality != 'partner_irish'
				PhraseList.new(:consular_cni_os_italy_scenario_two_a)
			elsif partner_nationality == 'partner_irish' and residency_uk_region == 'uk_scotland' or residency_uk_region == 'uk_ni'
				PhraseList.new(:consular_cni_os_italy_scenario_two_b)
			elsif residency_country == ceremony_country and partner_nationality =='partner_british'
				PhraseList.new(:consular_cni_os_italy_scenario_three)
			elsif residency_country == ceremony_country and partner_nationality !='partner_british'
				PhraseList.new(:consular_cni_os_italy_scenario_four)
			elsif partner_nationality == 'partner_irish' and residency_uk_region == 'uk_england' or residency_uk_region == 'uk_wales'
				PhraseList.new(:consular_cni_os_italy_scenario_five)
			elsif data_query.non_commonwealth_country?(residency_country) and residency_country != 'ireland' and partner_nationality == 'partner_british'
				PhraseList.new(:consular_cni_os_italy_scenario_six)
			elsif data_query.non_commonwealth_country?(residency_country) and residency_country != 'ireland' and partner_nationality != 'partner_british'
				PhraseList.new(:consular_cni_os_italy_scenario_seven)
			elsif data_query.commonwealth_country?(residency_country)
				PhraseList.new(:consular_cni_os_italy_scenario_eight)
			elsif residency_country == 'ireland'
				PhraseList.new(:consular_cni_os_italy_scenario_nine)
			end
		end
	end
	precalculate :consular_cni_os_denmark_variant do
		if ceremony_country == 'denmark'
			PhraseList.new(:consular_cni_os_denmark)
		end
	end
	precalculate :consular_cni_os_germany_local_residency_variant do
		if ceremony_country == 'germany' and residency_country == 'germany'
			PhraseList.new(:consular_cni_os_german_resident)
		end
	end
#the consular_cni_os_italy_variant_two calculation is written like this as partner_irish for uk_iom and uk_ci may be different. Awaiting clarifcation from FCO so until then we'll assign the same phrase. (AK)
	precalculate :consular_cni_os_italy_variant_two do
		if ceremony_country == 'italy'
			case residency_uk_region
			when 'uk_iom','uk_ci'
					PhraseList.new(:consular_cni_os_italy_iom_ci_partner_not_irish)
			end
		end
	end
	precalculate :consular_cni_os_residency_variant_three do
		case resident_of
		when 'uk'
			if partner_nationality !='partner_irish'
				PhraseList.new(:uk_resident_partner_not_irish_os_consular_cni_three)
			elsif partner_nationality == 'partner_irish' and residency_uk_region == 'uk_scotland' or residency_uk_region == 'uk_ni'
				PhraseList.new(:scotland_ni_resident_partner_irish_os_consular_cni_three)
			end
		end
	end
	precalculate :consular_cni_os_italy_variant_three do
		if ceremony_country == 'italy' and resident_of == 'uk'
			case residency_uk_region
			when 'uk_england','uk_wales'
				if partner_nationality == 'partner_irish'
					PhraseList.new(:consular_cni_os_england_or_wales_partner_irish_three)
				else
					PhraseList.new(:consular_cni_os_scotland_or_ni_partner_irish_or_partner_not_irish_three)
				end
			when 'uk_iom', 'uk_ci'
				''
			else
				PhraseList.new(:consular_cni_os_scotland_or_ni_partner_irish_or_partner_not_irish_three)
			end
		end
	end
	precalculate :consular_cni_os_uk_residency_not_italy_variant do
		if ceremony_country != 'italy' and partner_nationality == 'partner_irish'
			if residency_uk_region == 'uk_england' or residency_uk_region == 'uk_wales'
				PhraseList.new(:consular_cni_os_england_or_wales_resident_not_italy)
			end
		end
	end
	precalculate :consular_cni_os_uk_residency_not_italy_variant_two do
		if ceremony_country != 'italy' and resident_of == 'uk'
			PhraseList.new(:consular_cni_os_uk_resident_not_italy_two)
		end
	end


	precalculate :consular_cni_os_local_resident_not_italy_or_germany_variant do
		if ceremony_country == residency_country
			if ceremony_country != 'italy' or ceremony_country != 'germany'
				phrases = PhraseList.new(:consular_cni_os_local_resident_not_italy_germany)
				if multiple_clickbooks
					phrases << :clickbook_links
				else
					phrases << :clickbook_link
				end
			end
		end
	end
	

	precalculate :consular_cni_os_local_resident_italy_variant do
		if ceremony_country == residency_country
			if ceremony_country == 'italy'
				PhraseList.new(:consular_cni_os_local_resident_italy)
			end
		end
	end
	precalculate :consular_cni_os_foreign_or_commonwealth_resident_variant do
		if data_query.non_commonwealth_country?(residency_country) and residency_country != 'ireland'
			PhraseList.new(:consular_cni_os_foreign_resident)
		elsif data_query.commonwealth_country?(residency_country) and residency_country != 'ireland'
			PhraseList.new(:consular_cni_os_commonwealth_resident)
		end
	end
	precalculate :consular_cni_os_commonwealth_resident_partner_british_variant do
		if data_query.commonwealth_country?(residency_country) and partner_nationality == 'partner_british'
			PhraseList.new(:consular_cni_os_commonwealth_resident_british_partner)
		end
	end
	precalculate :consular_cni_os_commowealth_or_ireland_resident_variable do
		if data_query.commonwealth_country?(residency_country)
			PhraseList.new(:consular_cni_os_commonwealth_resident_two)
		elsif residency_country == 'ireland'
			PhraseList.new(:consular_cni_os_ireland_resident)
		end
	end
	precalculate :consular_cni_os_ireland_resident_partner_british_variant do
		if residency_country == 'ireland' and partner_nationality == 'partner_british'
			PhraseList.new(:consular_cni_os_ireland_resident_british_partner)
		end
	end
	precalculate :consular_cni_os_ireland_residency_variant do
		if residency_country == 'ireland'
			PhraseList.new(:consular_cni_os_ireland_resident)
		end
	end
	precalculate :consular_cni_os_commonwealth_ireland_resident_british_partner_variant do
		case partner_nationality
		when 'partner_british'
			if data_query.commonwealth_country?(residency_country) or residency_country == 'ireland'
				PhraseList.new(:consular_cni_os_commonwealth_or_ireland_resident_british_partner)
			end
		else
			if data_query.commonwealth_country?(residency_country) or residency_country == 'ireland'
				PhraseList.new(:consular_cni_os_commonwealth_or_ireland_resident_non_british_partner)
			end
		end
	end
	precalculate :consular_cni_os_local_foreign_residency_spain_germany_variant do
		if ceremony_country == residency_country
			if residency_country != 'spain' and residency_country != 'germany'
				PhraseList.new(:consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident)			
			elsif ceremony_country == 'spain'
				PhraseList.new(:consular_cni_variant_local_resident_spain)
			end
		elsif data_query.non_commonwealth_country?(residency_country) or residency_country == 'ireland'
			PhraseList.new(:consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident)
		end
	end
	precalculate :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residents_variant do
		if ceremony_country == residency_country
			if residency_country != 'spain' and residency_country != 'germany'
				PhraseList.new(:consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency)
			end
		elsif data_query.non_commonwealth_country?(residency_country) or data_query.commonwealth_country?(residency_country) or residency_country == 'ireland'
			PhraseList.new(:consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency)
		end
	end
	precalculate :consular_cni_os_local_foreign_residency_spain_germany_variant_two do
		if ceremony_country == residency_country
			if residency_country != 'spain' and residency_country != 'germany'
				PhraseList.new(:consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident_two)		
			end
		elsif data_query.non_commonwealth_country?(residency_country) or residency_country == 'ireland'
			PhraseList.new(:consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident_two)
		end
	end
	precalculate :consular_cni_os_local_resident_not_germany_or_italy_variant do
		if ceremony_country == residency_country
			if residency_country != 'germany' and residency_country != 'italy'
				PhraseList.new(:consular_cni_os_local_resident_not_germany_or_italy)
			end
		elsif ceremony_country == residency_country and residency_country == 'italy'
			Phrase.new(:consular_cni_os_local_resident_italy_two)
		end
	end
	precalculate :consular_cni_os_foreign_resident_not_italy_variant do
		case ceremony_country
		when 'italy'
			if data_query.non_commonwealth_country?(residency_country) and residency_country != 'ireland'
				PhraseList.new(:consular_cni_os_foreign_resident_ceremony_italy)
			end
		else			
			if data_query.non_commonwealth_country?(residency_country) and residency_country != 'ireland'
				PhraseList.new(:consular_cni_os_foreign_resident_ceremony_not_italy)
			end
		end
	end
	precalculate :consular_cni_os_commonwealth_resident_ceremony_not_italy_variant do
		if ceremony_country != 'italy'
			if data_query.commonwealth_country?(residency_country)
				PhraseList.new(:consular_cni_os_commonwealth_resident_ceremony_not_italy)
			elsif residency_country == 'ireland'
				PhraseList.new(:consular_cni_os_ireland_resident_ceremony_not_italy)
			end
		end
	end

	precalculate :counsular_cni_os_remainder do
		phrases = PhraseList.new
		if data_query.commonwealth_country?(residency_country) and ceremony_country == 'italy'
			phrases << :consular_cni_os_commonwealth_resident_ceremony_italy
		end
		if residency_country == 'ireland' and ceremony_country == 'italy'
			phrases << :consular_cni_os_ireland_resident_ceremony_italy
		end
		if ceremony_country == 'italy'
			phrases << :consular_cni_os_ceremony_italy
		end
		phrases
	end

end

outcome :outcome_ss_commonwealth


