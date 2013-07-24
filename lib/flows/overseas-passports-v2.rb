status :draft
satisfies_need 2820

i18n_prefix = "flow.overseas-passports-v2"
data_query = Calculators::PassportAndEmbassyDataQueryV2.new 
exclude_countries = %w(holy-see british-antarctic-territory)


# Q1
country_select :which_country_are_you_in?, :exclude_countries => exclude_countries do
  save_input_as :current_location

  calculate :location do
    loc = WorldLocation.find(current_location)
    raise InvalidResponse unless loc
    loc
  end

  next_node do |response|
    if Calculators::PassportAndEmbassyDataQueryV2::NO_APPLICATION_REGEXP.match(response)
      :cannot_apply
    elsif %w(the-occupied-palestinian-territories).include?(response)
      :which_opt?
    elsif %w(st-helena-ascension-and-tristan-da-cunha).include?(response)
      :which_bot?
    else
      :renewing_replacing_applying?
    end
  end
end

# Q1a
multiple_choice :which_opt? do
  option :gaza
  option :"jerusalem-or-westbank"

  save_input_as :current_location
  next_node :renewing_replacing_applying?
end

# Q1b
multiple_choice :which_bot? do
  option :"st-helena"
  option :"ascension-island"
  option :"tristan-da-cunha"

  save_input_as :current_location
  next_node :renewing_replacing_applying?
end

# Q2
multiple_choice :renewing_replacing_applying? do
  option :renewing_new
  option :renewing_old
  option :applying
  option :replacing

  save_input_as :application_action

  precalculate :organisation do
    location.fco_organisation
  end

  calculate :overseas_passports_embassies do
    if organisation && organisation.all_offices.any?
      embassies = organisation.all_offices.select do |o| 
        o.services.any? { |s| s.title.include?('Overseas Passports Service') }
      end
      embassies << organisation.main_office if embassies.empty?
      embassies
    else
      []
    end
  end
  
  calculate :general_action do
    responses.last =~ /^renewing_/ ? 'renewing' : responses.last
  end

  calculate :passport_data do
    data_query.find_passport_data(current_location)
  end
  calculate :application_type do
    passport_data['type']
  end
  calculate :is_ips_application do
    application_type =~ Calculators::PassportAndEmbassyDataQueryV2::IPS_APPLICATIONS_REGEXP
  end
  calculate :is_fco_application do
    application_type =~ Calculators::PassportAndEmbassyDataQueryV2::FCO_APPLICATIONS_REGEXP
  end
  calculate :ips_number do
    application_type.split("_")[2] if is_ips_application 
  end

  calculate :supporting_documents do
    passport_data['group']
  end

  data_query.passport_costs.each do |k,v|
    calculate "costs_#{k}".to_sym do 
      v
    end
  end

  next_node :child_or_adult_passport?
end

# Q3
multiple_choice :child_or_adult_passport? do
  option :adult
  option :child

  save_input_as :child_or_adult

  calculate :fco_forms do
    if %w(nigeria).include?(current_location)
      PhraseList.new(:"#{responses.last}_fco_forms_nigeria")
    else
      PhraseList.new(:"#{responses.last}_fco_forms")
    end
  end

  next_node do |response|
    case application_type
    when 'australia_post', 'new_zealand'
      :"which_best_describes_you_#{response}?"
    when Calculators::PassportAndEmbassyDataQueryV2::IPS_APPLICATIONS_REGEXP
      %Q(applying renewing_old).include?(application_action) ? :country_of_birth? : :ips_application_result 
    when Calculators::PassportAndEmbassyDataQueryV2::FCO_APPLICATIONS_REGEXP
      :fco_result
    else
      :result
    end
  end
end

# Q4
country_select :country_of_birth?, :include_uk => true, :exclude_countries => exclude_countries do
  save_input_as :birth_location

  calculate :application_group do
    data_query.find_passport_data(responses.last)['group']
  end

  calculate :supporting_documents do
    responses.last == 'united-kingdom' ? supporting_documents : application_group
  end

  next_node do |response|
    case application_type
    when 'australia_post', 'new_zealand'
      :aus_nz_result
    when Calculators::PassportAndEmbassyDataQueryV2::IPS_APPLICATIONS_REGEXP 
      :ips_application_result 
    when Calculators::PassportAndEmbassyDataQueryV2::FCO_APPLICATIONS_REGEXP
      :fco_result
    else
      :result
    end
  end
end

# QAUS1
multiple_choice :which_best_describes_you_adult? do
  option "born-in-uk-pre-1983" # 4
  option "born-in-uk-post-1982-uk-father" # 5
  option "born-in-uk-post-1982-uk-mother" # 6
  option "born-outside-uk-parents-married" # 7
  option "born-outside-uk-mother-born-in-uk" # 8
  option "born-in-uk-post-1982-father-uk-citizen" # 9
  option "born-in-uk-post-1982-mother-uk-citizen" # 10
  option "born-outside-uk-father-registered-uk-citizen" # 11
  option "born-outside-uk-mother-registered-uk-citizen" # 12
  option "born-in-uk-post-1982-father-uk-service" # 13
  option "born-in-uk-post-1982-mother-uk-service" # 14
  option "married-to-uk-citizen-pre-1983-reg-pre-1988" # 15
  option "registered-uk-citizen" # 16
  option "child-born-outside-uk-father-citizen" # 17
  option "woman-married-to-uk-citizen-pre-1949" # 18

  save_input_as :aus_nz_checklist_variant

  next_node :aus_nz_result
end
# QAUS1 Child specific options
multiple_choice :which_best_describes_you_child? do
  option "born-in-uk-post-1982-uk-father" # 5
  option "born-in-uk-post-1982-uk-mother" # 6
  option "born-outside-uk-parents-married" # 7
  option "born-outside-uk-mother-born-in-uk" # 8
  option "born-in-uk-post-1982-father-uk-citizen" # 9
  option "born-in-uk-post-1982-mother-uk-citizen" # 10
  option "born-in-uk-post-1982-father-uk-service" # 13
  option "born-in-uk-post-1982-mother-uk-service" # 14
  option "registered-uk-citizen" # 16

  save_input_as :aus_nz_checklist_variant

  next_node :aus_nz_result
end

## australia_post/new_zealand result.
outcome :aus_nz_result do
  precalculate :how_long_it_takes do
    PhraseList.new(:"how_long_#{application_type}")
  end
  precalculate :cost do
    PhraseList.new(:"cost_#{application_type}")
  end
  precalculate :how_to_apply do
    PhraseList.new(:"how_to_apply_#{application_type}")
  end
  precalculate :how_to_apply_documents do
    phrases = PhraseList.new(:"how_to_apply_#{child_or_adult}_#{application_type}")

    if application_action == 'replacing' 
      phrases << :"aus_nz_replacing"
    end
    if application_action =~ /^renewing_/
      phrases << :"aus_nz_renewing"
    end

    phrases << :"aus_nz_#{aus_nz_checklist_variant}"
    phrases
  end
  precalculate :instructions do
    PhraseList.new(:"instructions_#{application_type}")
  end
  precalculate :receiving_your_passport do
    PhraseList.new(:"receiving_your_passport_#{application_type}")
  end
  precalculate :helpline do
    PhraseList.new(:helpline_fco_webchat)
  end
end


## IPS Application Result 
outcome :ips_application_result do

  precalculate :how_long_it_takes do
    if %w{mauritania morocco western-sahara tunisia}.include?(current_location)
      if application_action == 'renewing_new'
        PhraseList.new(:how_long_renewing_new_ips2_morocco,
                       :"how_long_it_takes_ips#{ips_number}")
      elsif application_action == 'replacing'
        PhraseList.new(:how_long_replacing_ips2_morocco,
                       :"how_long_it_takes_ips#{ips_number}")
      else
        PhraseList.new(:how_long_other_ips2_morocco,
                       :"how_long_it_takes_ips#{ips_number}")
      end
    else
      if %w{kazakhstan kyrgyzstan}.include?(current_location)
        PhraseList.new(:"how_long_#{current_location}",
                      :"how_long_it_takes_ips#{ips_number}")
      else
        PhraseList.new(:"how_long_#{application_action}_ips#{ips_number}",
                     :"how_long_it_takes_ips#{ips_number}")
      end
    end
  end
  precalculate :cost do
    if application_action == 'replacing' && ips_number == '1'
      PhraseList.new(:"passport_courier_costs_replacing_ips#{ips_number}",
                   :"#{child_or_adult}_passport_costs_replacing_ips#{ips_number}",
                   :"passport_costs_ips#{ips_number}")
    elsif %w{cuba gaza libya mauritania morocco sudan tunisia western-sahara}.include?(current_location) # IPS 2&3 countries where payment must be made in cash
      PhraseList.new(:"passport_courier_costs_ips#{ips_number}",
                   :"#{child_or_adult}_passport_costs_ips#{ips_number}",
                   :"passport_costs_ips_cash")
    else
      PhraseList.new(:"passport_courier_costs_ips#{ips_number}",
                   :"#{child_or_adult}_passport_costs_ips#{ips_number}",
                   :"passport_costs_ips#{ips_number}")
    end
  end
  precalculate :how_to_apply do
    PhraseList.new(:"how_to_apply_ips#{ips_number}",
                   supporting_documents.to_sym)
  end
  precalculate :send_your_application do
    if data_query.belfast_application_address?(current_location)
      PhraseList.new(:"send_application_ips#{ips_number}_belfast")
    elsif data_query.durham_application_address?(current_location)
      PhraseList.new(:"send_application_ips#{ips_number}_durham")
    elsif %w(gaza).include?(current_location)
      PhraseList.new(:send_application_ips3_gaza)
    else
      PhraseList.new(:"send_application_ips#{ips_number}")
    end
  end
  precalculate :getting_your_passport do
    if %w(cyprus egypt iraq jordan yemen).include?(current_location)
      PhraseList.new :"getting_your_passport_#{current_location}"
    else
      PhraseList.new :"getting_your_passport_ips#{ips_number}"
    end
  end
  precalculate :tracking_and_receiving do
    PhraseList.new(:"tracking_and_receiving_ips#{ips_number}")
  end
end

## FCO Result
outcome :fco_result do
  precalculate :how_long_it_takes do
    if application_action == 'applying' and %w(india tanzania).include?(current_location)
      PhraseList.new(:"how_long_applying_#{current_location}")
    else
      PhraseList.new(:"how_long_#{application_action}_fco")
    end
  end

  precalculate :cost do
    cost_type = application_type
    # All european FCO applications cost the same
    cost_type = 'fco_europe' if application_type =~ /^(dublin_ireland|madrid_spain|paris_france)$/
    # Jamaican courier costs vary from the USA FCO office standard.
    cost_type = current_location if current_location == 'jamaica'
    cost_type = "applying_#{current_location}" if current_location == 'india' and general_action != 'renewing'
   
    payment_methods = :"passport_costs_#{application_type}"
    payment_methods = :"passport_costs_#{current_location}" if current_location == 'jamaica'

    # Indonesian first time applications have courier and cost variations.
    if current_location == 'indonesia' and application_action == 'applying'
      cost_type = current_location
      payment_methods = :passport_costs_indonesia
    end

    phrases = PhraseList.new(:"passport_courier_costs_#{cost_type}",
                             :"#{child_or_adult}_passport_costs_#{cost_type}", 
                             payment_methods)

    phrases << :passport_costs_nepal if current_location == 'nepal'
    phrases
  end

  precalculate :how_to_apply_supplement do
    if application_type == 'dublin_ireland'
      PhraseList.new(:"how_to_apply_#{application_type}")
    elsif general_action == 'renewing' and data_query.retain_passport?(current_location)
      PhraseList.new(:how_to_apply_retain_passport)
    else
      ''
    end
  end

  precalculate :hurricane_warning do
    if general_action == 'renewing' and data_query.retain_passport_hurricanes?(current_location)
      PhraseList.new(:how_to_apply_retain_passport_hurricane)
    else
      ''
    end
  end

  precalculate :supporting_documents do
    if application_action == 'applying' and current_location == 'jordan'
      PhraseList.new(:supporting_documents_jordan_applying)
    elsif current_location == 'india' and %w(applying renewing).include?(general_action)
      PhraseList.new(:supporting_documents_india_applying_renewing)
    elsif current_location == 'south-africa' and general_action == 'applying'
      PhraseList.new(:supporting_documents_south_africa_applying)
    else
      ''
    end
  end

  precalculate :send_your_application do
    phrases = PhraseList.new
    if %(jamaica south-africa).include?(current_location)
      phrases << :"send_application_#{current_location}"
    elsif current_location == 'indonesia'
      if application_action == 'applying' or application_action == 'replacing'
        phrases << :send_application_indonesia_applying
      else
        phrases << :send_application_fco_preamble << :"send_application_#{application_type}"
      end
    else
      phrases << :send_application_fco_preamble
      phrases << :"send_application_#{application_type}"
    end
    phrases
  end
  precalculate :getting_your_passport do
    location = 'fco'
    location = current_location if %(jamaica nepal india).include?(current_location)
    PhraseList.new(:"getting_your_passport_#{location}")
  end
  precalculate :helpline do
    phrases = PhraseList.new(:"helpline_#{application_type}")
    unless %w{madrid_spain paris_france}.include?(application_type)
      phrases << :helpline_fco_webchat
    end
    phrases
  end
end

## Generic country outcome.
outcome :result do
  precalculate :how_long_it_takes do
    phrase = ['how_long', application_type]
    phrase << general_action if application_type == 'nairobi_kenya'
    PhraseList.new(phrase.join('_').to_sym)
  end
  precalculate :cost do
    phrase = ['cost', application_type]
    phrase << general_action if %w(cameroon nairobi_kenya).include?(application_type)
    PhraseList.new(phrase.join('_').to_sym)
  end
  precalculate :how_to_apply do
    phrases = PhraseList.new(:"how_to_apply_#{application_type}")
    if general_action == 'renewing' and data_query.retain_passport?(current_location)
      phrases << :how_to_apply_retain_passport 
    end
    phrases
  end
  precalculate :supporting_documents do
    phrase = ['supporting_documents', application_type]
    phrase << general_action if %w(iraq nairobi_kenya yemen zambia).include?(application_type)
    PhraseList.new(phrase.join('_').to_sym)
  end
  precalculate :making_application do
    phrase = ['making_application', application_type]
    phrase << general_action if application_type == 'cameroon'
    PhraseList.new(phrase.join('_').to_sym)
  end
  precalculate :making_application_additional do
    if current_location == 'yemen'
      PhraseList.new(:making_application_additional_yemen)
    else
      ''
    end
  end
  precalculate :getting_your_passport do
    PhraseList.new(:"getting_your_passport_#{application_type}")
  end
  precalculate :helpline do
    phrases = PhraseList.new
    if %w(cuba libya morocco tunisia).include?(current_location)
      phrases << :helpline_exceptions
    elsif current_location == 'yemen'
      phrases << :helpline_exception_yemen
    else
      phrases << :helpline_intro << :"helpline_#{passport_data['helpline']}"
    end
    unless %w{madrid_spain paris_france}.include?(application_type)
      phrases << :helpline_fco_webchat
    end
    phrases
  end
end

## No-op outcome.
outcome :cannot_apply do
  precalculate :organisation do
    location.fco_organisation
  end

  precalculate :overseas_passports_embassies do
    if organisation && organisation.all_offices.any?
      embassies = organisation.all_offices.select do |o| 
        o.services.any? { |s| s.title.include?('Overseas Passports Service') }
      end
      embassies << organisation.main_office if embassies.empty?
      embassies
    else
      []
    end
  end

  precalculate :body_text do
    PhraseList.new(:"body_#{current_location}")
  end
end
