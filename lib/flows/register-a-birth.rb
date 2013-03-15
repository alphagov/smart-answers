status :draft

reg_data_query = SmartAnswer::Calculators::RegistrationsDataQuery.new
embassy_data_query = SmartAnswer::Calculators::PassportAndEmbassyDataQuery.new
i18n_prefix = 'flow.register-a-birth'
exclusions = %w(afghanistan cambodia central-african-republic chad comoros
                dominican-republic east-timor eritrea haiti kosovo laos lesotho
                liberia madagascar montenegro paraguay samoa slovenia somalia swaziland
                taiwan tajikistan western-sahara)
no_embassies = %w(iran syria yemen)

# Q1
country_select :country_of_birth? do
  save_input_as :country_of_birth

  calculate :registration_country do
    reg_data_query.registration_country_slug(responses.last)
  end
  calculate :country_of_birth_name do
    SmartAnswer::Question::CountrySelect.countries.find { |c| c[:slug] == responses.last }[:name]
  end
  calculate :registration_country_name do
    SmartAnswer::Question::CountrySelect.countries.find { |c| c[:slug] == registration_country }[:name]
  end

  next_node do |response|
    if no_embassies.include?(response)
      :no_embassy_result
    elsif reg_data_query.commonwealth_country?(response)
      :commonwealth_result
    else
      :who_has_british_nationality?
    end
  end
end
# Q2
multiple_choice :who_has_british_nationality? do
  option :mother => :married_couple_or_civil_partnership?
  option :father => :married_couple_or_civil_partnership?
  option :mother_and_father => :married_couple_or_civil_partnership?
  option :neither => :no_registration_result

  save_input_as :british_national_parent

end
# Q3
multiple_choice :married_couple_or_civil_partnership? do
  option :yes
  option :no

  calculate :paternity_declaration do
    responses.last == 'no'
  end

  next_node do |response|
    if response == 'no' and british_national_parent == 'father'
      :childs_date_of_birth?
    else
      :where_are_you_now?
    end
  end
end
# Q4
date_question :childs_date_of_birth? do
  from { Date.today }
  to { 50.years.ago(Date.today) }
  next_node do |response|
    if Date.new(2006,07,01) > Date.parse(response)
      :homeoffice_result
    else
      :where_are_you_now?
    end
  end
end
# Q5
multiple_choice :where_are_you_now? do
  option :same_country
  option :another_country
  option :in_the_uk

  calculate :another_country do
    responses.last == 'another_country'
  end

  next_node do |response|
    case response
    when 'same_country' then :embassy_result
    when 'another_country' then :which_country?
    else
      if %w(niger pakistan).include?(country_of_birth)
        :embassy_result
      else
        :fco_result
      end
    end
  end
end
# Q6
country_select :which_country? do
  calculate :registration_country do
    reg_data_query.registration_country_slug(responses.last)
  end
  calculate :registration_country_name do
    SmartAnswer::Question::CountrySelect.countries.find { |c| c[:slug] == registration_country }[:name]
  end

  next_node do |response| 
    if no_embassies.include?(response)
      :no_embassy_result
    else
      :embassy_result
    end
  end
end
# Outcomes
outcome :embassy_result do
  precalculate :embassy_high_commission_or_consulate do
    reg_data_query.has_high_commission?(registration_country) ? "High commission" :
      reg_data_query.has_consulate?(registration_country) ? "British embassy or consulate" :
        "British embassy"
  end
  precalculate :documents_you_must_provide do
    checklist_countries = %w(bangladesh japan pakistan philippines sweden taiwan turkey)
    key = "documents_you_must_provide_"  
    key += (checklist_countries.include?(registration_country) ? registration_country : "all")
    PhraseList.new(key.to_sym)
  end
  precalculate :documents_footnote do
    registration_country == 'japan' ? PhraseList.new("docs_footnote_japan") : ''
  end
  precalculate :clickbook_data do
    reg_data_query.clickbook(registration_country)
  end
  precalculate :multiple_clickbooks do
    clickbook_data and clickbook_data.class == Hash
  end
  precalculate :clickbook do
    result = ''
    unless clickbook_data.nil?
      if clickbook_data.class == Hash
        clickbook_data.each do |k,v|
          result += I18n.translate!(i18n_prefix + ".phrases.clickbook_link", city: k, url: v)
        end
      end
    end
    result
  end
  precalculate :go_to_the_embassy do
    phrases = PhraseList.new
    if multiple_clickbooks
      phrases << :registering_clickbooks
    elsif clickbook_data
      phrases << :registering_clickbook
    else
      phrases << :registering_all
    end
    phrases << (paternity_declaration ? :registering_paternity_declaration : :registering_either_parent)
    phrases
  end
  precalculate :postal_form_url do
    reg_data_query.birth_postal_form(registration_country)
  end
  precalculate :postal do
    if postal_form_url
      PhraseList.new(:"postal_form")
    elsif reg_data_query.class::NO_POSTAL_COUNTRIES.include?(registration_country) 
      PhraseList.new(:"postal_info_#{registration_country}")
    else
      ''
    end
  end
  precalculate :embassy_details do
    details = embassy_data_query.find_embassy_data(registration_country)
    if details
      details = details.first
      I18n.translate("#{i18n_prefix}.phrases.embassy_details",
                     address: details['address'], phone: details['phone'], email: details['email'])
    else
      ''
    end
  end
  precalculate :cash_only do
    reg_data_query.cash_only?(registration_country) ? PhraseList.new(:cash_only) : ''
  end
  precalculate :footnote do
    if exclusions.include?(registration_country)
      PhraseList.new(:footnote_exceptions)
    elsif another_country
      PhraseList.new(:footnote_another_country)
    else
      PhraseList.new(:footnote)
    end
  end
end
outcome :fco_result do
  precalculate :intro do
    if exclusions.include?(registration_country)
      ''
    else
      PhraseList.new(:intro)
    end
  end
end
outcome :commonwealth_result
outcome :no_registration_result
outcome :no_embassy_result
outcome :homeoffice_result
