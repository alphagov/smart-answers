module SmartAnswer::Calculators
  class PassportAndEmbassyDataQuery
 
    FCO_APPLICATIONS = ["hong_kong", "madrid", "paris", "pretoria", "washington_usa", "wellington_new_zealand"]

    def self.fco_applications_regexp
      Regexp.new("^#{FCO_APPLICATIONS.join('|')}$", 'i')
    end

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
