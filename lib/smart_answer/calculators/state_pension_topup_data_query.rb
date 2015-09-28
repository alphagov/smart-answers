module SmartAnswer::Calculators
  class StatePensionTopupDataQuery

    attr_reader :data

    def initialize
      @data = self.class.age_and_rates_data
    end

    def age_and_rates(age)
      upper_age = data['age_and_rates'].keys.max
      if age > upper_age
        data['age_and_rates'][upper_age]
      else
        data['age_and_rates'][age]
      end
    end

    def self.age_and_rates_data
      @age_and_rates_data ||= YAML.load_file(Rails.root.join("lib", "data", "pension_top_up_data.yml"))
    end
  end
end
