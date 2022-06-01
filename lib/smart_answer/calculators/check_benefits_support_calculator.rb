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
      OUTCOME_DATA.dig("benefits_for_outcome", "supporting_your_income", "benefits").select { |benefit|
        benefit
      }.compact
    end

    def benefit_types_for_outcome
      benefits_for_outcome.map { |benefit| benefit["name"] }
    end
  end
end
