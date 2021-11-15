class CovidTravelAbroadFlow < SmartAnswer::Flow
  def define
    name "covid-travel-abroad"
    content_id "b46df1e7-e770-43ab-8b4c-ce402736420c"
    status :draft

    value_question :how_many_countries?, parse: Integer do
      on_response do |response|
        self.calculator = SmartAnswer::Calculators::CovidTravelAbroadCalculator.new
        calculator.country_count = response.to_i
      end

      next_node do
        question :which_1_country?
      end
    end

    (1..SmartAnswer::Calculators::CovidTravelAbroadCalculator::MAX_COUNTRIES).each do |num|
      country_select "which_#{num}_country?".to_sym, exclude_countries: [] do
        template_name "which_country"

        on_response do |response|
          calculator.countries << response
        end

        next_node do
          if num < calculator.country_count
            question "which_#{num + 1}_country?".to_sym
          else
            outcome :results
          end
        end
      end
    end

    outcome :results
  end
end
