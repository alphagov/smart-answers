status :draft
satisfies_need 2820


data_query = Calculators::PassportAndEmbassyDataQueryV2.new
exclude_countries = %w(holy-see british-antarctic-territory)


# Q1
country_select :which_country_are_you_in?, :exclude_countries => exclude_countries do
  save_input_as :current_location

  calculate :location do
    loc = WorldLocation.find(current_location)
    if Calculators::PassportAndEmbassyDataQueryV2::ALT_EMBASSIES.has_key?(current_location)
      loc = WorldLocation.find(Calculators::PassportAndEmbassyDataQueryV2::ALT_EMBASSIES[current_location])
    end
    raise InvalidResponse unless loc
    loc
  end

  next_node do |response|
    if Calculators::PassportAndEmbassyDataQueryV2::NO_APPLICATION_REGEXP.match(response)
      :cannot_apply
    elsif %w(the-occupied-palestinian-territories).include?(response)
      :which_opt?
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
    if organisation
      organisation.offices_with_service 'Overseas Passports Service'
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

  calculate :application_form do
    passport_data['app_form']
  end

  calculate :supporting_documents do
    passport_data['group']
  end

  calculate :application_address do
    passport_data['address']
  end

  calculate :ips_docs_number do
    supporting_documents.split("_")[3] if is_ips_application
  end

  calculate :ips_result_type do
    passport_data['online_application'] ? :ips_application_result_online : :ips_application_result
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
      %Q(applying renewing_old).include?(application_action) ? :country_of_birth? : ips_result_type
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
      ips_result_type
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
  option "child-born-outside-uk-father-citizen" # 17

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

## Online IPS Application Result
outcome :ips_application_result_online do
  precalculate :how_long_it_takes do
    action = application_action =~/applying|renewing_old/ ? 'applying' : application_action
    PhraseList.new(:"how_long_#{action}_online",
                    :how_long_additional_time_online)
  end
  precalculate :cost do
    if application_action == 'replacing' and ips_number == '1' and ips_docs_number == '1'
      PhraseList.new(:"passport_courier_costs_replacing_ips#{ips_number}",
                     :"#{child_or_adult}_passport_costs_replacing_ips#{ips_number}")
    else
      PhraseList.new(:"passport_courier_costs_ips#{ips_number}",
                     :"#{child_or_adult}_passport_costs_ips#{ips_number}")
    end
  end
  precalculate :how_to_apply do
    PhraseList.new(:how_to_apply_online,
                   :"how_to_apply_online_prerequisites_#{general_action}",
                   :"how_to_apply_online_guidance_doc_group_#{ips_docs_number}")
  end
  precalculate :getting_your_passport do
    PhraseList.new(:"getting_your_passport_ips#{ips_number}")
  end
  precalculate :tracking_and_receiving do
    PhraseList.new(:"tracking_and_receiving_ips#{ips_number}")
  end
end

## IPS Application Result
outcome :ips_application_result do

  precalculate :how_long_it_takes do
    eight_week_application_countries = %w(mauritania morocco western-sahara tunisia)
    twelve_week_application_countries = %w(cameroon chad djibouti eritrea ethiopia kenya somalia tanzania uganda)

    phrases = PhraseList.new
    if eight_week_application_countries.include?(current_location)
      number_of_weeks = application_action =~ /renewing_new|replacing/ ? 4 : 8
      phrases << :"how_long_#{number_of_weeks}_weeks"
    elsif twelve_week_application_countries.include?(current_location) and %w(applying renewing_old).include?(application_action)
      phrases << :"how_long_applying_12_weeks"
    elsif %w{kazakhstan kyrgyzstan}.include?(current_location)
      phrases << :"how_long_#{current_location}"
    elsif %w{afghanistan pakistan}.include?(current_location) and %w(applying renewing_old).include?(application_action)
      phrases << :"how_long_applying_6_months"
    elsif %w{india}.include?(current_location) and %w(applying renewing_old).include?(application_action)
      phrases << :"how_long_applying_16_weeks"
    elsif %w{india}.include?(current_location) and %w(renewing_new replacing).include?(application_action)
      phrases << :"how_long_5_weeks"
    elsif %w{bangladesh}.include?(current_location)
      if %w(applying renewing_old).include?(application_action)
        phrases << :"how_long_applying_6_months"
      elsif %w(renewing_new).include?(application_action)
        phrases << :"how_long_6_weeks"
      else
        phrases << :"how_long_16_weeks"
      end
    else
      phrases << :"how_long_#{application_action}_ips#{ips_number}"
    end
    phrases << :"how_long_it_takes_ips#{ips_number}"
    phrases
  end

  precalculate :cost do
    if application_action == 'replacing' and ips_number == '1' and ips_docs_number == '1'
      PhraseList.new(:"passport_courier_costs_replacing_ips#{ips_number}",
                    :"#{child_or_adult}_passport_costs_replacing_ips#{ips_number}",
                    :"passport_costs_ips#{ips_number}")
    else
      phrases = PhraseList.new
      if current_location == 'india'
        phrases << :"passport_courier_costs_ips3_india"
      else
        phrases << :"passport_courier_costs_ips#{ips_number}"
      end

      phrases << :"#{child_or_adult}_passport_costs_ips#{ips_number}"

      if %w(afghanistan bangladesh).include?(current_location)
        phrases << :"passport_costs_ips3_cash_or_card_#{current_location}"
      elsif data_query.cash_only_countries?(current_location)
        phrases << :passport_costs_ips_cash
      else
        phrases << :"passport_costs_ips#{ips_number}"
      end

      phrases
    end
  end

  precalculate :how_to_apply do
    if passport_data['online_application']
    else
      PhraseList.new(:"how_to_apply_ips#{ips_number}",
                     application_form.to_sym,
                     supporting_documents.to_sym)
    end
  end

  precalculate :send_your_application do
    phrases = PhraseList.new
    if application_address
      phrases << :"send_application_ips#{ips_number}_#{application_address}"
    elsif %w(gaza).include?(current_location)
      phrases << :send_application_ips3_gaza
    elsif %w(afghanistan bangladesh).include?(current_location)
      phrases << :"send_application_ips3_#{current_location}"
      phrases << :send_application_embassy_address
    elsif %w(india pakistan).include?(current_location)
      phrases << :send_application_ips3_must_post
      phrases << :send_application_embassy_address
    elsif general_action == 'renewing' and data_query.renewing_countries?(current_location)
      phrases << :"send_application_ips#{ips_number}" << :renewing_new_renewing_old << :send_application_embassy_address
    else
      phrases << :"send_application_ips#{ips_number}"
      phrases << :send_application_embassy_address if ips_number.to_i > 1
    end
    phrases
  end

  precalculate :getting_your_passport do
    collect_in_person_countries = %w(angola benin burundi cameroon chad congo egypt eritrea ethiopia gambia ghana guinea jamaica kenya nigeria rwanda sierra-leone somalia south-sudan uganda zambia)
    collect_in_person_variant_countries = %w(india iraq jordan yemen)

    phrases = PhraseList.new
    if collect_in_person_countries.include?(current_location)
      phrases << :"getting_your_passport_#{current_location}" << :getting_your_passport_contact_and_id
    elsif collect_in_person_variant_countries.include?(current_location)
      phrases << :"getting_your_passport_#{current_location}"
    else
      phrases << :"getting_your_passport_ips#{ips_number}"
    end
  end
  precalculate :tracking_and_receiving do
    PhraseList.new(:"tracking_and_receiving_ips#{ips_number}")
  end
end

## FCO Result
outcome :fco_result do
  precalculate :how_long_it_takes do
    PhraseList.new(:"how_long_#{application_action}_fco")
  end

  precalculate :cost do
    cost_type = application_type
    # All european FCO applications cost the same
    cost_type = 'fco_europe' if application_type =~ /^(dublin_ireland|madrid_spain|paris_france)$/

    payment_methods = :"passport_costs_#{application_type}"

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
    elsif general_action == 'renewing' and data_query.retain_passport_exception?(current_location)
      PhraseList.new(:how_to_apply_retain_passport_exception)
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
    elsif current_location == 'south-africa' and general_action == 'applying'
      PhraseList.new(:supporting_documents_south_africa_applying)
    else
      ''
    end
  end

  precalculate :send_your_application do
    phrases = PhraseList.new
    if %(south-africa).include?(current_location)
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
    location = current_location if %(burma cambodia congo nepal).include?(current_location)
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
    PhraseList.new(:"how_long_#{application_type}")
  end
  precalculate :cost do
    PhraseList.new(:"cost_#{application_type}")
  end
  precalculate :how_to_apply do
    phrases = PhraseList.new(:"how_to_apply_#{application_type}")
    if general_action == 'renewing' and data_query.retain_passport?(current_location)
      phrases << :how_to_apply_retain_passport
    elsif general_action == 'renewing' and data_query.retain_passport_exception?(current_location)
      phrases << :how_to_apply_retain_passport_exception
    end
    phrases
  end
  precalculate :making_application_additional do
    if current_location == 'yemen'
      PhraseList.new(:making_application_additional_yemen)
    else
      ''
    end
  end
  precalculate :supporting_documents do
    phrase = ['supporting_documents', application_type]
    phrase << general_action if %w(iraq yemen zambia).include?(application_type)
    PhraseList.new(phrase.join('_').to_sym)
  end
  precalculate :making_application do
    PhraseList.new(:"making_application_#{application_type}")
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
    if organisation
      organisation.offices_with_service 'Overseas Passports Service'
    else
      []
    end
  end

  precalculate :body_text do
    PhraseList.new(:"body_#{current_location}")
  end
end
