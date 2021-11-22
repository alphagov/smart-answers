class CovidTravelAbroadFlow < SmartAnswer::Flow
  def define
    name "covid-travel-abroad"
    content_id "b46df1e7-e770-43ab-8b4c-ce402736420c"
    status :draft
    response_store :query_parameters

    country_select "which_country".to_sym, exclude_countries: [] do
      on_response do |response|
        self.calculator = SmartAnswer::Calculators::CovidTravelAbroadCalculator.new
        calculator.countries << response
      end

      next_node do
        question "any_other_countries_#{calculator.countries.count}".to_sym
      end
    end

    (1..SmartAnswer::Calculators::CovidTravelAbroadCalculator::MAX_COUNTRIES).each do |num|
      radio "any_other_countries_#{num}".to_sym do
        template_name "any_other_countries"

        option :yes
        option :no

        on_response do |response|
          calculator.any_other_countries = response
        end

        next_node do
          if calculator.any_other_countries == "no"
            question :transit_countries
          else
            question "which_#{calculator.countries.count}_country".to_sym
          end
        end
      end

      country_select "which_#{num}_country".to_sym, exclude_countries: [] do
        template_name "which_country"

        on_response do |response|
          calculator.countries << response
        end

        validate do
          calculator.countries.uniq == calculator.countries
        end

        next_node do
          question "any_other_countries_#{calculator.countries.count}".to_sym
        end
      end
    end

    checkbox_question :transit_countries do
      options { calculator.countries }

      on_response do |response|
        calculator.transit_countries = response
      end

      next_node do
        question :vaccination_status
      end
    end

    radio :vaccination_status do
      option :fully_vaccinated
      option :unvaccinated

      on_response do |response|
        calculator.vaccination_status = response
      end

      next_node do
        question :travelling_with_children
      end
    end

    radio :travelling_with_children do
      option :yes
      option :no

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
