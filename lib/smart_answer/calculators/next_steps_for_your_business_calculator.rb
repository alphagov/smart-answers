# ======================================================================
# Allows access to the quesion answers provides custom validations
# and calculations, and other supporting methods.
# ======================================================================

module SmartAnswer::Calculators
  class NextStepsForYourBusinessCalculator
    attr_accessor :question

    def validate?
      return false if question.blank?

      question != "none"
    end

    def question_count
      validate? ? question.split(",").size : 0
    end
  end
end
