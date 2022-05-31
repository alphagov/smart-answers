module SmartAnswer::Calculators
  class CheckBenefitsSupportCalculator
    attr_accessor :where_do_you_live,
                  :over_state_pension_age,
                  :are_you_working,
                  :disability_or_health_condition,
                  :disability_affecting_work,
                  :carer_disability_or_health_condition,
                  :unpaid_care_hours
  end
end
