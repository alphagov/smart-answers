class CovidTravelAbroadFlow < SmartAnswer::Flow
  def define
    name "covid-travel-abroad"
    content_id "b46df1e7-e770-43ab-8b4c-ce402736420c"
    status :draft
    response_store :query_parameters

    radio :vaccination_status do
      option :vaccinated
      option :in_trial
      option :exempt
      option :none

      on_response do |response|
        self.calculator = SmartAnswer::Calculators::CovidTravelAbroadCalculator.new
        calculator.vaccination_status = response
      end

      next_node do
        question :travelling_with_children
      end
    end

    checkbox_question :travelling_with_children do
      option :zero_to_four
      option :five_to_seventeen
      none_option

      on_response do |response|
        calculator.travelling_with_children = response
      end

      next_node do
        outcome :results
      end
    end

    outcome :results
  end
end
