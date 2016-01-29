module SmartAnswer::Calculators
  class BenefitCalculator
    attr_accessor :single_couple_lone_parent, :postcode

    def initialize
      @benefits = Hash.new(0)
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
      single_couple_lone_parent == 'single' ? benefit_cap_rate(:single) : benefit_cap_rate(:couple)
    end

    def total_over_cap
      total_benefits - benefit_cap
    end

    def benefit_cap_rate(single_couple_lone_parent)
      self.class.benefit_cap_rates[group_name_for_postcode][single_couple_lone_parent]
    end

    def group_name_for_postcode
      return :default unless postcode
      return group_names[postcode] if group_names.has_key?(postcode)

      match = areas_for_postcode.detect {|a| benefit_cap_rate_groups.include?(a['slug'].to_sym) }
      group_names[postcode] = match ? match['slug'].to_sym : :default
    end

    private

    def self.benefit_cap_rates
      @rates ||= YAML::load_file(Rails.root.join("lib", "data", "benefit_caps.yml"))
    end

    def benefit_cap_rate_groups
      groups = self.class.benefit_cap_rates.keys
      groups.delete(:default)
      groups
    end

    def group_names
      @groups_names ||= Hash.new
    end

    def areas_for_postcode
      response = Services.imminence_api.areas_for_postcode(postcode)
      response.try(:code) == 200 ? response.to_hash["results"] : {}
    end
  end
end
