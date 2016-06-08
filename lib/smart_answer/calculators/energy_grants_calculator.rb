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
  end
end
