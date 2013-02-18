status :draft

data_query = SmartAnswer::Calculators::RegistrationsDataQuery.new

multiple_choice :where_did_the_death_happen? do
  save_input_as :where_death_happened
  option :england_wales => :did_the_person_die_at_home_hospital?
  option :scotland => :did_the_person_die_at_home_hospital?
  option :northern_ireland => :did_the_person_die_at_home_hospital?
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
      sections << :"intro_#{where_death_happened}"
      sections << :"intro_other_unexpected" unless death_expected
      sections << :"documents_youll_get_other_#{death_expected ? :expected : :unexpected}"
    end
    sections
  end
end

outcome :fco_result do
  precalculate :unexpected_death_section do
    death_expected ? '' : PhraseList.new(:unexpected_death) 
  end
end

outcome :embassy_result do

  precalculate :clickbook do
    result = ''
    clickbook = data_query.clickbook(country)
    i18n_prefix = "flow.register-a-death-v2"
    unless clickbook.nil?
      if clickbook.class == Hash
        result = I18n.translate!("#{i18n_prefix}.phrases.multiple_clickbooks_intro") << "\n"
        clickbook.each do |k,v|
          result += %Q(- #{I18n.translate!(i18n_prefix + ".phrases.clickbook_link", 
                                           title: k, clickbook_url: v)})
        end
      else
        result = I18n.translate!("#{i18n_prefix}.phrases.clickbook_link",
                                 title: "Book an appointment online", clickbook_url: clickbook)
      end
    end
    result
  end

  precalculate :postal do
  end
end
