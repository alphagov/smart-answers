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

    OUTCOME_DATA = YAML.load_file(Rails.root.join("config/smart_answers/check_benefit_support_data.yml")).freeze

    def benefits_for_outcome
      OUTCOME_DATA.dig("benefits_for_outcome").select { |benefit|
        benefit["condition"].nil? || send(benefit["condition"])
      }.compact
    end

    def benefit_types_for_outcome
      benefits_for_outcome.sort_by { |benefit| benefit["hierarchy_order"] }
    end

    def eligible_for_employment_and_support_allowance?
      @over_state_pension_age == "no" &&
      @disability_or_health_condition == "yes" &&
      (@disability_affecting_work == "yes_unable_to_work" || @disability_affecting_work == "yes_limits_work")
    end
  end
end
