status :draft
satisfies_need "FCO-01"

data_query = SmartAnswer::Calculators::MarriageAbroadDataQueryV2.new
reg_data_query = SmartAnswer::Calculators::RegistrationsDataQuery.new
i18n_prefix = 'flow.marriage-abroad-v2'
use_second_embassy_address = %w(bosnia-and-herzegovina india)
use_third_embassy_address = %w(indonesia)

# Q1
country_select :country_of_ceremony?, :use_legacy_data => true do
  save_input_as :ceremony_country

  calculate :ceremony_country_name do
    LegacyCountry.all.find { |c| c.slug == responses.last }.name
  end
  calculate :country_name_lowercase_prefix do
    if data_query.countries_with_definitive_articles?(ceremony_country)
      "the #{ceremony_country_name}"
    elsif SmartAnswer::Calculators::MarriageAbroadDataQueryV2::COUNTRY_NAME_TRANSFORM.has_key?(ceremony_country)
      SmartAnswer::Calculators::MarriageAbroadDataQueryV2::COUNTRY_NAME_TRANSFORM[ceremony_country]
    else
      "#{ceremony_country_name}"
    end
  end
  calculate :country_name_uppercase_prefix do
    if data_query.countries_with_definitive_articles?(ceremony_country)
      "The #{ceremony_country_name}"
    else
      "#{country_name_lowercase_prefix}"
    end
  end
  calculate :country_name_for_links do
    if SmartAnswer::Calculators::MarriageAbroadDataQueryV2::LINK_NAME_TRANSFORM.has_key?(ceremony_country)
      SmartAnswer::Calculators::MarriageAbroadDataQueryV2::LINK_NAME_TRANSFORM[ceremony_country]
    else
      "#{ceremony_country}"
    end
  end
  calculate :country_name_partner_residence do
    if data_query.british_overseas_territories?(ceremony_country)
      "British (overseas territories citizen)"
    elsif data_query.french_overseas_territories?(ceremony_country)
      "French"
    elsif data_query.dutch_caribbean_islands?(ceremony_country)
      "Dutch"
    elsif %w(hong-kong-(sar-of-china) macao).include?(ceremony_country)
      "Chinese" 
    else
      "National of #{country_name_lowercase_prefix}"
    end
  end
  calculate :embassy_address do
    data = data_query.find_embassy_data(ceremony_country)
    data.first['address'] if data
  end
  calculate :embassy_details do
    details = data_query.find_embassy_data(ceremony_country)
    if use_third_embassy_address.include?(ceremony_country)
      details = details.third
    elsif use_second_embassy_address.include?(ceremony_country)
      details = details.second
    else
      details = details.first
    end
      I18n.translate("#{i18n_prefix}.phrases.embassy_details",
                       address: details['address'], phone: details['phone'], email: details['email'], office_hours: details['office_hours'])
  end
  calculate :clickbook_data do
    reg_data_query.clickbook(ceremony_country)
  end
  calculate :multiple_clickbooks do
    clickbook_data and clickbook_data.class == Hash
  end
  calculate :embassy_or_consulate_ceremony_country do
    if reg_data_query.has_consulate?(ceremony_country) or reg_data_query.has_consulate_general?(ceremony_country)
      "consulate"
    else
      "embassy"
    end
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

  next_node do |response|
    case response.to_s
    when 'uk_iom','uk_ci'
      if data_query.os_other_countries?(ceremony_country)
        :what_is_your_partners_nationality?
      else
        :outcome_os_iom_ci
      end
    else
      if ceremony_country == 'france' or %w(new-caledonia wallis-and-futuna).include?(ceremony_country)
        :marriage_or_pacs?
      elsif %w(french-guiana french-polynesia guadeloupe martinique mayotte reunion st-pierre-and-miquelon).include?(ceremony_country)
        :outcome_os_france_or_fot
      else
        :what_is_your_partners_nationality?
      end
    end
  end
end

# Q3b
country_select :residency_nonuk?, :use_legacy_data => true do
  save_input_as :residency_country

  calculate :residency_country_name do
    LegacyCountry.all.find { |c| c.slug == responses.last }.name
  end
  calculate :residency_country_name_lowercase_prefix do
    if data_query.countries_with_definitive_articles?(residency_country)
      "the #{residency_country_name}"
    elsif SmartAnswer::Calculators::MarriageAbroadDataQueryV2::COUNTRY_NAME_TRANSFORM.has_key?(residency_country)
      SmartAnswer::Calculators::MarriageAbroadDataQueryV2::COUNTRY_NAME_TRANSFORM[residency_country]
    else
      "#{residency_country_name}"
    end
  end
  calculate :residency_country_link_names do
    if SmartAnswer::Calculators::MarriageAbroadDataQueryV2::LINK_NAME_TRANSFORM.has_key?(residency_country)
      SmartAnswer::Calculators::MarriageAbroadDataQueryV2::LINK_NAME_TRANSFORM[residnecy_country]
    else
      "#{residency_country}"
    end
  end
  calculate :residency_embassy_address do
    data = data_query.find_embassy_data(residency_country)
    data.first['address'] if data
  end
  calculate :residency_embassy_details do
    details = data_query.find_embassy_data(residency_country)
    if use_third_embassy_address.include?(residency_country)
      details = details.third
    elsif use_second_embassy_address.include?(residency_country)
      details = details.second
    else
      details = details.first
    end
      I18n.translate("#{i18n_prefix}.phrases.embassy_details",
                       address: details['address'], phone: details['phone'], email: details['email'], office_hours: details['office_hours'])
  end
  calculate :embassy_or_consulate_residency_country do
    if reg_data_query.has_consulate?(residency_country) or reg_data_query.has_consulate_general?(residency_country)
      "consulate"
    else
      "embassy"
    end
  end

  next_node do
    if %w(france new-caledonia wallis-and-futuna).include?(ceremony_country)
      :marriage_or_pacs?
    elsif %w(french-guiana french-polynesia guadeloupe martinique mayotte new-caledonia reunion st-pierre-and-miquelon).include?(ceremony_country)
      :outcome_os_france_or_fot
    else
      :what_is_your_partners_nationality?
    end
  end
  
end

# Q3c
multiple_choice :marriage_or_pacs? do
  option :marriage
  option :pacs

  next_node do |response|
    if response == 'marriage'
      :outcome_os_france_or_fot
    else
      :outcome_cp_france_pacs
    end
  end
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
      elsif data_query.os_consular_cni_countries?(ceremony_country) or (resident_of == 'uk' and data_query.os_no_marriage_related_consular_services?(ceremony_country))
        :outcome_os_consular_cni
      elsif %w(thailand egypt korea lebanon).include?(ceremony_country)
        :outcome_os_affirmation
      elsif data_query.os_no_consular_cni_countries?(ceremony_country) or (resident_of == 'other' and data_query.os_no_marriage_related_consular_services?(ceremony_country))
        :outcome_os_no_cni
      elsif data_query.os_other_countries?(ceremony_country)
        :outcome_os_other_countries
      end
    else
      if ceremony_country == 'ireland'
        :outcome_ireland
      elsif ceremony_country == 'spain'
        :outcome_os_consular_cni
      elsif data_query.cp_equivalent_countries?(ceremony_country)
        :outcome_cp_cp_or_equivalent
      elsif ceremony_country == 'czech-republic'
        if partner_nationality == 'partner_local'
          :outcome_cp_cp_or_equivalent
        else
          :outcome_cp_consular_cni
        end
      elsif data_query.cp_cni_not_required_countries?(ceremony_country)
        :outcome_cp_no_cni
      elsif %w(australia canada new-zealand south-africa).include?(ceremony_country)
        :outcome_cp_commonwealth_countries
      elsif data_query.cp_consular_cni_countries?(ceremony_country)
        :outcome_cp_consular_cni
      else
        :outcome_cp_all_other_countries
      end
    end
  end
end

outcome :outcome_os_iom_ci do
  precalculate :iom_ci_os_outcome do
    phrases = PhraseList.new
    phrases << :iom_ci_os_all
    if ceremony_country == 'spain'
      phrases << :iom_ci_os_spain
    end
    if residency_uk_region == 'uk_iom'
      phrases << :iom_ci_os_resident_of_iom
    else
      phrases << :iom_ci_os_resident_of_ci
    end
    if ceremony_country != 'italy'
      phrases << :iom_ci_os_ceremony_not_italy
    else
      phrases << :iom_ci_os_ceremony_italy
    end
    phrases
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
    elsif ceremony_country == 'british-virgin-islands'
      phrases << :bot_os_ceremony_bvi
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
    if ceremony_country == 'ecuador' and partner_nationality == 'partner_local' and residency_country != 'ecuador'
      phrases << :ecuador_os_consular_cni
    end
    if resident_of == 'uk' and ceremony_country != 'italy' and !data_query.dutch_caribbean_islands?(ceremony_country)
      phrases << :uk_resident_os_consular_cni
    elsif residency_country == ceremony_country and ceremony_country != 'italy'
      phrases << :local_resident_os_consular_cni
    elsif resident_of == 'uk' and data_query.dutch_caribbean_islands?(ceremony_country)
      phrases << :uk_resident_os_consular_cni_dutch_caribbean_islands
    else
      unless resident_of == 'uk' or ceremony_country == residency_country or ceremony_country == 'italy'
      phrases << :other_resident_os_consular_cni
      end
    end

    if %w(jordan oman qatar united-arab-emirates).include?(ceremony_country)
      phrases << :gulf_states_os_consular_cni
      if residency_country == ceremony_country and partner_nationality != 'partner_irish'
        phrases << :gulf_states_os_consular_cni_local_resident_partner_not_irish
      end
    end

    if ceremony_country == 'spain'
      if sex_of_your_partner == 'opposite_sex'
        phrases << :spain_os_consular_cni_opposite_sex
      else
        phrases << :spain_os_consular_cni_same_sex
      end
      phrases << :spain_os_consular_civil_registry
      if residency_country != 'spain'
        phrases << :spain_os_consular_cni_not_local_resident
      end
    end

    if ceremony_country == 'italy'
      phrases << :italy_os_consular_cni_ceremony_italy
    else
      phrases << :italy_os_consular_cni_ceremony_not_italy
    end

    phrases << :consular_cni_all_what_you_need_to_do

    if ceremony_country != 'italy' and ceremony_country != 'spain' or (ceremony_country == 'germany' and resident_of == 'other')
      phrases << :consular_cni_os_ceremony_not_spain_or_italy
    elsif ceremony_country == 'spain'
      phrases << :spain_os_consular_cni_two
    elsif ceremony_country == 'italy'
      if resident_of == 'uk'
        if partner_nationality !='partner_irish' or (residency_uk_region == 'uk_scotland' or residency_uk_region == 'uk_ni' and partner_nationality == 'partner_irish')
          phrases << :italy_os_consular_cni_uk_resident
        end
      end
      if resident_of == 'uk' and partner_nationality == 'partner_british'
        phrases << :italy_os_consular_cni_uk_resident_two
      end
      if resident_of != 'uk' or (resident_of == 'uk' and partner_nationality == 'partner_irish' and residency_uk_region != 'uk_scotland' and residency_uk_region != 'uk_ni')
        phrases << :italy_os_consular_cni_uk_resident_three
      end
    end

    if ceremony_country == 'denmark'
      phrases << :consular_cni_os_denmark
    elsif ceremony_country == 'germany'
      if residency_country == 'germany'
        phrases << :consular_cni_os_german_resident
      else
        if resident_of == 'other'
          phrases << :consular_cni_os_not_germany_or_uk_resident
        end
      end
      if resident_of == 'other'
        phrases << :consular_cni_os_ceremony_germany_not_uk_resident
      end
    elsif ceremony_country == 'china'
      if residency_country == 'china'
        phrases << :consular_cni_os_china_local_resident
      else
        phrases << :consular_cni_os_china_not_local_resident
      end
      if partner_nationality != 'partner_local'
        phrases << :consular_cni_os_china_not_local_partner
      end
    end

    if resident_of == 'uk'
      if partner_nationality !='partner_irish'
        phrases << :uk_resident_partner_not_irish_os_consular_cni_three
      elsif partner_nationality == 'partner_irish' and %w(uk_scotland uk_ni).include?(residency_uk_region)
        phrases << :scotland_ni_resident_partner_irish_os_consular_cni_three
      end
      if ceremony_country == 'italy'
        case residency_uk_region
        when 'uk_england','uk_wales'
          if partner_nationality == 'partner_irish'
            phrases << :consular_cni_os_england_or_wales_partner_irish_three
          else
            phrases << :consular_cni_os_scotland_or_ni_partner_irish_or_partner_not_irish_three
          end
        else
          phrases << :consular_cni_os_scotland_or_ni_partner_irish_or_partner_not_irish_three
        end
      end
    end

    if ceremony_country != 'italy' and partner_nationality == 'partner_irish'
      if residency_uk_region == 'uk_england' or residency_uk_region == 'uk_wales'
        phrases << :consular_cni_os_england_or_wales_resident_not_italy
      end
    end

    if resident_of == 'uk'
      if !%w(italy portugal philippines montenegro poland kazakhstan kyrgyzstan).include?(ceremony_country)
        phrases << :consular_cni_os_uk_resident_legalisation
      elsif %w(montenegro).include?(ceremony_country)
        phrases << :consular_cni_os_uk_resident_montenegro
      elsif %w(poland kazakhstan kyrgyzstan).include?(ceremony_country)
        phrases << :consular_cni_os_uk_resident_poland_kazak_kyrg      
      end
      if !%w(italy portugal philippines).include?(ceremony_country)
        phrases << :consular_cni_os_uk_resident_not_italy_or_portugal
      end
      if ceremony_country == 'philippines'
        phrases << :consular_cni_os_uk_resident_philippines
      end
      if ceremony_country == 'portugal'
        phrases << :consular_cni_os_uk_resident_ceremony_portugal
        if reg_data_query.clickbook(ceremony_country)
          if multiple_clickbooks
            phrases << :clickbook_links
          else
            phrases << :clickbook_link
          end
        end
      end
    end

    if ceremony_country == residency_country
      if ceremony_country != 'italy' and ceremony_country != 'germany' and ceremony_country != 'kazakhstan'
        phrases << :consular_cni_os_local_resident_not_italy_germany
      end
      if ceremony_country == 'kazakhstan'
        phrases << :kazakhstan_os_local_resident
      end
      if ceremony_country != 'italy' and ceremony_country != 'germany' and ceremony_country != 'spain'
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
      if ceremony_country == 'italy'
        phrases << :consular_cni_os_local_resident_italy
      end
    end

    if data_query.non_commonwealth_country?(residency_country) and residency_country != 'ireland' and ceremony_country != 'germany' and ceremony_country != residency_country
      phrases << :consular_cni_os_foreign_resident
    elsif data_query.commonwealth_country?(residency_country) and residency_country != 'ireland' and ceremony_country != 'germany' and ceremony_country != residency_country
      phrases << :consular_cni_os_commonwealth_resident
    end
    if data_query.commonwealth_country?(residency_country) and partner_nationality == 'partner_british' and ceremony_country != residency_country and ceremony_country != 'germany'
      phrases << :consular_cni_os_commonwealth_resident_british_partner
    end
    if data_query.commonwealth_country?(residency_country) and ceremony_country != residency_country and ceremony_country != 'germany'
      phrases << :consular_cni_os_commonwealth_resident_two
    elsif residency_country == 'ireland' and ceremony_country != 'germany'
      phrases << :consular_cni_os_ireland_resident
    end
    if residency_country == 'ireland' and partner_nationality == 'partner_british' and ceremony_country != 'germany'
      phrases << :consular_cni_os_ireland_resident_british_partner
    end
    if residency_country == 'ireland' and ceremony_country != 'germany'
      phrases << :consular_cni_os_ireland_resident_two
    end

    case partner_nationality
    when 'partner_british'
      if data_query.commonwealth_country?(residency_country) or residency_country == 'ireland' and ceremony_country != residency_country and ceremony_country != 'germany'
        phrases << :consular_cni_os_commonwealth_or_ireland_resident_british_partner
      end
    else
      if data_query.commonwealth_country?(residency_country) or residency_country == 'ireland' and ceremony_country != residency_country and ceremony_country != 'germany'
        phrases << :consular_cni_os_commonwealth_or_ireland_resident_non_british_partner
      end
    end
    if ceremony_country == residency_country and residency_country != 'spain' and residency_country != 'germany' and residency_country != 'italy' or (data_query.non_commonwealth_country?(residency_country) and residency_country != 'ireland' and ceremony_country != residency_country and ceremony_country != 'germany')
      phrases << :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident
    end
    if ceremony_country == residency_country
      if ceremony_country == 'italy'
        if partner_nationality == 'partner_local'
          phrases << :italy_consular_cni_os_partner_local
        elsif partner_nationality == 'partner_irish' or partner_nationality == 'partner_other'
          phrases << :italy_consular_cni_os_partner_other_or_irish
        elsif partner_nationality == 'partner_british'
          phrases << :italy_consular_cni_os_partner_british
        end
      elsif ceremony_country == 'spain'
        phrases << :consular_cni_variant_local_resident_spain
      end
    end
    if ceremony_country != 'germany' and resident_of == 'other'
      phrases << :consular_cni_os_not_uk_resident_ceremony_not_germany
    end
    if ceremony_country == residency_country and ceremony_country == 'spain'
      phrases << :spain_os_consular_cni_three
    end
    if data_query.non_commonwealth_country?(residency_country) and residency_country != 'ireland' and ceremony_country != 'germany' or (ceremony_country == residency_country and ceremony_country != 'spain' and ceremony_country != 'germany')
      phrases << :consular_cni_os_local_resident_not_germany_or_spain_or_foreign_resident_not_germany
    end
    if ceremony_country == residency_country
      if residency_country != 'germany' and residency_country != 'italy' and residency_country != 'spain'
        phrases << :consular_cni_os_local_resident_not_germany_or_italy_or_spain
      elsif residency_country == 'italy'
        phrases << :consular_cni_os_local_resident_italy_two
      end
    end
    if data_query.non_commonwealth_country?(residency_country) and residency_country != 'ireland' and ceremony_country != residency_country
      if ceremony_country != 'italy' and ceremony_country != 'germany'
        phrases << :consular_cni_os_foreign_resident_ceremony_not_italy
      elsif ceremony_country == 'italy'
        phrases << :consular_cni_os_foreign_resident_ceremony_italy
      end
    end
    if ceremony_country != 'italy' and ceremony_country != 'germany'
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
    if data_query.commonwealth_country?(residency_country) or residency_country == 'ireland' and ceremony_country == 'italy'
      phrases << :italy_os_consular_cni_four
    end
    if resident_of == 'uk' and partner_nationality == 'partner_british' and ceremony_country != 'italy'
      phrases << :consular_cni_os_partner_british
    end

    if partner_nationality == 'partner_british' and ceremony_country != 'italy' and ceremony_country != 'germany'
      phrases << :consular_cni_os_local_resident_ceremony_not_italy_not_germany_partner_british
    end

    if ceremony_country != residency_country and resident_of == 'other' and partner_nationality == 'partner_british' and ceremony_country == 'italy'
      phrases << :consular_cni_os_other_resident_partner_british_ceremony_italy
    end
    if ceremony_country == 'china' and residency_country == 'china' and partner_nationality == 'partner_local'
      phrases << :consular_cni_os_china_partner_local
    end
    if ceremony_country != 'germany' or (ceremony_country == 'germany' and resident_of == 'uk')
      phrases << :consular_cni_os_all_names_but_germany
    end
    if resident_of == 'other' and ceremony_country != 'italy' and ceremony_country != 'spain' and ceremony_country != 'germany'
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
    if ceremony_country == 'italy'
      phrases << :italy_os_consular_cni_five
    else
      phrases << :italy_os_consular_cni_six
    end
    if ceremony_country != residency_country or ceremony_country == 'germany' and ceremony_country != 'italy'
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
    if ceremony_country == 'italy'
      phrases << :italy_os_consular_cni_seven
    end
    if ceremony_country == 'finland'
      phrases << :consular_cni_os_ceremony_finland
    elsif ceremony_country == 'turkey'
      phrases << :consular_cni_os_ceremony_turkey
    end
    if resident_of == 'uk'
      phrases << :consular_cni_os_uk_resident
    end

    if ceremony_country == 'italy' and resident_of == 'uk'
      phrases << :consular_cni_os_fees_ceremony_italy_uk_resident
    else
      phrases << :consular_cni_os_fees_not_italy_not_uk
      if ceremony_country == residency_country or resident_of == 'uk'
        phrases << :consular_cni_os_fees_local_or_uk_resident
      else
        phrases << :consular_cni_os_fees_foreign_commonwealth_roi_resident
      end
    end

    if %w(armenia bosnia-and-herzegovina cambodia iceland kazakhstan latvia luxembourg slovenia tunisia tajikistan).include?(ceremony_country)
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
    if data_query.french_overseas_territories?(ceremony_country)
      phrases << :fot_os_all
    end
    phrases << :france_fot_os_all
    if resident_of == 'uk'
      phrases << :france_fot_os_uk_resident
    else
      phrases << :france_fot_os_non_uk_resident
    end
    phrases << :france_fot_os_all_two
    if resident_of == 'uk'
      phrases << :france_fot_os_uk_resident_two
    end
    phrases << :france_fot_os_all_three
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
    if data_query.dutch_caribbean_islands?(ceremony_country)
      phrases << :no_cni_os_dutch_caribbean_islands
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

    phrases << :no_cni_os_consular_facilities

    if ceremony_country != 'taiwan'
      phrases << :no_cni_os_all_nearest_embassy_not_taiwan
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
    else
      ''
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
    when 'iceland','luxembourg','slovenia'
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
    if %w(new-caledonia wallis-and-futuna).include?(ceremony_country)
      phrases << :fot_cp_all
    end
    phrases << :france_fot_cp_all
    if resident_of == 'uk'
      phrases << :france_fot_cp_uk_resident
    else
      phrases << :france_fot_cp_non_uk_resident
    end
    phrases << :france_fot_cp_all_two
    if resident_of == 'uk'
      phrases << :france_fot_cp_uk_resident_two
    end
    phrases << :france_fot_cp_all_three
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
    elsif %w(croatia bulgaria).include?(ceremony_country) and partner_nationality == 'partner_local'
      phrases << :consular_cni_cp_local_partner_croatia_bulgaria
    else
      phrases << :consular_cni_cp_all_contact
      if reg_data_query.clickbook(ceremony_country)
        if multiple_clickbooks
          phrases << :clickbook_links
        else
          phrases << :clickbook_link
        end
      end
      unless reg_data_query.clickbook(ceremony_country)
        phrases << :consular_cni_cp_no_clickbook_so_embassy_details
      end
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
