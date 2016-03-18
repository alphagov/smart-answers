module SmartAnswer
  class OverseasPassportsFlow < Flow
    def define
      content_id "dd113259-fcaf-4e9b-83d5-d1148f33cf34"
      name 'overseas-passports'
      status :published
      satisfies_need "100131"

      # Q1
      country_select :which_country_are_you_in?, exclude_countries: Calculators::OverseasPassportsCalculator::EXCLUDE_COUNTRIES do
        next_node_calculation :calculator do
          Calculators::OverseasPassportsCalculator.new
        end

        validate do |response|
          calculator.world_location(response)
        end

        calculate :overseas_passports_embassies do |response|
          calculator.overseas_passports_embassies(response)
        end

        next_node do |response|
          calculator.current_location = response

          if calculator.ineligible_country?
            outcome :cannot_apply
          elsif response == 'the-occupied-palestinian-territories'
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

        next_node do |response|
          calculator.current_location = response

          question :renewing_replacing_applying?
        end
      end

      # Q2
      multiple_choice :renewing_replacing_applying? do
        option :renewing_new
        option :renewing_old
        option :applying
        option :replacing

        next_node do |response|
          calculator.application_action = response

          question :child_or_adult_passport?
        end
      end

      # Q3
      multiple_choice :child_or_adult_passport? do
        option :adult
        option :child

        next_node do |response|
          calculator.child_or_adult = response

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
        next_node do |response|
          calculator.birth_location = response

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

      ## No-op outcome.
      outcome :cannot_apply

      outcome :apply_in_neighbouring_country
    end
  end
end
