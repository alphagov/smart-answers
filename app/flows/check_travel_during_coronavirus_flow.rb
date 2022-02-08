class CheckTravelDuringCoronavirusFlow < SmartAnswer::Flow
  def define
    name "check-travel-during-coronavirus"
    content_id "b46df1e7-e770-43ab-8b4c-ce402736420c"
    status :draft
    response_store :query_parameters

    country_select "which_country".to_sym, exclude_countries: [] do
      on_response do |response|
        self.calculator = SmartAnswer::Calculators::CheckTravelDuringCoronavirusCalculator.new
        calculator.countries << response
      end

      next_node do
        question "any_other_countries_#{calculator.countries.count}".to_sym
      end
    end

    (1..SmartAnswer::Calculators::CheckTravelDuringCoronavirusCalculator::MAX_COUNTRIES).each do |num|
      radio "any_other_countries_#{num}".to_sym do
        template_name "any_other_countries"

        option :yes
        option :no

        on_response do |response|
          calculator.any_other_countries = response
        end

        next_node do
          if calculator.any_other_countries == "no"
            if calculator.countries.count > 1
              question :transit_countries
            else
              question :vaccination_status
            end
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
      options { calculator.countries.dup << "none" }

      on_response do |response|
        calculator.transit_countries = response unless response == "none"
      end

      next_node do
        if calculator.red_list_countries.any? && calculator.countries.length > 1
          question :going_to_countries_within_10_days
        else
          question :vaccination_status
        end
      end
    end

    radio :going_to_countries_within_10_days do
      option :yes
      option :no

      on_response do |response|
        calculator.going_to_countries_within_10_days = response
      end

      next_node do
        question :vaccination_status
      end
    end

    # ****** Important ******
    # If you rename this question, please also update:
    #   * the `strip-query-string-parameters` `meta` tag in app/views/layouts/application.html.erb, and
    #   * `config.filter_parameters` in config/application.rb
    radio :vaccination_status do
      option "3371ccf8123dfadf".to_sym
      option "e9e286f8822bc330".to_sym
      option "529202127233d442".to_sym
      option "9ddc7655bfd0d477".to_sym

      on_response do |response|
        calculator.vaccination_status = response
      end

      next_node do
        if calculator.red_list_countries.any?
          question :travelling_with_children
        else
          question :travelling_with_young_people
        end
      end
    end

    radio :travelling_with_young_people do
      option :yes
      option :no

      on_response do |response|
        calculator.travelling_with_young_people = response
      end

      next_node do
        outcome :results
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

    outcome :results do
      view_template "smart_answers/custom_result_full_width"
    end
  end
end
