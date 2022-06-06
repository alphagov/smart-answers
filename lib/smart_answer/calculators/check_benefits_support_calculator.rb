module SmartAnswer::Calculators
  class CheckBenefitsSupportCalculator
    attr_accessor :where_do_you_live,
                  :over_state_pension_age,
                  :are_you_working,
                  :disability_or_health_condition,
                  :disability_affecting_work,
                  :carer_disability_or_health_condition,
                  :unpaid_care_hours,
                  :children_living_with_you,
                  :age_of_children,
                  :children_with_disability,
                  :assets_and_savings

    def benefit_data
      YAML.load_file(Rails.root.join("config/smart_answers/check_benefits_support_data.yml")).freeze
    end

    def benefits_for_outcome
      benefit_data["benefits"].select { |benefit| benefit }.compact
    end

    def eligible_for_employment_and_support_allowance?
      @over_state_pension_age == "no" &&
        @disability_or_health_condition == "yes" &&
        disability_affecting_work != "no"
    end

    def eligible_for_jobseekers_allowance?
      @where_do_you_live != "northern-ireland" &&
        @over_state_pension_age == "no" &&
        @are_you_working != "yes_over_16_hours_per_week" &&
        @disability_affecting_work != "yes_unable_to_work"
    end

    def eligible_for_pension_credit?
      @over_state_pension_age == "no"
    end
  end
end
