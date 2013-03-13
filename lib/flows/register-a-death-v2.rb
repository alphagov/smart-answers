status :draft

data_query = SmartAnswer::Calculators::RegistrationsDataQuery.new
exclusions = %w(afghanistan cambodia central-african-republic chad comoros 
                dominican-republic east-timor eritrea haiti kosovo laos lesotho 
                liberia madagascar montenegro paraguay samoa slovenia somalia 
                swaziland taiwan tajikistan western-sahara)

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
country_select :which_country? do
  save_input_as :country
  calculate :country_name do
    SmartAnswer::Question::CountrySelect.countries.find { |c| c[:slug] == responses.last }[:name]
  end
  calculate :current_location do
    data_query.registration_country_slug(responses.last) || responses.last 
  end
  calculate :current_location_name do
    SmartAnswer::Question::CountrySelect.countries.find { |c| c[:slug] == current_location }[:name]
  end
  next_node do |response|
    if data_query.commonwealth_country?(response)
      :commonwealth_result
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
country_select :which_country_are_you_in_now? do
  save_input_as :current_location
  calculate :current_location_name do
    SmartAnswer::Question::CountrySelect.countries.find { |c| c[:slug] == responses.last }[:name]
  end
  next_node :embassy_result
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
    end
    sections
  end
end

outcome :fco_result

outcome :embassy_result do
  precalculate :embassy_high_commission_or_consulate do
    data_query.has_high_commission?(current_location) ? "High commission" :
      data_query.has_consulate?(current_location) ? "British embassy or consulate" :
        "British embassy"
  end

  precalculate :clickbook do
    result = ''
    clickbook = data_query.clickbook(current_location)
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

  precalculate :postal_form_url do
    data_query.death_postal_form(current_location)
  end

  precalculate :postal_return_form_url do
    data_query.death_postal_return_form(current_location)
  end

  precalculate :postal do
    if data_query.register_death_by_post?(current_location)
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

  precalculate :cash_only do
    data_query.cash_only?(current_location) ? PhraseList.new(:cash_only) : ''
  end

  precalculate :embassy_address do
    data = SmartAnswer::Calculators::PassportAndEmbassyDataQuery.new.find_embassy_data(current_location)
    data.first['address'] if data
  end

  precalculate :footnote do
    if exclusions.include?(country)
      PhraseList.new(:footnote_exceptions)
    elsif another_country
      PhraseList.new(:footnote_another_country)
    else
      PhraseList.new(:footnote)
    end
  end
end
