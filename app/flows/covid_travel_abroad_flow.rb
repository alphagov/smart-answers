class CovidTravelAbroadFlow < SmartAnswer::Flow
  def define
    name "covid-travel-abroad"
    content_id "b46df1e7-e770-43ab-8b4c-ce402736420c"
    status :draft

    country_select "which_country?".to_sym, exclude_countries: [] do
      on_response do |response|
        self.calculator = SmartAnswer::Calculators::CovidTravelAbroadCalculator.new
        calculator.country_count += 1
        calculator.countries << response
      end

      next_node do
        question "any_other_countries_#{calculator.country_count}?".to_sym
      end
    end

    (1..SmartAnswer::Calculators::CovidTravelAbroadCalculator::MAX_COUNTRIES).each do |num|
      radio "any_other_countries_#{num}?".to_sym do
        template_name "any_other_countries"

        option :yes
        option :no

        on_response do |response|
          calculator.any_other_countries = response
        end

        next_node do
          if calculator.any_other_countries == "no"
            question :vaccine_status?
          else
            question "which_#{calculator.country_count}_country?".to_sym
          end
        end
      end

      country_select "which_#{num}_country?".to_sym, exclude_countries: [] do
        template_name "which_country"

        on_response do |response|
          calculator.countries << response
          calculator.country_count += 1
        end

        next_node do
          question "any_other_countries_#{calculator.country_count}?".to_sym
        end
      end
    end

    radio :vaccine_status? do
      option :vaccinated
      option :not_vaccinated

      on_response do |response|
        calculator.vaccine_status = response
      end

      next_node do
        outcome :results
      end
    end

    outcome :results
  end
end
