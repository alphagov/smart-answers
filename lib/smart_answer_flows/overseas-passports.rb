module SmartAnswer
  class OverseasPassportsFlow < Flow
    def define
      content_id "dd113259-fcaf-4e9b-83d5-d1148f33cf34"
      name 'overseas-passports'
      status :published
      satisfies_need "100131"

      # Q1
      country_select :which_country_are_you_in?, exclude_countries: Calculators::OverseasPassportsCalculator::EXCLUDE_COUNTRIES do
        on_response do |response|
          self.calculator = Calculators::OverseasPassportsCalculator.new
          calculator.current_location = response
        end

        validate do
          calculator.valid_current_location?
        end

        calculate :overseas_passports_embassies do |response|
          calculator.overseas_passports_embassies(response)
        end

        next_node do
          if calculator.current_location == 'the-occupied-palestinian-territories'
            question :which_opt?
          elsif calculator.apply_in_neighbouring_countries?
            outcome :apply_in_neighbouring_country
          else
            question :renewing_replacing_applying?
          end
        end
      end

      # Q1a
      multiple_choice :which_opt? do
        option :gaza
        option :"jerusalem-or-westbank"

        on_response do |response|
          calculator.current_location = response
        end

        next_node do
          question :renewing_replacing_applying?
        end
      end

      # Q2
      multiple_choice :renewing_replacing_applying? do
        option :renewing_new
        option :renewing_old
        option :applying
        option :replacing

        on_response do |response|
          calculator.application_action = response
        end

        next_node do
          question :child_or_adult_passport?
        end
      end

      # Q3
      multiple_choice :child_or_adult_passport? do
        option :adult
        option :child

        on_response do |response|
          calculator.child_or_adult = response
        end

        next_node do
          if calculator.ips_application?
            if calculator.applying? || calculator.renewing_old?
              question :country_of_birth?
            elsif calculator.ips_online_application?
              outcome :ips_application_result_online
            else
              outcome :ips_application_result
            end
          end
        end
      end

      # Q4
      country_select :country_of_birth?, include_uk: true, exclude_countries: Calculators::OverseasPassportsCalculator::EXCLUDE_COUNTRIES do
        on_response do |response|
          calculator.birth_location = response
        end

        next_node do
          if calculator.ips_application?
            if calculator.ips_online_application?
              outcome :ips_application_result_online
            else
              outcome :ips_application_result
            end
          end
        end
      end

      ## Online IPS Application Result
      outcome :ips_application_result_online

      ## IPS Application Result
      outcome :ips_application_result

      outcome :apply_in_neighbouring_country
    end
  end
end
