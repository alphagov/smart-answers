module SmartAnswer::Calculators
  class BenefitCalculator
    attr_accessor :single_couple_lone_parent
    attr_reader :data

    def initialize
      @benefits = Hash.new(0)
      @data = self.class.benefit_cap_rates
    end

    def claim(benefit, amount)
      @benefits[benefit] = amount
    end

    def amount(benefit)
      @benefits[benefit]
    end

    def total_benefits
      @benefits.values.inject(0) {|sum, value| sum + value }
    end

    def benefit_cap
      single_couple_lone_parent == 'single' ? data[:single] : data[:couple]
    end

    def total_over_cap
      total_benefits - benefit_cap
    end

    def self.benefit_cap_rates
      @rates ||= YAML::load_file(Rails.root.join("lib", "data", "benefit_caps.yml"))
    end
  end
end
