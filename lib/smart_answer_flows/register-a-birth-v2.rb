status :draft
satisfies_need "101003"

country_name_query = SmartAnswer::Calculators::CountryNameFormatter.new
reg_data_query = SmartAnswer::Calculators::RegistrationsDataQueryV2.new
translator_query = SmartAnswer::Calculators::TranslatorLinksV2.new
country_has_no_embassy = SmartAnswer::Predicate::RespondedWith.new(%w(iran syria yemen))
exclude_countries = %w(holy-see british-antarctic-territory)

# Q1
country_select :country_of_birth?, exclude_countries: exclude_countries do
  save_input_as :country_of_birth

  calculate :registration_country do
    reg_data_query.registration_country_slug(responses.last)
  end

  calculate :registration_country_name_lowercase_prefix do
    country_name_query.definitive_article(registration_country)
  end

  calculate :birth_registration_form do
    if %w(usa).include?(country_of_birth)
      PhraseList.new(:"birth_registration_form_#{country_of_birth}")
    else
      PhraseList.new(:birth_registration_form)
    end
  end

  next_node_if(:no_embassy_result, country_has_no_embassy)
  next_node_if(:commonwealth_result, reg_data_query.responded_with_commonwealth_country?)
  next_node(:who_has_british_nationality?)
end

# Q2
multiple_choice :who_has_british_nationality? do
  option mother: :married_couple_or_civil_partnership?
  option father: :married_couple_or_civil_partnership?
  option mother_and_father: :married_couple_or_civil_partnership?
  option neither: :no_registration_result

  calculate :british_national_parent do
    if country_of_birth == 'sweden'
      'mother_and_father'
    else
      responses.last
    end
  end
end

# Q3
multiple_choice :married_couple_or_civil_partnership? do
  option :yes
  option :no

  calculate :paternity_declaration do
    responses.last == 'no'
  end

  next_node_if(:childs_date_of_birth?, responded_with('no'), variable_matches(:british_national_parent, 'father'))
  next_node_if(:childs_date_of_birth?, variable_matches(:country_of_birth, 'sweden') | (responded_with('no') & variable_matches(:british_national_parent, 'father')))
  next_node(:where_are_you_now?)
end

# Q4
date_question :childs_date_of_birth? do
  from { Date.today }
  to { 50.years.ago(Date.today) }

  before_july_2006 = SmartAnswer::Predicate::Callable.new("before 1 July 2006") do |response|
    Date.new(2006, 07, 01) > Date.parse(response)
  end

  next_node_if(:homeoffice_result, before_july_2006)

  next_node(:where_are_you_now?)
end

# Q5
multiple_choice :where_are_you_now? do
  option :same_country
  option another_country: :which_country?
  option :in_the_uk

  calculate :another_country do
    responses.last == 'another_country'
  end

  calculate :in_the_uk do
    responses.last == 'in_the_uk'
  end

  on_condition(->(_) { reg_data_query.class::ORU_TRANSITION_EXCEPTIONS.include?(country_of_birth) }) do
    next_node_if(:embassy_result, responded_with('same_country'))
  end

  next_node_if(:oru_result, reg_data_query.born_in_oru_transitioned_country? | responded_with('in_the_uk'))
  next_node_if(:embassy_result, responded_with('same_country'))
  next_node(:which_country?)
end

# Q6
country_select :which_country?, exclude_countries: exclude_countries do
  calculate :registration_country do
    reg_data_query.registration_country_slug(responses.last)
  end

  calculate :registration_country_name_lowercase_prefix do
    country_name_query.definitive_article(registration_country)
  end

  next_node_if(:oru_result, reg_data_query.born_in_oru_transitioned_country?)
  next_node_if(:no_embassy_result, country_has_no_embassy)
  next_node(:embassy_result)
end

# Outcomes
outcome :embassy_result do
  precalculate :embassy_high_commission_or_consulate do
    if reg_data_query.has_high_commission?(registration_country)
      "British high commission"
    elsif reg_data_query.has_consulate?(registration_country)
      "British consulate"
    elsif reg_data_query.has_trade_and_cultural_office?(registration_country)
      "British Trade & Cultural Office"
    elsif reg_data_query.has_consulate_general?(registration_country)
      "British consulate general"
    else
      "British embassy"
    end
  end
  precalculate :documents_you_must_provide do
    checklist_countries = %w(bangladesh kuwait libya north-korea pakistan philippines turkey)
    key = "documents_you_must_provide_"
    if checklist_countries.include?(country_of_birth)
      key << country_of_birth
    else
      key << "all"
    end
    PhraseList.new(key.to_sym)
  end

  precalculate :fees_for_consular_services do
    phrases = PhraseList.new
    if registration_country == 'libya'
      phrases << :consular_service_fees_libya
    else
      phrases << :consular_service_fees
    end
    phrases
  end
  precalculate :go_to_the_embassy_heading do
    unless reg_data_query.post_only_countries?(registration_country)
      PhraseList.new(:go_to_the_embassy_heading_text)
    end
  end
  precalculate :go_to_the_embassy do
    unless reg_data_query.post_only_countries?(registration_country)
      phrases = PhraseList.new
      if %w(hong-kong japan).include?(registration_country)
        phrases << :"registering_#{registration_country}"
      else
        phrases << :registering_all
      end
      phrases << (paternity_declaration ? :registering_paternity_declaration : :registering_either_parent)
      phrases
    end
  end

  precalculate :postal_form_url do
    reg_data_query.postal_form(registration_country)
  end

  precalculate :postal do
    if reg_data_query.modified_card_only_countries?(registration_country)
      PhraseList.new(:post_only_pay_by_card_countries)
    elsif reg_data_query.post_only_countries?(registration_country)
      PhraseList.new(:"post_only_#{registration_country}")
    elsif postal_form_url
      PhraseList.new(:postal_form)
    elsif reg_data_query.class::NO_POSTAL_COUNTRIES.include?(registration_country)
      PhraseList.new(:postal_info, :"postal_info_#{registration_country}")
    else
      ''
    end
  end

  precalculate :postal_return_form_url do
    reg_data_query.postal_return_form(registration_country)
  end
  precalculate :postal_return do
    if postal_return_form_url
      PhraseList.new(:postal_form_return)
    end
  end

  precalculate :location do
    loc = WorldLocation.find(registration_country)
    raise InvalidResponse unless loc
    loc
  end

  precalculate :organisations do
    [location.fco_organisation]
  end

  precalculate :overseas_passports_embassies do
    if organisations and organisations.any?
      service_title = 'Births and Deaths registration service'
      organisations.first.offices_with_service(service_title)
    else
      []
    end
  end

  precalculate :cash_only do
    if reg_data_query.pay_by_bank_draft?(registration_country)
      PhraseList.new(:pay_by_bank_draft)
    elsif reg_data_query.cash_only?(registration_country)
      PhraseList.new(:cash_only)
    elsif reg_data_query.cash_and_card_only?(registration_country)
      PhraseList.new(:cash_and_card)
    else
      ''
    end
  end
  precalculate :footnote do
    if reg_data_query.class::FOOTNOTE_EXCLUSIONS.include?(country_of_birth)
      phrases = PhraseList.new(:footnote_exceptions)
      phrases << :"footnote_oru_variants_#{registration_country}" if reg_data_query.class::ORU_TRANSITION_EXCEPTIONS.include?(registration_country)
      phrases
    elsif country_of_birth != registration_country and reg_data_query.eastern_caribbean_countries?(registration_country) and reg_data_query.eastern_caribbean_countries?(country_of_birth)
      PhraseList.new(:footnote_caribbean)
    elsif reg_data_query.class::ORU_COURIER_VARIANTS.include?(registration_country) and ! reg_data_query.class::ORU_COURIER_VARIANTS.include?(country_of_birth)
      PhraseList.new(:footnote_oru_variants_intro,
                      :"footnote_oru_variants_#{registration_country}",
                      :footnote_oru_variants_out)
    elsif another_country
      PhraseList.new(:footnote_another_country)
    else
      PhraseList.new(:footnote)
    end
  end
end

outcome :oru_result do

  precalculate :button_data do
    {text: "Pay now", url: "https://pay-register-birth-abroad.service.gov.uk/start"}
  end

  precalculate :embassy_result_indonesia_british_father_paternity do
    if registration_country == 'indonesia' and british_national_parent == 'father' and paternity_declaration
      PhraseList.new(:indonesia_british_father_paternity)
    end
  end

  precalculate :waiting_time do
    phrases = PhraseList.new
    if reg_data_query.class::ORU_TRANSITIONED_COUNTRIES.exclude?(country_of_birth) && in_the_uk
      phrases << :registration_can_take_3_months
    else
      phrases << :registration_takes_5_days
    end
    phrases
  end

  precalculate :oru_documents_variant do
    if reg_data_query.class::ORU_DOCUMENTS_VARIANT_COUNTRIES.include?(country_of_birth)
      phrases = PhraseList.new
      if country_of_birth == 'united-arab-emirates' && paternity_declaration
        phrases << :oru_documents_variant_uae_not_married
      else
        phrases << :"oru_documents_variant_#{country_of_birth}"
      end
      phrases
    else
      PhraseList.new(:oru_documents)
    end
  end

  precalculate :translator_link_url do
    translator_query.links[country_of_birth]
  end

  precalculate :translator_link do
    if translator_link_url
      PhraseList.new(:approved_translator_link)
    else
      PhraseList.new(:no_translator_link)
    end
  end

  precalculate :oru_address do
    if in_the_uk
      PhraseList.new(:oru_address_uk)
    else
      PhraseList.new(:oru_address_abroad)
    end
  end

  precalculate :oru_courier_text do
    phrases = PhraseList.new
    if reg_data_query.class::ORU_COURIER_VARIANTS.include?(registration_country) && !in_the_uk
      phrases << :"oru_courier_text_#{registration_country}" << :oru_courier_text_common
    else
      phrases << :oru_courier_text_default
    end
    phrases
  end
end

outcome :commonwealth_result
outcome :no_registration_result
outcome :no_embassy_result
outcome :homeoffice_result
