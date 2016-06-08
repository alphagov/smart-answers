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
      @features ||= []
    end

    def may_qualify_for_affordable_warmth_obligation?
      disabled_or_have_children != 'none' && benefits_claimed.include?('universal_credit')
    end

    def incomesupp_jobseekers_1
      case disabled_or_have_children
      when 'disabled', 'disabled_child', 'child_under_5', 'pensioner_premium'
        :incomesupp_jobseekers_1
      end
    end

    def age_variant
      dob = date_of_birth
      if dob < Date.new(1951, 7, 5)
        :winter_fuel_payment
      elsif dob < 60.years.ago(Date.today + 1)
        :over_60
      end
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

    def warm_home_discount_amount
      ''
    end

    def disabled_or_have_children_question?
      response = benefits_claimed.join(",")
      response == 'income_support' ||
        response == 'jsa' ||
        response == 'esa' ||
        response == 'working_tax_credit' ||
        response.include?('universal_credit') ||
        %w{child_tax_credit esa income_support jsa pension_credit}.all? { |key| response.include? key } ||
        %w{child_tax_credit esa income_support pension_credit}.all? { |key| response.include? key } ||
        %w{child_tax_credit esa jsa pension_credit}.all? { |key| response.include? key }
    end

    def incomesupp_jobseekers_2
      if disabled_or_have_children
        incomesupp_jobseekers_2_part_2
      else
        incomesupp_jobseekers_2_part_1
      end
    end

    def incomesupp_jobseekers_2_part_1
      if (benefits_claimed == %w(working_tax_credit)) && (age_variant == :over_60)
        :incomesupp_jobseekers_2
      end
    end

    def incomesupp_jobseekers_2_part_2
      case disabled_or_have_children
      when 'child_under_16', 'work_support_esa'
        if circumstances.include?('social_housing') || (benefits_claimed.include?('working_tax_credit') && age_variant != :over_60)
          nil
        else
          :incomesupp_jobseekers_2
        end
      end
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

    def no_benefits?
      circumstances.exclude?('benefits')
    end

    def property_permission_circumstance_and_benefits?
      (circumstances & %w(property permission)).any? && ((benefits_claimed & %w(child_tax_credit esa pension_credit)).any? || incomesupp_jobseekers_1 || incomesupp_jobseekers_2)
    end

    def house_property_type?
      property_type == 'house'
    end

    def flat_property_type?
      property_type == 'flat'
    end

    def under_green_deal_part_1?
      both_help? && no_benefits?
    end

    def under_green_deal_part_2?
      !((both_help? && circumstances.include?('property')) || (circumstances.include?('permission') && circumstances.include?('pension_credit')) || incomesupp_jobseekers_1 || incomesupp_jobseekers_2 || (benefits_claimed & %w(esa child_tax_credit working_tax_credit)).any?)
    end

    def under_green_deal_part_3?
      both_help? && age_variant == :over_60 && (benefits_claimed & %w(esa child_tax_credit working_tax_credit) || incomesupp_jobseekers_1 || incomesupp_jobseekers_2)
    end
  end
end
