class PassportDataQuery
  def self.find(country_slug)
    data = passport_data[country_slug]
    # TODO: Remove once we have complete mappings.
    raise "No passport application data found for slug '#{country_slug}'." unless data
    data
  end

  def self.passport_data
    @passport_data ||= YAML.load_file(Rails.root.join("lib", "data", "passport_data.yml"))
  end
end
