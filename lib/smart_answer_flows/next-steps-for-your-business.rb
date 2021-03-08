# ======================================================================
# The flow logic.
# ======================================================================

module SmartAnswer
  class NextStepsForYourBusinessFlow < Flow
    def define
      name "next-steps-for-your-business"
      start_page_content_id "4d7751b5-d860-4812-aa36-5b8c57253ff2"
      flow_content_id "981e0708-9fa5-42fb-baf5-ee5630a9b722"
      status :draft
      use_session true
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
          self.calculator = Calculators::NextStepsForYourBusinessCalculator.new
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
