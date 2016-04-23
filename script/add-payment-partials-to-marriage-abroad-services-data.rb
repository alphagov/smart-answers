countries = %w(
  belarus
)

payment_method_partial = {
  'default' => 'pay_by_cash_only'
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
