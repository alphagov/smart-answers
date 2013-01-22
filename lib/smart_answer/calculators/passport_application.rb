module SmartAnswer::Calculators
	class PassportGroupQuery
    
    def initialize(country_slug)
      data = self.class.passport_data[country_slug]
      raise "No passport application data found for slug '#{country_slug}'."
    end

    def self.passport_data
      @passport_data ||= YAML.load_file(Rails.root.join("lib", "data", "passport_data.yml"))
    end
  end
end
