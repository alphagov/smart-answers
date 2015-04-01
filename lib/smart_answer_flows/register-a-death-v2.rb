status :draft
satisfies_need "101006"

country_name_query = SmartAnswer::Calculators::CountryNameFormatter.new
reg_data_query = SmartAnswer::Calculators::RegistrationsDataQueryV2.new
translator_query = SmartAnswer::Calculators::TranslatorLinksV2.new
country_has_no_embassy = SmartAnswer::Predicate::RespondedWith.new(%w(iran syria yemen))
exclude_countries = %w(holy-see british-antarctic-territory)
modified_card_only_countries = %w(czech-republic slovakia hungary poland switzerland)

# Q1
multiple_choice :where_did_the_death_happen? do
  save_input_as :where_death_happened
  option england_wales: :did_the_person_die_at_home_hospital?
  option scotland: :did_the_person_die_at_home_hospital?
  option northern_ireland: :did_the_person_die_at_home_hospital?
  option overseas: :which_country?
end

# Q2
multiple_choice :did_the_person_die_at_home_hospital? do
  option :at_home_hospital
  option :elsewhere
  calculate :died_at_home_hospital do
    responses.last == 'at_home_hospital'
  end
  next_node :was_death_expected?
end

# Q3
multiple_choice :was_death_expected? do
  option :yes
  option :no

  calculate :death_expected do
    responses.last == 'yes'
  end

  next_node :uk_result
end

# Q4
country_select :which_country?, exclude_countries: exclude_countries do
  save_input_as :country_of_death

  calculate :current_location do
    reg_data_query.registration_country_slug(responses.last) || responses.last
  end

  calculate :current_location_name_lowercase_prefix do
    country_name_query.definitive_article(country_of_death)
  end

  calculate :death_country_name_lowercase_prefix do
    current_location_name_lowercase_prefix
  end

  next_node_if(:commonwealth_result, reg_data_query.responded_with_commonwealth_country?)
  next_node_if(:no_embassy_result, country_has_no_embassy)
  next_node(:where_are_you_now?)
end

# Q5
multiple_choice :where_are_you_now? do
  option :same_country
  option another_country: :which_country_are_you_in_now?
  option :in_the_uk

  calculate :another_country do
    responses.last == 'another_country'
  end

  calculate :in_the_uk do
    responses.last == 'in_the_uk'
  end

  on_condition(->(_) { reg_data_query.class::ORU_TRANSITION_EXCEPTIONS.include?(country_of_death) }) do
    next_node_if(:embassy_result, responded_with('same_country'))
  end

  next_node_if(:oru_result, reg_data_query.died_in_oru_transitioned_country? | responded_with('in_the_uk'))
  next_node_if(:embassy_result, responded_with('same_country'))
  next_node(:which_country_are_you_in_now?)
end

# Q6
country_select :which_country_are_you_in_now?, exclude_countries: exclude_countries do
  calculate :current_location do
    reg_data_query.registration_country_slug(responses.last) || responses.last
  end

  calculate :current_location_name_lowercase_prefix do
    country_name_query.definitive_article(current_location)
  end

  next_node_if(:oru_result, reg_data_query.died_in_oru_transitioned_country?)
  next_node :embassy_result
end

outcome :commonwealth_result
outcome :no_embassy_result

outcome :uk_result do
  precalculate :content_sections do
    sections = PhraseList.new
    if where_death_happened == 'england_wales'
      sections << :intro_ew << :who_can_register
      sections << (died_at_home_hospital ? :who_can_register_home_hospital : :who_can_register_elsewhere)
      sections << :"what_you_need_to_do_#{death_expected ? :expected : :unexpected}"
      sections << :need_to_tell_registrar
      sections << :"documents_youll_get_ew_#{death_expected ? :expected : :unexpected}"
    else
      sections << :"intro_#{where_death_happened}"
    end
    sections
  end
end

outcome :oru_result do
  precalculate :button_data do
    {text: "Pay now", url: "https://pay-register-death-abroad.service.gov.uk/start"}
  end

  precalculate :translator_link_url do
    translator_query.links[country_of_death]
  end

  precalculate :translator_link do
    if translator_link_url
      PhraseList.new(:approved_translator_link)
    else
      PhraseList.new(:no_translator_link)
    end
  end

  precalculate :waiting_time do
    phrases = PhraseList.new
    if reg_data_query.class::ORU_TRANSITIONED_COUNTRIES.exclude?(country_of_death) && in_the_uk
      phrases << :registration_can_take_3_months
    else
      phrases << :registration_takes_3_days
    end
    phrases
  end

  precalculate :oru_documents_variant_death do
    if reg_data_query.class::ORU_DOCUMENTS_VARIANT_COUNTRIES_DEATH.include?(country_of_death)
      PhraseList.new(:"oru_documents_variant_#{country_of_death}")
    else
      PhraseList.new(:oru_documents_death)
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
    if reg_data_query.class::ORU_COURIER_VARIANTS.include?(current_location)
      if current_location == 'cameroon'
        phrases << :oru_courier_text_cameroon
      else
        phrases << :"oru_courier_text_#{current_location}" << :oru_courier_text_common
      end
    else
      phrases << :oru_courier_text_default
    end
    phrases
  end

  precalculate :payment_method do
    if !in_the_uk && current_location == 'algeria'
      PhraseList.new(:payment_method_in_algeria)
    else
      PhraseList.new(:standard_payment_method)
    end
  end
end

outcome :embassy_result do
  precalculate :documents_required_embassy_result do
    phrases = PhraseList.new
    if country_of_death == 'libya'
      phrases << :documents_list_embassy_libya
    elsif country_of_death == 'north-korea'
      phrases << :"documents_list_embassy_north-korea"
    else
      phrases << :documents_list_embassy
    end
    phrases
  end

  precalculate :embassy_high_commission_or_consulate do
    if reg_data_query.has_high_commission?(current_location)
      "British high commission"
    elsif reg_data_query.has_consulate?(current_location)
      "British embassy or consulate"
    elsif reg_data_query.has_trade_and_cultural_office?(current_location)
      "British Trade & Cultural Office"
    elsif reg_data_query.has_consulate_general?(current_location)
      "British consulate general"
    else
      "British embassy"
    end
  end

  precalculate :go_to_the_embassy_heading do
    unless reg_data_query.post_only_countries?(current_location)
      PhraseList.new(:go_to_the_embassy_heading_text)
    end
  end
  precalculate :booking_text_embassy_result do
    unless reg_data_query.post_only_countries?(current_location)
      phrases = PhraseList.new
      if current_location == 'hong-kong'
        phrases << :booking_text_embassy_hong_kong
      else
        phrases << :booking_text_embassy
      end
      phrases
    end
  end

  precalculate :post_only do
    if reg_data_query.post_only_countries?(current_location)
      PhraseList.new(:"post_only_#{current_location}")
    else
      ''
    end
  end
  precalculate :postal_form_url do
    reg_data_query.postal_form(current_location)
  end
  precalculate :postal_return_form_url do
    reg_data_query.postal_return_form(current_location)
  end

  precalculate :postal do
    phrases = PhraseList.new
    if modified_card_only_countries.include?(current_location)
      phrases << :"post_only_pay_by_card_countries"
    elsif reg_data_query.post_only_countries?(current_location)
      phrases << :"post_only_#{current_location}"
    elsif reg_data_query.register_death_by_post?(current_location)
      phrases = PhraseList.new(:postal_intro)
      if postal_form_url
        phrases << :postal_registration_by_form
      else
        phrases << :"postal_registration_#{current_location}"
      end
      phrases << :postal_delivery_form if postal_return_form_url
      phrases
    else
      ''
    end
  end

  precalculate :fees_for_consular_services do
    phrases = PhraseList.new
    if current_location == 'libya'
      phrases << :consular_service_fees_libya
    else
      phrases << :consular_service_fees
    end
    phrases
  end

  precalculate :cash_only do
    if reg_data_query.cheque_only?(current_location)
      PhraseList.new(:cheque_only)
    elsif reg_data_query.cash_only?(current_location)
      PhraseList.new(:cash_only)
    elsif reg_data_query.cash_and_card_only?(current_location)
      PhraseList.new(:cash_and_card)
    else
      ''
    end
  end

  precalculate :location do
    loc = WorldLocation.find(current_location)
    raise InvalidResponse unless loc
    loc
  end
  precalculate :organisation do
    location.fco_organisation
  end
  precalculate :overseas_passports_embassies do
    if organisation
      organisation.offices_with_service 'Births and Deaths registration service'
    else
      []
    end
  end

  precalculate :footnote do
    if reg_data_query.class::FOOTNOTE_EXCLUSIONS.include?(country_of_death)
      phrases = PhraseList.new(:footnote_exceptions)
      phrases << :"footnote_oru_variants_#{current_location}" if reg_data_query.class::ORU_TRANSITION_EXCEPTIONS.include?(current_location)
      phrases
    elsif country_of_death != current_location and reg_data_query.eastern_caribbean_countries?(country_of_death) and reg_data_query.eastern_caribbean_countries?(current_location)
      PhraseList.new(:footnote_caribbean)
    elsif reg_data_query.class::ORU_COURIER_VARIANTS.include?(current_location) and ! reg_data_query.class::ORU_COURIER_VARIANTS.include?(country_of_death)
      PhraseList.new(:footnote_oru_variants_intro,
                      :"footnote_oru_variants_#{current_location}",
                      :footnote_oru_variants_out)
    elsif another_country
      PhraseList.new(:footnote_another_country)
    else
      PhraseList.new(:footnote)
    end
  end
end
