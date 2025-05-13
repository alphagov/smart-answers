# ======================================================================
# The flow logic.
# ======================================================================
class CalculateInheritanceTaxInterestFlow < SmartAnswer::Flow
  def define
    name "calculate-inheritance-tax-interest"
    content_id "f066bf22-70c1-4085-986b-39c585a138a3"
    status :draft
    # ======================================================================
    # Available input types:
    # ======================================================================
    # - Checkbox
    # - Country select
    # - Date
    # - Money
    # - Radio
    # - Postcode
    # - Salary
    # - Value (text)

    # ======================================================================
    # Question
    # ======================================================================
    checkbox_question :question? do
      option :blue
      option :green
      option :red
      option :yellow

      on_response do |response|
        self.calculator = SmartAnswer::Calculators::CalculateInheritanceTaxInterestCalculator.new
        calculator.question = response
      end

      validate do
        calculator.validate?
      end

      next_node do
        outcome :results
      end
    end

    # ======================================================================
    # Outcome
    # ======================================================================
    outcome :results
  end
end
