satisfies_need "2189"
status :draft

data_query = SmartAnswer::Calculators::MarriageAbroadDataQueryV2.new
i18n_prefix = "flow.register-a-death-v2"
reg_data_query = SmartAnswer::Calculators::RegistrationsDataQueryV2.new
embassy_data_query = SmartAnswer::Calculators::PassportAndEmbassyDataQueryV2.new
exclusions = %w(afghanistan cambodia central-african-republic chad comoros 
                dominican-republic east-timor eritrea haiti kosovo laos lesotho 
                liberia madagascar montenegro paraguay samoa slovenia somalia 
                swaziland taiwan tajikistan western-sahara)
no_embassies = %w(iran syria yemen)
different_address = %w(belgium brazil germany india turkey united-arab-emirates)

# Q1
multiple_choice :where_did_the_death_happen? do
  save_input_as :where_death_happened
  option :england_wales => :did_the_person_die_at_home_hospital?
  option :scotland => :did_the_person_die_at_home_hospital?
  option :northern_ireland => :did_the_person_die_at_home_hospital?
  option :overseas => :which_country?
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
  next_node do |response|
    if where_death_happened == 'overseas'
      :which_country?
    else
      :uk_result
    end
  end
end
# Q4
country_select :which_country?, :use_legacy_data => true do
  save_input_as :country

  calculate :country_name do
    LegacyCountry.all.find { |c| c.slug == responses.last }.name
  end
  calculate :country_name_lowercase_prefix do
    if data_query.countries_with_definitive_articles?(country)
      "the #{country_name}"
    else
      country_name
    end
  end


  calculate :current_location do
    reg_data_query.registration_country_slug(responses.last) || responses.last 
  end
  calculate :current_location_name do
    LegacyCountry.all.find { |c| c.slug == current_location }.name
  end
  calculate :current_location_name_lowercase_prefix do
    if data_query.countries_with_definitive_articles?(country)
      "the #{current_location_name}"
    else
      current_location_name
    end
  end

  next_node do |response|
    if reg_data_query.commonwealth_country?(response)
      :commonwealth_result
    elsif no_embassies.include?(response)
      :no_embassy_result
    else
      :where_are_you_now?
    end
  end
end
# Q5
multiple_choice :where_are_you_now? do
  option :same_country => :embassy_result
  option :another_country => :which_country_are_you_in_now?
  option :back_in_the_uk => :fco_result

  calculate :another_country do
    responses.last == 'another_country'
  end
end
# Q6
country_select :which_country_are_you_in_now?, :use_legacy_data => true do
  save_input_as :current_location
  calculate :current_location_name do
    country_slug = reg_data_query.registration_country_slug(responses.last)
    LegacyCountry.all.find { |c| c.slug == country_slug }.name
  end
  calculate :current_location_name_lowercase_prefix do
    if data_query.countries_with_definitive_articles?(current_location)
      "the #{current_location_name}"
    else
      current_location_name
    end
  end



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

outcome :fco_result do
  precalculate :embassy_high_commission_or_consulate do
    if reg_data_query.has_high_commission?(current_location)
     "British high commission"
    elsif reg_data_query.has_consulate?(current_location)
      "British embassy or consulate"
    elsif reg_data_query.has_consulate_general?(current_location)
      "British consulate-general"
    else
      "British embassy"
    end
  end
  precalculate :registration_footnote do
    exclusions.include?(country) ? '' : PhraseList.new(:reg_footnote)
  end
end

outcome :embassy_result do
  precalculate :documents_required_embassy_result do
    phrases = PhraseList.new
    if current_location == 'libya'
      phrases << :documents_list_embassy_libya
    elsif current_location == 'sweden'
      phrases << :documents_list_embassy_sweden
    elsif current_location == 'netherlands'
      phrases << :documents_list_embassy_netherlands
    elsif current_location == 'malaysia'
      phrases << :documents_list_embassy_malaysia
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
    elsif reg_data_query.has_consulate_general?(current_location)
      "British consulate-general"
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

  precalculate :clickbook_data do
    reg_data_query.clickbook(current_location)
  end

  precalculate :clickbook do
    if clickbook_data.nil?
      ''
    else
      if clickbook_data.class == Hash
        PhraseList.new :clickbooks
      else
        PhraseList.new :clickbook
      end
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
    reg_data_query.death_postal_form(current_location)
  end
  precalculate :postal_return_form_url do
    reg_data_query.death_postal_return_form(current_location)
  end

  precalculate :postal do
    if reg_data_query.register_death_by_post?(current_location)
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
    reg_data_query.cash_only?(current_location) ? PhraseList.new(:cash_only) : PhraseList.new(:cash_and_card)
  end

  precalculate :embassy_details do
    details = embassy_data_query.find_embassy_data(current_location)

    if details
      details = different_address.include?(current_location) ? details.second : details.first
      I18n.translate("#{i18n_prefix}.phrases.embassy_details",
                     address: details['address'], phone: details['phone'], email: details['email'])
    else
      ''
    end
  end

  precalculate :footnote do
    if exclusions.include?(country)
      PhraseList.new(:footnote_exceptions)
    elsif country != current_location and reg_data_query.eastern_caribbean_countries?(country) and reg_data_query.eastern_caribbean_countries?(current_location)
        PhraseList.new(:footnote_caribbean)
    elsif another_country
      PhraseList.new(:footnote_another_country)
    else
      PhraseList.new(:footnote)
    end
  end
end
