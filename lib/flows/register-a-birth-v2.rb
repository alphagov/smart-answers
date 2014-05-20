status :draft
satisfies_need "101003"

data_query = SmartAnswer::Calculators::MarriageAbroadDataQuery.new
reg_data_query = SmartAnswer::Calculators::RegistrationsDataQueryV2.new
translator_query = SmartAnswer::Calculators::TranslatorLinks.new
exclusions = %w(afghanistan cambodia central-african-republic chad comoros
                dominican-republic east-timor eritrea haiti kosovo laos lesotho
                liberia madagascar montenegro paraguay samoa slovenia somalia swaziland
                taiwan tajikistan western-sahara)
no_embassies = %w(iran syria yemen)
exclude_countries = %w(holy-see british-antarctic-territory)

# Q1
country_select :country_of_birth?, :exclude_countries => exclude_countries do
  save_input_as :country_of_birth

  calculate :registration_country do
    reg_data_query.registration_country_slug(responses.last)
  end

  calculate :registration_country_name do
    WorldLocation.all.find { |c| c.slug == registration_country }.name
  end
  calculate :registration_country_name_lowercase_prefix do
    if data_query.countries_with_definitive_articles?(registration_country)
      "the #{registration_country_name}"
    else
      registration_country_name
    end
  end

  calculate :birth_registration_form do
    if %w(usa).include?(country_of_birth)
      PhraseList.new(:"birth_registration_form_#{country_of_birth}")
    else
      PhraseList.new(:birth_registration_form)
    end
  end

  next_node_if(:no_embassy_result) { |response| no_embassies.include?(response) }
  next_node_if(:commonwealth_result) { |response| reg_data_query.commonwealth_country?(response) }
  next_node(:who_has_british_nationality?)
end

# Q2
multiple_choice :who_has_british_nationality? do
  option :mother => :married_couple_or_civil_partnership?
  option :father => :married_couple_or_civil_partnership?
  option :mother_and_father => :married_couple_or_civil_partnership?
  option :neither => :no_registration_result

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
  
  next_node_if(:childs_date_of_birth?) { |response| response == 'no' and british_national_parent == 'father' }
  next_node(:where_are_you_now?)
end

# Q4
date_question :childs_date_of_birth? do
  from { Date.today }
  to { 50.years.ago(Date.today) }
  
  next_node_if(:homeoffice_result) { |response| Date.new(2006,07,01) > Date.parse(response) }
  next_node(:where_are_you_now?)
end

# Q5
multiple_choice :where_are_you_now? do
  option :same_country
  option :another_country
  option :in_the_uk

  calculate :another_country do
    responses.last == 'another_country'
  end
  
  calculate :in_the_uk do
    responses.last == 'in_the_uk'
  end

  next_node_if(:oru_result) do |response|
    reg_data_query.class::ORU_TRANSITIONED_COUNTRIES.include?(country_of_birth) || response == 'in_the_uk'
  end
  next_node_if(:embassy_result) { |response| response == 'same_country' }
  next_node(:which_country?)
end

# Q6
country_select :which_country?, :exclude_countries => exclude_countries do
  calculate :registration_country do
  reg_data_query.registration_country_slug(responses.last)
  end
  calculate :registration_country_name do
    WorldLocation.all.find { |c| c.slug == registration_country }.name
  end
  calculate :registration_country_name_lowercase_prefix do
    if data_query.countries_with_definitive_articles?(registration_country)
      "the #{registration_country_name}"
    else
      registration_country_name
    end
  end
  
  next_node_if(:no_embassy_result) { |response| no_embassies.include?(response) }
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
  precalculate :embassy_result_indonesia_british_father_paternity do
    if registration_country =='indonesia' and british_national_parent == 'father' and paternity_declaration
      PhraseList.new(:indonesia_british_father_paternity)
    end
  end
  precalculate :documents_you_must_provide do
    checklist_countries = %w(bangladesh finland japan kuwait libya pakistan philippines sweden taiwan turkey)
    key = "documents_you_must_provide_"
    key += (checklist_countries.include?(registration_country) ? registration_country : "all")
    PhraseList.new(key.to_sym)
  end
  precalculate :documents_footnote do
    %w(japan sweden).include?(registration_country) ? PhraseList.new(:"docs_footnote_#{registration_country}") : ''
  end
  precalculate :clickbook_data do
    reg_data_query.clickbook(registration_country)
  end
  precalculate :multiple_clickbooks do
    clickbook_data and clickbook_data.class == Hash
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
      if multiple_clickbooks
        phrases << :registering_clickbooks
      elsif clickbook_data
        phrases << :registering_clickbook
      elsif registration_country == 'hong-kong'
        phrases << :registering_hong_kong
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
    if reg_data_query.cheque_only?(registration_country)
      PhraseList.new(:cheque_only)
    elsif reg_data_query.cash_only?(registration_country)
      PhraseList.new(:cash_only)
    elsif reg_data_query.cash_and_card_only?(registration_country)
      PhraseList.new(:cash_and_card)
    else
      ''
    end
  end
  precalculate :footnote do
    if exclusions.include?(registration_country)
      PhraseList.new(:footnote_exceptions)
    elsif country_of_birth != registration_country and reg_data_query.eastern_caribbean_countries?(registration_country) and reg_data_query.eastern_caribbean_countries?(country_of_birth)
        PhraseList.new(:footnote_caribbean)
    elsif another_country
      PhraseList.new(:footnote_another_country)
    else
      PhraseList.new(:footnote)
    end
  end
end

outcome :oru_result do

  precalculate :button_data do
    {:text => "Pay now", :url => "https://pay-register-birth-abroad.service.gov.uk/start?country=#{country_of_birth}"}
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

end

outcome :commonwealth_result
outcome :no_registration_result
outcome :no_embassy_result
outcome :homeoffice_result
