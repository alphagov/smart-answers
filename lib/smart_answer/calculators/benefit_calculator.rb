module SmartAnswer::Calculators
  class BenefitCalculator
    attr_accessor :single_couple_lone_parent

    def initialize
      @benefits = Hash.new(0)
    end

    def claim(benefit, amount)
      @benefits[benefit] = amount
    end

    def total_benefits
      @benefits.values.inject(0) {|sum, value| sum + value }
    end

    def benefit_cap
      single_couple_lone_parent == 'single' ? 350 : 500
    end

    def total_over_cap
      total_benefits - benefit_cap
    end
  end
end
