update_file = ARGV.shift
unless update_file && File.exist?(update_file)
  puts "Usage: #{__FILE__} <update-file>"
  exit 1
end

worldwide_locations_file = Rails.root.join('test', 'fixtures', 'worldwide_locations.yml')
worldwide_locations = YAML.load_file(worldwide_locations_file)

updates = YAML.load_file(update_file)

marriage_abroad_services_file = Rails.root.join('lib', 'data', 'marriage_abroad_services.yml')
yaml = File.read(marriage_abroad_services_file)
existing_data = YAML.load(yaml)

updates[:countries].each do |country|
  unless worldwide_locations.include?(country)
    warn "Country: #{country} not found in worldwide location data. Is it spelled correctly?"
  end

  residencies = updates[:residency_overrides][country] || updates[:default_residencies]
  partner_nationalities = updates[:partner_nationality_overrides][country] || updates[:default_partner_nationalities]

  if updates[:services].empty?
    if existing_data[country]
      # Delete the `sex_of_partner` key from this country
      existing_data[country].delete(updates[:sex_of_partner])
      if existing_data[country].empty?
        # Delete the `country` key if it's now empty
        existing_data.delete(country)
      end
    end
  else
    existing_data[country] ||= {}
    existing_data[country][updates[:sex_of_partner]] = {}
    residencies.each do |residency|
      existing_data[country][updates[:sex_of_partner]][residency] = {}
      partner_nationalities.each do |partner_nationality|
        existing_data[country][updates[:sex_of_partner]][residency][partner_nationality] = updates[:services].map(&:to_sym)
      end
    end
  end
end

File.open(marriage_abroad_services_file, 'w') do |file|
  file.puts(existing_data.to_yaml)
end
