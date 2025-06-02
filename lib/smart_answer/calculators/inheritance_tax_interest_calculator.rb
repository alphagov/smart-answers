module SmartAnswer::Calculators
  class InheritanceTaxInterestCalculator
    attr_accessor :start_date, :end_date, :inheritance_tax_owed

    def validate?
      return false if question.blank?

      question != "none"
    end

    def question_count
      validate? ? question.split(",").size : 0
    end
  end
end
