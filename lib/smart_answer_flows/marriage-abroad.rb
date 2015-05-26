# Abbreviations used in this smart answer:
# CNI - Certificate of No Impediment
# CI - Channel Islands
# CP - Civil Partnership
# FCO - Foreign & Commonwealth Office
# IOM - Isle Of Man
# OS - Opposite Sex
# SS - Same Sex

status :published
satisfies_need "101000"

data_query = SmartAnswer::Calculators::MarriageAbroadDataQuery.new
country_name_query = SmartAnswer::Calculators::CountryNameFormatter.new
reg_data_query = SmartAnswer::Calculators::RegistrationsDataQuery.new
exclude_countries = %w(holy-see british-antarctic-territory the-occupied-palestinian-territories)

# Q1
country_select :country_of_ceremony?, exclude_countries: exclude_countries do
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
      organisation.offices_with_service 'Registrations of Marriage and Civil Partnerships'
    else
      []
    end
  end

  calculate :marriage_and_partnership_phrases do
    if data_query.ss_marriage_countries?(ceremony_country) | data_query.ss_marriage_countries_when_couple_british?(ceremony_country)
      "ss_marriage"
    elsif data_query.ss_marriage_and_partnership?(ceremony_country)
      "ss_marriage_and_partnership"
    end
  end

  calculate :ceremony_country_name do
    location.name
  end

  calculate :country_name_lowercase_prefix do
    if country_name_query.class::COUNTRIES_WITH_DEFINITIVE_ARTICLES.include?(ceremony_country)
      country_name_query.definitive_article(ceremony_country)
    elsif country_name_query.class::FRIENDLY_COUNTRY_NAME.has_key?(ceremony_country)
      country_name_query.class::FRIENDLY_COUNTRY_NAME[ceremony_country]
    else
      ceremony_country_name
    end
  end

  calculate :country_name_uppercase_prefix do
    country_name_query.definitive_article(ceremony_country, true)
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

  calculate :embassy_or_consulate_ceremony_country do
    if reg_data_query.has_consulate?(ceremony_country) or reg_data_query.has_consulate_general?(ceremony_country)
      "consulate"
    else
      "embassy"
    end
  end

  next_node_if(:partner_opposite_or_same_sex?, responded_with('ireland'))
  next_node_if(:marriage_or_pacs?, responded_with(%w(france monaco new-caledonia wallis-and-futuna)))
  next_node_if(:outcome_os_france_or_fot, ->(response) { data_query.french_overseas_territories?(response)})
  next_node(:legal_residency?)
end

# Q2
multiple_choice :legal_residency? do
  option :uk
  option :ceremony_country
  option :third_country

  save_input_as :resident_of

  next_node_if(:partner_opposite_or_same_sex?, variable_matches(:ceremony_country, 'switzerland'))
  next_node_if(:residency_uk?, responded_with('uk'))
  next_node(:what_is_your_partners_nationality?)
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

  on_condition(responded_with(%w{uk_iom uk_ci})) do
    next_node_if(:what_is_your_partners_nationality?,
      -> {
        data_query.os_other_countries?(ceremony_country) ||
        data_query.ss_marriage_countries?(ceremony_country) ||
        data_query.ss_marriage_and_partnership?(ceremony_country) ||
        %w(portugal czech-republic).include?(ceremony_country)
      })
    next_node(:outcome_os_iom_ci)
  end
  next_node(:what_is_your_partners_nationality?)
end

# Q3b
multiple_choice :marriage_or_pacs? do
  option :marriage
  option :pacs
  save_input_as :marriage_or_pacs

  next_node_if(:outcome_monaco, variable_matches(:ceremony_country, "monaco"))
  next_node_if(:outcome_os_france_or_fot, responded_with('marriage'))
  next_node(:outcome_cp_france_pacs)
end

# Q4
multiple_choice :what_is_your_partners_nationality? do
  option :partner_british
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

  calculate :ceremony_type do |response|
    if response == 'opposite_sex'
      PhraseList.new(:ceremony_type_marriage)
    else
      PhraseList.new(:ceremony_type_civil_partnership)
    end
  end

  calculate :ceremony_type_lowercase do |response|
    if response == 'opposite_sex'
      "marriage"
    else
      "civil partnership"
    end
  end

  define_predicate(:ceremony_in_laos_partners_not_local) {
    (ceremony_country == "laos") & (partner_nationality != "partner_local")
  }

  define_predicate(:ceremony_in_finland_uk_resident) {
    (ceremony_country == "finland") & (resident_of == "uk")
  }

  define_predicate(:ceremony_in_mexico_partner_british_not_third_country) {
    ceremony_country == "mexico" and partner_nationality == "partner_british" and resident_of != 'third_country'
  }

  define_predicate(:ceremony_in_mexico_partner_british_residing_in_third_country) {
    ceremony_country == "mexico" and partner_nationality == "partner_british" and resident_of == 'third_country'
  }

  define_predicate(:ceremony_in_brazil_not_resident_in_the_uk) {
    (ceremony_country == 'brazil') & (resident_of != 'uk')
  }

  define_predicate(:os_marriage_with_local_in_japan) {
    ceremony_country == 'japan' and resident_of == 'ceremony_country' and partner_nationality == 'partner_local'
  }

  define_predicate(:consular_cni_residing_in_third_country) {
    resident_of == 'third_country' and data_query.os_consular_cni_countries?(ceremony_country)
  }

  next_node_if(:outcome_brazil_not_living_in_the_uk, ceremony_in_brazil_not_resident_in_the_uk)
  next_node_if(:outcome_netherlands, variable_matches(:ceremony_country, "netherlands"))
  next_node_if(:outcome_portugal, variable_matches(:ceremony_country, "portugal"))
  next_node_if(:outcome_ireland, variable_matches(:ceremony_country, "ireland"))
  next_node_if(:outcome_switzerland, variable_matches(:ceremony_country, "switzerland"))
  on_condition(responded_with('opposite_sex')) do
    next_node_if(:outcome_consular_cni_os_residing_in_third_country, consular_cni_residing_in_third_country)
    next_node_if(:outcome_consular_cni_os_residing_in_third_country, ceremony_in_mexico_partner_british_residing_in_third_country)
    next_node_if(:outcome_os_local_japan, os_marriage_with_local_in_japan)
    next_node_if(:outcome_os_colombia, variable_matches(:ceremony_country, "colombia"))
    next_node_if(:outcome_os_kosovo, variable_matches(:ceremony_country, "kosovo"))
    next_node_if(:outcome_os_indonesia, variable_matches(:ceremony_country, "indonesia"))
    next_node_if(:outcome_os_marriage_impossible_no_laos_locals, ceremony_in_laos_partners_not_local)
    next_node_if(:outcome_os_laos, variable_matches(:ceremony_country, "laos"))
    next_node_if(:outcome_os_consular_cni, -> {
      data_query.os_consular_cni_countries?(ceremony_country) or (resident_of == 'uk' and data_query.os_no_marriage_related_consular_services?(ceremony_country))
    })
    next_node_if(:outcome_os_consular_cni, ceremony_in_finland_uk_resident)
    next_node_if(:outcome_os_consular_cni, ceremony_in_mexico_partner_british_not_third_country)
    next_node_if(:outcome_os_affirmation, -> { data_query.os_affirmation_countries?(ceremony_country) })
    next_node_if(:outcome_os_commonwealth, -> { data_query.commonwealth_country?(ceremony_country) or ceremony_country == 'zimbabwe' })
    next_node_if(:outcome_os_bot, -> { data_query.british_overseas_territories?(ceremony_country) })
    next_node_if(:outcome_os_no_cni, -> {
      data_query.os_no_consular_cni_countries?(ceremony_country) or (resident_of != 'uk' and data_query.os_no_marriage_related_consular_services?(ceremony_country))
    })
    next_node_if(:outcome_os_other_countries, -> {
      data_query.os_other_countries?(ceremony_country)
    })
  end

  define_predicate(:ss_marriage_germany_partner_local?) {
    (ceremony_country == "germany") & (partner_nationality == "partner_local") & (ceremony_type != 'opposite_sex')
  }
  define_predicate(:ss_marriage_countries?) {
    data_query.ss_marriage_countries?(ceremony_country)
  }
  define_predicate(:ss_marriage_countries_when_couple_british?) {
    data_query.ss_marriage_countries_when_couple_british?(ceremony_country) & %w(partner_british).include?(partner_nationality)
  }
  define_predicate(:ss_marriage_and_partnership?) {
    data_query.ss_marriage_and_partnership?(ceremony_country)
  }

  define_predicate(:ss_marriage_not_possible?) {
    data_query.ss_marriage_not_possible?(ceremony_country, partner_nationality)
  }

  define_predicate(:ss_unknown_no_embassies) {
    data_query.ss_unknown_no_embassies?(ceremony_country)
  }

  next_node_if(:outcome_os_no_cni, ss_unknown_no_embassies)

  next_node_if(:outcome_ss_marriage_malta, -> {ceremony_country == "malta"})

  next_node_if(:outcome_ss_marriage_not_possible, ss_marriage_not_possible?)

  next_node_if(:outcome_cp_cp_or_equivalent, ss_marriage_germany_partner_local?)

  next_node_if(:outcome_ss_marriage,
    ss_marriage_countries? | ss_marriage_countries_when_couple_british? | ss_marriage_and_partnership?
  )

  next_node_if(:outcome_os_consular_cni, variable_matches(:ceremony_country, "spain"))

  next_node_if(:outcome_cp_cp_or_equivalent, -> {
    data_query.cp_equivalent_countries?(ceremony_country)
  })
  next_node_if(:outcome_cp_no_cni, -> {
    data_query.cp_cni_not_required_countries?(ceremony_country)
  })
  next_node_if(:outcome_cp_commonwealth_countries, -> {
    %w(canada new-zealand south-africa).include?(ceremony_country)
  })
  next_node_if(:outcome_cp_consular, -> {
    data_query.cp_consular_countries?(ceremony_country)
  })
  next_node(:outcome_cp_all_other_countries)
end

outcome :outcome_os_iom_ci do
  precalculate :iom_ci_os_outcome do
    phrases = PhraseList.new
    phrases << :contact_local_authorities_in_country_marriage
    phrases << :iom_ci_os_spain if ceremony_country == 'spain'
    if residency_uk_region == 'uk_iom'
      phrases << :iom_ci_os_resident_of_iom
    else
      phrases << :iom_ci_os_resident_of_ci
    end
    if ceremony_country == 'italy'
      phrases << :iom_ci_os_ceremony_italy
    else
      phrases << :embassies_data
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

outcome :outcome_switzerland do
  precalculate :switzerland_marriage_outcome do
    phrases = PhraseList.new
    if sex_of_your_partner == 'opposite_sex'
      phrases << :switzerland_os_variant
    else
      phrases << :switzerland_ss_variant
    end

    unless resident_of == 'ceremony_country'
      if resident_of == 'uk'
        phrases << :what_you_need_to_do_switzerland_resident_uk
      end
      phrases << :switzerland_not_resident
      phrases << :what_you_need_to_do
      if sex_of_your_partner == 'opposite_sex'
        phrases << :switzerland_os_not_resident
      else
        phrases << :switzerland_ss_not_resident
      end
      phrases << :switzerland_not_resident_two
    end
    phrases
  end
end

outcome :outcome_netherlands do
  precalculate :netherlands_phraselist do
    PhraseList.new(
      :contact_local_authorities,
      :get_legal_advice,
      :partner_naturalisation_in_uk
    )
  end
end

outcome :outcome_portugal do
  precalculate :portugal_phraselist do
    PhraseList.new(:contact_civil_register_office_portugal)
  end
  precalculate :portugal_title do
    phrases = PhraseList.new
    if sex_of_your_partner == 'opposite_sex'
      phrases << :marriage_title
    else
      phrases << :same_sex_marriage_title
    end
  end
end

outcome :outcome_os_indonesia do
  precalculate :indonesia_os_phraselist do
    PhraseList.new(
      :appointment_for_affidavit_indonesia,
      :embassies_data,
      :documents_for_divorced_or_widowed,
      :partner_affidavit_needed,
      :fee_table_45_70_55
    )
  end
end

outcome :outcome_os_laos do
  precalculate :laos_os_phraselist do
    phrases = PhraseList.new

    if resident_of == 'uk'
      phrases << :contact_embassy_of_ceremony_country_in_uk_marriage
    else
      phrases << :no_cni_os_not_dutch_caribbean_other_resident
    end

    phrases << :get_legal_and_travel_advice
    phrases << :what_you_need_to_do
    phrases << :what_to_do_laos
    phrases << :legalisation_and_translation
    phrases << :cni_os_partner_local_legislation_documents_for_appointment
    phrases << :affirmation_os_translation_in_local_language_text
    phrases << :docs_decree_and_death_certificate
    phrases << :divorced_or_widowed_evidences
    phrases << :change_of_name_evidence
    phrases << :consular_cni_os_all_names_but_germany
    phrases << :fee_table_affirmation_55
    phrases << :list_of_consular_fees
    phrases << :pay_by_cash_or_credit_card_no_cheque
    phrases << :partner_naturalisation_in_uk
  end
end

outcome :outcome_os_local_japan do
  precalculate :japan_os_local_phraselist do
    PhraseList.new(
      :contact_local_authorities_in_country_marriage,
      :japan_legal_advice,
      :what_you_need_to_do,
      :what_to_do_os_local_japan,
      :consular_cni_os_not_uk_resident_ceremony_not_germany,
      :what_happens_next_os_local_japan,
      :consular_cni_os_all_names_but_germany,
      :partner_naturalisation_in_uk,
      :fee_table_oath_declaration_55,
      :list_of_consular_fees,
      :payment_methods_japan
    )
  end
end

outcome :outcome_os_kosovo do
  precalculate :kosovo_os_phraselist do
    phrases = PhraseList.new
    if resident_of == 'uk'
      phrases << :kosovo_uk_resident
    else
      phrases << :kosovo_not_uk_resident
    end
  end
end

outcome :outcome_brazil_not_living_in_the_uk do
  precalculate :brazil_phraselist_not_in_the_uk do
    phrases = PhraseList.new
    if resident_of == 'ceremony_country'
      phrases << :contact_local_authorities << :get_legal_advice << :consular_cni_os_download_affidavit_notary_public << :notary_public_will_charge_a_fee << :consular_cni_os_all_names_but_germany << :partner_naturalisation_in_uk
    else
      phrases << :contact_local_authorities_in_country_marriage << :get_legal_and_travel_advice << :what_you_need_to_do << :make_an_appointment_bring_passport_and_pay_55_brazil << :list_of_consular_fees << :pay_by_cash_or_credit_card_no_cheque << :embassies_data << :download_affidavit_forms_but_do_not_sign << :download_affidavit_brazil << :documents_for_divorced_or_widowed << :affirmation_os_partner_not_british_turkey
    end
    phrases
  end
end

outcome :outcome_os_colombia do
  precalculate :colombia_os_phraselist do
    PhraseList.new(
      :contact_embassy_of_ceremony_country_in_uk_marriage,
      :get_legal_and_travel_advice,
      :what_you_need_to_do_affirmation,
      :make_an_appointment_bring_passport_and_pay_55_colombia,
      :list_of_consular_fees,
      :pay_by_cash_or_credit_card_no_cheque,
      :embassies_data,
      :legalisation_and_translation,
      :affirmation_os_translation_in_local_language_text,
      :documents_for_divorced_or_widowed_china_colombia,
      :change_of_name_evidence,
      :consular_cni_os_all_names_but_germany,
      :partner_naturalisation_in_uk
    )
  end
end

outcome :outcome_monaco do

  precalculate :monaco_title do
    phrases = PhraseList.new
    if marriage_or_pacs == 'marriage'
      phrases << "Marriage in Monaco"
    else
      phrases << "PACS in Monaco"
    end
    phrases
  end
  precalculate :monaco_phraselist do
    PhraseList.new(:"monaco_#{marriage_or_pacs}")
  end
end

outcome :outcome_os_commonwealth do
  precalculate :commonwealth_os_outcome do
    phrases = PhraseList.new

    if resident_of == 'uk'
      if ceremony_country == 'zimbabwe'
        phrases << :contact_zimbabwean_embassy_in_uk
      else
        phrases << :contact_high_comission_of_ceremony_country_in_uk
      end
    else
      phrases << :contact_local_authorities_in_country_marriage
    end

    if resident_of == 'ceremony_country'
      phrases << :get_legal_advice
    else
      phrases << :get_legal_and_travel_advice
    end

    if ceremony_country == 'zimbabwe'
      phrases << :commonwealth_os_all_cni_zimbabwe
    else
      phrases << :commonwealth_os_all_cni
    end

    case ceremony_country
    when 'south-africa'
      phrases << :commonwealth_os_other_countries_south_africa  if  partner_nationality == 'partner_local'
    when 'india'
      phrases << :commonwealth_os_other_countries_india
    when 'malaysia'
      phrases << :commonwealth_os_other_countries_malaysia
    when 'singapore'
      phrases << :commonwealth_os_other_countries_singapore
    when 'brunei'
      phrases << :commonwealth_os_other_countries_brunei
    when 'cyprus'
      phrases << :commonwealth_os_other_countries_cyprus if resident_of == 'ceremony_country'
    end
    phrases << :partner_naturalisation_in_uk unless partner_nationality == 'partner_british'
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
      phrases << :also_check_travel_advice unless resident_of == 'ceremony_country'
      phrases << :partner_naturalisation_in_uk unless partner_nationality == 'partner_british'
    end
    phrases
  end
end

outcome :outcome_consular_cni_os_residing_in_third_country do
  precalculate :current_path do
    (['/marriage-abroad/y'] + responses).join('/')
  end

  precalculate :uk_residence_outcome_path do
    current_path.gsub('third_country', 'uk/uk_england')
  end

  precalculate :ceremony_country_residence_outcome_path do
    current_path.gsub('third_country', 'ceremony_country')
  end

  precalculate :body do
    phrases = PhraseList.new
    phrases << :contact_local_authorities_in_country_marriage
    phrases << :get_legal_and_travel_advice
    phrases << :what_you_need_to_do
    phrases << :os_consular_cni_requirement
  end
end

outcome :outcome_os_consular_cni do
  precalculate :consular_cni_os_start do
    phrases = PhraseList.new

    cni_posted_after_7_days_countries = %w(albania algeria angola armenia austria azerbaijan bahrain bolivia bosnia-and-herzegovina bulgaria cambodia chile croatia cuba ecuador estonia georgia greece hong-kong iceland iran italy japan kazakhstan kuwait kyrgyzstan libya lithuania luxembourg macedonia mexico montenegro nicaragua norway poland russia spain sweden tajikistan tunisia turkmenistan ukraine uzbekistan venezuela)

    cni_notary_public_countries = %w(albania algeria angola armenia austria azerbaijan bahrain bolivia bosnia-and-herzegovina bulgaria croatia cuba estonia georgia greece iceland kazakhstan kuwait kyrgyzstan libya lithuania luxembourg mexico moldova montenegro norway poland russia serbia sweden tajikistan tunisia turkmenistan ukraine uzbekistan venezuela)

    no_document_download_link_if_os_resident_of_uk_countries = %w(albania algeria angola armenia austria azerbaijan bahrain bolivia bosnia-and-herzegovina bulgaria croatia cuba estonia georgia greece iceland italy japan kazakhstan kuwait kyrgyzstan libya lithuania luxembourg macedonia mexico moldova montenegro nicaragua norway poland russia spain serbia sweden tajikistan tunisia turkmenistan ukraine uzbekistan venezuela)

    cni_posted_after_14_days_countries = %w(oman jordan qatar saudi-arabia united-arab-emirates yemen)
    not_italy_or_spain = %w(italy spain).exclude?(ceremony_country)
    ceremony_not_germany_or_not_resident_other = (ceremony_country != 'germany' or resident_of == 'uk') # TODO verify this is ok
    ceremony_and_residency_in_croatia = (ceremony_country == 'croatia' and resident_of == 'ceremony_country')

    if ceremony_country == 'japan'
      phrases << :japan_intro
    end

    if %(japan italy).exclude?(ceremony_country)
      if resident_of == 'uk'
        if data_query.dutch_caribbean_islands?(ceremony_country)
          phrases << :contact_dutch_embassy_for_dutch_caribbean_islands
        else
          phrases << :contact_embassy_of_ceremony_country_in_uk_marriage
        end
      elsif resident_of == 'ceremony_country'
        phrases << :contact_local_authorities_in_country_marriage
      end
    end

    if %w(jordan oman qatar).include?(ceremony_country)
      phrases << :gulf_states_os_consular_cni
      if resident_of == 'ceremony_country'
        phrases << :gulf_states_os_consular_cni_local_resident
      end
    end

    if %(japan italy spain).exclude?(ceremony_country)
      if resident_of == 'ceremony_country'
        phrases << :get_legal_advice
      else
        phrases << :get_legal_and_travel_advice
      end
    end

    if ceremony_country == 'spain'
      if sex_of_your_partner == 'opposite_sex'
        phrases << :spain_os_consular_cni_opposite_sex
      else
        phrases << :spain_os_consular_cni_same_sex
      end
      phrases << :spain_os_consular_civil_registry
      phrases << :spain_os_consular_cni_not_local_resident unless resident_of == 'ceremony_country'
    elsif ceremony_country == 'italy'
      phrases << :italy_os_consular_cni_ceremony_italy
    end

    phrases << :what_you_need_to_do

    if ceremony_and_residency_in_croatia
      phrases << :what_to_do_croatia
    elsif ceremony_country == 'jordan'
      phrases << :consular_cni_os_foreign_resident_21_days_jordan
    elsif data_query.os_21_days_residency_required_countries?(ceremony_country)
      phrases << :consular_cni_os_ceremony_21_day_requirement
      phrases << :os_consular_cni_requirement
    elsif not_italy_or_spain && ceremony_not_germany_or_not_resident_other
      phrases << :os_consular_cni_requirement
    end

    if ceremony_country == 'spain'
      phrases << :spain_os_consular_cni_two
    elsif ceremony_country == 'italy'
      if resident_of == 'uk'
        phrases << :italy_os_consular_cni_uk_resident
      end
      if resident_of == 'uk' and partner_nationality == 'partner_british'
        phrases << :italy_os_consular_cni_uk_resident_two
      end
      if resident_of != 'uk'
        phrases << :italy_os_consular_cni_uk_resident_three
      end
    end

    if ceremony_country == 'denmark'
      phrases << :consular_cni_os_denmark
    elsif ceremony_country == 'germany' and resident_of != 'uk'
      phrases << :consular_cni_requirements_in_germany
    end

    if resident_of == 'uk'
      if cni_posted_after_14_days_countries.include?(ceremony_country)
        if cni_notary_public_countries.include?(ceremony_country) or ceremony_country == 'italy'
          phrases << :cni_posted_if_no_objection_14_days_notary_public
        else
          phrases << :cni_posted_if_no_objection_14_days
        end
      else
        if cni_notary_public_countries.include?(ceremony_country) or %w(italy japan macedonia spain).include?(ceremony_country)
          phrases << :cni_at_local_register_office_notary_public
        else
          phrases << :cni_at_local_register_office
        end
      end

      if ceremony_country == 'italy'
        phrases << :consular_cni_os_resident_in_uk_ceremony_in_italy
      end
    end

    if resident_of == 'uk'
      if ceremony_country == 'tunisia'
        phrases << :tunisia_legalisation_and_translation
      elsif ceremony_country == 'germany'
        phrases << :germany_legalisation_and_translation
      elsif ceremony_country == 'montenegro'
        phrases << :consular_cni_os_uk_resident_montenegro
      elsif %w(finland kazakhstan kyrgyzstan poland).include?(ceremony_country)
        phrases << :consular_cni_os_uk_legalisation_check_with_authorities
      elsif %w(italy portugal).exclude?(ceremony_country)
        phrases << :consular_cni_os_uk_resident_legalisation
      end

      if %w(germany italy portugal tunisia).exclude?(ceremony_country)
        phrases << :consular_cni_os_uk_resident_not_italy_or_portugal
      end
    end

    if resident_of == 'ceremony_country'

      if ceremony_country == 'croatia'
        phrases << :consular_cni_os_local_resident_table
      elsif %w(germany italy kazakhstan macedonia russia).exclude?(ceremony_country)
        phrases << :consular_cni_os_giving_notice_in_ceremony_country
      end

      phrases << :"#{ceremony_country}_os_local_resident" if %w(kazakhstan russia).include?(ceremony_country)
      unless %w(germany italy japan russia spain).include?(ceremony_country)
        if ceremony_country == 'macedonia'
          phrases << :consular_cni_os_foreign_resident_3_days_macedonia
        else
          phrases << :embassies_data
        end
      end
      phrases << :consular_cni_os_local_resident_italy if ceremony_country == 'italy'
    end

    if resident_of == 'ceremony_country' and %w(croatia germany italy japan spain russia).exclude?(ceremony_country) and cni_posted_after_7_days_countries.include?(ceremony_country)
      phrases << :living_in_ceremony_country_3_days
    end

    if ceremony_country == 'italy' and resident_of != 'uk'
      phrases << :consular_cni_variant_local_resident_italy
    elsif resident_of == 'ceremony_country' and %w(germany japan spain).exclude?(ceremony_country)
      if cni_notary_public_countries.include?(ceremony_country) or %w(japan macedonia spain).include?(ceremony_country)
        phrases << :consular_cni_variant_local_resident_or_foreign_resident_notary_public
      elsif ceremony_country == 'jordan'
        phrases << :consular_cni_variant_local_resident_jordan
      else
        phrases << :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident
      end
    end

    if resident_of == 'ceremony_country'
      if ceremony_country == 'japan'
        phrases << :japan_consular_cni_os_local_resident
        phrases << :japan_consular_cni_os_local_resident_partner_local if partner_nationality == 'partner_local'
      end
      if ceremony_country == 'italy'
        if partner_nationality == 'partner_local'
          phrases << :italy_consular_cni_os_partner_local
        elsif partner_nationality == 'partner_other'
          phrases << :italy_consular_cni_os_partner_other
        elsif partner_nationality == 'partner_british'
          phrases << :italy_consular_cni_os_partner_british
        end
      elsif ceremony_country == 'spain'
        phrases << :consular_cni_variant_local_resident_spain
      end
    end

    if resident_of != 'uk'
      if ceremony_country == 'jordan'
        phrases << :consular_cni_os_not_uk_resident_ceremony_jordan
      elsif ceremony_country != 'germany'
        phrases << :consular_cni_os_not_uk_resident_ceremony_not_germany
      end
    end

    if resident_of != 'uk'
      if ceremony_country == 'italy' and resident_of != 'uk'
        phrases << :consular_cni_os_other_resident_ceremony_italy
      elsif %w(germany spain).exclude?(ceremony_country)
        phrases << :consular_cni_os_other_resident_ceremony_not_germany_or_spain
      end
    end

    if resident_of == 'ceremony_country' and ceremony_country == 'spain'
      phrases << :spain_os_consular_cni_three
    end

    if ceremony_country == 'italy' and resident_of != 'uk'
      phrases << :wait_300_days_before_remarrying
    end

    if resident_of == 'ceremony_country'
      if %w(spain germany).exclude?(ceremony_country)
        phrases << :consular_cni_os_download_documents_notary_public
      end
    else
      uk_resident_with_os = sex_of_your_partner == 'opposite_sex' && resident_of == 'uk'
      uk_resident_os_no_docs = uk_resident_with_os && no_document_download_link_if_os_resident_of_uk_countries.include?(ceremony_country)
      if !uk_resident_os_no_docs && (cni_notary_public_countries + %w(italy japan macedonia spain) - %w(greece tunisia)).include?(ceremony_country)
        phrases << :consular_cni_os_download_documents_notary_public
      elsif resident_of != 'uk' && ceremony_country != 'germany'
        phrases << :consular_cni_os_download_documents_notary_public
      end
    end

    if resident_of == 'ceremony_country'
      if ceremony_country == 'kazakhstan'
        phrases << :display_notice_of_marriage_7_days
      elsif ceremony_country == 'greece'
        phrases << :consular_cni_os_foreign_resident_ceremony_notary_public_greece
      elsif cni_notary_public_countries.include?(ceremony_country) or ceremony_country == 'italy' or ceremony_country == 'japan'
        phrases << :consular_cni_os_foreign_resident_ceremony_notary_public
      elsif %w(germany spain).exclude?(ceremony_country)
        phrases << :display_notice_of_marriage_7_days
      end
    elsif data_query.requires_7_day_notice?(ceremony_country)
      phrases << :display_notice_of_marriage_7_days # TODO: the text refers to residency country
    end
    phrases
  end

  precalculate :consular_cni_os_remainder do
    phrases = PhraseList.new

    if ceremony_country != 'italy' and resident_of == 'uk' and "partner_other" == partner_nationality and "finland" == ceremony_country
      phrases << :callout_partner_equivalent_document
    end

    if partner_nationality == 'partner_british' and %w(italy germany finland).exclude?(ceremony_country)
      phrases << :consular_cni_os_local_resident_ceremony_not_italy_not_germany_partner_british
    end

    if ceremony_country != 'germany'  or (ceremony_country == 'germany' and resident_of == 'uk')
      phrases << :consular_cni_os_all_names_but_germany
    end

    if resident_of != 'uk' and %w(italy spain germany).exclude?(ceremony_country)
      phrases << :consular_cni_os_other_resident_ceremony_not_italy
    end

    if ceremony_country == 'belgium'
      phrases << :consular_cni_os_ceremony_belgium
    end

    if ceremony_country == 'spain'
      phrases << :consular_cni_os_ceremony_spain
      if partner_nationality == 'partner_british'
        phrases << :consular_cni_os_ceremony_spain_partner_british
      end
      phrases << :consular_cni_os_ceremony_spain_two
    end

    phrases << :partner_naturalisation_in_uk if partner_nationality != 'partner_british'

    if resident_of == 'ceremony_country'
      phrases << :no_need_to_stay_after_posting_notice
    end

    unless (ceremony_country == 'italy' and resident_of == 'uk')
      if ceremony_country == 'croatia' and resident_of == 'ceremony_country'
        phrases << :fee_table_croatia
      else
        phrases << :consular_cni_os_fees_not_italy_not_uk
      end

      unless data_query.countries_without_consular_facilities?(ceremony_country)
        if resident_of == 'ceremony_country' or resident_of == 'uk'
          if ceremony_country != 'cote-d-ivoire'
            if ceremony_country == 'monaco'
              phrases << :list_of_consular_fees_france
            elsif ceremony_country == 'kazakhstan'
              phrases << :list_of_consular_kazakhstan
            else
              phrases << :list_of_consular_fees
            end
          end
        else
          if ceremony_country == 'kazakhstan'
            phrases << :consular_cni_os_fees_foreign_commonwealth_roi_resident_kazakhstan
          else
            phrases << :consular_cni_os_fees_foreign_commonwealth_roi_resident
          end
        end
      end
    end

    unless data_query.countries_without_consular_facilities?(ceremony_country)
      if %w(armenia bosnia-and-herzegovina cambodia iceland kazakhstan latvia slovenia tunisia tajikistan).include?(ceremony_country)
        phrases << :pay_in_local_currency_ceremony_country_name
      elsif ceremony_country == 'luxembourg'
        phrases << :pay_in_cash_visa_or_mastercard
      elsif ceremony_country == 'russia'
        phrases << :consular_cni_os_fees_russia
      elsif ceremony_country == 'finland'
        phrases << :pay_in_euros_or_visa_electron
      elsif !%w(cote-d-ivoire burundi).include? ceremony_country
        phrases << :pay_by_cash_or_credit_card_no_cheque
      end
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
    if ceremony_country == 'colombia'
      phrases << :contact_embassy_of_ceremony_country_in_uk_marriage
      phrases << :get_legal_and_travel_advice
    else
      if resident_of == 'uk'
        phrases << :contact_embassy_of_ceremony_country_in_uk_marriage
        if ceremony_country == 'morocco'
          phrases << :contact_laadoul
        end
      elsif (resident_of == 'ceremony_country') or ceremony_country == 'qatar'
        phrases << :contact_local_authorities_in_country_marriage
        if ceremony_country == 'qatar'
          phrases << :gulf_states_os_consular_cni << :gulf_states_os_consular_cni_local_resident
        end
      elsif resident_of == 'third_country'
        phrases << :contact_nearest_embassy_or_consulate_of_ceremony_country
        if ceremony_country == 'morocco'
          phrases << :contact_laadoul
        end
      end

      if %w(cambodia ecuador).exclude?(ceremony_country)
        if resident_of == 'ceremony_country'
          phrases << :get_legal_advice
        else
          phrases << :get_legal_and_travel_advice
        end
      end

      phrases << :affirmation_os_uae if ceremony_country == 'united-arab-emirates'
    end
    #What you need to do section
    if %w(turkey egypt china).include?(ceremony_country)
      phrases << :what_you_need_to_do
    elsif data_query.os_21_days_residency_required_countries?(ceremony_country)
      phrases << :what_you_need_to_do_affirmation_21_days
    else
      phrases << :what_you_need_to_do_affirmation
    end

    if ceremony_country == 'turkey' and resident_of == 'uk'
      phrases << :appointment_for_affidavit_notary
    elsif ceremony_country == 'philippines'
      phrases << :contact_for_affidavit << :make_appointment_online_philippines
    elsif ceremony_country == 'egypt'
      phrases << :make_an_appointment
    elsif ceremony_country == 'china'
      prelude = "book_online_china_#{partner_nationality != 'partner_local' ? 'non_' : ''}local_prelude".to_sym
      phrases << prelude << :book_online_china_affirmation_affidavit
    else
      phrases << :appointment_for_affidavit
    end

    unless ceremony_country == 'turkey'
      phrases << :embassies_data
      if ceremony_country == 'cambodia'
        phrases << :cni_os_partner_local_legislation_documents_for_appointment
        phrases << :affirmation_os_translation_in_local_language_text
      elsif ceremony_country != 'china' and ceremony_country != 'egypt'
        phrases << :affirmation_os_translation_in_local_language_text
      end
    end
    phrases << :affirmation_os_download_affidavit_philippines if ceremony_country == 'philippines'

    if ceremony_country == 'turkey' and not resident_of == 'uk'
      phrases << :embassies_data
    end
    if ceremony_country == 'turkey'
      phrases << :complete_affidavit << :download_affidavit
      if resident_of == 'ceremony_country'
        phrases << :affirmation_os_legalised_in_turkey
      else
        phrases << :affirmation_os_legalised
      end
      phrases << :documents_for_divorced_or_widowed
    end

    if ceremony_country == 'morocco'
      phrases << :documents_for_divorced_or_widowed
    elsif ceremony_country == 'ecuador'
      phrases << :documents_for_divorced_or_widowed_ecuador
    elsif ceremony_country == 'cambodia'
      phrases << :documents_for_divorced_or_widowed_cambodia
      phrases << :change_of_name_evidence
    elsif %w(china colombia).include?(ceremony_country)
      phrases << :documents_for_divorced_or_widowed_china_colombia
    elsif ceremony_country != 'turkey'
      phrases << :docs_decree_and_death_certificate
    end

    if not %w(cambodia china colombia ecuador egypt morocco turkey).include?(ceremony_country)
      phrases << :divorced_or_widowed_evidences
    end
    if not %w(cambodia ecuador morocco turkey).include?(ceremony_country)
      phrases << :change_of_name_evidence
    end

    if ceremony_country == 'egypt'
      if partner_nationality == 'partner_british'
        phrases << :partner_declaration
      else
        phrases << :callout_partner_equivalent_document
      end
    end
    unless ceremony_country == 'egypt'
      if ceremony_country == 'turkey'
        if partner_nationality == 'partner_british'
          phrases << :affirmation_os_partner
        else
          phrases << :affirmation_os_partner_not_british_turkey
        end
      elsif ceremony_country == 'morocco'
        phrases << :morocco_affidavit_length
        phrases << :partner_equivalent_document
      else
        if partner_nationality == 'partner_british'
          phrases << :affirmation_os_partner_british
        else
          if ceremony_country == 'china' && partner_nationality != 'partner_local'
            phrases << :affirmation_affidavit_os_partner
          else
            phrases << :partner_equivalent_document_warning
            phrases << :consular_cni_os_all_names_but_germany if %w(ecuador colombia).include?(ceremony_country)
            phrases << :partner_naturalisation_in_uk
          end
        end
      end
    end
    phrases << :consular_cni_os_all_names_but_germany if ceremony_country == 'cambodia'

    #fee tables
    if %w(south-korea thailand turkey vietnam).include?(ceremony_country)
      phrases << :fee_table_affidavit_55
    elsif %w(cambodia ecuador morocco).include? ceremony_country
      phrases << :fee_table_affirmation_55
    elsif ceremony_country == 'finland'
      phrases << :fee_table_affirmation_65
    elsif ceremony_country == 'philippines'
      phrases << :fee_table_55_70
    elsif ceremony_country == 'qatar'
      phrases << :fee_table_45_70_55
    elsif ceremony_country == 'egypt'
      phrases << :fee_table_45_55
    else
      phrases << :affirmation_os_all_fees_45_70
    end
    unless data_query.countries_without_consular_facilities?(ceremony_country)

      if ceremony_country == 'monaco'
        phrases << :list_of_consular_fees_france
      elsif ceremony_country != 'cambodia'
        phrases << :list_of_consular_fees
      end

      if ceremony_country == 'finland'
        phrases << :pay_in_euros_or_visa_electron
      elsif ceremony_country == 'philippines'
        phrases << :pay_in_cash_or_manager_cheque
      elsif ceremony_country == 'cambodia'
        phrases << :pay_by_cash_or_us_dollars_only
      else
        phrases << :pay_by_cash_or_credit_card_no_cheque
      end
    end
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
      elsif resident_of == 'ceremony_country' # TODO: refactor to use the same phrase for local authorities.
        phrases << :contact_local_authorities_in_country_marriage
      elsif resident_of == 'third_country'
        phrases << :no_cni_os_dutch_caribbean_other_resident
      end
    else
      if resident_of == 'ceremony_country' or data_query.ss_unknown_no_embassies?(ceremony_country)
        phrases << :contact_local_authorities_in_country_marriage
      elsif resident_of == 'uk'
        phrases << :no_cni_os_not_dutch_caribbean_islands_uk_resident
      elsif resident_of == 'third_country'
        phrases << :no_cni_os_not_dutch_caribbean_other_resident
      end
    end

    if resident_of == 'ceremony_country'
      phrases << :get_legal_advice
    else
      phrases << :get_legal_and_travel_advice
    end

    phrases << :cni_os_consular_facilities_unavailable

    unless data_query.countries_without_consular_facilities?(ceremony_country)
      if ceremony_country == 'monaco'
        phrases << :list_of_consular_fees_france
      else
        phrases << :list_of_consular_fees
      end
      phrases << :pay_by_cash_or_credit_card_no_cheque
    end
    if partner_nationality != 'partner_british'
      phrases << :partner_naturalisation_in_uk
    end
    if data_query.requires_7_day_notice?(ceremony_country)
      phrases << :display_notice_of_marriage_7_days
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
    elsif %w(iran somalia syria).include?(ceremony_country)
      phrases << :other_countries_os_iran_somalia_syria
    elsif ceremony_country == 'yemen'
      phrases << :other_countries_os_yemen
    end
    if ceremony_country == 'saudi-arabia'
      if resident_of != 'ceremony_country'
        phrases << :other_countries_os_ceremony_saudia_arabia_not_local_resident
      else
        phrases << :other_countries_os_saudi_arabia_local_resident
        if partner_nationality != 'partner_british'
          phrases << :partner_naturalisation_in_uk
        end
        phrases << :other_countries_os_saudi_arabia_local_resident_two
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

    if ceremony_country == 'brazil' and sex_of_your_partner == 'same_sex' and resident_of != 'ceremony_country'
      phrases << :check_travel_advice
    elsif resident_of == 'uk'
      phrases << :contact_embassy_of_ceremony_country_in_uk_cp
    elsif resident_of == 'ceremony_country'
      phrases << :contact_local_authorities_in_country_cp
    elsif resident_of == 'third_country'
      phrases << :cp_or_equivalent_cp_other_resident
    end

    if resident_of != 'ceremony_country' and ceremony_country != 'brazil'
      phrases << :also_check_travel_advice
    end

    unless ceremony_country == 'czech-republic' and sex_of_your_partner == 'same_sex'
      if ceremony_country == 'brazil' and sex_of_your_partner == 'same_sex' and resident_of == 'uk'
        phrases << :what_you_need_to_do_cni << :get_cni_at_registrar_in_uk << :consular_cni_os_uk_resident_legalisation << :consular_cni_os_uk_resident_not_italy_or_portugal << :consular_cni_os_all_names_but_germany
      else
        phrases << :cp_or_equivalent_cp_all_what_you_need_to_do
      end
    end
    if partner_nationality != 'partner_british'
      phrases << :partner_naturalisation_in_uk
    end
    unless ceremony_country == 'czech-republic' and sex_of_your_partner == 'same_sex'
      phrases << :cp_or_equivalent_cp_all_fees
    end

    unless (ceremony_country == 'czech-republic' or data_query.countries_without_consular_facilities?(ceremony_country))
      if ceremony_country == 'monaco'
        phrases << :list_of_consular_fees_france
      else
        phrases << :list_of_consular_fees
      end
    end
    if %w(iceland slovenia).include?(ceremony_country)
      phrases << :pay_in_local_currency
    elsif ceremony_country == 'luxembourg'
      phrases << :pay_in_cash_visa_or_mastercard
    elsif %w(czech-republic cote-d-ivoire).exclude?(ceremony_country)
      phrases << :pay_by_cash_or_credit_card_no_cheque
    end
    phrases
  end
end
outcome :outcome_cp_france_pacs do
  precalculate :france_pacs_law_cp_outcome do
    PhraseList.new(:fot_cp_all) if %w(new-caledonia wallis-and-futuna).include?(ceremony_country)
  end
end

outcome :outcome_cp_no_cni do
  precalculate :no_cni_required_cp_outcome do
    phrases = PhraseList.new
    phrases << :"no_cni_required_cp_#{ceremony_country}" if data_query.cp_cni_not_required_countries?(ceremony_country)
    phrases << :get_legal_advice
    phrases << :no_cni_required_cp_ceremony_us if ceremony_country == 'usa'
    phrases << :what_you_need_to_do
    if ceremony_country == 'bonaire-st-eustatius-saba'
      phrases << :no_cni_required_cp_dutch_islands
      if resident_of == 'uk'
        phrases << :no_cni_required_cp_dutch_islands_uk_resident
      elsif resident_of == 'ceremony_country'
        phrases << :contact_local_authorities_in_country_cp
      elsif resident_of == 'third_country'
        phrases << :no_cni_required_cp_dutch_islands_other_resident
      end
    else
      if resident_of == 'uk'
        phrases << :no_cni_required_cp_not_dutch_islands_uk_resident
      elsif resident_of == 'ceremony_country'
        phrases << :contact_local_authorities_in_country_cp
      elsif resident_of == 'third_country'
        phrases << :no_cni_required_cp_not_dutch_islands_other_resident
      end
    end
    phrases << :no_cni_required_cp_all_consular_facilities
    phrases << :partner_naturalisation_in_uk if partner_nationality != 'partner_british'
    phrases
  end
end

outcome :outcome_cp_commonwealth_countries do

  precalculate :type_of_ceremony do
    phrases = PhraseList.new
    if ceremony_country == 'new-zealand'
      phrases << :title_ss_marriage_and_partnership
    else
      phrases << :title_civil_partnership
    end
  end

  precalculate :commonwealth_countries_cp_outcome do
    phrases = PhraseList.new
    if ceremony_country == 'australia'
      phrases << :commonwealth_countries_cp_australia
    elsif ceremony_country == 'canada'
      phrases << :commonwealth_countries_cp_canada
    elsif ceremony_country == 'new-zealand'
      phrases << :commonwealth_countries_cp_new_zealand
    elsif ceremony_country == 'south-africa'
      phrases << :commonwealth_countries_cp_south_africa
    end
    phrases << :commonwealth_countries_cp_australia_two if ceremony_country == 'australia'

    if resident_of == 'uk'
      phrases << :commonwealth_countries_cp_uk_resident_two
    elsif resident_of == 'ceremony_country'
      phrases << :commonwealth_countries_cp_local_resident
    elsif resident_of == 'third_country'
      phrases << :commonwealth_countries_cp_other_resident
    end

    if ceremony_country == 'australia'
      phrases << :commonwealth_countries_cp_australia_three
      phrases << :commonwealth_countries_cp_australia_four
      if partner_nationality == 'partner_local'
        phrases << :commonwealth_countries_cp_australia_partner_local
      elsif partner_nationality == 'partner_other'
        phrases << :commonwealth_countries_cp_australia_partner_other
      end
      phrases << :commonwealth_countries_cp_australia_five
    end
    phrases << :embassies_data unless ceremony_country == 'australia'

    if ceremony_country == 'new-zealand'
      phrases << :commonwealth_os_all_cni
    end
    phrases << :partner_naturalisation_in_uk if partner_nationality != 'partner_british'
    phrases << :commonwealth_countries_cp_australia_six if ceremony_country == 'australia'
    phrases
  end
end

outcome :outcome_cp_consular do
  precalculate :consular_cp_outcome do
    phrases = PhraseList.new
    # cyprus is a country with a high commission. This is why some of its phraselists end with 'hc', we need to refer to High Commission instead Embassy or Consulate.
    # The logic behind it could be made prettier by creating a group of High Commission Countries or by querying the API and checking whether the country has a High Commission, a consulate, an embassy or something else.
    # I am not going to do any of that because Marriage Abroad will (Should) be rebuilt soon, is better to keep the logic as much explicit as possible.

    if ceremony_country == 'cyprus'
      phrases << :consular_cp_ceremony_hc
    else
      phrases << :consular_cp_ceremony
    end
    if ceremony_country == 'vietnam'
      phrases << :consular_cp_ceremony_vietnam_partner_local if partner_nationality == 'partner_local'
      phrases << :consular_cp_vietnam
    elsif %w(croatia bulgaria).include?(ceremony_country) and partner_nationality == 'partner_local'
      phrases << :consular_cp_local_partner_croatia_bulgaria
    elsif ceremony_country == 'japan'
      phrases << :consular_cp_all_contact << :embassies_data << :documents_needed_21_days_residency << :documents_needed_ss_british
    else
      phrases << :consular_cp_all_contact
    end
    phrases << :embassies_data
    unless ceremony_country == 'japan'
      if ceremony_country == 'cyprus'
        phrases << :documents_needed_7_days_residency_hc
      elsif data_query.ss_21_days_residency_required_countries?(ceremony_country)
        phrases << :documents_needed_21_days_residency
      else
        phrases << :documents_needed_7_days_residency
      end
    end
    phrases << :consular_cp_all_documents
    phrases << :consular_cp_partner_not_british if partner_nationality != 'partner_british'
    if ceremony_country == 'cyprus'
      phrases << :consular_cp_all_what_you_need_to_do_hc
    else
      phrases << :consular_cp_all_what_you_need_to_do
    end
    phrases << :partner_naturalisation_in_uk unless partner_nationality == 'partner_british'
    if %w(vietnam thailand south-korea).include?(ceremony_country)
      phrases << :fee_table_affidavit_55
    else
      phrases << :consular_cp_all_fees
    end
    if %w(cambodia latvia).include?(ceremony_country)
      phrases << :pay_in_local_currency
    else
      phrases << :pay_by_cash_or_credit_card_no_cheque
    end
    phrases
  end
end

outcome :outcome_cp_all_other_countries

outcome :outcome_ss_marriage do
  precalculate :ss_title do
    PhraseList.new(:"title_#{marriage_and_partnership_phrases}")
  end

  precalculate :ss_fees_table do
    if data_query.ss_alt_fees_table_country?(ceremony_country, partner_nationality)
      :"#{marriage_and_partnership_phrases}_alt"
    else
      :"#{marriage_and_partnership_phrases}"
    end
  end

  precalculate :ss_ceremony_body do
    phrases = PhraseList.new
    phrases << :"able_to_#{marriage_and_partnership_phrases}"

    if ceremony_country == 'japan'
      phrases << :consular_cp_all_contact << :embassies_data << :documents_needed_21_days_residency << :documents_needed_ss_british
    elsif ceremony_country == 'albania'
      phrases << :appointment_booking_link_albania
    elsif ceremony_country == 'germany'
      phrases << :contact_british_embassy_or_consulate_berlin << :embassies_data
    else
      phrases << :contact_embassy_or_consulate << :embassies_data
    end

    unless ceremony_country == 'japan'
      if data_query.ss_21_days_residency_required_countries?(ceremony_country)
        phrases << :documents_needed_21_days_residency
      else
        phrases << :documents_needed_7_days_residency
      end
      if partner_nationality == 'partner_british'
        phrases << :documents_needed_ss_british
      elsif ceremony_country == 'germany'
        phrases << :documents_needed_ss_not_british_germany_same_sex
      else
        phrases << :documents_needed_ss_not_british
      end
    end
    phrases << :"what_to_do_#{marriage_and_partnership_phrases}" << :will_display_in_14_days << :"no_objection_in_14_days_#{marriage_and_partnership_phrases}" << :"provide_two_witnesses_#{marriage_and_partnership_phrases}"
    phrases << :australia_ss_relationships if ceremony_country == 'australia'
    if data_query.ss_21_days_residency_required_countries?(ceremony_country)
      phrases << :ss_marriage_footnote_21_days_residency
    else
      phrases << :ss_marriage_footnote
    end
    phrases << :partner_naturalisation_in_uk << :"fees_table_#{ss_fees_table}"

    if ceremony_country == 'cambodia'
      phrases << :pay_by_cash_or_us_dollars_only
    else
      phrases << :list_of_consular_fees << :pay_by_cash_or_credit_card_no_cheque
    end

    phrases << :convert_cc_to_ss_marriage if %w{albania australia germany japan philippines russia serbia vietnam}.include?(ceremony_country)
    phrases
  end
end

outcome :outcome_ss_marriage_not_possible
outcome :outcome_ss_marriage_malta do
  precalculate :ss_body do
    PhraseList.new(:able_to_ss_marriage_and_partnership_hc, :consular_cp_all_contact, :embassies_data, :documents_needed_21_days_residency, :documents_needed_ss_british, :what_to_do_ss_marriage_and_partnership_hc, :will_display_in_14_days_hc, :no_objection_in_14_days_ss_marriage_and_partnership, :provide_two_witnesses_ss_marriage_and_partnership, :ss_marriage_footnote_hc, :partner_naturalisation_in_uk, :fees_table_ss_marriage_and_partnership, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque, :convert_cc_to_ss_marriage)
  end
end
outcome :outcome_os_marriage_impossible_no_laos_locals
