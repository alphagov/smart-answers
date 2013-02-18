module SmartAnswer::Calculators
  class RegistrationsDataQuery

    attr_reader :data

    def initialize
      @data = self.class.registration_data
    end

    def commonwealth_country?(country_slug)
      data['commonwealth_countries'].include?(country_slug) 
    end

    def clickbook(country_slug)
      data['death']['clickbook'][country_slug]
    end

    def self.registration_data
      @embassy_data ||= YAML.load_file(Rails.root.join("lib", "data", "registrations.yml"))
    end
  end
end
