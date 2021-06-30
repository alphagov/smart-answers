# ======================================================================
# The flow logic.
# ======================================================================

module SmartAnswer
  class SmartAnswerNameFlow < Flow
    def define
      # ======================================================================
      # Start page
      # ======================================================================
      start_page do
        next_node { question :question? }
      end

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
          self.calculator = Calculators::SmartAnswerNameCalculator.new
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
end
