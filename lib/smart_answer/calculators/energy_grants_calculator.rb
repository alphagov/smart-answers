module SmartAnswer::Calculators
  class EnergyGrantsCalculator
    include ActiveModel::Model

    attr_accessor :which_help
    attr_accessor :circumstances
    attr_accessor :date_of_birth
    attr_accessor :benefits_claimed
    attr_accessor :disabled_or_have_children
    attr_accessor :property_age
    attr_accessor :property_type
    attr_accessor :flat_type
    attr_accessor :features

    def initialize(attributes = {})
      super
      @circumstances ||= []
      @date_of_birth ||= Date.today
      @benefits_claimed ||= []
      @disabled_or_have_children ||= []
      @features ||= []
    end

    def may_qualify_for_affordable_warmth_obligation?
      disabled_or_have_children != %w(none) && benefits_claimed.include?('universal_credit')
    end

    def incomesupp_jobseekers_1?
      disabled_or_have_children == %w(disabled) ||
        disabled_or_have_children == %w(disabled_child) ||
        disabled_or_have_children == %w(child_under_5) ||
        disabled_or_have_children == %w(pensioner_premium)
    end

    def age_variant
      dob = date_of_birth
      if dob < Date.new(1951, 7, 5)
        :winter_fuel_payment
      elsif dob < 60.years.ago(Date.today + 1)
        :over_60
      end
    end

    def eligible_for_winter_fuel_payment?
      age_variant == :winter_fuel_payment
    end

    def bills_help?
      %w(help_with_fuel_bill).include?(which_help)
    end

    def measure_help?
      %w(help_energy_efficiency help_boiler_measure).include?(which_help)
    end

    def both_help?
      %w(all_help).include?(which_help)
    end

    def claiming_pension_credit_only_or_child_tax_credit_only?
      benefits_claimed == %w(pension_credit) || benefits_claimed == %w(child_tax_credit)
    end

    def disabled_or_have_children_question?
      benefits_claimed == %w(income_support) ||
        benefits_claimed == %w(jsa) ||
        benefits_claimed == %w(esa) ||
        benefits_claimed == %w(working_tax_credit) ||
        benefits_claimed.include?('universal_credit') ||
        %w(child_tax_credit esa income_support pension_credit).all? { |key| benefits_claimed.include? key } ||
        %w(child_tax_credit esa jsa pension_credit).all? { |key| benefits_claimed.include? key }
    end

    def incomesupp_jobseekers_2?
      if disabled_or_have_children.any?
        incomesupp_jobseekers_2_part_2?
      else
        incomesupp_jobseekers_2_part_1?
      end
    end

    def incomesupp_jobseekers_2_part_1?
      (benefits_claimed == %w(working_tax_credit)) && (age_variant == :over_60)
    end

    def incomesupp_jobseekers_2_part_2?
      (disabled_or_have_children == %w(child_under_16) || disabled_or_have_children == %w(work_support_esa)) &&
        !(circumstances.include?('social_housing') || (benefits_claimed.include?('working_tax_credit') && age_variant != :over_60))
    end

    def modern_property?
      %w(on-or-after-1995).include?(property_age)
    end

    def older_property?
      %w(1940s-1984).include?(property_age)
    end

    def historic_property?
      %w(before-1940).include?(property_age)
    end

    def measure_help_and_property_permission_circumstance?
      measure_help? && (circumstances & %w(property permission)).any?
    end

    def modern_and_gas_and_electric_heating?
      modern_property? && features.include?('mains_gas') && features.include?('electric_heating')
    end

    def modern_boiler?
      (features & %w(modern_boiler)).any?
    end

    def mains_gas?
      (features & %w(mains_gas)).any?
    end

    def mains_gas_or_solid_wall_insulation?
      (features & %w(mains_gas solid_wall_insulation)).any?
    end

    def draught_proofing_or_mains_gas?
      (features & %w(draught_proofing mains_gas)).any?
    end

    def loft_insulation_or_loft_attic_conversion?
      (features & %w(loft_insulation loft_attic_conversion)).any?
    end

    def loft_attic_conversion?
      (features & %w(loft_attic_conversion)).any?
    end

    def modern_double_glazing?
      (features & %w(modern_double_glazing)).any?
    end

    def cavity_wall_insulation_or_mains_gas?
      (features & %w(cavity_wall_insulation mains_gas)).any?
    end

    def draught_proofing?
      (features & %w(draught_proofing)).any?
    end

    def eligible_for_cold_weather_payment?
      (benefits_claimed & %w(esa pension_credit)).any? || incomesupp_jobseekers_1?
    end

    def eligible_for_warm_home_discount?
      eligible_for_cold_weather_payment? && benefits_claimed.include?('pension_credit')
    end

    def eligible_for_energy_company_obligation?
      (benefits_claimed & %w(esa child_tax_credit pension_credit)).any? || incomesupp_jobseekers_1? || incomesupp_jobseekers_2? || benefits_claimed.include?('working_tax_credit') && age_variant == :over_60
    end

    def no_benefits?
      circumstances.exclude?('benefits')
    end

    def property_permission_circumstance_and_benefits?
      (circumstances & %w(property permission)).any? && ((benefits_claimed & %w(child_tax_credit esa pension_credit)).any? || incomesupp_jobseekers_1? || incomesupp_jobseekers_2?)
    end

    def house_property_type?
      property_type == 'house'
    end

    def flat_property_type?
      property_type == 'flat'
    end

    def top_floor_flat?
      flat_type == 'top_floor'
    end

    def under_green_deal?
      part_1 = !measure_help_and_property_permission_circumstance? && no_benefits?
      part_2 = !part_1 && property_permission_circumstance_and_benefits?
      part_3 = !part_2
      (part_1 && under_green_deal_part_1?) || (part_2 && under_green_deal_part_2?) || (part_3 && under_green_deal_part_3?)
    end

    def under_green_deal_part_1?
      both_help? && no_benefits?
    end

    def under_green_deal_part_2?
      !((both_help? && circumstances.include?('property')) || (circumstances.include?('permission') && circumstances.include?('pension_credit')) || incomesupp_jobseekers_1? || incomesupp_jobseekers_2? || (benefits_claimed & %w(esa child_tax_credit working_tax_credit)).any?)
    end

    def under_green_deal_part_3?
      both_help? && age_variant == :over_60 && (benefits_claimed & %w(esa child_tax_credit working_tax_credit) || incomesupp_jobseekers_1? || incomesupp_jobseekers_2?)
    end
  end
end
