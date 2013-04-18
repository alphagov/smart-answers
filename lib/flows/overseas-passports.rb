status :published

i18n_prefix = "flow.overseas-passports"
data_query = Calculators::PassportAndEmbassyDataQuery.new 

# Q1
country_select :which_country_are_you_in? do
  save_input_as :current_location

  calculate :passport_data do
    data_query.find_passport_data(responses.last)
  end
  calculate :application_type do
    passport_data['type']
  end
  calculate :is_ips_application do
    application_type =~ Calculators::PassportAndEmbassyDataQuery::IPS_APPLICATIONS_REGEXP
  end
  calculate :is_fco_application do
    application_type =~ Calculators::PassportAndEmbassyDataQuery::FCO_APPLICATIONS_REGEXP
  end
  calculate :ips_number do
    application_type.split("_")[2] if is_ips_application 
  end
  calculate :embassies_data do
    data_query.find_embassy_data(current_location)
  end
  calculate :embassy_addresses do
    addresses = [] 
    unless ips_number.to_i ==  1 or embassies_data.nil?
      embassies_data.each do |e|
        addresses << I18n.translate!("#{i18n_prefix}.phrases.embassy_address",
                                      address: e['address'], office_hours: e['office_hours'])
      end
    end
    addresses
  end
  calculate :embassy_address do
    if embassy_addresses
      responses.last =~ /^(russian-federation|pakistan)$/ ? embassy_addresses.join : embassy_addresses.first
    end
  end
  calculate :embassies_details do
    details = []
    embassies_data.each do |e|
      details << I18n.translate!("#{i18n_prefix}.phrases.embassy_details",
                                address: e['address'], phone: e['phone'],
                                email: e['email'], office_hours: e['office_hours'])
    end if embassies_data
    details
  end
  calculate :embassy_details do
    if embassies_details
      responses.last == 'russian-federation' ? embassies_details.join : embassies_details.first
    end
  end

  calculate :supporting_documents do
    passport_data['group']
  end

  next_node do |response|
    if Calculators::PassportAndEmbassyDataQuery::NO_APPLICATION_REGEXP.match(response)
      :cannot_apply
    else
      :renewing_replacing_applying?
    end
  end
end

# Q2
multiple_choice :renewing_replacing_applying? do
  option :renewing_new
  option :renewing_old
  option :applying
  option :replacing

  save_input_as :application_action

  calculate :general_action do
    responses.last =~ /^renewing_/ ? 'renewing' : responses.last
  end

  next_node :child_or_adult_passport?
end

# Q3
multiple_choice :child_or_adult_passport? do
  option :adult
  option :child

  save_input_as :child_or_adult

  calculate :fco_forms do
    PhraseList.new(:"#{responses.last}_fco_forms")
  end

  next_node do |response|
    case application_type
    when 'australia_post', 'new_zealand'
      :"which_best_describes_you_#{response}?"
    when Calculators::PassportAndEmbassyDataQuery::IPS_APPLICATIONS_REGEXP
      %Q(applying renewing_old).include?(application_action) ? :country_of_birth? : :ips_application_result 
    when Calculators::PassportAndEmbassyDataQuery::FCO_APPLICATIONS_REGEXP
      :fco_result
    else
      :result
    end
  end
end

# Q4
country_select :country_of_birth?, include_uk: true do
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
    when Calculators::PassportAndEmbassyDataQuery::IPS_APPLICATIONS_REGEXP 
      :ips_application_result 
    when Calculators::PassportAndEmbassyDataQuery::FCO_APPLICATIONS_REGEXP
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
end


## IPS Application Result 
outcome :ips_application_result do

  precalculate :how_long_it_takes do
    if %w{mauritania morocco western-sahara}.include?(current_location)
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
      PhraseList.new(:"how_long_#{application_action}_ips#{ips_number}",
                     :"how_long_it_takes_ips#{ips_number}")
    end
  end
  precalculate :cost do
    if application_action == 'replacing' && ips_number == '1'
      PhraseList.new(:"passport_courier_costs_replacing_ips#{ips_number}",
                   :"#{child_or_adult}_passport_costs_replacing_ips#{ips_number}",
                   :"passport_costs_ips#{ips_number}")
    elsif %w{mauritania morocco western-sahara cuba libya}.include?(current_location) # IPS 2&3 countries where payment must be made in cash
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
    if %w{cyprus greece portugal}.include?(current_location)
      PhraseList.new(:"send_application_ips#{ips_number}_belfast")
    else
      PhraseList.new(:"send_application_ips#{ips_number}")
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
    cost_type = current_location if %w{jamaica jordan}.include?(current_location)
    cost_type = "applying_#{current_location}" if current_location == 'india' and general_action != 'renewing'
   
    payment_methods = :"passport_costs_#{application_type}"
    # Malta and Netherlands have custom payment methods
    payment_methods = :passport_costs_malta_netherlands if current_location =~ /^(malta|netherlands)$/
    payment_methods = :"passport_costs_#{current_location}" if %w{jamaica jordan}.include?(current_location)

    # Indonesian first time applications have courier and cost variations.
    if current_location == 'indonesia' and application_action == 'applying'
      cost_type = current_location
      payment_methods = :passport_costs_indonesia
    end

    PhraseList.new(:"passport_courier_costs_#{cost_type}",
                   :"#{child_or_adult}_passport_costs_#{cost_type}", 
                   payment_methods)
  end

  precalculate :how_to_apply_supplement do
    if application_type =~ /^(dublin_ireland|india)$/
      PhraseList.new(:"how_to_apply_#{application_type}")
    elsif general_action == 'renewing' and data_query.retain_passport?(current_location)
      PhraseList.new(:how_to_apply_retain_passport)
    else
      ''
    end
  end

  precalculate :send_your_application do
    phrases = PhraseList.new
    if current_location == 'indonesia' and %w{applying replacing}.include?(application_action)
      phrases << :send_application_indonesia_applying
    elsif current_location =~ /^(indonesia|jamaica|jordan|south-africa)$/
      phrases << :"send_application_#{current_location}"
    else
      phrases << :send_application_fco_preamble
      phrases << :"send_application_#{application_type}"
    end
    phrases
  end
  precalculate :getting_your_passport do
    location = 'fco'
    location = current_location if %(egypt jamaica jordan nepal india).include?(current_location)
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
  precalculate :embassy_address do
    if application_type == 'iraq'
      e = data_query.find_embassy_data('iraq', false).first
      I18n.translate!("#{i18n_prefix}.phrases.embassy_address",
                      address: e['address'], office_hours: e['office_hours'])
    else
      embassy_address
    end
  end
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
    if %w{yemen iraq}.include?(application_type) and application_action == 'applying'
      phrases << :"#{application_type}_first_passport_documents"
    end

    phrases
  end
  precalculate :supporting_documents do
    phrase = ['supporting_documents', application_type]
    phrase << general_action if application_type == 'nairobi_kenya'
    PhraseList.new(phrase.join('_').to_sym)
  end
  precalculate :making_application do
    phrase = ['making_application', application_type]
    phrase << general_action if application_type == 'cameroon'
    PhraseList.new(phrase.join('_').to_sym)
  end
  precalculate :getting_your_passport do
    PhraseList.new(:"getting_your_passport_#{application_type}")
  end
  precalculate :helpline do
    phrases = PhraseList.new
    if %w(cuba libya morocco tunisia).include?(current_location)
      phrases << :helpline_exceptions
    else
      phrases << :helpline_intro << :"helpline_#{passport_data['helpline']}"
    end
    phrases
  end
end

## No-op outcome.
outcome :cannot_apply do
  precalculate :body_text do
    PhraseList.new(:"body_#{current_location}")
  end
end
