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

    # Q1
    country_select :question?, exclude_countries: [] do
      on_response do |response|
        self.calculator = SmartAnswer::Calculators::CovidTravelAbroadCalculator.new
        calculator.question = response
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
