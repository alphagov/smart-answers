# ======================================================================
# Allows access to the quesion answers provides custom validations
# and calculations, and other supporting methods.
# ======================================================================

module SmartAnswer::Calculators
  class NextStepsForYourBusinessCalculator
    attr_accessor :crn,
                  :annual_turnover,
                  :employ_someone,
                  :business_intent,
                  :business_support,
                  :business_premises
  end
end
