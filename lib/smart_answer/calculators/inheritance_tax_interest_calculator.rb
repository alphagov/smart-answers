module SmartAnswer::Calculators
  class InheritanceTaxInterestCalculator
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
