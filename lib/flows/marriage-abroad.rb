status :published
satisfies_need "FCO-01"

data_query = SmartAnswer::Calculators::MarriageAbroadDataQuery.new
reg_data_query = SmartAnswer::Calculators::RegistrationsDataQuery.new


i18n_prefix = 'flow.marriage-abroad'

# Q1
country_select :country_of_ceremony? do
  save_input_as :ceremony_country

  calculate :ceremony_country_name do
    SmartAnswer::Question::CountrySelect.countries.find { |c| c[:slug] == responses.last }[:name]
  end
  calculate :country_name_lowercase_prefix do
    case ceremony_country
    when 'bahamas','british-virgin-islands','cayman-islands','czech-republic','dominican-republic','falkland-islands','gambia','maldives','marshall-islands','philippines','russian-federation','seychelles','solomon-islands','south-georgia-and-south-sandwich-islands','turks-and-caicos-islands','united-states'
      "the #{ceremony_country_name}"
    when 'korea'
      "South #{ceremony_country_name}"
    else
      "#{ceremony_country_name}"
    end
  end
  calculate :country_name_uppercase_prefix do
    case ceremony_country
    when 'bahamas','british-virgin-islands','cayman-islands','czech-republic','dominican-republic','falkland-islands','gambia','maldives','marshall-islands','philippines','russian-federation','seychelles','solomon-islands','south-georgia-and-south-sandwich-islands','turks-and-caicos-islands','united-states'
      "The #{ceremony_country_name}"
    when 'korea'
      "South #{ceremony_country_name}"
    else
      "#{ceremony_country_name}"
    end
  end
  calculate :embassy_address do
    data = data_query.find_embassy_data(ceremony_country)
    data.first['address'] if data
  end
  calculate :embassy_details do
    details = data_query.find_embassy_data(ceremony_country)
    if details
      details = details.first
      I18n.translate("#{i18n_prefix}.phrases.embassy_details",
                     address: details['address'], phone: details['phone'], email: details['email'], office_hours: details['office_hours'])
    else
      ''
    end
  end
  calculate :clickbook_data do
    reg_data_query.clickbook(ceremony_country)
  end
  calculate :multiple_clickbooks do
    clickbook_data and clickbook_data.class == Hash
  end
  calculate :clickbooks do
    result = ''
    if multiple_clickbooks
      clickbook_data.each do |k,v|
          result += I18n.translate!(i18n_prefix + ".phrases.multiple_clickbook_link", city: k, url: v) << "\n"
      end
    end
    result
  end

  next_node do |response|
    if response == 'ireland'
      :partner_opposite_or_same_sex?
    elsif response == 'spain'
      :outcome_spain_italy
    elsif response == 'italy'
      :outcome_spain_italy
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
      if ceremony_country == 'ireland'
        :outcome_ireland
      elsif data_query.commonwealth_country?(ceremony_country) or ceremony_country == 'zimbabwe'
        :outcome_os_commonwealth
      elsif data_query.british_overseas_territories?(ceremony_country)
        :outcome_os_bot
      elsif data_query.os_consular_cni_countries?(ceremony_country)
        :outcome_os_consular_cni
      elsif ceremony_country == 'france' or data_query.french_overseas_territories?(ceremony_country)
        :outcome_os_france_or_fot
      elsif ceremony_country == 'thailand' or ceremony_country == 'egypt' or ceremony_country == 'korea' or ceremony_country == 'lebanon'
        :outcome_os_affirmation
      elsif data_query.os_no_consular_cni_countries?(ceremony_country)
        :outcome_os_no_cni
      elsif data_query.os_other_countries?(ceremony_country)
        :outcome_os_other_countries
      end
    else
      if ceremony_country == 'ireland'
        :outcome_ireland
      elsif data_query.cp_equivalent_countries?(ceremony_country)
        :outcome_cp_cp_or_equivalent
      elsif ceremony_country == 'czech-republic'
        if partner_nationality == 'partner_local'
          :outcome_cp_cp_or_equivalent
        else
          :outcome_cp_consular_cni
        end
      elsif ceremony_country == 'france' or ceremony_country == 'new-caledonia' or ceremony_country == 'wallis-and-futuna'
        :outcome_cp_france_pacs
      elsif data_query.cp_cni_not_required_countries?(ceremony_country)
        :outcome_cp_no_cni
      elsif ceremony_country == 'australia' or ceremony_country == 'canada' or ceremony_country == 'new-zealand' or ceremony_country == 'south-africa'
        :outcome_cp_commonwealth_countries
      elsif data_query.cp_consular_cni_countries?(ceremony_country)
        :outcome_cp_consular_cni
      else
        :outcome_cp_all_other_countries
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
  precalculate :commonwealth_os_outcome do
    phrases = PhraseList.new
    if ceremony_country != 'zimbabwe'
      phrases << :commonwealth_os_all_intro
    else
      phrases << :commonwealth_os_zimbabwe_intro
    end
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
    if ceremony_country != 'zimbabwe'
      phrases << :commonwealth_os_all_cni
    else
      phrases << :commonwealth_os_all_cni_zimbabwe
    end
    case ceremony_country
    when 'south-africa'
      if partner_nationality == 'partner_local'
        phrases << :commonwealth_os_other_countries_south_africe
      end
    when 'india'
      phrases << :commonwealth_os_other_countries_india
    when 'malaysia'
      phrases << :commonwealth_os_other_countries_malaysia
    when 'singapore'
      phrases << :commonwealth_os_other_countries_singapore
    when 'brunei'
      phrases << :commonwealth_os_other_countries_brunei
    when 'cyprus'
      if residency_country == 'cyprus'
        phrases << :commonwealth_os_other_countries_cyprus
      end
    end
    if partner_nationality != 'partner_british'
      phrases << :commonwealth_os_naturalisation
    end
    phrases
  end
end
outcome :outcome_os_bot do
  precalculate :bot_outcome do
    phrases = PhraseList.new
    if ceremony_country == 'british-indian-ocean-territory'
      phrases << :bot_os_ceremony_biot
    else
      phrases << :bot_os_ceremony_non_biot
      if residency_country != ceremony_country
        phrases << :bot_os_not_local_resident
      end
      unless partner_nationality == 'partner_british'
        phrases << :bot_os_naturalisation
      end
    end
    phrases
  end
end

outcome :outcome_os_consular_cni do
  precalculate :consular_cni_os_start do
    phrases = PhraseList.new 
    if resident_of == 'uk'
      phrases << :uk_resident_os_consular_cni
    elsif residency_country == ceremony_country
      phrases << :local_resident_os_consular_cni
    else
      unless resident_of == 'uk' or ceremony_country == residency_country
      phrases << :other_resident_os_consular_cni
      end
    end
    case ceremony_country
    when 'jordan','oman','qatar','united-arab-emirates'
      phrases << :gulf_states_os_consular_cni
    end
    case ceremony_country
    when 'jordan','oman','qatar','united-arab-emirates'
      if residency_country == ceremony_country and partner_nationality != 'partner_irish'
        phrases << :gulf_states_os_consular_cni_local_resident_partner_not_irish
      end
    end
    if ceremony_country == 'spain'
      phrases << :spain_os_consular_cni
    end
    phrases << :consular_cni_all_what_you_need_to_do
    if ceremony_country == 'italy'
      if resident_of == 'uk' and partner_nationality == 'partner_british'
        phrases << :consular_cni_os_italy_scenario_one
      elsif resident_of == 'uk' and partner_nationality != 'partner_british' and partner_nationality != 'partner_irish'
        phrases << :consular_cni_os_italy_scenario_two_a
      elsif partner_nationality == 'partner_irish' and residency_uk_region == 'uk_scotland' or residency_uk_region == 'uk_ni'
        phrases << :consular_cni_os_italy_scenario_two_b
      elsif residency_country == ceremony_country and partner_nationality =='partner_british'
        phrases << :consular_cni_os_italy_scenario_three
      elsif residency_country == ceremony_country and partner_nationality !='partner_british'
        phrases << :consular_cni_os_italy_scenario_four
      elsif partner_nationality == 'partner_irish' and residency_uk_region == 'uk_england' or residency_uk_region == 'uk_wales'
        phrases << :consular_cni_os_italy_scenario_five
      elsif data_query.non_commonwealth_country?(residency_country) and residency_country != 'ireland' and partner_nationality == 'partner_british'
        phrases << :consular_cni_os_italy_scenario_six
      elsif data_query.non_commonwealth_country?(residency_country) and residency_country != 'ireland' and partner_nationality != 'partner_british'
        phrases << :consular_cni_os_italy_scenario_seven
      elsif data_query.commonwealth_country?(residency_country)
        phrases << :consular_cni_os_italy_scenario_eight
      elsif residency_country == 'ireland'
        phrases << :consular_cni_os_italy_scenario_nine
      end
    end
    if ceremony_country == 'denmark'
      phrases << :consular_cni_os_denmark
    end
    if ceremony_country == 'germany' and residency_country == 'germany'
      phrases << :consular_cni_os_german_resident
    end
#the next calculation is written like this as partner_irish for uk_iom and uk_ci may be different. Awaiting clarifcation from FCO so until then we'll assign the same phrase. (AK)
    if ceremony_country == 'italy'
      case residency_uk_region
      when 'uk_iom','uk_ci'
        phrases << :consular_cni_os_italy_iom_ci_partner_not_irish
      end
    end
    case resident_of
    when 'uk'
      if partner_nationality !='partner_irish'
        phrases << :uk_resident_partner_not_irish_os_consular_cni_three
      elsif partner_nationality == 'partner_irish' and residency_uk_region == 'uk_scotland' or residency_uk_region == 'uk_ni'
        phrases << :scotland_ni_resident_partner_irish_os_consular_cni_three
      end
    end
    if ceremony_country == 'italy' and resident_of == 'uk'
      case residency_uk_region
      when 'uk_england','uk_wales'
        if partner_nationality == 'partner_irish'
          phrases << :consular_cni_os_england_or_wales_partner_irish_three
        else
          phrases << :consular_cni_os_scotland_or_ni_partner_irish_or_partner_not_irish_three
        end
      when 'uk_iom', 'uk_ci'
        ''
      else
        phrases << :consular_cni_os_scotland_or_ni_partner_irish_or_partner_not_irish_three
      end
    end
    if ceremony_country != 'italy' and partner_nationality == 'partner_irish'
      if residency_uk_region == 'uk_england' or residency_uk_region == 'uk_wales'
        phrases << :consular_cni_os_england_or_wales_resident_not_italy
      end
    end
    if ceremony_country != 'italy' and ceremony_country != 'portugal' and resident_of == 'uk'
      phrases << :consular_cni_os_uk_resident_not_italy_two
    end
    if ceremony_country == 'portugal' and resident_of == 'uk'
      phrases << :consular_cni_os_uk_resident_ceremony_portugal
      if reg_data_query.clickbook(ceremony_country)
        if multiple_clickbooks
          phrases << :clickbook_links
        else
          phrases << :clickbook_link
        end
      end
    end
    if ceremony_country == residency_country
      if ceremony_country != 'italy' or ceremony_country != 'germany'
        phrases << :consular_cni_os_local_resident_not_italy_germany
        if reg_data_query.clickbook(ceremony_country)
          if multiple_clickbooks
            phrases << :clickbook_links
          else
            phrases << :clickbook_link
          end
        end
        unless reg_data_query.clickbook(ceremony_country)
          phrases << :consular_cni_os_no_clickbook_so_embassy_details
        end
      end
    end
    if ceremony_country == residency_country
      if ceremony_country == 'italy'
        phrases << :consular_cni_os_local_resident_italy
      end
    end
    if data_query.non_commonwealth_country?(residency_country) and residency_country != 'ireland' and ceremony_country != residency_country
      phrases << :consular_cni_os_foreign_resident
    elsif data_query.commonwealth_country?(residency_country) and residency_country != 'ireland' and ceremony_country != residency_country
      phrases << :consular_cni_os_commonwealth_resident
    end
    if data_query.commonwealth_country?(residency_country) and partner_nationality == 'partner_british' and ceremony_country != residency_country
      phrases << :consular_cni_os_commonwealth_resident_british_partner
    end
    if data_query.commonwealth_country?(residency_country) and ceremony_country != residency_country
      phrases << :consular_cni_os_commonwealth_resident_two
    elsif residency_country == 'ireland'
      phrases << :consular_cni_os_ireland_resident
    end
    if residency_country == 'ireland' and partner_nationality == 'partner_british'
      phrases << :consular_cni_os_ireland_resident_british_partner
    end
    if residency_country == 'ireland'
      phrases << :consular_cni_os_ireland_resident_two
    end
    case partner_nationality
    when 'partner_british'
      if data_query.commonwealth_country?(residency_country) or residency_country == 'ireland' and ceremony_country != residency_country
        phrases << :consular_cni_os_commonwealth_or_ireland_resident_british_partner
      end
    else
      if data_query.commonwealth_country?(residency_country) or residency_country == 'ireland' and ceremony_country != residency_country
        phrases << :consular_cni_os_commonwealth_or_ireland_resident_non_british_partner
      end
    end
    if ceremony_country == residency_country
      if residency_country != 'spain' and residency_country != 'germany'
        phrases << :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident    
      elsif ceremony_country == 'spain'
        phrases << :consular_cni_variant_local_resident_spain
      end
    elsif data_query.non_commonwealth_country?(residency_country) and residency_country != 'ireland'
      phrases << :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident
    end
    if ceremony_country == residency_country
      if residency_country != 'spain' and residency_country != 'germany'
        phrases << :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency
      end
    elsif data_query.non_commonwealth_country?(residency_country) or data_query.commonwealth_country?(residency_country) or residency_country == 'ireland'
      phrases << :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency
    end
    if ceremony_country == residency_country
      if residency_country != 'spain' and residency_country != 'germany'
        phrases << :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident_two    
      end
    elsif data_query.non_commonwealth_country?(residency_country) and residency_country != 'ireland'
      phrases << :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident_two
    end
    if ceremony_country == residency_country
      if residency_country != 'germany' and residency_country != 'italy'
      phrases << :consular_cni_os_local_resident_not_germany_or_italy
      end
    elsif ceremony_country == residency_country and residency_country == 'italy'
      phrases << :consular_cni_os_local_resident_italy_two
    end
    case ceremony_country
    when 'italy'
      if data_query.non_commonwealth_country?(residency_country) and residency_country != 'ireland' and ceremony_country != residency_country
        phrases << :consular_cni_os_foreign_resident_ceremony_italy
      end
    else      
      if data_query.non_commonwealth_country?(residency_country) and residency_country != 'ireland' and ceremony_country != residency_country
        phrases << :consular_cni_os_foreign_resident_ceremony_not_italy
      end
    end
    if ceremony_country != 'italy'
      if data_query.commonwealth_country?(residency_country) and ceremony_country != residency_country
        phrases << :consular_cni_os_commonwealth_resident_ceremony_not_italy
      elsif residency_country == 'ireland'
        phrases << :consular_cni_os_ireland_resident_ceremony_not_italy
      end
    end
    phrases
  end

  precalculate :consular_cni_os_remainder do
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
    if resident_of == 'uk' and partner_nationality == 'partner_british'
      phrases << :consular_cni_os_partner_british
    end
    if residency_country == ceremony_country and partner_nationality == 'partner_british'
      if ceremony_country != 'italy' and ceremony_country != 'germany'
        phrases << :consular_cni_os_partner_british
      end
    end
    unless ceremony_country == residency_country or resident_of == 'uk'
      if partner_nationality == 'partner_british' and ceremony_country != 'italy'
        phrases << :consular_cni_os_partner_british
      end
    end
    if ceremony_country != residency_country and resident_of == 'other' and partner_nationality == 'partner_british' and ceremony_country == 'italy'
      phrases << :consular_cni_os_other_resident_partner_british_ceremony_italy
    end
    phrases << :consular_cni_os_all_names
    if resident_of == 'other' and ceremony_country != 'italy'
      phrases << :consular_cni_os_other_resident_ceremony_not_italy
    end
    if ceremony_country == 'belgium'
      phrases << :consular_cni_os_ceremony_belgium
      if ceremony_country != residency_country
        phrases << :consular_cni_os_belgium_clickbook
      end
    end
    if ceremony_country == 'spain'
      phrases << :consular_cni_os_ceremony_spain
      if partner_nationality == 'partner_british'
        phrases << :consular_cni_os_ceremony_spain_partner_british
      end
      phrases << :consular_cni_os_ceremony_spain_two
    end
    if partner_nationality != 'partner_british'
      phrases << :consular_cni_os_naturalisation
    end
    phrases << :consular_cni_os_all_depositing_certificate
    if ceremony_country != residency_country or ceremony_country == 'germany'
      if reg_data_query.clickbook(ceremony_country)
        if multiple_clickbooks
          phrases << :clickbook_links
        else
          phrases << :clickbook_link
        end
      end
      unless reg_data_query.clickbook(ceremony_country)
        phrases << :consular_cni_os_no_clickbook_so_embassy_details
      end
    end
    if ceremony_country == 'finland'
      phrases << :consular_cni_os_ceremony_finland
    elsif ceremony_country == 'turkey'
      phrases << :consular_cni_os_ceremony_turkey
    end
    if resident_of == 'uk'
      phrases << :consular_cni_os_uk_resident
    end
    phrases << :consular_cni_os_all_fees
    case ceremony_country
    when 'armenia','bosnia-and-herzegovina','cambodia','czech-republic','estonia','hungary','iceland','kazakhstan','latvia','luxembourg','poland','slovenia','tunisia'
      phrases << :consular_cni_os_fees_local_currency
    else
      phrases << :consular_cni_os_fees_no_cheques
    end
    phrases
  end
end
outcome :outcome_os_france_or_fot do
  precalculate :france_or_fot_os_outcome do
    phrases = PhraseList.new
    if ceremony_country == 'france'
      if resident_of == 'uk'
        phrases << :france_fot_os_ceremony_france_uk_resident
      elsif ceremony_country == residency_country
        phrases << :france_fot_os_ceremony_france_local_resident
      elsif ceremony_country != residency_country and resident_of !='uk'
        phrases << :france_fot_os_ceremony_france_other_resident
      end
    else
      if resident_of == 'uk'
        phrases << :france_fot_os_ceremony_fot_uk_resident
      elsif ceremony_country == residency_country
        phrases << :france_fot_os_ceremony_fot_local_resident
      elsif ceremony_country != residency_country and resident_of !='uk'
        phrases << :france_fot_os_ceremony_fot_other_resident
      end
    end
    phrases << :france_fot_os_all_what_you_need_to_do
    if resident_of == 'uk'
      phrases << :france_fot_os_uk_resident_two
    else
      phrases << :france_fot_os_not_uk_resident_two
    end
    phrases << :france_fot_os_all_celibacy
    if partner_nationality != 'partner_british'
      phrases << :france_fot_os_naturalisation
    end
    phrases << :france_fot_os_all_depositing_certificate
    if resident_of =='uk'
      phrases << :france_fot_os_uk_resident_two_point_five
    end
    phrases << :france_fot_os_all_multilingual_extract
    if resident_of == 'uk'
      phrases << :france_fot_os_uk_resident_three
    end
    phrases << :france_fot_os_all_fees
    phrases
  end
end
outcome :outcome_os_affirmation do
  precalculate :affirmation_os_outcome do
    phrases = PhraseList.new
    if resident_of == 'uk'
      phrases << :affirmation_os_uk_resident
    elsif ceremony_country == residency_country
      phrases << :affirmation_os_local_resident
    elsif ceremony_country != residency_country and resident_of !='uk'
      phrases << :affirmation_os_other_resident
    end
    phrases << :affirmation_os_all_what_you_need_to_do
    if partner_nationality == 'partner_british'
      phrases << :affirmation_os_partner_british
    else
      phrases << :affirmation_os_partner_not_british
    end
    phrases << :affirmation_os_all_depositing_certificate
    if resident_of == 'uk'
      phrases << :affirmation_os_uk_resident_three
    end
    phrases << :affirmation_os_all_fees
    phrases
  end
end
outcome :outcome_os_no_cni do
  precalculate :no_cni_os_outcome do
    phrases = PhraseList.new
    case ceremony_country
    when 'aruba', 'bonaire-st-eustatius-saba','curacao','st-maarten'
      phrases << :no_cni_os_dutch_caribbean_islands
    end
    case ceremony_country
    when 'aruba', 'bonaire-st-eustatius-saba','curacao','st-maarten'
      if resident_of == 'uk'
        phrases << :no_cni_os_dutch_caribbean_islands_uk_resident
      elsif ceremony_country == residency_country
        phrases << :no_cni_os_dutch_caribbean_islands_local_resident
      elsif ceremony_country != residency_country and resident_of !='uk'
        phrases << :no_cni_os_dutch_caribbean_other_resident
      end
    else
      if resident_of == 'uk'
        phrases << :no_cni_os_not_dutch_caribbean_islands_uk_resident
      elsif ceremony_country == residency_country
        phrases << :no_cni_os_not_dutch_caribbean_islands_local_resident
      elsif ceremony_country != residency_country and resident_of !='uk'
        phrases << :no_cni_os_not_dutch_caribbean_other_resident
      end
    end
    phrases << :no_cni_os_all_nearest_embassy
    phrases << :no_cni_os_all_depositing_certificate
    if ceremony_country == 'united-states'
      phrases << :no_cni_os_ceremony_usa
    else
      phrases << :no_cni_os_ceremony_not_usa
    end
    if resident_of == 'uk'
      phrases << :no_cni_os_uk_resident_three
    end
    phrases << :no_cni_os_all_fees
    if partner_nationality != 'partner_british'
      phrases << :no_cni_os_naturalisation
    end
    phrases
  end
end
outcome :outcome_os_other_countries do
  precalculate :other_countries_os_outcome do
    phrases = PhraseList.new
    if ceremony_country == 'burma'
      phrases << :other_countries_os_burma
      if partner_nationality == 'partner_local'
        phrases << :other_countries_os_burma_partner_local
      end
    elsif ceremony_country == 'north-korea'
      phrases << :other_countries_os_north_korea
      if partner_nationality == 'partner_local'
        phrases << :other_countries_os_north_korea_partner_local
      end     
    elsif ceremony_country == 'iran' or ceremony_country == 'somalia' or ceremony_country == 'syria'
      phrases << :other_countries_os_iran_somalia_syria
    elsif ceremony_country == 'yemen'
      phrases << :other_countries_os_yemen
    end
    case ceremony_country
    when 'saudi-arabia'
      if ceremony_country != residency_country
        phrases << :other_countries_os_ceremony_saudia_arabia_not_local_resident
      else
        if partner_nationality == 'partner_irish'
          phrases << :other_countries_os_saudi_arabia_local_resident_partner_irish
        else
          phrases << :other_countries_os_saudi_arabia_local_resident_partner_not_irish
        end
        if partner_nationality != 'partner_irish' and partner_nationality != 'partner_british'
          phrases << :other_countries_os_saudi_arabia_local_resident_partner_not_irish_or_british
        end
        if partner_nationality != 'partner_irish'
          phrases << :other_countries_os_saudi_arabia_local_resident_partner_not_irish_two
        end         
      end
    end
    phrases
  end
end
#CP outcomes
outcome :outcome_cp_cp_or_equivalent do
  precalculate :cp_or_equivalent_cp_outcome do
    phrases = PhraseList.new
    if data_query.cp_equivalent_countries?(ceremony_country)
      phrases << :"cp_or_equivalent_cp_#{ceremony_country}"
    end
    if ceremony_country == 'czech-republic' and partner_nationality == 'partner_local'
      phrases << :cp_or_equivalent_cp_czech_republic_partner_local
    end
    if resident_of == 'uk'
      phrases << :cp_or_equivalent_cp_uk_resident
    elsif ceremony_country == residency_country
      phrases << :cp_or_equivalent_cp_local_resident
    elsif ceremony_country != residency_country and resident_of !='uk'
      phrases << :cp_or_equivalent_cp_other_resident
    end
    phrases << :cp_or_equivalent_cp_all_what_you_need_to_do
    if partner_nationality != 'partner_british'
      phrases << :cp_or_equivalent_cp_naturalisation
    end
    phrases << :cp_or_equivalent_all_depositing_certificate
    if resident_of == 'uk'
      phrases << :cp_or_equivalent_cp_uk_resident_two
    end
    phrases << :cp_or_equivalent_cp_all_fees
    case ceremony_country
    when 'czech-republic','hungary','iceland','luxembourg','poland','slovenia'
      phrases << :cp_or_equivalent_cp_local_currency_countries
    else
      phrases << :cp_or_equivalent_cp_cash_or_credit_card_countries
    end
    phrases
  end
end
outcome :outcome_cp_france_pacs do
  precalculate :france_pacs_law_cp_outcome do
    phrases = PhraseList.new
    phrases << :france_pacs_law_cp_all_intro
    if ceremony_country == 'france'
      if resident_of == 'uk'
        phrases << :france_pacs_law_cp_ceremony_france_uk_resident
      elsif ceremony_country == residency_country
        phrases << :france_pacs_law_cp_ceremony_france_local_resident
      elsif ceremony_country != residency_country and resident_of !='uk'
        phrases << :france_pacs_law_cp_ceremony_france_other_resident
      end
    else
      if resident_of == 'uk'
        phrases << :france_pacs_law_cp_ceremony_nc_or_wf_cp_uk_resident
      elsif ceremony_country == residency_country
        phrases << :france_pacs_law_cp_ceremony_nc_or_wf_cp_local_resident
      elsif ceremony_country != residency_country and resident_of !='uk'
        phrases << :france_pacs_law_cp_ceremony_nc_or_wf_cp_other_resident
      end
    end
    phrases << :france_pacs_law_cp_all_cp_what_you_need_to_do
    if resident_of == 'uk'
      phrases << :france_pacs_law_cp_uk_resident_two
    else
      phrases << :france_pacs_law_cp_not_uk_resident_two
    end
    phrases << :france_pacs_law_cp_all_celibacy_certificate
    if partner_nationality != 'partner_british'
      phrases << :france_pacs_law_cp_naturalisation
    end
    phrases << :france_pacs_law_cp_all_depositing_pacs_certificate
    if resident_of == 'uk'
      phrases << :france_pacs_law_cp_uk_resident_two_point_five
    end
    phrases << :france_pacs_law_all_pacs_extract
    if resident_of == 'uk'
      phrases << :france_pacs_law_cp_uk_resident_three
    end
    phrases << :france_pacs_law_cp_all_fees
    phrases
  end
end
outcome :outcome_cp_no_cni do
  precalculate :no_cni_required_cp_outcome do
    phrases = PhraseList.new
    if data_query.cp_cni_not_required_countries?(ceremony_country)
      phrases << :"no_cni_required_cp_#{ceremony_country}"
    end
    phrases << :no_cni_required_all_legal_advice
    if ceremony_country == 'united-states'
      phrases << :no_cni_required_cp_ceremony_us
    end
    phrases << :no_cni_required_all_what_you_need_to_do
    case ceremony_country
    when 'bonaire-st-eustatius-saba'
      phrases << :no_cni_required_cp_dutch_islands
      if resident_of == 'uk'
        phrases << :no_cni_required_cp_dutch_islands_uk_resident
      elsif ceremony_country == residency_country
        phrases << :no_cni_required_cp_dutch_islands_local_resident
      elsif ceremony_country != residency_country and resident_of !='uk'
        phrases << :no_cni_required_cp_dutch_islands_other_resident
      end
    else
      if resident_of == 'uk'
        phrases << :no_cni_required_cp_not_dutch_islands_uk_resident
      elsif ceremony_country == residency_country
        phrases << :no_cni_required_cp_not_dutch_islands_local_resident
      elsif ceremony_country != residency_country and resident_of !='uk'
        phrases << :no_cni_required_cp_not_dutch_islands_other_resident
      end
    end
    phrases << :no_cni_required_cp_all_consular_facilities
    phrases << :no_cni_required_cp_all_depositing_certifictate
    if ceremony_country == 'united-states'
      phrases << :no_cni_required_cp_ceremony_us_two
    else
      phrases << :no_cni_required_cp_ceremony_not_us
    end
    if resident_of == 'uk'
      phrases << :no_cni_required_cp_uk_resident_three
    end
    if partner_nationality != 'partner_british'
      phrases << :no_cni_required_cp_naturalisation
    end
    phrases << :no_cni_required_cp_all_fees
    phrases   
  end
end
outcome :outcome_cp_commonwealth_countries do
  precalculate :commonwealth_countries_cp_outcome do
    phrases = PhraseList.new
    case ceremony_country
    when 'australia'
      phrases << :commonwealth_countries_cp_australia
    when 'canada'
      phrases << :commonwealth_countries_cp_canada
    when 'new-zealand'
      phrases << :commonwealth_countries_cp_new_zealand
    when 'south-africa'
      phrases << :commonwealth_countries_cp_south_africa
    end
    if ceremony_country == 'australia'
      phrases << :commonwealth_countries_cp_australia_two
    end
    if resident_of == 'uk'
      phrases << :commonwealth_countries_cp_uk_resident_two
    elsif ceremony_country == residency_country
        phrases << :commonwealth_countries_cp_local_resident
    elsif ceremony_country != residency_country and resident_of !='uk'
        phrases << :commonwealth_countries_cp_other_resident
    end
    case ceremony_country
    when 'australia'
      phrases << :commonwealth_countries_cp_australia_three
      phrases << :commonwealth_countries_cp_australia_four
      if partner_nationality == 'partner_local'
        phrases << :commonwealth_countries_cp_australia_partner_local
      elsif partner_nationality == 'partner_other'
        phrases << :commonwealth_countries_cp_australia_partner_other
      end
      phrases << :commonwealth_countries_cp_australia_five
    end
    phrases << :commonwealth_countries_cp_all_depositing_cp_certificate
    if ceremony_country != 'australia'
      phrases << :commonwealth_countries_cp_ceremony_not_australia
    end
    if resident_of == 'uk'
      phrases << :commonwealth_countries_cp_uk_resident_three
    end
    if partner_nationality != 'partner_british'
      phrases << :commonwealth_countries_cp_naturalisation
    end
    if ceremony_country == 'australia'
      phrases << :commonwealth_countries_cp_australia_six
    end
    phrases
  end
end
outcome :outcome_cp_consular_cni do
  precalculate :consular_cni_cp_outcome do
    phrases = PhraseList.new
    if ceremony_country == 'czech-republic'
      if partner_nationality != 'partner_local'
        phrases << :consular_cni_cp_ceremony_czech_republic_partner_not_local
      end
    else
      phrases << :consular_cni_cp_ceremony_not_czech_republic
    end
    if ceremony_country == 'vietnam' and partner_nationality == 'partner_local'
      phrases << :consular_cni_cp_ceremony_vietnam_partner_local
    else
      phrases << :consular_cni_cp_all_contact
      phrases << :consular_cni_cp_all_documents
      if partner_nationality != 'partner_british'
        phrases << :consular_cni_cp_partner_not_british
      end
      phrases << :consular_cni_cp_all_what_you_need_to_do
      if partner_nationality != 'partner_british'
        phrases << :consular_cni_cp_naturalisation
      end
      phrases << :consular_cni_cp_all_fees
      if ceremony_country == 'cambodia' or ceremony_country == 'latvia'
        phrases << :consular_cni_cp_local_currency
      else
        phrases << :consular_cni_cp_cheque
      end
    end
    phrases
  end
end
outcome :outcome_cp_all_other_countries
outcome :outcome_spain_italy
