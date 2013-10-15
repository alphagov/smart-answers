status :published
satisfies_need "2799"

data_query = SmartAnswer::Calculators::MarriageAbroadDataQuery.new
reg_data_query = SmartAnswer::Calculators::RegistrationsDataQuery.new
exclude_countries = %w(holy-see british-antarctic-territory the-occupied-palestinian-territories)

# Q1
country_select :country_of_ceremony?, :exclude_countries => exclude_countries do
  save_input_as :ceremony_country

  calculate :location do
    loc = WorldLocation.find(ceremony_country)
    raise InvalidResponse unless loc
    loc
  end

  calculate :organisation do
    location.fco_organisation
  end
  calculate :overseas_passports_embassies do
    if organisation
      organisation.offices_with_service 'Marriages or Civil Partnership registrations'
    else
      []
    end
  end

  calculate :ceremony_country_name do
    location.name
  end
  calculate :country_name_lowercase_prefix do
    if data_query.countries_with_definitive_articles?(ceremony_country)
      "the #{ceremony_country_name}"
    elsif SmartAnswer::Calculators::MarriageAbroadDataQuery::COUNTRY_NAME_TRANSFORM.has_key?(ceremony_country)
      SmartAnswer::Calculators::MarriageAbroadDataQuery::COUNTRY_NAME_TRANSFORM[ceremony_country]
    else
      ceremony_country_name
    end
  end
  calculate :country_name_uppercase_prefix do
    if data_query.countries_with_definitive_articles?(ceremony_country)
      "The #{ceremony_country_name}"
    else
      country_name_lowercase_prefix
    end
  end

  calculate :country_name_partner_residence do
    if data_query.british_overseas_territories?(ceremony_country)
      "British (overseas territories citizen)"
    elsif data_query.french_overseas_territories?(ceremony_country)
      "French"
    elsif data_query.dutch_caribbean_islands?(ceremony_country)
      "Dutch"
    elsif %w(hong-kong macao).include?(ceremony_country)
      "Chinese" 
    else
      "National of #{country_name_lowercase_prefix}"
    end
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
    if %w(ireland).include?(response)
      :partner_opposite_or_same_sex?
    elsif %w(france new-caledonia wallis-and-futuna).include?(response)
      :marriage_or_pacs?
    elsif %w(french-guiana french-polynesia guadeloupe martinique mayotte new-caledonia reunion st-pierre-and-miquelon).include?(response)
      :outcome_os_france_or_fot
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
    if %w(uk_iom uk_ci).include?(response)
      if data_query.os_other_countries?(ceremony_country)
        :what_is_your_partners_nationality?
      else
        :outcome_os_iom_ci
      end
    else
      :what_is_your_partners_nationality?
    end
  end
end

# Q3b
country_select :residency_nonuk?, :exclude_countries => exclude_countries do
  save_input_as :residency_country

  calculate :location do
    loc = WorldLocation.find(residency_country)
    raise InvalidResponse unless loc
    loc
  end

  calculate :organisation do
    location.fco_organisation
  end
  calculate :overseas_passports_embassies do
    if organisation
      organisation.offices_with_service 'Marriages or Civil Partnership service'
    else
      []
    end
  end

  calculate :residency_country_name do
    location.name
  end
  calculate :residency_country_name_lowercase_prefix do
    if data_query.countries_with_definitive_articles?(residency_country)
      "the #{residency_country_name}"
    elsif SmartAnswer::Calculators::MarriageAbroadDataQuery::COUNTRY_NAME_TRANSFORM.has_key?(residency_country)
      SmartAnswer::Calculators::MarriageAbroadDataQuery::COUNTRY_NAME_TRANSFORM[residency_country]
    else
      residency_country_name
    end
  end

  calculate :embassy_or_consulate_residency_country do
    if reg_data_query.has_consulate?(residency_country) or reg_data_query.has_consulate_general?(residency_country)
      "consulate"
    else
      "embassy"
    end
  end

  next_node :what_is_your_partners_nationality?  
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
      if %w(ireland).include?(ceremony_country)
        :outcome_ireland
      elsif data_query.commonwealth_country?(ceremony_country) or %w(zimbabwe).include?(ceremony_country)
        :outcome_os_commonwealth
      elsif data_query.british_overseas_territories?(ceremony_country)
        :outcome_os_bot
      elsif data_query.os_consular_cni_countries?(ceremony_country) or (%w(uk).include?(resident_of) and data_query.os_no_marriage_related_consular_services?(ceremony_country))
        :outcome_os_consular_cni
      elsif %w(thailand egypt south-korea lebanon united-arab-emirates).include?(ceremony_country)
        :outcome_os_affirmation
      elsif data_query.os_no_consular_cni_countries?(ceremony_country) or (%w(other).include?(resident_of) and data_query.os_no_marriage_related_consular_services?(ceremony_country))
        :outcome_os_no_cni
      elsif data_query.os_other_countries?(ceremony_country)
        :outcome_os_other_countries
      end
    else
      if %w(ireland).include?(ceremony_country)
        :outcome_ireland
      elsif %w(spain).include?(ceremony_country)
        :outcome_os_consular_cni
      elsif data_query.cp_equivalent_countries?(ceremony_country)
        :outcome_cp_cp_or_equivalent
      elsif %w(czech-republic).include?(ceremony_country)
        if %w(partner_local).include?(partner_nationality)
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
    if %w(spain).include?(ceremony_country)
      phrases << :iom_ci_os_spain
    end
    if %w(uk_iom).include?(residency_uk_region)
      phrases << :iom_ci_os_resident_of_iom
    else
      phrases << :iom_ci_os_resident_of_ci
    end
    if %w(italy).exclude?(ceremony_country)
      phrases << :iom_ci_os_ceremony_not_italy
    else
      phrases << :iom_ci_os_ceremony_italy
    end
    phrases
  end
end

outcome :outcome_ireland do
  precalculate :ireland_partner_sex_variant do
    if %w(opposite_sex).include?(sex_of_your_partner)
      PhraseList.new(:outcome_ireland_opposite_sex)
    else
      PhraseList.new(:outcome_ireland_same_sex)
    end
  end
end

outcome :outcome_os_commonwealth do
  precalculate :commonwealth_os_outcome do
    phrases = PhraseList.new
    if %w(zimbabwe).exclude?(ceremony_country)
      phrases << :commonwealth_os_all_intro
    else
      phrases << :commonwealth_os_zimbabwe_intro
    end
    if %w(zimbabwe).exclude?(ceremony_country)
      if %w(uk).include?(resident_of)
        phrases << :uk_resident_os_ceremony_not_zimbabwe
      elsif residency_country == ceremony_country
        phrases << :local_resident_os_ceremony_not_zimbabwe
      else
        phrases << :other_resident_os_ceremony_not_zimbabwe
      end
    else
      if %w(uk).include?(resident_of)
        phrases << :uk_resident_os_ceremony_zimbabwe
      elsif residency_country == ceremony_country
        phrases << :local_resident_os_ceremony_zimbabwe
      else
        phrases << :other_resident_os_ceremony_zimbabwe
      end
    end
    if %w(zimbabwe).exclude?(ceremony_country)
      phrases << :commonwealth_os_all_cni
    else
      phrases << :commonwealth_os_all_cni_zimbabwe
    end
    case ceremony_country
    when 'south-africa'
      if %w(partner_local).include?(partner_nationality)
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
      if %w(cyprus).include?(residency_country)
        phrases << :commonwealth_os_other_countries_cyprus
      end
    end
    if %w(partner_british).exclude?(partner_nationality)
      phrases << :commonwealth_os_naturalisation
    end
    phrases
  end
end

outcome :outcome_os_bot do
  precalculate :bot_outcome do
    phrases = PhraseList.new
    if %w(british-indian-ocean-territory).include?(ceremony_country)
      phrases << :bot_os_ceremony_biot
    elsif %w(british-virgin-islands).include?(ceremony_country)
      phrases << :bot_os_ceremony_bvi
    else
      phrases << :bot_os_ceremony_non_biot
      if residency_country != ceremony_country
        phrases << :bot_os_not_local_resident
      end
      unless %w(partner_british).include?(partner_nationality)
        phrases << :bot_os_naturalisation
      end
    end
    phrases
  end
end

outcome :outcome_os_consular_cni do
  precalculate :consular_cni_os_start do
    phrases = PhraseList.new
    if %w(ecuador).include?(ceremony_country) and %w(partner_local).include?(partner_nationality) and %w(ecuador).exclude?(residency_country)
      phrases << :ecuador_os_consular_cni
    end
    if %w(uk).include?(resident_of) and %w(italy).exclude?(ceremony_country) and !data_query.dutch_caribbean_islands?(ceremony_country)
      phrases << :uk_resident_os_consular_cni
    elsif residency_country == ceremony_country and %w(italy).exclude?(ceremony_country)
      phrases << :local_resident_os_consular_cni
    elsif %w(uk).include?(resident_of) and data_query.dutch_caribbean_islands?(ceremony_country)
      phrases << :uk_resident_os_consular_cni_dutch_caribbean_islands
    else
      unless %w(uk).include?(resident_of) or ceremony_country == residency_country or %w(italy).include?(ceremony_country)
      phrases << :other_resident_os_consular_cni
      end
    end

    if %w(jordan oman qatar).include?(ceremony_country)
      phrases << :gulf_states_os_consular_cni
      if residency_country == ceremony_country and %w(partner_irish).exclude?(partner_nationality)
        phrases << :gulf_states_os_consular_cni_local_resident_partner_not_irish
      end
    end

    if %w(spain).include?(ceremony_country)
      if %w(opposite_sex).include?(sex_of_your_partner)
        phrases << :spain_os_consular_cni_opposite_sex
      else
        phrases << :spain_os_consular_cni_same_sex
      end
      phrases << :spain_os_consular_civil_registry
      if %w(spain).exclude?(residency_country)
        phrases << :spain_os_consular_cni_not_local_resident
      end
    end

    if %w(italy).include?(ceremony_country)
      phrases << :italy_os_consular_cni_ceremony_italy
    end
    if %w(italy spain).exclude?(ceremony_country)
      phrases << :italy_os_consular_cni_ceremony_not_italy_or_spain
    end

    phrases << :consular_cni_all_what_you_need_to_do

    if %w(italy spain).exclude?(ceremony_country)
      unless %w(germany).include?(ceremony_country) and %w(other).include?(resident_of)
        phrases << :consular_cni_os_ceremony_not_spain_or_italy
      end
    end
    if %w(spain).include?(ceremony_country)
      phrases << :spain_os_consular_cni_two
    elsif %w(italy).include?(ceremony_country)
      if %w(uk).include?(resident_of)
        if %w(partner_irish).exclude?(partner_nationality) or (%w(uk_scotland uk_ni).include?(residency_uk_region) and %w(partner_irish).include?(partner_nationality))
          phrases << :italy_os_consular_cni_uk_resident
        end
      end
      if %w(uk).include?(resident_of) and %w(partner_british).include?(partner_nationality)
        phrases << :italy_os_consular_cni_uk_resident_two
      end
      if %w(uk).exclude?(resident_of) or (%w(uk).include?(resident_of) and %w(partner_irish).include?(partner_nationality) and %w(uk_scotland uk_ni).exclude?(residency_uk_region))
        phrases << :italy_os_consular_cni_uk_resident_three
      end
    end

    if %w(denmark).include?(ceremony_country)
      phrases << :consular_cni_os_denmark
    elsif %w(germany).include?(ceremony_country)
      if %w(germany).include?(residency_country)
        phrases << :consular_cni_os_german_resident
      else
        if %w(other).include?(resident_of)
          phrases << :consular_cni_os_not_germany_or_uk_resident
        end
      end
      if %w(other).include?(resident_of)
        phrases << :consular_cni_os_ceremony_germany_not_uk_resident
      end
    elsif %w(china).include?(ceremony_country)
      if %w(china).include?(residency_country)
        phrases << :consular_cni_os_china_local_resident
      else
        phrases << :consular_cni_os_china_not_local_resident
      end
      if %w(partner_local).exclude?(partner_nationality)
        phrases << :consular_cni_os_china_not_local_partner
      end
    end

    if %w(uk).include?(resident_of)
      if %w(partner_irish).exclude?(partner_nationality)
        phrases << :uk_resident_partner_not_irish_os_consular_cni_three
      elsif %w(partner_irish).include?(partner_nationality) and %w(uk_scotland uk_ni).include?(residency_uk_region)
        phrases << :scotland_ni_resident_partner_irish_os_consular_cni_three
      end
      if %w(italy).include?(ceremony_country)
        if %w(uk_england uk_wales).include?(residency_uk_region)
          if %w(partner_irish).include?(partner_nationality)
            phrases << :consular_cni_os_england_or_wales_partner_irish_three
          else
            phrases << :consular_cni_os_scotland_or_ni_partner_irish_or_partner_not_irish_three
          end
        else
          phrases << :consular_cni_os_scotland_or_ni_partner_irish_or_partner_not_irish_three
        end
      end
    end

    if %w(italy).exclude?(ceremony_country) and %w(partner_irish).include?(partner_nationality)
      if %w(uk_england uk_wales).include?(residency_uk_region)
        phrases << :consular_cni_os_england_or_wales_resident_not_italy
      end
    end

    if %w(uk).include?(resident_of)
      if %w(china italy kazakhstan kyrgyzstan montenegro philippines poland portugal).exclude?(ceremony_country)
        phrases << :consular_cni_os_uk_resident_legalisation
      elsif %w(montenegro).include?(ceremony_country)
        phrases << :consular_cni_os_uk_resident_montenegro
      elsif %w(kazakhstan kyrgyzstan poland).include?(ceremony_country)
        phrases << :consular_cni_os_uk_resident_poland_kazak_kyrg      
      end
      if %w(china italy philippines portugal).exclude?(ceremony_country)
        phrases << :consular_cni_os_uk_resident_not_italy_or_portugal
      end
      if %w(philippines).include?(ceremony_country)
        phrases << :consular_cni_os_uk_resident_philippines
      end
      if %w(portugal).include?(ceremony_country)
        phrases << :consular_cni_os_uk_resident_ceremony_portugal
        if reg_data_query.clickbook(ceremony_country)
          if multiple_clickbooks
            phrases << :clickbook_links
          else
            phrases << :clickbook_link
          end
        end
      elsif %w(china).include?(ceremony_country)
        phrases << :consular_cni_os_uk_resident_ceremony_china
        if %w(partner_local).include?(partner_nationality)
          phrases << :consular_cni_os_uk_resident_ceremony_china_local_partner
        end
      end
    end

    if ceremony_country == residency_country
      if %w(germany italy kazakhstan russia).exclude?(ceremony_country)
        phrases << :consular_cni_os_local_resident_not_italy_germany
      end
      if %w(kazakhstan).include?(ceremony_country)
        phrases << :kazakhstan_os_local_resident
      elsif %w(russia).include?(ceremony_country)
        phrases << :"russia_os_local_resident"
      end
      if %w(germany italy japan spain).exclude?(ceremony_country)
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
      if %w(italy).include?(ceremony_country)
        phrases << :consular_cni_os_local_resident_italy
      end
    end

    if data_query.non_commonwealth_country?(residency_country) and %w(ireland).exclude?(residency_country) and ceremony_country != residency_country
      if %w(germany italy).exclude?(ceremony_country)
        phrases << :consular_cni_os_foreign_resident_ceremony_not_germany_italy
      elsif %w(italy).include?(ceremony_country)
        phrases << :consular_cni_os_foreign_resident_ceremony_country_italy
      end
      if %w(germany).exclude?(ceremony_country)
        phrases << :consular_cni_os_foreign_resident_ceremony_country_not_germany
      end
    end

    if data_query.commonwealth_country?(residency_country) and %w(ireland).exclude?(residency_country) and %w(germany).exclude?(ceremony_country) and ceremony_country != residency_country
      phrases << :consular_cni_os_commonwealth_resident
    end

    if data_query.commonwealth_country?(residency_country) and %w(partner_british).include?(partner_nationality) and ceremony_country != residency_country and %w(germany).exclude?(ceremony_country)
      phrases << :consular_cni_os_commonwealth_resident_british_partner
    end
    if data_query.commonwealth_country?(residency_country) and ceremony_country != residency_country and %w(germany).exclude?(ceremony_country)
      phrases << :consular_cni_os_commonwealth_resident_two
    elsif %w(ireland).include?(residency_country) and %w(germany).exclude?(ceremony_country)
      phrases << :consular_cni_os_ireland_resident
    end
    if %w(ireland).include?(residency_country) and %w(partner_british).include?(partner_nationality) and %w(germany).exclude?(ceremony_country)
      phrases << :consular_cni_os_ireland_resident_british_partner
    end
    if %w(ireland).include?(residency_country) and %w(germany).exclude?(ceremony_country)
      phrases << :consular_cni_os_ireland_resident_two
    end

    if %w(partner_british).include?(partner_nationality)
      if data_query.commonwealth_country?(residency_country) or %w(ireland).include?(residency_country) and ceremony_country != residency_country and %w(germany).exclude?(ceremony_country)
        phrases << :consular_cni_os_commonwealth_or_ireland_resident_british_partner
      end
    else
      if data_query.commonwealth_country?(residency_country) or %w(ireland).include?(residency_country) and ceremony_country != residency_country and %w(germany).exclude?(ceremony_country)
        phrases << :consular_cni_os_commonwealth_or_ireland_resident_non_british_partner
      end
    end
    if ceremony_country == residency_country and %w(germany italy japan spain).exclude?(ceremony_country) or (data_query.non_commonwealth_country?(residency_country) and %w(ireland).exclude?(residency_country) and ceremony_country != residency_country and %w(germany).exclude?(ceremony_country))
      phrases << :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident
    end

    if ceremony_country == residency_country
      if %w(japan).include?(ceremony_country)
        phrases << :japan_consular_cni_os_local_resident
        if %w(partner_local).include?(partner_nationality)
          phrases << :japan_consular_cni_os_local_resident_partner_local
        end
      end
      if %w(italy).include?(ceremony_country)
        if %w(partner_local).include?(partner_nationality)
          phrases << :italy_consular_cni_os_partner_local
        elsif %w(partner_irish partner_other).include?(partner_nationality)
          phrases << :italy_consular_cni_os_partner_other_or_irish
        elsif %w(partner_british).include?(partner_nationality)
          phrases << :italy_consular_cni_os_partner_british
        end
      elsif %w(spain).include?(ceremony_country)
        phrases << :consular_cni_variant_local_resident_spain
      end
    end

    if %w(germany).exclude?(ceremony_country) and %w(other).include?(resident_of)
      phrases << :consular_cni_os_not_uk_resident_ceremony_not_germany
    end
    if %w(other).include?(resident_of) and %(germany spain).exclude?(ceremony_country)
      phrases << :consular_cni_os_other_resident_ceremony_not_germany_or_spain
    end
    if ceremony_country == residency_country and %w(spain).include?(ceremony_country)
      phrases << :spain_os_consular_cni_three
    end
    if ceremony_country == residency_country
      if %w(spain germany japan).exclude?(ceremony_country)
        phrases << :consular_cni_os_local_resident_not_germany_or_spain_or_foreign_resident_not_germany
      end
    else
      if data_query.non_commonwealth_country?(residency_country) and %w(ireland).exclude?(residency_country) and %w(germany).exclude?(ceremony_country)
        phrases << :consular_cni_os_local_resident_not_germany_or_spain_or_foreign_resident_not_germany
      end
    end
    
    if ceremony_country == residency_country
      if %w(germany italy spain).exclude?(residency_country)
        phrases << :consular_cni_os_local_resident_not_germany_or_italy_or_spain
      elsif %w(italy).include?(residency_country)
        phrases << :consular_cni_os_local_resident_italy_two
      end
    end
    if data_query.non_commonwealth_country?(residency_country) and %w(ireland).exclude?(residency_country) and ceremony_country != residency_country
      if %w(italy germany).exclude?(ceremony_country)
        phrases << :consular_cni_os_foreign_resident_ceremony_not_italy
      elsif %w(italy).include?(ceremony_country)
        phrases << :consular_cni_os_foreign_resident_ceremony_italy
      end
    end
    if %w(italy germany).exclude?(ceremony_country)
      if data_query.commonwealth_country?(residency_country) and ceremony_country != residency_country
        phrases << :consular_cni_os_commonwealth_resident_ceremony_not_italy
      elsif %w(ireland).include?(residency_country)
        phrases << :consular_cni_os_ireland_resident_ceremony_not_italy
      end
    end
    phrases
  end

  precalculate :consular_cni_os_remainder do
    phrases = PhraseList.new
    if data_query.commonwealth_country?(residency_country) and %w(italy).include?(ceremony_country)
      phrases << :consular_cni_os_commonwealth_resident_ceremony_italy
    end
    if %w(ireland).include?(residency_country) and %w(italy).include?(ceremony_country)
      phrases << :consular_cni_os_ireland_resident_ceremony_italy
    end
    if ceremony_country == residency_country and %w(japan).include?(ceremony_country)
      phrases << :japan_consular_cni_os_local_resident_two
    end
    if data_query.commonwealth_country?(residency_country) or %w(ireland).include?(residency_country) and %w(italy).include?(ceremony_country)
      phrases << :italy_os_consular_cni_four
    end
    if %w(uk).include?(resident_of) and %w(partner_british).include?(partner_nationality) and %w(italy).exclude?(ceremony_country)
      phrases << :consular_cni_os_partner_british
    end
    if %w(partner_british).include?(partner_nationality) and %w(italy germany).exclude?(ceremony_country)
      phrases << :consular_cni_os_local_resident_ceremony_not_italy_not_germany_partner_british
    end
    if ceremony_country != residency_country and %w(other).include?(resident_of) and %w(partner_british).include?(partner_nationality) and %w(italy).include?(ceremony_country)
      phrases << :consular_cni_os_other_resident_partner_british_ceremony_italy
    end
    if %w(china).include?(ceremony_country) and %w(china).include?(residency_country) and %w(partner_local).include?(partner_nationality)
      phrases << :consular_cni_os_china_partner_local
    end
    if %w(germany).exclude?(ceremony_country) or (%w(germany).include?(ceremony_country) and %w(uk).include?(resident_of))
      phrases << :consular_cni_os_all_names_but_germany
    end

    if %w(other).include?(resident_of) and %w(italy spain germany).exclude?(ceremony_country)
      phrases << :consular_cni_os_other_resident_ceremony_not_italy
    end
    if %w(belgium).include?(ceremony_country)
      phrases << :consular_cni_os_ceremony_belgium
      if ceremony_country != residency_country
        phrases << :consular_cni_os_belgium_clickbook
      end
    end
    if %w(spain).include?(ceremony_country)
      phrases << :consular_cni_os_ceremony_spain
      if %w(partner_british).include?(partner_nationality)
        phrases << :consular_cni_os_ceremony_spain_partner_british
      end
      phrases << :consular_cni_os_ceremony_spain_two
    end
    if %w(partner_british).exclude?(partner_nationality)
      phrases << :consular_cni_os_naturalisation
    end
    phrases << :consular_cni_os_all_depositing_certificate
    if %w(italy).include?(ceremony_country)
      phrases << :italy_os_consular_cni_five
    else
      phrases << :italy_os_consular_cni_six
    end
    if ceremony_country != residency_country or %w(germany).include?(ceremony_country) and %w(italy).exclude?(ceremony_country)
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
    if %w(italy).include?(ceremony_country)
      phrases << :italy_os_consular_cni_seven
    elsif %w(finland).include?(ceremony_country)
      phrases << :consular_cni_os_ceremony_finland
    elsif %w(turkey).include?(ceremony_country)
      phrases << :consular_cni_os_ceremony_turkey
    elsif %w(japan).include?(ceremony_country)
      phrases << :consular_cni_os_ceremony_japan
    end
    if %w(uk).include?(resident_of)
      phrases << :consular_cni_os_uk_resident
    end
    if %w(italy).include?(ceremony_country) and %w(uk).include?(resident_of)
      phrases << :consular_cni_os_fees_ceremony_italy_uk_resident
    else
      phrases << :consular_cni_os_fees_not_italy_not_uk
      if ceremony_country == residency_country or %w(uk).include?(resident_of)
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
    phrases
  end
end

outcome :outcome_os_affirmation do
  precalculate :affirmation_os_outcome do
    phrases = PhraseList.new
    if %w(uk).include?(resident_of)
      phrases << :affirmation_os_uk_resident
    elsif ceremony_country == residency_country
      phrases << :affirmation_os_local_resident
    elsif ceremony_country != residency_country and %w(uk).exclude?(resident_of)
      phrases << :affirmation_os_other_resident
    end
    phrases << :affirmation_os_all_what_you_need_to_do
    if %w(united-arab-emirates).include?(ceremony_country)
      phrases << :affirmation_os_uae
    end
    phrases << :affirmation_os_all_what_you_need_to_do_two
    if %w(partner_british).include?(partner_nationality)
      phrases << :affirmation_os_partner_british
    else
      phrases << :affirmation_os_partner_not_british
    end
    phrases << :affirmation_os_all_depositing_certificate
    if %w(uk).include?(resident_of)
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
      if %w(uk).include?(resident_of)
        phrases << :no_cni_os_dutch_caribbean_islands_uk_resident
      elsif ceremony_country == residency_country
        phrases << :no_cni_os_dutch_caribbean_islands_local_resident
      elsif ceremony_country != residency_country and %w(uk).exclude?(resident_of)
        phrases << :no_cni_os_dutch_caribbean_other_resident
      end
    else
      if %w(uk).include?(resident_of)
        phrases << :no_cni_os_not_dutch_caribbean_islands_uk_resident
      elsif ceremony_country == residency_country
        phrases << :no_cni_os_not_dutch_caribbean_islands_local_resident
      elsif ceremony_country != residency_country and %w(uk).exclude?(resident_of)
        phrases << :no_cni_os_not_dutch_caribbean_other_resident
      end
    end
    phrases << :no_cni_os_consular_facilities
    if %w(taiwan).exclude?(ceremony_country)
      phrases << :no_cni_os_all_nearest_embassy_not_taiwan
      phrases << :no_cni_os_all_depositing_certificate
      if %w(usa).include?(ceremony_country)
        phrases << :no_cni_os_ceremony_usa
      else
        phrases << :no_cni_os_ceremony_not_usa
      end
      if %w(uk).include?(resident_of)
        phrases << :no_cni_os_uk_resident_three
      end
      phrases << :no_cni_os_all_fees
      if %w(partner_british).exclude?(partner_nationality)
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
    if %w(burma).include?(ceremony_country)
      phrases << :other_countries_os_burma
      if %w(partner_local).include?(partner_nationality)
        phrases << :other_countries_os_burma_partner_local
      end
    elsif %w(north-korea).include?(ceremony_country)
      phrases << :other_countries_os_north_korea
      if %w(partner_local).include?(partner_nationality)
        phrases << :other_countries_os_north_korea_partner_local
      end
    elsif %w(iran somalia syria).include?(ceremony_country)
      phrases << :other_countries_os_iran_somalia_syria
    elsif %w(yemen).include?(ceremony_country)
      phrases << :other_countries_os_yemen
    end
    if %w(saudi-arabia).include?(ceremony_country)
      if ceremony_country != residency_country
        phrases << :other_countries_os_ceremony_saudia_arabia_not_local_resident
      else
        if %w(partner_irish).include?(partner_nationality)
          phrases << :other_countries_os_saudi_arabia_local_resident_partner_irish
        else
          phrases << :other_countries_os_saudi_arabia_local_resident_partner_not_irish
        end
        if %w(partner_irish partner_british).exclude?(partner_nationality)
          phrases << :other_countries_os_saudi_arabia_local_resident_partner_not_irish_or_british
        end
        if %w(partner_irish).exclude?(partner_nationality)
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
    if %w(czech-republic).include?(ceremony_country) and %w(partner_local).include?(partner_nationality)
      phrases << :cp_or_equivalent_cp_czech_republic_partner_local
    end
    if %w(uk).include?(resident_of)
      phrases << :cp_or_equivalent_cp_uk_resident
    elsif ceremony_country == residency_country
      phrases << :cp_or_equivalent_cp_local_resident
    elsif ceremony_country != residency_country and %w(uk).exclude?(resident_of)
      phrases << :cp_or_equivalent_cp_other_resident
    end
    phrases << :cp_or_equivalent_cp_all_what_you_need_to_do
    if %w(partner_british).exclude?(partner_nationality)
      phrases << :cp_or_equivalent_cp_naturalisation
    end
    phrases << :cp_or_equivalent_all_depositing_certificate
    if %w(uk).include?(resident_of)
      phrases << :cp_or_equivalent_cp_uk_resident_two
    end
    phrases << :cp_or_equivalent_cp_all_fees
    if %w(iceland luxembourg slovenia).include?(ceremony_country)
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
    if %w(usa).include?(ceremony_country)
      phrases << :no_cni_required_cp_ceremony_us
    end
    phrases << :no_cni_required_all_what_you_need_to_do
    if %w(bonaire-st-eustatius-saba).include?(ceremony_country)
      phrases << :no_cni_required_cp_dutch_islands
      if %w(uk).include?(resident_of)
        phrases << :no_cni_required_cp_dutch_islands_uk_resident
      elsif ceremony_country == residency_country
        phrases << :no_cni_required_cp_dutch_islands_local_resident
      elsif ceremony_country != residency_country and %w(uk).exclude?(resident_of)
        phrases << :no_cni_required_cp_dutch_islands_other_resident
      end
    else
      if %w(uk).include?(resident_of)
        phrases << :no_cni_required_cp_not_dutch_islands_uk_resident
      elsif ceremony_country == residency_country
        phrases << :no_cni_required_cp_not_dutch_islands_local_resident
      elsif ceremony_country != residency_country and %w(uk).exclude?(resident_of)
        phrases << :no_cni_required_cp_not_dutch_islands_other_resident
      end
    end
    phrases << :no_cni_required_cp_all_consular_facilities
    phrases << :no_cni_required_cp_all_depositing_certifictate
    if %w(usa).include?(ceremony_country)
      phrases << :no_cni_required_cp_ceremony_us_two
    else
      phrases << :no_cni_required_cp_ceremony_not_us
    end
    if %w(uk).include?(resident_of)
      phrases << :no_cni_required_cp_uk_resident_three
    end
    if %w(partner_british).exclude?(partner_nationality)
      phrases << :no_cni_required_cp_naturalisation
    end
    phrases << :no_cni_required_cp_all_fees
    phrases
  end
end

outcome :outcome_cp_commonwealth_countries do
  precalculate :commonwealth_countries_cp_outcome do
    phrases = PhraseList.new
    if %w(australia).include?(ceremony_country)
      phrases << :commonwealth_countries_cp_australia
    elsif %w(canada).include?(ceremony_country)
      phrases << :commonwealth_countries_cp_canada
    elsif %w(new-zealand).include?(ceremony_country)
      phrases << :commonwealth_countries_cp_new_zealand
    elsif %w(south-africa).include?(ceremony_country)
      phrases << :commonwealth_countries_cp_south_africa
    end
    if %w(australia).include?(ceremony_country)
      phrases << :commonwealth_countries_cp_australia_two
    end
    if %w(uk).include?(resident_of)
      phrases << :commonwealth_countries_cp_uk_resident_two
    elsif ceremony_country == residency_country
        phrases << :commonwealth_countries_cp_local_resident
    elsif ceremony_country != residency_country and %w(uk).exclude?(resident_of)
        phrases << :commonwealth_countries_cp_other_resident
    end
    if %w(australia).include?(ceremony_country)
      phrases << :commonwealth_countries_cp_australia_three
      phrases << :commonwealth_countries_cp_australia_four
      if %w(partner_local).include?(partner_nationality)
        phrases << :commonwealth_countries_cp_australia_partner_local
      elsif %w(partner_other).include?(partner_nationality)
        phrases << :commonwealth_countries_cp_australia_partner_other
      end
      phrases << :commonwealth_countries_cp_australia_five
    end
    phrases << :commonwealth_countries_cp_all_depositing_cp_certificate
    if %w(australia).exclude?(ceremony_country)
      phrases << :commonwealth_countries_cp_ceremony_not_australia
    end
    if %w(uk).include?(resident_of)
      phrases << :commonwealth_countries_cp_uk_resident_three
    end
    if %w(partner_british).exclude?(partner_nationality)
      phrases << :commonwealth_countries_cp_naturalisation
    end
    if %w(australia).include?(ceremony_country)
      phrases << :commonwealth_countries_cp_australia_six
    end
    phrases
  end
end

outcome :outcome_cp_consular_cni do
  precalculate :consular_cni_cp_outcome do
    phrases = PhraseList.new
    if %w(czech-republic).include?(ceremony_country)
      if %w(partner_local).exclude?(partner_nationality)
        phrases << :consular_cni_cp_ceremony_czech_republic_partner_not_local
      end
    else
      phrases << :consular_cni_cp_ceremony_not_czech_republic
    end
    if %w(vietnam).include?(ceremony_country) and %w(partner_local).include?(partner_nationality)
      phrases << :consular_cni_cp_ceremony_vietnam_partner_local
    elsif %w(croatia bulgaria).include?(ceremony_country) and %w(partner_local).include?(partner_nationality)
      phrases << :consular_cni_cp_local_partner_croatia_bulgaria
    elsif %w(japan).include?(ceremony_country)
      phrases << :consular_cni_cp_japan
    else
      phrases << :consular_cni_cp_all_contact
      if reg_data_query.clickbook(ceremony_country)
        if multiple_clickbooks
          phrases << :clickbook_links
        else
          phrases << :clickbook_link
        end
      end
    end
    unless reg_data_query.clickbook(ceremony_country)
      phrases << :consular_cni_cp_no_clickbook_so_embassy_details
    end
    phrases << :consular_cni_cp_all_documents
    if %w(partner_british).exclude?(partner_nationality)
      phrases << :consular_cni_cp_partner_not_british
    end
    phrases << :consular_cni_cp_all_what_you_need_to_do
    if %w(partner_british).exclude?(partner_nationality)
      phrases << :consular_cni_cp_naturalisation
    end
    phrases << :consular_cni_cp_all_fees
    if %w(cambodia latvia).include?(ceremony_country)
      phrases << :consular_cni_cp_local_currency
    else
      phrases << :consular_cni_cp_cheque
    end
    phrases
  end
end
outcome :outcome_cp_all_other_countries
