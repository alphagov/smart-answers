module SmartAnswer::Calculators
  class PassportAndEmbassyDataQuery
 
    FCO_APPLICATIONS_REGEXP = /^(hong_kong|madrid_spain|paris_france|pretoria_south_africa|washington_usa|wellington_new_zealand)$/
    IPS_APPLICATIONS_REGEXP = /^ips_application_\d$/ 

    def self.find_passport_data(country_slug)
      passport_data[country_slug]
    end

    def self.embassy_data_for(countr_slug)
      embassy_data[country_slug]
    end

    def self.passport_data
      @passport_data ||= YAML.load_file(Rails.root.join("lib", "data", "passport_data.yml"))
    end

    def self.embassy_data
      @embassy_data ||= YAML.load_file(Rails.root.join("lib", "data", "embassies.yml"))
    end
  end
end
