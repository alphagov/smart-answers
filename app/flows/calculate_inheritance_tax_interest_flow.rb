class CalculateInheritanceTaxInterestFlow < SmartAnswer::Flow
  def define
    name "calculate-inheritance-tax-interest"
    content_id "f066bf22-70c1-4085-986b-39c585a138a3"
    status :draft

    date_question :start_date_for_interest? do
      on_response do |response|
        self.calculator = SmartAnswer::Calculators::InheritanceTaxInterestCalculator.new
        calculator.start_date = response
        calculator.end_date = response
        calculator.inheritance_tax_owed = response
      end

      next_node do
        question :end_date_for_interest?
      end
    end

    date_question :end_date_for_interest? do
      on_response do |response|
        calculator.end_date = response
      end

      next_node do
        question :how_much_inheritance_tax_owed?
      end
    end

    money_question :how_much_inheritance_tax_owed? do
      on_response do |response|
        calculator.inheritance_tax_owed = response
      end

      next_node do
        outcome :inheritance_tax_interest
      end
    end

    outcome :inheritance_tax_interest
  end
end
