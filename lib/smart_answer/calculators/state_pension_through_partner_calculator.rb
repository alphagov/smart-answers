module SmartAnswer::Calculators
  class StatePensionThroughPartnerCalculator
    include ActiveModel::Model

    attr_accessor :marital_status
    attr_accessor :when_will_you_reach_pension_age
    attr_accessor :when_will_your_partner_reach_pension_age
    attr_accessor :gender

    def lower_basic_state_pension_rate
      rates.lower_weekly_rate
    end

    def higher_basic_state_pension_rate
      rates.weekly_rate
    end

    def divorced?
      marital_status == "divorced"
    end

    def married?
      marital_status == "married"
    end

    def widowed?
      marital_status == "widowed"
    end

    def reached_pension_age_before_specific_date?
      when_will_you_reach_pension_age == "your_pension_age_before_specific_date"
    end

    def reached_pension_age_after_specific_date?
      when_will_you_reach_pension_age == "your_pension_age_after_specific_date"
    end

    def partner_reached_pension_age_before_specific_date?
      when_will_your_partner_reach_pension_age == "partner_pension_age_before_specific_date"
    end

    def partner_reached_pension_age_after_specific_date?
      when_will_your_partner_reach_pension_age == "partner_pension_age_after_specific_date"
    end

    def male?
      gender == "male_gender"
    end

    def female?
      gender == "female_gender"
    end

    def widow_and_new_pension?
      widowed? && reached_pension_age_after_specific_date?
    end

    def widow_and_old_pension?
      widowed? && reached_pension_age_before_specific_date?
    end

    def current_rules_no_additional_pension?
      married? && reached_pension_age_before_specific_date? && partner_reached_pension_age_before_specific_date?
    end

    def current_rules_national_insurance_no_state_pension?
      married? && reached_pension_age_before_specific_date? && partner_reached_pension_age_after_specific_date?
    end

  private

    def rates
      @rates ||= RatesQuery.from_file("state_pension").rates
    end
  end
end
