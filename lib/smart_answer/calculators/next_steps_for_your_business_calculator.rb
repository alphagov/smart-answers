# ======================================================================
# Allows access to the quesion answers provides custom validations
# and calculations, and other supporting methods.
# ======================================================================

module SmartAnswer::Calculators
  class NextStepsForYourBusinessCalculator
    RESULT_DATA = YAML.load_file(Rails.root.join("config/smart_answers/next_steps_for_your_business.yml")).freeze

    attr_accessor :crn,
                  :annual_turnover,
                  :employ_someone,
                  :business_intent,
                  :business_support,
                  :business_premises

    def grouped_results
      RESULT_DATA.group_by { |result| result["section_name"] }
    end
  end
end
