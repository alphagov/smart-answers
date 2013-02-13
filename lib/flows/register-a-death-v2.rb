status :draft

data_query = SmartAnswer::Calculators::RegistrationsDataQuery.new

multiple_choice :where_did_the_death_happen? do
  save_input_as :where_death_happened
  option :england_wales => :did_the_person_die_at_home_hospital?
  option :scotland_northern_ireland => :did_the_person_die_at_home_hospital?
  option :overseas => :was_death_expected?
end

multiple_choice :did_the_person_die_at_home_hospital? do
  option :at_home_hospital
  option :elsewhere
  calculate :died_at_home_hospital do
    responses.last == 'at_home_hospital'
  end
  next_node :was_death_expected?
end

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

country_select :which_country? do
  save_input_as :country
  calculate :country_name do
    SmartAnswer::Question::CountrySelect.countries.find { |c| c[:slug] == responses.last }[:name]
  end
  next_node do |response|
    if data_query.commonwealth_country?(response)
      :commonwealth_result
    else
      :where_do_you_want_to_register_the_death?
    end
  end
end

multiple_choice :where_do_you_want_to_register_the_death? do
  option :embassy => :embassy_result
  option :fco_uk => :fco_result
end

outcome :commonwealth_result
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
      sections << :intro_other
      sections << :intro_other_unexpected unless death_expected
      #who can register and documents you need sections are not needed for this type of outcome
      sections << :"documents_youll_get_other_#{death_expected ? :expected : :unexpected}"
    end
    sections
  end
end
outcome :fco_result do

end
outcome :embassy_result do
  precalculate :registration_form_url do
    data_query.data['death_registration']['registration_forms'][country]
  end
  precalculate :registration_form do
    if registration_form_url
      PhraseList.new(:country_registration_form_download)
    else
      ''
    end
  end
end
