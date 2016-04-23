countries = %w(
  afghanistan
  albania
  algeria
  american-samoa
  andorra
  angola
  armenia
  aruba
  austria
  azerbaijan
  bahrain
  benin
  bhutan
  bolivia
  bonaire-st-eustatius-saba
  bosnia-and-herzegovina
  brazil
  bulgaria
  burkina-faso
  burundi
  cape-verde
  central-african-republic
  chad
  chile
  comoros
  congo
  croatia
  cuba
  curacao
  democratic-republic-of-congo
  denmark
  djibouti
  el-salvador
  equatorial-guinea
  eritrea
  estonia
  ethiopia
  finland
  gabon
  georgia
  greece
  guatemala
  guinea
  guinea-bissau
  haiti
  honduras
  hungary
  iceland
  iraq
  jordan
  kazakhstan
  kyrgyzstan
  latvia
  libya
  liechtenstein
  lithuania
  luxembourg
  macedonia
  mali
  marshall-islands
  mauritania
  mexico
  micronesia
  moldova
  montenegro
  nepal
  nicaragua
  niger
  norway
  palau
  panama
  paraguay
  romania
  russia
  rwanda
  san-marino
  sao-tome-and-principe
  serbia
  south-sudan
  st-maarten
  sudan
  suriname
  sweden
  tajikistan
  timor-leste
  togo
  tunisia
  turkmenistan
  uzbekistan
  venezuela
  western-sahara
)

# Exclude #country_without_consular_facilities? countries
countries = countries -
  SmartAnswer::Calculators::MarriageAbroadDataQuery::COUNTRIES_WITHOUT_CONSULAR_FACILITIES

# Excluded countries ignored in outcome template
countries = countries -
  %w(cote-d-ivoire burundi)

payment_method_partial = {
  'armenia' => 'pay_in_local_currency_ceremony_country_name',
  'bosnia-and-herzegovina' => 'pay_in_local_currency_ceremony_country_name',
  'cambodia' => 'pay_in_local_currency_ceremony_country_name',
  'iceland' => 'pay_in_local_currency_ceremony_country_name',
  'latvia' => 'pay_in_local_currency_ceremony_country_name',
  'slovenia' => 'pay_in_local_currency_ceremony_country_name',
  'tunisia' => 'pay_in_local_currency_ceremony_country_name',
  'tajikistan' => 'pay_in_local_currency_ceremony_country_name',

  'kazakhstan' => 'pay_by_cash_in_kazakhstan',
  'kyrgyzstan' => 'pay_by_cash_in_kazakhstan',

  'luxembourg' => 'pay_in_cash_visa_or_mastercard',

  'russia' => 'pay_by_mastercard_and_visa_only',

  'finland' => 'pay_in_euros_or_visa_electron',

  'default' => 'pay_by_cash_or_credit_card_no_cheque'
}

marriage_abroad_services_file = Rails.root.join('lib', 'data', 'marriage_abroad_services.yml')
marriage_abroad_services = YAML.load_file(marriage_abroad_services_file)

countries.each do |country|
  payment_partial_name = payment_method_partial[country] ||
    payment_method_partial['default']

  if marriage_abroad_services[country].present?
    current_payment_partial_name = marriage_abroad_services[country]['payment_partial_name']

    if current_payment_partial_name.blank? || current_payment_partial_name == payment_partial_name
      marriage_abroad_services[country]['payment_partial_name'] = payment_partial_name
    else
      warn "Payment method partial already set for #{country}. Existing value: #{current_payment_partial_name}. New value: #{payment_partial_name}."
    end
  else
    warn "Entry not found for #{country}."
  end
end

File.open(marriage_abroad_services_file, 'w') do |file|
  file.puts marriage_abroad_services.to_yaml
end
