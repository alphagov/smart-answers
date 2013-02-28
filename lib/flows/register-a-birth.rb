status :draft

reg_data_query = SmartAnswer::Calculators::RegistrationsDataQuery.new
i18n_prefix = 'flow.register-a-birth'

# Q1
multiple_choice :have_you_adopted_the_child? do
  option :yes => :no_registration_result 
  option :no => :who_has_british_nationality? 
end
# Q2
multiple_choice :who_has_british_nationality? do
  option :mother => :country_of_birth?
  option :father => :country_of_birth?
  option :mother_and_father => :country_of_birth?
  option :neither => :no_registration_result

  save_input_as :british_national_parent

end
# Q3
country_select :country_of_birth? do
  save_input_as :country_of_birth

  calculate :registration_country do
    responses.last
  end

  next_node do |response|
    if reg_data_query.commonwealth_country?(response)
      :commonwealth_result
    else
      :married_couple_or_civil_partnership?
    end
  end
end
# Q4
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
# Q5
date_question :childs_date_of_birth? do
  next_node do |response|
    if Date.parse(response) > Date.new(2006,07,01)
      :homeoffice_result
    else
      :where_are_you_now?
    end
  end
end
# Q6
multiple_choice :where_are_you_now? do
  option :same_country
  option :another_country
  option :in_the_uk 

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
# Q7
country_select :which_country? do

  calculate :registration_country do
    responses.last
  end

  next_node do |response|
    if reg_data_query.commonwealth_country?(response)
      :commonwealth_result
    else
      :embassy_result
    end 
  end
end
# Outcomes
outcome :embassy_result do
  precalculate :registration_country_name do
    SmartAnswer::Question::CountrySelect.countries.find { |c| c[:slug] == registration_country }[:name]
  end
  precalculate :embassy_high_commission_or_consulate do
    reg_data_query.has_high_commission?(registration_country) ? "High commission" :
      reg_data_query.has_consulate?(registration_country) ? "British embassy or consulate" :
        "British embassy"
  end
  precalculate :documents_you_must_provide do
    key = "documents_you_must_provide_"  
    key += (%w(sweden taiwan turkey).include?(registration_country) ? registration_country : "all")
    PhraseList.new(key.to_sym)
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
  end
  precalculate :cash_only do
    reg_data_query.cash_only?(registration_country) ? PhraseList.new(:cash_only) : ''
  end
  precalculate :footnote do
    unless %w(cambodia eritrea kosovo laos madagascar 
              montenegro paraguay slovenia taiwan tajikistan).include?(registration_country)
      I18n.translate("#{i18n_prefix}.phrases.footnote_#{registration_country}", 
                    :default => I18n.translate("#{i18n_prefix}.phrases.footnote"))
    end
  end
end
outcome :fco_result
outcome :commonwealth_result
outcome :no_registration_result
outcome :homeoffice_result
