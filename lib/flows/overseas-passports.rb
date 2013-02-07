status :draft

# Q1
country_select :which_country_are_you_in? do
  save_input_as :current_location

  calculate :passport_data do
    Calculators::PassportAndEmbassyDataQuery.find_passport_data(responses.last)
  end
  calculate :application_type do
    passport_data[:type]
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
  calculate :embassy_data do
    data = Calculators::PassportAndEmbassyDataQuery.find_embassy_data(current_location)
    data ? data.first : nil
  end
  calculate :embassy_address do
    address = nil
    unless ips_number.to_i ==  1
      address = embassy_data['address'] if embassy_data
    end
    address
  end
  calculate :embassy_details do
    details = nil
    if embassy_address
      details = [embassy_address]
      details << embassy_data['phone'] if embassy_data['phone'].present?
      details << embassy_data['email'] if embassy_data['email'].present?
      details << embassy_data['office_hours'] if embassy_data['office_hours'].present?
      details = details.join("\n")
    end
    details
  end

  calculate :supporting_documents do
    passport_data[:group]
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

  next_node :child_or_adult_passport?
end

# Q3
multiple_choice :child_or_adult_passport? do
  option :child
  option :adult

  save_input_as :child_or_adult

  calculate :fco_forms do
    PhraseList.new("#{responses.last}_fco_forms".to_sym)
  end

  next_node do |response|
    case application_type
    when 'australia_post', 'new_zealand'
      :which_best_describes_you?
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
    Calculators::PassportAndEmbassyDataQuery.find_passport_data(responses.last)[:group]
  end

  calculate :supporting_documents do
    application_group
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
multiple_choice :which_best_describes_you? do
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

## australia_post/new_zealand result.
outcome :aus_nz_result do
  precalculate :how_long_it_takes do
    PhraseList.new("how_long_#{application_type}".to_sym)
  end
  precalculate :cost do
    PhraseList.new("cost_#{application_type}".to_sym)
  end
  precalculate :how_to_apply do
    PhraseList.new("how_to_apply_#{application_type}".to_sym)
  end
  precalculate :how_to_apply_documents do
    phrases = PhraseList.new("how_to_apply_#{child_or_adult}_#{application_type}".to_sym)

    if application_action == 'replacing' 
      phrases << "aus_nz_replacing".to_sym
    end
    if application_action =~ /^renewing_/
      phrases << "aus_nz_renewing".to_sym
    end

    phrases << "aus_nz_#{aus_nz_checklist_variant}".to_sym
    phrases
  end
  precalculate :receiving_your_passport do
    PhraseList.new("receiving_your_passport_#{application_type}".to_sym)
  end
end


## IPS Application Result 
outcome :ips_application_result do
  precalculate :how_long_it_takes do
    PhraseList.new("how_long_#{application_action}_ips#{ips_number}".to_sym,
                   "how_long_it_takes_ips#{ips_number}".to_sym)
  end
  precalculate :cost do
    PhraseList.new("passport_courier_costs_ips#{ips_number}".to_sym,
                   "#{child_or_adult}_passport_costs_ips#{ips_number}".to_sym,
                   "passport_costs_ips#{ips_number}".to_sym)
  end
  precalculate :how_to_apply do
    PhraseList.new("how_to_apply_ips#{ips_number}".to_sym,
                   supporting_documents.to_sym)
  end
  precalculate :send_your_application do
    PhraseList.new("send_application_ips#{ips_number}".to_sym)
  end
  precalculate :tracking_and_receiving do
    PhraseList.new("tracking_and_receiving_ips#{ips_number}".to_sym)
  end
end

## FCO Result
outcome :fco_result do
  precalculate :how_long_it_takes do
    PhraseList.new("how_long_#{application_action}_fco".to_sym)
  end

  precalculate :cost do
    if application_type =~ /^(dublin_ireland|madrid_spain|paris_france)$/
      cost_type = 'fco_europe'
    else
      cost_type = application_type
    end

    PhraseList.new("passport_courier_costs_#{cost_type}".to_sym,
                   "#{child_or_adult}_passport_costs_#{cost_type}".to_sym, 
                   "passport_costs_#{application_type}".to_sym)
  end
  precalculate :send_your_application do
    PhraseList.new("send_application_#{application_type}".to_sym)
  end
  precalculate :helpline do
    PhraseList.new("helpline_#{application_type}".to_sym)
  end
end

## Generic country outcome.
outcome :result do
  precalculate :how_long_it_takes do
    PhraseList.new("how_long_#{application_type}".to_sym)
  end
  precalculate :cost do
    PhraseList.new("cost_#{application_type}".to_sym)
  end
  precalculate :how_to_apply do
    PhraseList.new("how_to_apply_#{application_type}".to_sym)
  end
  precalculate :supporting_documents do
    PhraseList.new("supporting_documents_#{application_type}".to_sym)
  end
  precalculate :making_application do
    PhraseList.new("making_application_#{application_type}".to_sym)
  end
  precalculate :getting_your_passport do
    PhraseList.new("getting_your_passport_#{application_type}".to_sym)
  end
end

## No-op outcome.
outcome :cannot_apply do
  precalculate :body_text do
    PhraseList.new("body_#{current_location}".to_sym)
  end
end
