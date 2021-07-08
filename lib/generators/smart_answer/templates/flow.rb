# ======================================================================
# The flow logic.
# ======================================================================
class SmartAnswerNameFlow < SmartAnswer::Flow
  def define
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
        self.calculator = SmartAnswer::Calculators::SmartAnswerNameCalculator.new
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
