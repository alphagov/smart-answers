# ======================================================================
# The flow logic.
# ======================================================================
class CovidTravelAbroadFlow < SmartAnswer::Flow
  def define
      name "covid-travel-abroad"
      content_id "b46df1e7-e770-43ab-8b4c-ce402736420c"
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
        self.calculator = SmartAnswer::Calculators::CovidTravelAbroadCalculator.new
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
